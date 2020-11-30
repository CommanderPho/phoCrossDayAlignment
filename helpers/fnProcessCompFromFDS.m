function [outputs] = fnProcessCompFromFDS(fStruct, currentAnm, currentSesh, currentComp, processingOptions)
    %TODO: Figure out how the 26 different stimuli (numStimuli) map to the uniqueAmps/uniqueFreqs points.
    
    if ~exist('processingOptions','var')
        processingOptions.startSound=31;
        processingOptions.endSound=90;
        processingOptions.sampPeak = 2;
        processingOptions.frameRate=30;
        processingOptions.smoothValue = 5;
        processingOptions.compute_neuropil_corrected_versions = true;
    end
        
    
    %%%+S- fnProcessCompFromFDS outputs
    %= imgDataNeuropil - the neuropil data for this component. 520 x 150 double
    %= referenceMask - the reference mask for this component
    %= stimList - 
    %= uniqueStimuli - 26x2 double - contains each unique pair of stimuli, with first column being freq and second column being depth
    %= tracesForEachStimulus - 
    %= numStimuli - 
    %= uniqueFreqs - 
    %= uniqueAmps - 
    %= indexMap_AmpsFreqs2StimulusArray - a map from each unique stimuli to a linear stimulus index. Each row contains a fixed amplitude, each column a fixed freq
    %= indexMap_StimulusLinear2AmpsFreqsArray - each row contains a fixed linear stimulus, and the two entries in the adjacent columns contain the uniqueAmps index and the uniqueFreqs index.
    %= imgDataToPlot - 
    %= tbImg - make a timebase to plot as xAxis for traces
    %= TracesForAllStimuli.meanData - The important red lines
    %= TracesForAllStimuli.imgDataToPlot - 
    %= TracesForAllStimuli.finalSeriesAmps - 2D projections of the plots
    %= TracesForAllStimuli.finalSeriesFreqs - 2D projections of the plots
    %= AMConditions.imgDataToPlot - 
    %= AMConditions.peakSignal - get max of current signal only within the startSound:endSound range
    %= finalOutGrid - 
    %= maximallyPreferredStimulus - See reference structure
    %

%     outputs.imgDataRaw = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingData; % 520x150 double
    imgDataDFF = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF;  % 520x150 double. %assumes you have this field
    
    if processingOptions.compute_neuropil_corrected_versions
       imagingDataMinusNeuropilDFF = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataMinusNeuropilDFF;  % 520x150 double. %assumes you have this field
       outputs.imgDataNeuropil = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataNeuropil; % 520x150 double
    
    end
%     
    
    
    outputs.referenceMask = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).segmentLabelMatrix; % get the reference mask for this component
    
    [numTrials, numFrames] = size(imgDataDFF);
    
    if processingOptions.smoothValue>0
        for i = 1:numTrials
            imgDataDFF(i,:) = smooth(imgDataDFF(i,:), processingOptions.smoothValue);
            if processingOptions.compute_neuropil_corrected_versions
                imagingDataMinusNeuropilDFF(i,:) = smooth(imagingDataMinusNeuropilDFF(i,:), processingOptions.smoothValue);
            end
        end
    end
    
    [~, numFrames] = size(imgDataDFF);
    
    % outputs.stimList: starts as a 520x2 double
	outputs.stimList(:,1) = fStruct.(currentAnm).(currentSesh).behData.amFrequency;
    outputs.stimList(:,2) = fStruct.(currentAnm).(currentSesh).behData.amAmplitude;
    
    %correct the 0 depth condition value glitch here; TODO: This appears that it's correcting for a data-entry error in outputs.stimList, where all trials that should been listed as [0, 0] were instead entered as [10 0].
    zeroValIndicies = find(outputs.stimList(:,2)==0); % In the stimList list, several entries should be found.
    outputs.stimList(zeroValIndicies, 1) = 0; % Set the invalid '10' entry to a zero.
    
    [outputs.uniqueStimuli, ~, ib] = unique(outputs.stimList, 'rows');
    
    outputs.tracesForEachStimulus = accumarray(ib, find(ib), [], @(rows){rows});
    
    [outputs.numStimuli, ~] = size(outputs.uniqueStimuli);
    outputs.uniqueAmps = unique(outputs.uniqueStimuli(:,2));
    outputs.uniqueFreqs = unique(outputs.uniqueStimuli(:,1));
    numUniqueAmps = length(outputs.uniqueAmps);
    numUniqueFreqs = length(outputs.uniqueFreqs);
    
    %% Up to this point, the setup is common for both plotAMConditions_FDS and plotTracesForAllStimuli_FDS
    
    %% Build a map from each unique stimuli to a linear stimulus index:
    outputs.indexMap_AmpsFreqs2StimulusArray = zeros(numUniqueAmps, numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
    outputs.indexMap_StimulusLinear2AmpsFreqsArray = zeros(outputs.numStimuli, 2); % each row contains a fixed linear stimulus, and the two entries in the adjacent columns contain the uniqueAmps index and the uniqueFreqs index.
    
    for i = 1:numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(i);
        for j = 1:numUniqueFreqs
            activeUniqueFreq = outputs.uniqueFreqs(j);
            if (activeUniqueAmp == 0 || activeUniqueFreq == 0)
                outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = 1; % The linear index should be 1 (indicating the first entry) for all cases where either the freq or amp is zero.
                outputs.indexMap_StimulusLinear2AmpsFreqsArray(1,:) = [1, 1];
            else
                currentLinearStimulusIdx = find((outputs.uniqueStimuli(:,1)==activeUniqueFreq) & (outputs.uniqueStimuli(:,2)==activeUniqueAmp));
                outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = currentLinearStimulusIdx;
                outputs.indexMap_StimulusLinear2AmpsFreqsArray(currentLinearStimulusIdx, :) = [i, j];
            end
        end
    end

	%pre-allocate
%     outputs.imgDataToPlot = zeros(outputs.numStimuli, numFrames);
    outputs.tbImg = linspace(0,numFrames/processingOptions.frameRate, numFrames); % make a timebase to plot as xAxis for traces
    
    % The important red lines:
    outputs.default_DFF.AMConditions.imgDataToPlot = zeros(outputs.numStimuli, numFrames); % The important red lines:
    outputs.default_DFF.AMConditions.peakSignal = zeros(outputs.numStimuli, 1);
    
    if processingOptions.compute_neuropil_corrected_versions
        outputs.minusNeuropil_DFF.AMConditions.imgDataToPlot = zeros(outputs.numStimuli, numFrames); % The important red lines:
        outputs.minusNeuropil_DFF.AMConditions.peakSignal = zeros(outputs.numStimuli, 1);
    end
    
    %% Loop through all stimuli:
    for b = 1:outputs.numStimuli
        tracesToPlot = outputs.tracesForEachStimulus{b};
        %% plotTracesForAllStimuli_FDS Style
%          %get the raw data that you're gonna plot
%         outputs.TracesForAllStimuli.imgDataToPlot = imgDataDFF(tracesToPlot, :); % These are sets of stimuli for this entry.
%         %make an average
%         outputs.TracesForAllStimuli.meanData(b,:) = mean(outputs.TracesForAllStimuli.imgDataToPlot, 1); % this is that main red line that we care about, it contains 1x150 double
        
        %% plotAMConditions_FDS Style
        outputs.default_DFF.AMConditions.imgDataToPlot(b,:) = mean(imgDataDFF(tracesToPlot,:));
        [~, maxInd] = max(outputs.default_DFF.AMConditions.imgDataToPlot(b, processingOptions.startSound:processingOptions.endSound)); % get max of current signal only within the startSound:endSound range
        maxInd = maxInd+processingOptions.startSound-1;
        outputs.default_DFF.AMConditions.peakSignal(b) = mean(outputs.default_DFF.AMConditions.imgDataToPlot(b, maxInd-processingOptions.sampPeak:maxInd+processingOptions.sampPeak));
        
        
        if processingOptions.compute_neuropil_corrected_versions
%             outputs.TracesForAllStimuli.neuroPillCorrected = imagingDataMinusNeuropilDFF(tracesToPlot, :); % These are sets of stimuli for this entry.
%             %make an average
%             outputs.TracesForAllStimuli.neuroPillCorrected_meanData(b,:) = mean(outputs.TracesForAllStimuli.neuroPillCorrected, 1); % this is that main red line that we care about, it contains 1x150 double

            %% plotAMConditions_FDS Style
            outputs.minusNeuropil_DFF.AMConditions.imgDataToPlot(b,:) = mean(imagingDataMinusNeuropilDFF(tracesToPlot,:));
            [~, maxInd] = max(outputs.minusNeuropil_DFF.AMConditions.imgDataToPlot(b, processingOptions.startSound:processingOptions.endSound)); % get max of current signal only within the startSound:endSound range
            maxInd = maxInd + processingOptions.startSound - 1;
            outputs.minusNeuropil_DFF.AMConditions.peakSignal(b) = mean(outputs.minusNeuropil_DFF.AMConditions.imgDataToPlot(b, maxInd-processingOptions.sampPeak:maxInd+processingOptions.sampPeak));
        end
    
    end

    % 2D projections of the plots:
    %% Loop through all amplitudes and frequencies:
    % Build 2D Mesh for each component
    outputs.default_DFF.finalOutGrid = zeros(numUniqueAmps, numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
    
    %% Computes the maximally preferred stimulus for this comp    
    % Also build information about the (amp, freq) pair corresponding to the maximum Peak DF/F for this comp.
    outputs.default_DFF.maximallyPreferredStimulus.LinearIndex = -1; % The linear stimulus index corresponding to the maximally preferred (amp, freq) pair for each comp.
    outputs.default_DFF.maximallyPreferredStimulus.AmpFreqIndexTuple = [-1, -1]; % A pair containing the index into the amp array followed by the index into the freq array corresponding to the maximally preferred (amp, freq) pair.
    outputs.default_DFF.maximallyPreferredStimulus.AmpFreqValuesTuple = [-1, -1]; % The unique amp and freq values at the preferred index
    outputs.default_DFF.maximallyPreferredStimulus.Value = 0.0; % The actual Peak DF/F value
    
    if processingOptions.compute_neuropil_corrected_versions
        outputs.minusNeuropil_DFF.finalOutGrid = outputs.default_DFF.finalOutGrid; % just a copy of the default_DFF one.
        outputs.minusNeuropil_DFF.maximallyPreferredStimulus = outputs.default_DFF.maximallyPreferredStimulus; % just a copy of the default_DFF one.
    end
    
    
    for i = 1:numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(i);
        for j = 1:numUniqueFreqs
            activeUniqueFreq = outputs.uniqueFreqs(j);
            % Get the appropriate linear index from the map
            linearStimulusIndex = outputs.indexMap_AmpsFreqs2StimulusArray(i, j);
            currPeaks = outputs.default_DFF.AMConditions.peakSignal(linearStimulusIndex); % 'Peak DF/F'
            outputs.default_DFF.finalOutGrid(i,j) = currPeaks;
            % Check if this new peak value exceeds the previous maximum, and if it does, keep track of the new value and index.
            if currPeaks > outputs.default_DFF.maximallyPreferredStimulus.Value 
                outputs.default_DFF.maximallyPreferredStimulus.LinearIndex = linearStimulusIndex; % Set this linear index as the maximum one.
                outputs.default_DFF.maximallyPreferredStimulus.AmpFreqIndexTuple = [i, j];
                outputs.default_DFF.maximallyPreferredStimulus.AmpFreqValuesTuple = [activeUniqueAmp, activeUniqueFreq];
                outputs.default_DFF.maximallyPreferredStimulus.Value = currPeaks;
            end
            
            % neuropil-corrected version
            if processingOptions.compute_neuropil_corrected_versions
                currPeaks = outputs.minusNeuropil_DFF.AMConditions.peakSignal(linearStimulusIndex); % 'Peak DF/F'
                outputs.minusNeuropil_DFF.finalOutGrid(i,j) = currPeaks;
                % Check if this new peak value exceeds the previous maximum, and if it does, keep track of the new value and index.
                if currPeaks > outputs.minusNeuropil_DFF.maximallyPreferredStimulus.Value 
                    outputs.minusNeuropil_DFF.maximallyPreferredStimulus.LinearIndex = linearStimulusIndex; % Set this linear index as the maximum one.
                    outputs.minusNeuropil_DFF.maximallyPreferredStimulus.AmpFreqIndexTuple = [i, j];
                    outputs.minusNeuropil_DFF.maximallyPreferredStimulus.AmpFreqValuesTuple = [activeUniqueAmp, activeUniqueFreq];
                    outputs.minusNeuropil_DFF.maximallyPreferredStimulus.Value = currPeaks;
                end
            end
    
        end
    end

    
    
end