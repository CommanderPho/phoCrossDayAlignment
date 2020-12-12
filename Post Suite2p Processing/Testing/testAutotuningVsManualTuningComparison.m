%% testAutotuningVsManualTuningComparison.m
% 12-11-2020, Pho Hale
% This script serves to test the "autotuning" values that have been added to final_data_explorer_obj against the manually labeled data.

addpath(genpath('../helpers'));

figure(9)
clf;
    
subplot(1,2,1)

show_only_first_session = true;


valid_only_quality = phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_quality_of_tuning;
valid_only_quality(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded) = []; % remove the excluded entries.

if show_only_first_session
    fnPhoMatrixPlotDetailed(valid_only_quality)
else
    valid_only_quality_all_sessions = repmat(valid_only_quality, [3 1]);
    fnPhoMatrixPlotDetailed(valid_only_quality_all_sessions)
end
title('manually ranked')
subplot(1,2,2)
% fnPhoMatrixPlot(final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning)
% valid_only = ~phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.data_table.isManuallyExcluded;

% final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning


% valid_only = ~phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded;
% valid_all_sessions = repmat(valid_only, [3 1]);

%% Filter from 82 cellROIs down to 53 cellROIs.
% That means for the three sessions, there are 53 * 3 = 159 comps while before there was 82 * 3 = 246


if show_only_first_session
    % Only plot the first session:
    fnPhoMatrixPlotDetailed(final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning(1:final_data_explorer_obj.num_cellROIs));
else
    fnPhoMatrixPlotDetailed(final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning)
end

title('autotuning algorithm')