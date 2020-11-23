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
    phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria = 0.1;

    phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions = true;
    phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound=31;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound=90;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.sampPeak = 2;
	phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.frameRate=30;
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

%%%+S- finalOutComponentSegment
    %= Masks - the binary mask for each component. zeros(numCompListEntries, 512, 512)
    %= Edge - the binary edge corresponding to each component in Masks
%

%% Filter down to entries for the current animal:
activeAnimalDataStruct = finalDataStruct.(phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal); % get the final data struct for the current animal
activeAnimalSessionList = sessionList(strcmpi({sessionList.anmID}, phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal));
activeAnimalCompList = compList(strcmpi({compList.anmID}, phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal));
%% Processing Options:
dateStrings = {activeAnimalSessionList.date};  % Strings representing each date.
numOfSessions = length(dateStrings); % The number of sessions (days) for this animal.

%% This will need to be modified for bad/ignored cellROIs:
compTable = struct2table(activeAnimalCompList);
numCompListEntries = height(compTable); % The number of rows in the compTable. Should be a integer multiple of the number of unique comps (corresponding to multiple sessions/days for each unique comp)

uniqueComps = unique(compTable.compName,'stable'); % Each unique component corresponds to a cellROI

%% Filter:
foundNewToBeExcludedComps = {};
if exist('excludedCompsList','var')
%     potentiallyNewExcludedCompsList = uniqueComps(phoPipelineOptions.ignoredCellROI_Indicies); % Before removing them, get the list of the component names that are being removed.
    potentiallyNewExcludedCompsList = phoPipelineOptions.ignoredCellROI_CompNames;
%     lia = ismember(potentiallyNewExcludedCompsList, excludedCompsList);
    for i = 1:length(potentiallyNewExcludedCompsList)
       if ~ismember(potentiallyNewExcludedCompsList{i}, excludedCompsList)
           % Found one that hasn't been filtered for
           foundNewToBeExcludedComps{end+1} = potentiallyNewExcludedCompsList{i};
       end        
    end
    
    
else
     % Make a backup before removing anything:
    backup.uniqueComps = uniqueComps;
    backup.compList = compList;
    backup.activeAnimalCompList = activeAnimalCompList;
    backup.compTable = compTable;
    
    excludedCompsList = {};
    foundNewToBeExcludedComps = phoPipelineOptions.ignoredCellROI_CompNames;
%     excludedCompsList = uniqueComps(phoPipelineOptions.ignoredCellROI_Indicies); % Before removing them, get the list of the component names that are being removed.
end


numNew = length(foundNewToBeExcludedComps);
if numNew > 0
    
    for i = 1:length(foundNewToBeExcludedComps)
%        curr_ignoredCellROI_OriginalIndex = phoPipelineOptions.ignoredCellROI_Indicies(i);
       curr_ignoredCellROI_ComponentName = foundNewToBeExcludedComps{i};

       uniqueComps(strcmpi(uniqueComps, curr_ignoredCellROI_ComponentName)) = []; % Remove the comps that are excluded
       
       rowsToRemove = strcmpi(compTable.compName, curr_ignoredCellROI_ComponentName);
       compTable(rowsToRemove, :) = []; % Remove these rows
       compList(rowsToRemove) = [];
       activeAnimalCompList(rowsToRemove) = [];
       
       excludedCompsList{end+1} = curr_ignoredCellROI_ComponentName;
    end

end

num_cellROIs = length(uniqueComps); 

% Add an index column to the table:
indexArray = 1:height(compTable);
indexColumn = table(indexArray','VariableNames',{'index'});
compTable = [compTable indexColumn];
% update numCompListEntries after removing the irrelevant ones
numCompListEntries = height(compTable); 

temp.excludedCompsStatusString = join(excludedCompsList,', ');
temp.excludedCompsStatusString = temp.excludedCompsStatusString{1};
temp.numberOriginal = length(backup.uniqueComps);
temp.numberIgnored = (temp.numberOriginal - num_cellROIs);

fprintf('Using %d of %d rows (Ignoring %d): %s.\n', num_cellROIs, temp.numberOriginal, temp.numberIgnored, temp.excludedCompsStatusString);

multiSessionCellRoi_CompListIndicies = zeros(num_cellROIs, numOfSessions); % a list of comp indicies for each CellRoi
finalOutComponentSegment.Masks = zeros(numCompListEntries, 512, 512);
finalOutComponentSegment.Edge = zeros(numCompListEntries, 512, 512);

default_DFF.cellROI_FirstDayTuningMaxPeak = zeros(num_cellROIs, 1); % Just the first day
default_DFF.cellROI_SatisfiesFirstDayTuning = zeros(num_cellROIs, 1); % Just the first day

default_DFF.redTraceLinesForAllStimuli = zeros(numCompListEntries, 26, 150);
% Build 2D Mesh for each component
default_DFF.finalOutPeaksGrid = zeros(numCompListEntries,6,6);
% componentAggregatePropeties.maxTuningPeakValue: the maximum peak value for each signal
default_DFF.componentAggregatePropeties.maxTuningPeakValue = zeros(numCompListEntries,1);
% componentAggregatePropeties.sumTuningPeaksValue: the sum of all peaks
default_DFF.componentAggregatePropeties.sumTuningPeaksValue = zeros(numCompListEntries,1);


if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
     % Generate similar grids for minusNeuropil outputs
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
% if exist('final_data_explorer_obj','var')
%     clear final_data_explorer_obj;
% end


for i = 1:num_cellROIs
   curr_cellROI = uniqueComps{i}; % Get the name of the current cellROI. It has a name like 'comp14'
   curr_cellROI_compListIndicies = find(strcmp(compTable.compName, curr_cellROI)); % Should be a list of 3 relevant indicies, one corresponding to each day.
   
   fprintf('\t \t uniqueComp[%d]: %s', i, curr_cellROI);
   disp(curr_cellROI_compListIndicies');
   multiSessionCellRoi_CompListIndicies(i,:) = curr_cellROI_compListIndicies';

   % Iterate through each component (all days) for this cellROI
%     currOutCells = {};
	for j = 1:length(curr_cellROI_compListIndicies)
		curr_day_linear_comp_index = curr_cellROI_compListIndicies(j); % The linear comp index, not the unique cellROI index
		[currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(activeAnimalCompList, curr_day_linear_comp_index);
        [outputs] = fnProcessCompFromFDS(finalDataStruct, currentAnm, currentSesh, currentComp, phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions);
        uniqueAmps = outputs.uniqueAmps;
        uniqueFreqs = outputs.uniqueFreqs; %
        finalOutComponentSegment.Masks(curr_day_linear_comp_index,:,:) = outputs.referenceMask;
        finalOutComponentSegment.Edge(curr_day_linear_comp_index,:,:) = edge(outputs.referenceMask); %sobel by default;
        
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
        default_DFF.redTraceLinesForAllStimuli(curr_day_linear_comp_index, :, :) = outputs.default_DFF.AMConditions.imgDataToPlot; % [26   150]
        
        if phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
            % Store the outputs in the grid:
            minusNeuropil.finalOutPeaksGrid(curr_day_linear_comp_index,:,:) = outputs.minusNeuropil_DFF.finalOutGrid;
            minusNeuropil.componentAggregatePropeties.maximallyPreferredStimulusInfo(curr_day_linear_comp_index) = outputs.minusNeuropil_DFF.maximallyPreferredStimulus; 
            minusNeuropil.peakSignals = outputs.minusNeuropil_DFF.AMConditions.peakSignal; % used
            minusNeuropil.maxPeakSignal = max(minusNeuropil.peakSignals); % used
            minusNeuropil.componentAggregatePropeties.maxTuningPeakValue(curr_day_linear_comp_index) = minusNeuropil.maxPeakSignal; 
            minusNeuropil.componentAggregatePropeties.sumTuningPeaksValue(curr_day_linear_comp_index) = sum(minusNeuropil.peakSignals);
            minusNeuropil.redTraceLinesForAllStimuli(curr_day_linear_comp_index, :, :) = outputs.minusNeuropil_DFF.AMConditions.imgDataToPlot;
        end

        temp.isFirstSessionInCellRoi = (j == 1);
        if temp.isFirstSessionInCellRoi
            default_DFF.cellROI_FirstDayTuningMaxPeak(i) = default_DFF.maxPeakSignal;
            if default_DFF.maxPeakSignal > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
               default_DFF.cellROI_SatisfiesFirstDayTuning(i) = 1;
            else
               default_DFF.cellROI_SatisfiesFirstDayTuning(i) = 0;
%                 break; % Skip remaining comps for the other days if the first day doesn't meat the criteria
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
final_data_explorer_obj = FinalDataExplorer(uniqueComps, multiSessionCellRoi_CompListIndicies, dateStrings, stimuli_mapper);


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
%     componentAggregatePropeties = minusNeuropil.componentAggregatePropeties;
%     finalOutPeaksGrid = minusNeuropil.finalOutPeaksGrid;
%     redTraceLinesForAllStimuli = minusNeuropil.redTraceLinesForAllStimuli;
    final_data_explorer_obj.active_DFF = minusNeuropil;
else
    fprintf('\t Using non-Neuropil Corrected Results...\n');
%     componentAggregatePropeties = default_DFF.componentAggregatePropeties;
%     finalOutPeaksGrid = default_DFF.finalOutPeaksGrid;
%     redTraceLinesForAllStimuli = default_DFF.redTraceLinesForAllStimuli;
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



