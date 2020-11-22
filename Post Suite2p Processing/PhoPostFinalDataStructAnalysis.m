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
    
end

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



%% Filter down to entries for the current animal:
activeAnimalDataStruct = finalDataStruct.(phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal); % get the final data struct for the current animal
activeAnimalSessionList = sessionList(strcmpi({sessionList.anmID}, phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal));
activeAnimalCompList = compList(strcmpi({compList.anmID}, phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal));
%% Processing Options:
dateStrings = {activeAnimalSessionList.date};  % Strings representing each date.
numOfSessions = length(dateStrings); % The number of sessions (days) for this animal.

compTable = struct2table(activeAnimalCompList);
numCompListEntries = height(compTable); % The number of rows in the compTable. Should be a integer multiple of the number of unique comps (corresponding to multiple sessions/days for each unique comp)
indexArray = 1:height(compTable);
indexColumn = table(indexArray','VariableNames',{'index'});
compTable = [compTable indexColumn];

uniqueComps = unique(compTable.compName,'stable'); % Each unique component corresponds to a cellROI
num_cellROIs = length(uniqueComps); 

multiSessionCellRoi_CompListIndicies = zeros(num_cellROIs, numOfSessions); % a list of comp indicies for each CellRoi
cellROI_FirstDayTuningMaxPeak = zeros(num_cellROIs, 1); % Just the first day
cellROI_SatisfiesFirstDayTuning = zeros(num_cellROIs, 1); % Just the first day

multiSessionCellRoiSeriesOutResults = {};

% Build 2D Mesh for each component
finalOutPeaksGrid = zeros(numCompListEntries,6,6);
finalOutComponentSegmentMasks = zeros(numCompListEntries, 512, 512);

% componentAggregatePropeties.maxTuningPeakValue: the maximum peak value for each signal
componentAggregatePropeties.maxTuningPeakValue = zeros(numCompListEntries,1);

% componentAggregatePropeties.sumTuningPeaksValue: the sum of all peaks
componentAggregatePropeties.sumTuningPeaksValue = zeros(numCompListEntries,1);

for i = 1:num_cellROIs
   curr_cellROI = uniqueComps{i};
   curr_cellROI_compListIndicies = find(strcmp(compTable.compName, curr_cellROI)); % Should be a list of 3 relevant indicies, one corresponding to each day.
   
   fprintf('\t \t uniqueComp[%d]: %s', i, curr_cellROI);
   disp(curr_cellROI_compListIndicies');
   multiSessionCellRoi_CompListIndicies(i,:) = curr_cellROI_compListIndicies';

   % Iterate through each component (all days) for this cellROI
    currOutCells = {};
	for j = 1:length(curr_cellROI_compListIndicies)
		curr_day_linear_comp_index = curr_cellROI_compListIndicies(j); % The linear comp index, not the unique cellROI index
		[currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(activeAnimalCompList, curr_day_linear_comp_index);
        [outputs] = fnProcessCompFromFDS(finalDataStruct, currentAnm, currentSesh, currentComp, phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions);
        uniqueAmps = outputs.uniqueAmps;
        uniqueFreqs = outputs.uniqueFreqs;
        peakSignals = outputs.AMConditions.peakSignal;
        maxPeakSignal = max(peakSignals);
        sumPeaksSignal = sum(peakSignals);
        
        % Store the outputs in the grid:
        finalOutPeaksGrid(curr_day_linear_comp_index,:,:) = outputs.finalOutGrid;
        finalOutComponentSegmentMasks(curr_day_linear_comp_index,:,:) = outputs.referenceMask;
        
        % outputs.maximallyPreferredStimulus
        %% LinearIndex % The linear stimulus index corresponding to the maximally preferred (amp, freq) pair for each comp.
        %% AmpFreqIndexTuple % A pair containing the index into the amp array followed by the index into the freq array corresponding to the maximally preferred (amp, freq) pair.
        %% AmpFreqValuesTuple % The unique amp and freq values at the preferred index
        %% Value % The actual Peak DF/F value
        %
        componentAggregatePropeties.maximallyPreferredStimulusInfo(curr_day_linear_comp_index) = outputs.maximallyPreferredStimulus; 
        
        componentAggregatePropeties.maxTuningPeakValue(curr_day_linear_comp_index) = maxPeakSignal; 
        componentAggregatePropeties.sumTuningPeaksValue(curr_day_linear_comp_index) = sumPeaksSignal;
        
        temp.isFirstSessionInCellRoi = (j == 1);
        if temp.isFirstSessionInCellRoi
            cellROI_FirstDayTuningMaxPeak(i) = maxPeakSignal;
            if maxPeakSignal > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
               cellROI_SatisfiesFirstDayTuning(i) = 1;

            else
                cellROI_SatisfiesFirstDayTuning(i) = 0;
%                 break; % Skip remaining comps for the other days if the first day doesn't meat the criteria
            end
                    
        else

        end %% endif is first session
        
    end %% endfor each comp session in this cellROI 

end %% endfor each cellROI

cellROI_SatisfiesFirstDayTuning = (cellROI_FirstDayTuningMaxPeak > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

fprintf('\t done. INFO: %d of %d cellROIs satisfy the tuning criteria of %f on the first day of the experiment. \n', sum(cellROI_SatisfiesFirstDayTuning), length(cellROI_FirstDayTuningMaxPeak), phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);


% WARNING: This assumes that there are the same number of sessions for each cellROI
componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = (componentAggregatePropeties.maxTuningPeakValue > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria);

componentAggregatePropeties.maxTuningPeakValue = reshape(componentAggregatePropeties.maxTuningPeakValue,[],3); % Reshape from linear to cellRoi indexing
componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = reshape(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria,[],3); % Reshape from linear to cellRoi indexing

% componentAggregatePropeties.tuningScore: the number of days the cellRoi meets the criteria
componentAggregatePropeties.tuningScore = sum(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria, 2);

fprintf('\t done.\n');






