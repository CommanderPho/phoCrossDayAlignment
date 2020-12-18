function [outputs] = fnProcessCompFromFDS(fStruct, currentAnm, currentSesh, currentComp, phoPipelineOptions)
    %TODO: Figure out how the 26 different stimuli (numStimuli) map to the uniqueAmps/uniqueFreqs points.
    
    processingOptions = phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions;
    
    if ~exist('processingOptions','var')
		error('processingOptions was not provided to fnProcessCompFromFDS(...)');
        processingOptions.startSound = 31;
        processingOptions.endSound = 90;
        processingOptions.sampPeak = 2;
        processingOptions.frameRate = 30;
        processingOptions.smoothValue = 5;
        processingOptions.compute_neuropil_corrected_versions = true;
    end
        
    
    %%%+S- fnProcessCompFromFDS outputs
    %= imgDataNeuropil - the neuropil data for this component. 520 x 150 double
    %= referenceMask - the reference mask for this component
    %= referenceMaskNeuropil - the reference mask for the neuropil mask for this component
    %= stimList - 
    %= uniqueStimuli - 26x2 double - contains each unique pair of stimuli, with first column being freq and second column being depth
    %= tracesForEachStimulus - 
    %= numStimuli - 
    %= uniqueFreqs - 
    %= uniqueAmps - 
    %= indexMap_AmpsFreqs2StimulusArray - a map from each unique stimuli to a linear stimulus index. Each row contains a fixed amplitude, each column a fixed freq
    %= indexMap_StimulusLinear2AmpsFreqsArray - each row contains a fixed linear stimulus, and the two entries in the adjacent columns contain the uniqueAmps index and the uniqueFreqs index.
    %= meanDFF - 
    %= traceTimebase_t - make a timebase to plot as xAxis for traces
    %= TracesForAllStimuli.meanData - The important red lines
    %= TracesForAllStimuli.meanDFF - 
    %= TracesForAllStimuli.finalSeriesAmps - 2D projections of the plots
    %= TracesForAllStimuli.finalSeriesFreqs - 2D projections of the plots
    %= AMConditions.meanDFF - 
    %= AMConditions.peakSignal - get max of current signal only within the startSound:endSound range
    %= finalOutGrid - 
    %= maximallyPreferredStimulus - See reference structure
    %


	% Load fStruct items for this Anm/session/comp


%     outputs.imgDataRaw = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingData; % 520x150 double

    % rawDFF
    % imgDataNeuropil
    % neuropilCorrectedDFF: the DFF corrected for neuropil artifacts

	% Use processingOptions.activeNeuropilCompensationMode instead of the old processingOptions.compute_neuropil_corrected_versions
	if strcmpi(phoPipelineOptions.activeNeuropilCompensationMode, 'none')
		% Don't need to do anything else if not in a mode that uses the neuropil data
		rawDFF = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF;  % 520x150 double. %assumes you have this field
		outputs.referenceMask = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).segmentLabelMatrix; % get the reference mask for this component

	elseif strcmpi(phoPipelineOptions.activeNeuropilCompensationMode, 'suite2p')
		rawDFF = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF;  % 520x150 double. %assumes you have this field
		outputs.referenceMask = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).segmentLabelMatrix; % get the reference mask for this component
        % for suite2p data, neuropilCorrectedDFF contains rawDFF - neuropilDFF
		outputs.referenceMaskNeuropil = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).neuropilMaskLabelMatrix; % get the reference mask for the neuropil mask of this component
		neuropilCorrectedDFF = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataMinusNeuropilDFF;  % 520x150 double. %assumes you have this field
       	outputs.imgDataNeuropil = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataNeuropil; % 520x150 double

	elseif strcmpi(phoPipelineOptions.activeNeuropilCompensationMode, 'fissa')
		rawDFF = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).fissa_df_raw;  % 520x150 double. %assumes you have this field
		%% TODO: use fissa masks, which haven't been figured out yet
		outputs.referenceMask = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).segmentLabelMatrix; % get the reference mask for this component
		%% TODO: use fissa masks, which haven't been figured out yet
		outputs.referenceMaskNeuropil = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).neuropilMaskLabelMatrix; % get the reference mask for the neuropil mask of this component
		neuropilCorrectedDFF = squeeze(fStruct.(currentAnm).(currentSesh).imgData.(currentComp).fissa_df_result(1,:,:));  % 520x150 double. %assumes you have this field
       	outputs.imgDataNeuropil = sum(fStruct.(currentAnm).(currentSesh).imgData.(currentComp).fissa_df_result(2:end,:,:),1); % 520x150 double
	else
		error('Invalid neuropil mode!')
	end
	    


    % if processingOptions.compute_neuropil_corrected_versions
    %    imagingDataMinusNeuropilDFF = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataMinusNeuropilDFF;  % 520x150 double. %assumes you have this field
    %    outputs.imgDataNeuropil = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataNeuropil; % 520x150 double
    
    % end

    
    

    [numTrials, outputs.numFramesPerTrial] = size(rawDFF);
    % Smooth the curve
    if processingOptions.smoothValue>0
        for i = 1:numTrials
            rawDFF(i,:) = smooth(rawDFF(i,:), processingOptions.smoothValue);
            if processingOptions.compute_neuropil_corrected_versions
                neuropilCorrectedDFF(i,:) = smooth(neuropilCorrectedDFF(i,:), processingOptions.smoothValue);
            end
        end
    end
    
    [~, outputs.numFramesPerTrial] = size(rawDFF);
    
	%% First-session only:
	% [outputs] = subfnProcessFirstCompFromFDS(outputs, fStruct, currentAnm, currentSesh, processingOptions);
	% outputs.stimList: starts as a 520x2 double
	outputs.stimList(:,1) = fStruct.(currentAnm).(currentSesh).behData.amFrequency;
	outputs.stimList(:,2) = fStruct.(currentAnm).(currentSesh).behData.amAmplitude;

	%correct the 0 depth condition value glitch here; TODO: This appears that it's correcting for a data-entry error in outputs.stimList, where all trials that should been listed as [0, 0] were instead entered as [10 0].
	zeroValIndicies = find(outputs.stimList(:,2)==0); % In the stimList list, several entries should be found.
	outputs.stimList(zeroValIndicies, 1) = 0; % Set the invalid '10' entry to a zero.
	
	[outputs.uniqueStimuli, ~, ib] = unique(outputs.stimList, 'rows'); % Find all unique combinations of [freq, ampl] stimuli-pairs
	% I think ib will contain all the repeated indicies in outputs.stimList for each outputs.uniqueStimuli
	% ib: 520x1 double
	% outputs.uniqueStimuli: 26x2
	
	% What is this doing?
	% Using the 'ib' indexes found corresponding to each unique [freq, amp] stimuli-pair, find all rows corresponding to each stimulus:
	outputs.linearStimulusPairIndexToTrialIndicies = accumarray(ib, find(ib), [], @(rows){rows}); % a outputs.numStimuli x outputs.numStimulusPairTrialRepetitionsPerSession (e.g. 26 x 20) map
	outputs.numStimulusPairTrialRepetitionsPerSession = 20;
	% outputs.linearStimulusPairIndexToTrialIndicies: 26x1 cell
		% each entry is a 20x1 double of indicies into the original stimulus array
		% '20' reflects the fact that there's 20 repetitions of each unique stimulus-pair across the session.
		
	[outputs.numStimuli, ~] = size(outputs.uniqueStimuli);
	outputs.uniqueAmps = unique(outputs.uniqueStimuli(:,2));
	outputs.uniqueFreqs = unique(outputs.uniqueStimuli(:,1));
	outputs.numUniqueAmps = length(outputs.uniqueAmps);
	outputs.numUniqueFreqs = length(outputs.uniqueFreqs);
	
	%% Up to this point, the setup is common for both plotAMConditions_FDS and plotTracesForAllStimuli_FDS
	
	%% Build a map from each unique stimuli to a linear stimulus index:
	outputs.indexMap_AmpsFreqs2StimulusArray = zeros(outputs.numUniqueAmps, outputs.numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
	outputs.indexMap_StimulusLinear2AmpsFreqsArray = zeros(outputs.numStimuli, 2); % each row contains a fixed linear stimulus, and the two entries in the adjacent columns contain the uniqueAmps index and the uniqueFreqs index.
	
	for i = 1:outputs.numUniqueAmps
		activeUniqueAmp = outputs.uniqueAmps(i);
		for j = 1:outputs.numUniqueFreqs
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
%     outputs.meanDFF = zeros(outputs.numStimuli, numFrames);
	outputs.traceTimebase_t = linspace(0, outputs.numFramesPerTrial/processingOptions.frameRate, outputs.numFramesPerTrial); % make a timebase to plot as xAxis for traces
	
	outputs.timingInfo.Index.startSound = processingOptions.startSound;
	outputs.timingInfo.Index.endSound = processingOptions.endSound;
	outputs.timingInfo.Index.sampPeak = processingOptions.sampPeak;



	%% Any session preallocations:
    outputs.TracesForAllStimuli.meanDFF = zeros([outputs.numStimuli, outputs.numStimulusPairTrialRepetitionsPerSession, outputs.numFramesPerTrial]); % raw traces
    outputs.default_DFF_Structure.AMConditions.meanDFF = zeros(outputs.numStimuli, outputs.numFramesPerTrial); % The important red lines
    outputs.default_DFF_Structure.AMConditions.peakSignal = zeros(outputs.numStimuli, 1);
    
    %% timingInfo: an object containing information about the timing of the trials and the peaks within the trials:
    outputs.default_DFF_Structure.timingInfo.Index.startSoundRelative.maxPeakIndex = zeros(outputs.numStimuli, 1);
    outputs.default_DFF_Structure.timingInfo.Index.trialStartRelative.maxPeakIndex = zeros(outputs.numStimuli, 1);
    outputs.default_DFF_Structure.timingInfo.Index.trialStartRelative.startSound = processingOptions.startSound;
	outputs.default_DFF_Structure.timingInfo.Index.trialStartRelative.endSound = processingOptions.endSound;
    outputs.default_DFF_Structure.timingInfo.Index.sampPeak = processingOptions.sampPeak;
    
    
    if processingOptions.compute_neuropil_corrected_versions
        outputs.TracesForAllStimuli.neuropilCorrected = zeros([outputs.numStimuli, outputs.numStimulusPairTrialRepetitionsPerSession, outputs.numFramesPerTrial]); % raw traces
        outputs.neuropilCorrected_DFF_Structure.AMConditions.meanDFF = zeros(outputs.numStimuli, outputs.numFramesPerTrial); % The important red lines
        outputs.neuropilCorrected_DFF_Structure.AMConditions.peakSignal = zeros(outputs.numStimuli, 1);
        
         % Timing info helpers:
%         outputs.neuropilCorrected_DFF_Structure.timingInfo.Index.startSoundRelative.maxPeakIndex = zeros(outputs.numStimuli, 1);
%         outputs.neuropilCorrected_DFF_Structure.timingInfo.Index.trialStartRelative.maxPeakIndex = zeros(outputs.numStimuli, 1);
        outputs.neuropilCorrected_DFF_Structure.timingInfo = outputs.default_DFF_Structure.timingInfo; % That should work, right?
    end
    

    %% Loop through all stimuli:
    for b = 1:outputs.numStimuli
        currStimulusTrialIndicies = outputs.linearStimulusPairIndexToTrialIndicies{b}; % The 20x1 repetitions of this specific stimulus
        
        %% plotTracesForAllStimuli_FDS Style
        %get the raw data that you're gonna plot
        outputs.TracesForAllStimuli.meanDFF(b,:,:) = rawDFF(currStimulusTrialIndicies, :); % These are sets of stimuli for this entry.

        %% plotAMConditions_FDS Style
        outputs.default_DFF_Structure.AMConditions.meanDFF(b,:) = mean(rawDFF(currStimulusTrialIndicies,:)); % This gets the particular red line for this stimulus
        
        currStimulusCurve = squeeze(outputs.default_DFF_Structure.AMConditions.meanDFF(b, :));
        [outputs.default_DFF_Structure.StimulusCurveSummaryStats(b)] = fnProcessCurveStats(currStimulusCurve, outputs.default_DFF_Structure.timingInfo); %% TODO: remove the redundant measures that are computed below
        
        [~, stimStartRelative_maxInd] = max(outputs.default_DFF_Structure.AMConditions.meanDFF(b, processingOptions.startSound:processingOptions.endSound)); % get max of current signal only within the startSound:endSound range
		maxInd = stimStartRelative_maxInd + processingOptions.startSound - 1; % convert back to a frame index instead of a stimulus start relative index

		% timingInfo.Index.trialStartRelative.peakIndexRange: range surrounding the peak index (by extending +processingOptions.sampPeak and -processingOptions.sampPeak on both sides of the peak index)
		timingInfo.Index.trialStartRelative.peakIndexRange = (maxInd-processingOptions.sampPeak):(maxInd+processingOptions.sampPeak);

        % Finally, the peakSignal(b): the portion of the fluoresence data surrounding the peak index (by extending +processingOptions.sampPeak and -processingOptions.sampPeak on both sides of the peak index) is extracted and the mean value is used as the peakSignal value.
        outputs.default_DFF_Structure.AMConditions.peakSignal(b) = mean(outputs.default_DFF_Structure.AMConditions.meanDFF(b, timingInfo.Index.trialStartRelative.peakIndexRange));
        
        % the relative offset between the start of the sound stimulus and the max peak
		outputs.default_DFF_Structure.timingInfo.Index.startSoundRelative.maxPeakIndex(b) = stimStartRelative_maxInd;
		% timingInfo.Index.trialStartRelative.maxPeakIndex: the relative offset between the start of the trial (not the stimulus) and the max peak. As close to an absolute index as it gets.
		outputs.default_DFF_Structure.timingInfo.Index.trialStartRelative.maxPeakIndex(b) = maxInd;
        
        
        if processingOptions.compute_neuropil_corrected_versions % If this is either of the neuropil processing modes:
		
            outputs.TracesForAllStimuli.neuropilCorrected(b,:,:) = neuropilCorrectedDFF(currStimulusTrialIndicies, :); % These are sets of stimuli for this entry.

            %% plotAMConditions_FDS Style
            outputs.neuropilCorrected_DFF_Structure.AMConditions.meanDFF(b,:) = mean(neuropilCorrectedDFF(currStimulusTrialIndicies,:));
            
            currStimulusCurve = squeeze(outputs.neuropilCorrected_DFF_Structure.AMConditions.meanDFF(b, :));
            [outputs.neuropilCorrected_DFF_Structure.StimulusCurveSummaryStats(b)] = fnProcessCurveStats(currStimulusCurve, outputs.neuropilCorrected_DFF_Structure.timingInfo); %% TODO: remove the redundant measures that are computed below
        
            [~, stimStartRelative_maxInd] = max(outputs.neuropilCorrected_DFF_Structure.AMConditions.meanDFF(b, processingOptions.startSound:processingOptions.endSound)); % get max of current signal only within the startSound:endSound range
            maxInd = stimStartRelative_maxInd + processingOptions.startSound - 1; % convert back to a frame index instead of a stimulus start relative index
            outputs.neuropilCorrected_DFF_Structure.AMConditions.peakSignal(b) = mean(outputs.neuropilCorrected_DFF_Structure.AMConditions.meanDFF(b, maxInd-processingOptions.sampPeak:maxInd+processingOptions.sampPeak));
             % the relative offset between the start of the sound stimulus and the max peak
            outputs.neuropilCorrected_DFF_Structure.timingInfo.Index.startSoundRelative.maxPeakIndex(b) = stimStartRelative_maxInd;
            % timingInfo.Index.trialStartRelative.maxPeakIndex: the relative offset between the start of the trial (not the stimulus) and the max peak. As close to an absolute index as it gets.
            outputs.neuropilCorrected_DFF_Structure.timingInfo.Index.trialStartRelative.maxPeakIndex(b) = maxInd;
            
        end
        

        
    
    end

    % 2D projections of the plots:
    %% Loop through all amplitudes and frequencies:
    % Build 2D Mesh for each component
    outputs.default_DFF_Structure.finalOutGrid = zeros(outputs.numUniqueAmps, outputs.numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
    
    %% Computes the maximally preferred stimulus for this comp    
    % Also build information about the (amp, freq) pair corresponding to the maximum Peak DF/F for this comp.
    outputs.default_DFF_Structure.maximallyPreferredStimulus.LinearIndex = -1; % The linear stimulus index corresponding to the maximally preferred (amp, freq) pair for each comp.
    outputs.default_DFF_Structure.maximallyPreferredStimulus.AmpFreqIndexTuple = [-1, -1]; % A pair containing the index into the amp array followed by the index into the freq array corresponding to the maximally preferred (amp, freq) pair.
    outputs.default_DFF_Structure.maximallyPreferredStimulus.AmpFreqValuesTuple = [-1, -1]; % The unique amp and freq values at the preferred index
    outputs.default_DFF_Structure.maximallyPreferredStimulus.Value = 0.0; % The actual Peak DF/F value
    
    if processingOptions.compute_neuropil_corrected_versions
        outputs.neuropilCorrected_DFF_Structure.finalOutGrid = outputs.default_DFF_Structure.finalOutGrid; % just a copy of the default_DFF_Structure one.
        outputs.neuropilCorrected_DFF_Structure.maximallyPreferredStimulus = outputs.default_DFF_Structure.maximallyPreferredStimulus; % just a copy of the default_DFF_Structure one.
    end
    
    
    for i = 1:outputs.numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(i);
        for j = 1:outputs.numUniqueFreqs
            activeUniqueFreq = outputs.uniqueFreqs(j);
            % Get the appropriate linear index from the map
            linearStimulusIndex = outputs.indexMap_AmpsFreqs2StimulusArray(i, j);
            currPeakValue = outputs.default_DFF_Structure.AMConditions.peakSignal(linearStimulusIndex); % 'Peak DF/F'
            outputs.default_DFF_Structure.finalOutGrid(i,j) = currPeakValue;
            % Check if this new peak value exceeds the previous maximum, and if it does, keep track of the new value and index.
            if currPeakValue > outputs.default_DFF_Structure.maximallyPreferredStimulus.Value 
                outputs.default_DFF_Structure.maximallyPreferredStimulus.LinearIndex = linearStimulusIndex; % Set this linear index as the maximum one.
                outputs.default_DFF_Structure.maximallyPreferredStimulus.AmpFreqIndexTuple = [i, j];
                outputs.default_DFF_Structure.maximallyPreferredStimulus.AmpFreqValuesTuple = [activeUniqueAmp, activeUniqueFreq];
                outputs.default_DFF_Structure.maximallyPreferredStimulus.Value = currPeakValue;
            end
            
            % neuropil-corrected version
            if processingOptions.compute_neuropil_corrected_versions
                currPeakValue = outputs.neuropilCorrected_DFF_Structure.AMConditions.peakSignal(linearStimulusIndex); % 'Peak DF/F'
                outputs.neuropilCorrected_DFF_Structure.finalOutGrid(i,j) = currPeakValue;
                % Check if this new peak value exceeds the previous maximum, and if it does, keep track of the new value and index.
                if currPeakValue > outputs.neuropilCorrected_DFF_Structure.maximallyPreferredStimulus.Value 
                    outputs.neuropilCorrected_DFF_Structure.maximallyPreferredStimulus.LinearIndex = linearStimulusIndex; % Set this linear index as the maximum one.
                    outputs.neuropilCorrected_DFF_Structure.maximallyPreferredStimulus.AmpFreqIndexTuple = [i, j];
                    outputs.neuropilCorrected_DFF_Structure.maximallyPreferredStimulus.AmpFreqValuesTuple = [activeUniqueAmp, activeUniqueFreq];
                    outputs.neuropilCorrected_DFF_Structure.maximallyPreferredStimulus.Value = currPeakValue;
                end
            end
    
        end
    end

	% 
%    function [outputs] = subfnProcessFirstCompFromFDS(outputs, fStruct, currentAnm, currentSesh, processingOptions)
% 		% subfnProcessFirstCompFromFDS: this can eventually be factored out, it doesn't need to be ran for each comp within the given session, only at the start of the session.
% 		% outputs.stimList: starts as a 520x2 double
% 		outputs.stimList(:,1) = fStruct.(currentAnm).(currentSesh).behData.amFrequency;
% 		outputs.stimList(:,2) = fStruct.(currentAnm).(currentSesh).behData.amAmplitude;

% 		%correct the 0 depth condition value glitch here; TODO: This appears that it's correcting for a data-entry error in outputs.stimList, where all trials that should been listed as [0, 0] were instead entered as [10 0].
% 		zeroValIndicies = find(outputs.stimList(:,2)==0); % In the stimList list, several entries should be found.
% 		outputs.stimList(zeroValIndicies, 1) = 0; % Set the invalid '10' entry to a zero.
		
% 		[outputs.uniqueStimuli, ~, ib] = unique(outputs.stimList, 'rows'); % Find all unique combinations of [freq, ampl] stimuli-pairs
% 		% I think ib will contain all the repeated indicies in outputs.stimList for each outputs.uniqueStimuli
% 		% ib: 520x1 double
% 		% outputs.uniqueStimuli: 26x2
		
% 		% What is this doing?
% 		% Using the 'ib' indexes found corresponding to each unique [freq, amp] stimuli-pair, find all rows corresponding to each stimulus:
% 		outputs.linearStimulusPairIndexToTrialIndicies = accumarray(ib, find(ib), [], @(rows){rows}); % a outputs.numStimuli x outputs.numStimulusPairTrialRepetitionsPerSession (e.g. 26 x 20) map
% 		outputs.numStimulusPairTrialRepetitionsPerSession = 20;
% 		% outputs.linearStimulusPairIndexToTrialIndicies: 26x1 cell
% 			% each entry is a 20x1 double of indicies into the original stimulus array
% 			% '20' reflects the fact that there's 20 repetitions of each unique stimulus-pair across the session.
			
% 		[outputs.numStimuli, ~] = size(outputs.uniqueStimuli);
% 		outputs.uniqueAmps = unique(outputs.uniqueStimuli(:,2));
% 		outputs.uniqueFreqs = unique(outputs.uniqueStimuli(:,1));
% 		outputs.numUniqueAmps = length(outputs.uniqueAmps);
% 		outputs.numUniqueFreqs = length(outputs.uniqueFreqs);
		
% 		%% Up to this point, the setup is common for both plotAMConditions_FDS and plotTracesForAllStimuli_FDS
		
% 		%% Build a map from each unique stimuli to a linear stimulus index:
% 		outputs.indexMap_AmpsFreqs2StimulusArray = zeros(outputs.numUniqueAmps, outputs.numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
% 		outputs.indexMap_StimulusLinear2AmpsFreqsArray = zeros(outputs.numStimuli, 2); % each row contains a fixed linear stimulus, and the two entries in the adjacent columns contain the uniqueAmps index and the uniqueFreqs index.
		
% 		for i = 1:outputs.numUniqueAmps
% 			activeUniqueAmp = outputs.uniqueAmps(i);
% 			for j = 1:outputs.numUniqueFreqs
% 				activeUniqueFreq = outputs.uniqueFreqs(j);
% 				if (activeUniqueAmp == 0 || activeUniqueFreq == 0)
% 					outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = 1; % The linear index should be 1 (indicating the first entry) for all cases where either the freq or amp is zero.
% 					outputs.indexMap_StimulusLinear2AmpsFreqsArray(1,:) = [1, 1];
% 				else
% 					currentLinearStimulusIdx = find((outputs.uniqueStimuli(:,1)==activeUniqueFreq) & (outputs.uniqueStimuli(:,2)==activeUniqueAmp));
% 					outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = currentLinearStimulusIdx;
% 					outputs.indexMap_StimulusLinear2AmpsFreqsArray(currentLinearStimulusIdx, :) = [i, j];
% 				end
% 			end
% 		end

% 		%pre-allocate
% 	%     outputs.meanDFF = zeros(outputs.numStimuli, numFrames);
% 		outputs.traceTimebase_t = linspace(0, outputs.numFramesPerTrial/processingOptions.frameRate, outputs.numFramesPerTrial); % make a timebase to plot as xAxis for traces
		
% 		outputs.timingInfo.Index.startSound = processingOptions.startSound;
% 		outputs.timingInfo.Index.endSound = processingOptions.endSound;
% 		outputs.timingInfo.Index.sampPeak = processingOptions.sampPeak;
%    end % end subfnProcessFirstCompFromFDS
    
end