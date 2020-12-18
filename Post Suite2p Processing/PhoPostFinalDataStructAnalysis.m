% Pho Post Final Data Struct Analysis: Pipeline Stage 5
% Pho Hale, November 14, 2020
% Uses the finalDataStruct workspace variable and shows results.

addpath(genpath('../helpers'));

fprintf('> Running PhoPostFinalDataStructAnalysis...\n');

%% Options:
% Uses:
%   phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal
%   phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
%   phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions
%   phoPipelineOptions.PhoPostFinalDataStructAnalysis.compute_neuropil_corrected_versions
%   phoPipelineOptions.PhoPostFinalDataStructAnalysis.should_use_neuropil_corrected_version
if ~exist('phoPipelineOptions','var')
	warning('phoPipelineOptions is missing! Using defaults specified in PhoPostFinalDataStructAnalysis.m')
	%%% PhoPostFinalDataStructAnalysis Options:
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal = 'anm265';
	% tuning_max_threshold_criteria: the threshold value for peakDFF
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria = 0.2;

	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions = true;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound = 31;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound = 60;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.sampPeak = 2;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.frameRate = 30;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.smoothValue = 5;
	
	% phoPipelineOptions.PhoPostFinalDataStructAnalysis.should_use_neuropil_corrected_version = true;
	
	phoPipelineOptions.ignoredCellROIs = [];
	
end

%% Primary Outputs:
% multiSessionCellRoi_CompListIndicies
% default_DFF_Structure
% minusNeuropil

%% DATA STRUCTURES:
%%%+S- componentAggregatePropeties
	%= maxTuningPeakValueSatisfiedCriteria - 
	%= maxTuningPeakValue - 
	%= maxTuningPeakValueSatisfiedCriteria - 
	%= tuningScore - the number of days the cellRoi meets the criteria
	%= maxTuningPeakValue - the maximum peak value for each signal
	%= sumTuningPeaksValue - the sum of all peaks
%

%%%+S- maximallyPreferredStimulus
	%= LinearIndex - The linear stimulus index corresponding to the maximally preferred (amp, freq) pair for each comp.
	%= AmpFreqIndexTuple - A pair containing the index into the amp array followed by the index into the freq array corresponding to the maximally preferred (amp, freq) pair.
	%= AmpFreqValuesTuple - The unique amp and freq values at the preferred index
	%= Value - The actual Peak DF/F value
%

%%%+S- compMasks
	%= Masks - the binary mask for each component. zeros(numCompListEntries, 512, 512)
	%= Edge - the binary edge corresponding to each component in Masks
%

%% Filter down to entries for the current animal:

%% TODO: refactoring filtered data struct stuff:
% activeAnimalDataStruct = finalDataStruct.(phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal); % get the final data struct for the current animal
% activeSessionList = sessionList(strcmpi({sessionList.anmID}, phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal));
% activeAnimalCompList = compList(strcmpi({compList.anmID}, phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal));

%% Processing Options:

%% This will need to be modified for bad/ignored cellROIs:


if exist('cellROIIndexMapper','var')
	clear cellROIIndexMapper;
end
cellROIIndexMapper = CellROIIndexMapper(activeSessionList, activeCompList, phoPipelineOptions);
num_cellROIs = cellROIIndexMapper.num_cellROIs;

% %% Pre-Allocate:
% compMasks.Masks = zeros(cellROIIndexMapper.numCompListEntries, 512, 512);
% compMasks.Edge = zeros(cellROIIndexMapper.numCompListEntries, 512, 512);

% compNeuropilMasks.Masks = zeros(cellROIIndexMapper.numCompListEntries, 512, 512);


if exist('stimuli_mapper','var')
	clear stimuli_mapper;
end

if exist('final_data_explorer_obj','var')
	clear final_data_explorer_obj;
end

% basically calls fnProcessCompFromFDS(...) for each component on each day


%% Process Each Cell ROI:
for i = 1:num_cellROIs
   
   curr_cellROI_compListIndicies = cellROIIndexMapper.getCompListIndicies(i);

   % Iterate through each component (all days) for this cellROI
	for j = 1:length(curr_cellROI_compListIndicies)
		curr_day_linear_comp_index = curr_cellROI_compListIndicies(j); % The linear comp index, not the unique cellROI index
		[currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(activeCompList, curr_day_linear_comp_index); % TODO: potentially refactor into CellROIIndexMapper?
		
		[outputs] = fnProcessCompFromFDS(finalDataStruct, currentAnm, currentSesh, currentComp, phoPipelineOptions);
		uniqueAmps = outputs.uniqueAmps;
		uniqueFreqs = outputs.uniqueFreqs; %

		% compMasks.Masks(curr_day_linear_comp_index,:,:) = outputs.referenceMask;
		% compMasks.Edge(curr_day_linear_comp_index,:,:) = edge(outputs.referenceMask); %sobel by default;

        % if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
        %     compNeuropilMasks.Masks(curr_day_linear_comp_index,:,:) = outputs.referenceMaskNeuropil;
        % end
        
		if ~exist('stimuli_mapper','var')
			% Only allow initialization once, if it doesn't exist.
			stimuli_mapper = StimuliIndexMapper(outputs.uniqueStimuli,...
				outputs.uniqueAmps,...
				outputs.uniqueFreqs,...
				outputs.indexMap_AmpsFreqs2StimulusArray, outputs.indexMap_StimulusLinear2AmpsFreqsArray);
		end

		if ~exist('final_data_explorer_obj','var')
			% Only allow initialization once, if it doesn't exist.
			% Initialize the output object once the loop is finished.
			% final_data_explorer_obj = FinalDataExplorer(uniqueComps, multiSessionCellRoi_CompListIndicies, dateStrings, stimuli_mapper);
			final_data_explorer_obj = FinalDataExplorer(cellROIIndexMapper, stimuli_mapper, phoPipelineOptions);
			% the value for outputs.traceTimebase_t should be the same for all traces, all cells, and all sessions, so we can just use the last one:
			final_data_explorer_obj.traceTimebase_t = outputs.traceTimebase_t;
			% final_data_explorer_obj = final_data_explorer_obj.allocateDffs(phoPipelineOptions);
			% [default_DFF_Structure] = final_data_explorer_obj.allocateNewDff();

			% if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
			% 	[minusNeuropil] = final_data_explorer_obj.allocateNewDff();
			% end
		end
		
		final_data_explorer_obj = final_data_explorer_obj.processOutputsDFF(outputs, 'default_DFF_Structure', curr_day_linear_comp_index, phoPipelineOptions);

		temp.isFirstSessionInCellRoi = (j == 1);	
		if temp.isFirstSessionInCellRoi
			final_data_explorer_obj.raw_DFF.cellROI_FirstDayTuningMaxPeak(i) = final_data_explorer_obj.raw_DFF.maxPeakSignal;
			if final_data_explorer_obj.raw_DFF.maxPeakSignal > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
			   final_data_explorer_obj.raw_DFF.cellROI_SatisfiesFirstDayTuning(i) = 1;
			else
			   final_data_explorer_obj.raw_DFF.cellROI_SatisfiesFirstDayTuning(i) = 0;
			end
		end %% endif is first session


		if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
			final_data_explorer_obj = final_data_explorer_obj.processOutputsDFF(outputs, 'neuropilCorrected_DFF_Structure', curr_day_linear_comp_index, phoPipelineOptions);

			if temp.isFirstSessionInCellRoi
				final_data_explorer_obj.corrected_DFF.cellROI_FirstDayTuningMaxPeak(i) = final_data_explorer_obj.corrected_DFF.maxPeakSignal;
				if final_data_explorer_obj.corrected_DFF.maxPeakSignal > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
					final_data_explorer_obj.corrected_DFF.cellROI_SatisfiesFirstDayTuning(i) = 1;
				else
					final_data_explorer_obj.corrected_DFF.cellROI_SatisfiesFirstDayTuning(i) = 0;
				end
			end %% endif is first session

		end

		
	end %% endfor each comp session in this cellROI 

end %% endfor each cellROI


% final_data_explorer_obj.compMasks = compMasks; % Set the compMasks, which contains the masks.
% final_data_explorer_obj.compNeuropilMasks = compNeuropilMasks; % Set the compNeuropilMasks, which contains the masks.

[final_data_explorer_obj] = final_data_explorer_obj.onCompleteProcessingDFF('default_DFF_Structure', phoPipelineOptions);
% default_DFF_Structure.cellROI_SatisfiesFirstDayTuning = (default_DFF_Structure.cellROI_FirstDayTuningMaxPeak > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
	[final_data_explorer_obj] = final_data_explorer_obj.onCompleteProcessingDFF('neuropilCorrected_DFF_Structure', phoPipelineOptions);
	% minusNeuropil.cellROI_SatisfiesFirstDayTuning = (minusNeuropil.cellROI_FirstDayTuningMaxPeak > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);
end
			
% if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
% 	fprintf('\t done. INFO: %d of %d (%d of %d for neuropil) cellROIs satisfy the tuning criteria of %f on the first day of the experiment. \n',...
% 	sum(default_DFF_Structure.cellROI_SatisfiesFirstDayTuning), length(default_DFF_Structure.cellROI_FirstDayTuningMaxPeak), ...
% 	sum(minusNeuropil.cellROI_SatisfiesFirstDayTuning), length(minusNeuropil.cellROI_FirstDayTuningMaxPeak), ...
% 	phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

% else
% 	fprintf('\t done. INFO: %d of %d cellROIs satisfy the tuning criteria of %f on the first day of the experiment. \n',...
% 		sum(default_DFF_Structure.cellROI_SatisfiesFirstDayTuning), length(default_DFF_Structure.cellROI_FirstDayTuningMaxPeak),...
% 		phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);
% end

% default_DFF_Structure.componentAggregatePropeties = updateComponentAggregateProperties(default_DFF_Structure.componentAggregatePropeties, phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

% if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
% 	minusNeuropil.componentAggregatePropeties = updateComponentAggregateProperties(minusNeuropil.componentAggregatePropeties, phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);
% end



%% Need to get the appropriate version:
% if phoPipelineOptions.PhoPostFinalDataStructAnalysis.should_use_neuropil_corrected_version
% 	fprintf('\t Using Neuropil Corrected Results...\n');
% 	final_data_explorer_obj.active_DFF = minusNeuropil;
% else
% 	fprintf('\t Using non-Neuropil Corrected Results...\n');
% 	final_data_explorer_obj.active_DFF = default_DFF_Structure;
% end

final_data_explorer_obj = final_data_explorer_obj.computeCurveAnalysis();
final_data_explorer_obj = final_data_explorer_obj.setupAutotuningDetection(autoTuningDetection);

fprintf('\t done.\n');



