function [outputs] = fnProcessCompFromFDS(fStruct, currentAnm, currentSesh, currentComp)
    %TODO: Figure out how the 26 different stimuli (numStimuli) map to the uniqueAmps/uniqueFreqs points.
    % outputs.uniqueStimuli: 26x2 double - contains each unique pair of stimuli, with first column being freq and second column being depth:
    
	startSound=31;
	endSound=90;
	sampPeak = 2;
	frameRate=30;
	smoothValue = 5;
        
    imgData = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF; %assumes you have this field
    
    outputs.referenceMask = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).segmentLabelMatrix; % get the reference mask for this component
    
    
    [numTrials, numFrames] = size(imgData);
    
    if smoothValue>0
        for i = 1:numTrials
            imgData(i,:)=smooth(imgData(i,:),smoothValue);
        end
    end
    
    [~, numFrames] = size(imgData);
    
	outputs.stimList(:,1) = fStruct.(currentAnm).(currentSesh).behData.amFrequency;
    outputs.stimList(:,2) = fStruct.(currentAnm).(currentSesh).behData.amAmplitude;
    
    [outputs.uniqueStimuli, ~, ib] = unique(outputs.stimList, 'rows');
    %correct the 0 depth condition value glitch here
    zeroVal = find(outputs.uniqueStimuli(:,2)==0);
    outputs.uniqueStimuli(zeroVal, 1) = 0;
    
    outputs.tracesForEachStimulus = accumarray(ib, find(ib), [], @(rows){rows});
    
    [outputs.numStimuli,~] = size(outputs.uniqueStimuli);
    outputs.uniqueAmps = unique(outputs.uniqueStimuli(:,2));
    outputs.uniqueFreqs = unique(outputs.uniqueStimuli(:,1));
    numUniqueAmps = length(outputs.uniqueAmps);
    numUniqueFreqs = length(outputs.uniqueFreqs);
    
    %% Up to this point, the setup is common for both plotAMConditions_FDS and plotTracesForAllStimuli_FDS
    
    %% Build a map from each unique stimuli to a linear stimulus index:
    outputs.indexMap_AmpsFreqs2StimulusArray = zeros(numUniqueAmps, numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
    for i = 1:numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(i);
        for j = 1:numUniqueFreqs
            activeUniqueFreq = outputs.uniqueFreqs(j);
            if (activeUniqueAmp == 0 || activeUniqueFreq == 0)
                outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = 1;
            else
                currentLinearStimulusIdx = find((outputs.uniqueStimuli(:,1)==activeUniqueFreq) & (outputs.uniqueStimuli(:,2)==activeUniqueAmp));
                outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = currentLinearStimulusIdx;
            end
        end
    end
    
	%pre-allocate
    outputs.imgDataToPlot = zeros(outputs.numStimuli, numFrames);
    outputs.tbImg = linspace(0,numFrames/frameRate,numFrames); % make a timebase to plot as xAxis for traces
    
    % The important red lines:
    outputs.TracesForAllStimuli.meanData = zeros(outputs.numStimuli, numFrames);
    
    outputs.AMConditions.imgDataToPlot = zeros(outputs.numStimuli, numFrames);
    outputs.AMConditions.peakSignal = zeros(outputs.numStimuli,1);
    
    %generate the dimensions of the subplots
    numRows = numel(nonzeros(outputs.uniqueFreqs))+1; %+1 because you have the zero mod condition too
    numCol = numel(nonzeros(outputs.uniqueAmps));
    
    for b = 1:outputs.numStimuli
        tracesToPlot = outputs.tracesForEachStimulus{b};
        %% plotTracesForAllStimuli_FDS Style
         %get the raw data that you're gonna plot
        outputs.TracesForAllStimuli.imgDataToPlot = imgData(tracesToPlot, :);
        %make an average
        outputs.TracesForAllStimuli.meanData(b,:) = mean(outputs.TracesForAllStimuli.imgDataToPlot, 1); % this is that main red line that we care about, it contains 1x150 double
        
        %% plotAMConditions_FDS Style
        outputs.AMConditions.imgDataToPlot(b,:) = mean(imgData(tracesToPlot,:));
        [~,maxInd] = max(outputs.AMConditions.imgDataToPlot(b, startSound:endSound)); % get max of current signal only within the startSound:endSound range
        maxInd = maxInd+startSound-1;
        outputs.AMConditions.peakSignal(b) = mean(outputs.AMConditions.imgDataToPlot(b, maxInd-sampPeak:maxInd+sampPeak));
    end

    % 2D projections of the plots:
    outputs.TracesForAllStimuli.finalSeriesAmps = {};
%     finalSeries = {};
 % uniqueAmps: the [0%, 20%, 40%, 60%, 80%, 100%] data series
    for c = 1:numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(c);
        currentAmpIdx = find(outputs.uniqueStimuli(:,2)==activeUniqueAmp); % this varies in size. for the 0 element it's 1x1, but for index 2 for example it's 5x1
        theseFreqs = outputs.uniqueStimuli(currentAmpIdx,1); % AM Depth (%)
        thesePeaks = outputs.AMConditions.peakSignal(currentAmpIdx); % 'Peak DF/F'
        
        tempCurrOutput = struct;
        tempCurrOutput.ampIdx = currentAmpIdx;
        tempCurrOutput.ampValue = activeUniqueAmp;
        tempCurrOutput.freqs = theseFreqs;
        tempCurrOutput.peaks = thesePeaks;

        outputs.TracesForAllStimuli.finalSeriesAmps{end+1} = tempCurrOutput;
    end
     
    outputs.TracesForAllStimuli.finalSeriesFreqs = {};
    % uniqueFreqs: the [0, 10, 20, 50, 100, 200 Hz] data series
    for d=1:numUniqueFreqs
        activeUniqueFreq = outputs.uniqueFreqs(d);
        currentFreqIdx = find(outputs.uniqueStimuli(:,1)==activeUniqueFreq);
        theseAmps = outputs.uniqueStimuli(currentFreqIdx,2);
        thesePeaks = outputs.AMConditions.peakSignal(currentFreqIdx); % 'Peak DF/F'
        
        tempCurrOutput = struct;
        tempCurrOutput.freqIdx = currentFreqIdx;
        tempCurrOutput.freqValue = activeUniqueFreq;
        tempCurrOutput.amps = theseAmps;
        tempCurrOutput.peaks = thesePeaks;

        outputs.TracesForAllStimuli.finalSeriesFreqs{end+1} = tempCurrOutput;
        
    end
    
    % Loop through all amplitudes and frequencies:
    % Build 2D Mesh for each component
    outputs.finalOutGrid = zeros(numUniqueAmps, numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
    
    % outputs.maximallyPreferredStimulus
    %% LinearIndex % The linear stimulus index corresponding to the maximally preferred (amp, freq) pair for each comp.
    %% AmpFreqIndexTuple % A pair containing the index into the amp array followed by the index into the freq array corresponding to the maximally preferred (amp, freq) pair.
    %% AmpFreqValuesTuple % The unique amp and freq values at the preferred index
    %% Value % The actual Peak DF/F value
    %
    
    % Also build information about the (amp, freq) pair corresponding to the maximum Peak DF/F for this comp.
    outputs.maximallyPreferredStimulus.LinearIndex = -1; % The linear stimulus index corresponding to the maximally preferred (amp, freq) pair for each comp.
    outputs.maximallyPreferredStimulus.AmpFreqIndexTuple = [-1, -1]; % A pair containing the index into the amp array followed by the index into the freq array corresponding to the maximally preferred (amp, freq) pair.
    outputs.maximallyPreferredStimulus.AmpFreqValuesTuple = [-1, -1]; % The unique amp and freq values at the preferred index
    outputs.maximallyPreferredStimulus.Value = 0.0; % The actual Peak DF/F value
    
    for i = 1:numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(i);
        for j = 1:numUniqueFreqs
            activeUniqueFreq = outputs.uniqueFreqs(j);
            % Get the appropriate linear index from the map
            linearStimulusIndex = outputs.indexMap_AmpsFreqs2StimulusArray(i, j);
            currPeaks = outputs.AMConditions.peakSignal(linearStimulusIndex); % 'Peak DF/F'
            outputs.finalOutGrid(i,j) = currPeaks;
            % Check if this new peak value exceeds the previous maximum, and if it does, keep track of the new value and index.
            if currPeaks >= outputs.maximallyPreferredStimulus.Value 
                outputs.maximallyPreferredStimulus.LinearIndex = linearStimulusIndex; % Set this linear index as the maximum one.
                outputs.maximallyPreferredStimulus.AmpFreqIndexTuple = [i, j];
                outputs.maximallyPreferredStimulus.AmpFreqValuesTuple = [activeUniqueAmp, activeUniqueFreq];
                outputs.maximallyPreferredStimulus.Value = currPeaks;
            end
        end
    end

    
    
end