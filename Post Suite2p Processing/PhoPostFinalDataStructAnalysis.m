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
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound = 90;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.sampPeak = 2;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.frameRate = 30;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.smoothValue = 5;
    
    phoPipelineOptions.PhoPostFinalDataStructAnalysis.should_use_neuropil_corrected_version = true;
    
    phoPipelineOptions.ignoredCellROIs = [];
    
end

%% Primary Outputs:
% multiSessionCellRoi_CompListIndicies
% default_DFF
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


%% Pre-Allocate:
compMasks.Masks = zeros(cellROIIndexMapper.numCompListEntries, 512, 512);
compMasks.Edge = zeros(cellROIIndexMapper.numCompListEntries, 512, 512);

compNeuropilMasks.Masks = zeros(cellROIIndexMapper.numCompListEntries, 512, 512);

default_DFF.cellROI_FirstDayTuningMaxPeak = zeros(cellROIIndexMapper.num_cellROIs, 1); % Just the first day
default_DFF.cellROI_SatisfiesFirstDayTuning = zeros(cellROIIndexMapper.num_cellROIs, 1); % Just the first day

default_DFF.TracesForAllStimuli.imgDataToPlot = zeros(cellROIIndexMapper.numCompListEntries, 26, 20, 150);
default_DFF.redTraceLinesForAllStimuli = zeros(cellROIIndexMapper.numCompListEntries, 26, 150);
% Build 2D Mesh for each component
default_DFF.finalOutPeaksGrid = zeros(cellROIIndexMapper.numCompListEntries,6,6);
% componentAggregatePropeties.maxTuningPeakValue: the maximum peak value for each signal
default_DFF.componentAggregatePropeties.maxTuningPeakValue = zeros(cellROIIndexMapper.numCompListEntries,1);
% componentAggregatePropeties.sumTuningPeaksValue: the sum of all peaks
default_DFF.componentAggregatePropeties.sumTuningPeaksValue = zeros(cellROIIndexMapper.numCompListEntries,1);


if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
     % Generate similar grids for minusNeuropil outputs
     minusNeuropil.TracesForAllStimuli.imgDataToPlot = default_DFF.TracesForAllStimuli.imgDataToPlot;
     minusNeuropil.redTraceLinesForAllStimuli = default_DFF.redTraceLinesForAllStimuli;
     minusNeuropil.finalOutPeaksGrid = default_DFF.finalOutPeaksGrid;
     minusNeuropil.cellROI_FirstDayTuningMaxPeak = default_DFF.cellROI_FirstDayTuningMaxPeak; % Just the first day
     minusNeuropil.cellROI_SatisfiesFirstDayTuning = default_DFF.cellROI_SatisfiesFirstDayTuning; % Just the first day
     minusNeuropil.componentAggregatePropeties.maxTuningPeakValue = default_DFF.componentAggregatePropeties.maxTuningPeakValue;
     minusNeuropil.componentAggregatePropeties.sumTuningPeaksValue = default_DFF.componentAggregatePropeties.sumTuningPeaksValue;
end
   

if exist('stimuli_mapper','var')
    clear stimuli_mapper;
end


%% Process Each Cell ROI:
for i = 1:num_cellROIs
   
   curr_cellROI_compListIndicies = cellROIIndexMapper.getCompListIndicies(i);

   % Iterate through each component (all days) for this cellROI
	for j = 1:length(curr_cellROI_compListIndicies)
		curr_day_linear_comp_index = curr_cellROI_compListIndicies(j); % The linear comp index, not the unique cellROI index
		[currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(activeCompList, curr_day_linear_comp_index); % TODO: potentially refactor into CellROIIndexMapper?
        
        [outputs] = fnProcessCompFromFDS(finalDataStruct, currentAnm, currentSesh, currentComp, phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions);
        uniqueAmps = outputs.uniqueAmps;
        uniqueFreqs = outputs.uniqueFreqs; %
        compMasks.Masks(curr_day_linear_comp_index,:,:) = outputs.referenceMask;
        compMasks.Edge(curr_day_linear_comp_index,:,:) = edge(outputs.referenceMask); %sobel by default;

        compNeuropilMasks.Masks(curr_day_linear_comp_index,:,:) = outputs.referenceMaskNeuropil;
        
        % Get timing info for the mean (red) curves for all stimuli.
%         outputs.timingInfo.Index.startSoundRelative.maxPeakIndex
        
        
        if ~exist('stimuli_mapper','var')
            % Only allow initialization once, if it doesn't exist.
            stimuli_mapper = StimuliIndexMapper(outputs.uniqueStimuli,...
                uniqueAmps,...
                uniqueFreqs,...
                outputs.indexMap_AmpsFreqs2StimulusArray, outputs.indexMap_StimulusLinear2AmpsFreqsArray);
        end
        
        % Store the outputs in the grid:
        default_DFF.finalOutPeaksGrid(curr_day_linear_comp_index,:,:) = outputs.default_DFF.finalOutGrid;
        default_DFF.componentAggregatePropeties.maximallyPreferredStimulusInfo(curr_day_linear_comp_index) = outputs.default_DFF.maximallyPreferredStimulus; 
        default_DFF.peakSignals = outputs.default_DFF.AMConditions.peakSignal; % used
        default_DFF.maxPeakSignal = max(default_DFF.peakSignals); % used
        default_DFF.componentAggregatePropeties.maxTuningPeakValue(curr_day_linear_comp_index) = default_DFF.maxPeakSignal; 
        default_DFF.componentAggregatePropeties.sumTuningPeaksValue(curr_day_linear_comp_index) = sum(default_DFF.peakSignals);   
        default_DFF.TracesForAllStimuli.imgDataToPlot(curr_day_linear_comp_index, :, :, :) = outputs.TracesForAllStimuli.imgDataToPlot;
        default_DFF.redTraceLinesForAllStimuli(curr_day_linear_comp_index, :, :) = outputs.default_DFF.AMConditions.imgDataToPlot; % [26   150]
     
        
        if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
            % Store the outputs in the grid:
            minusNeuropil.finalOutPeaksGrid(curr_day_linear_comp_index,:,:) = outputs.minusNeuropil_DFF.finalOutGrid;
            minusNeuropil.componentAggregatePropeties.maximallyPreferredStimulusInfo(curr_day_linear_comp_index) = outputs.minusNeuropil_DFF.maximallyPreferredStimulus; 
            minusNeuropil.peakSignals = outputs.minusNeuropil_DFF.AMConditions.peakSignal; % used
            minusNeuropil.maxPeakSignal = max(minusNeuropil.peakSignals); % used
            minusNeuropil.componentAggregatePropeties.maxTuningPeakValue(curr_day_linear_comp_index) = minusNeuropil.maxPeakSignal; 
            minusNeuropil.componentAggregatePropeties.sumTuningPeaksValue(curr_day_linear_comp_index) = sum(minusNeuropil.peakSignals);
            minusNeuropil.TracesForAllStimuli.imgDataToPlot(curr_day_linear_comp_index, :, :, :) = outputs.TracesForAllStimuli.neuroPillCorrected;
            minusNeuropil.redTraceLinesForAllStimuli(curr_day_linear_comp_index, :, :) = outputs.minusNeuropil_DFF.AMConditions.imgDataToPlot; % [26   150]
        end

        temp.isFirstSessionInCellRoi = (j == 1);
        if temp.isFirstSessionInCellRoi
            default_DFF.cellROI_FirstDayTuningMaxPeak(i) = default_DFF.maxPeakSignal;
            if default_DFF.maxPeakSignal > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
               default_DFF.cellROI_SatisfiesFirstDayTuning(i) = 1;
            else
               default_DFF.cellROI_SatisfiesFirstDayTuning(i) = 0;
%                 break; % Skip remaining comps for the other days if the first day doesn't meet the criteria
            end
            
            if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
                minusNeuropil.cellROI_FirstDayTuningMaxPeak(i) = minusNeuropil.maxPeakSignal;
                if minusNeuropil.maxPeakSignal > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
                   minusNeuropil.cellROI_SatisfiesFirstDayTuning(i) = 1;
                else
                    minusNeuropil.cellROI_SatisfiesFirstDayTuning(i) = 0;
                end
            end
                    
        else
            % If it isn't the first session

        end %% endif is first session
        
    end %% endfor each comp session in this cellROI 

end %% endfor each cellROI



% Initialize the output object once the loop is finished.
% final_data_explorer_obj = FinalDataExplorer(uniqueComps, multiSessionCellRoi_CompListIndicies, dateStrings, stimuli_mapper);
final_data_explorer_obj = FinalDataExplorer(cellROIIndexMapper, stimuli_mapper);

final_data_explorer_obj.compMasks = compMasks; % Set the compMasks, which contains the masks.
final_data_explorer_obj.compNeuropilMasks = compNeuropilMasks; % Set the compNeuropilMasks, which contains the masks.

% the value for outputs.traceTimebase_t should be the same for all traces, all cells, and all sessions, so we can just use the last one:
final_data_explorer_obj.traceTimebase_t = outputs.traceTimebase_t;

default_DFF.cellROI_SatisfiesFirstDayTuning = (default_DFF.cellROI_FirstDayTuningMaxPeak > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
    minusNeuropil.cellROI_SatisfiesFirstDayTuning = (minusNeuropil.cellROI_FirstDayTuningMaxPeak > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);
end
            
if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
    fprintf('\t done. INFO: %d of %d (%d of %d for neuropil) cellROIs satisfy the tuning criteria of %f on the first day of the experiment. \n',...
    sum(default_DFF.cellROI_SatisfiesFirstDayTuning), length(default_DFF.cellROI_FirstDayTuningMaxPeak), ...
    sum(minusNeuropil.cellROI_SatisfiesFirstDayTuning), length(minusNeuropil.cellROI_FirstDayTuningMaxPeak), ...
    phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

else
    fprintf('\t done. INFO: %d of %d cellROIs satisfy the tuning criteria of %f on the first day of the experiment. \n',...
        sum(default_DFF.cellROI_SatisfiesFirstDayTuning), length(default_DFF.cellROI_FirstDayTuningMaxPeak),...
        phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);
end

default_DFF.componentAggregatePropeties = updateComponentAggregateProperties(default_DFF.componentAggregatePropeties, phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
    minusNeuropil.componentAggregatePropeties = updateComponentAggregateProperties(minusNeuropil.componentAggregatePropeties, phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);
end



%% Need to get the appropriate version:
if phoPipelineOptions.PhoPostFinalDataStructAnalysis.should_use_neuropil_corrected_version
    fprintf('\t Using Neuropil Corrected Results...\n');
    final_data_explorer_obj.active_DFF = minusNeuropil;
else
    fprintf('\t Using non-Neuropil Corrected Results...\n');
    final_data_explorer_obj.active_DFF = default_DFF;
end


fprintf('\t done.\n');

% updateComponentAggregateProperties(...): small helper function that adds some reshaped properties
function [componentAggregatePropeties] = updateComponentAggregateProperties(componentAggregatePropeties, tuning_max_threshold_criteria)
    % WARNING: This assumes that there are the same number of sessions for each cellROI
    componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = (componentAggregatePropeties.maxTuningPeakValue > tuning_max_threshold_criteria);

    componentAggregatePropeties.maxTuningPeakValue = reshape(componentAggregatePropeties.maxTuningPeakValue,[],3); % Reshape from linear to cellRoi indexing
    componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = reshape(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria,[],3); % Reshape from linear to cellRoi indexing

    % componentAggregatePropeties.tuningScore: the number of days the cellRoi meets the criteria
    componentAggregatePropeties.tuningScore = sum(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria, 2);

end



