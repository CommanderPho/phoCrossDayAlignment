%% testAutotuningVsManualTuningComparison.m
% 12-11-2020, Pho Hale
% This script serves to test the "autotuning" values that have been added to final_data_explorer_obj against the manually labeled data.

addpath(genpath('../helpers'));

extantFigH = figure(9);
clf(extantFigH);
    


show_only_first_session = true;


valid_only_quality = phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_quality_of_tuning;
valid_only_quality(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded) = []; % remove the excluded entries.

if show_only_first_session
    auto_plot = final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning(1:final_data_explorer_obj.num_cellROIs);
    to_plot = [valid_only_quality auto_plot];
else
    valid_only_quality_all_sessions = repmat(valid_only_quality, [3 1]);
    auto_plot = final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning;
    to_plot = [valid_only_quality_all_sessions auto_plot];
end


% fnPhoMatrixPlotDetailed(to_plot', extantFigH)


ax1 = subplot(1,2,1);
if show_only_first_session
    [out_axes, h] = fnPhoMatrixPlotDetailed(valid_only_quality, ax1);
else
    [out_axes, h] = fnPhoMatrixPlotDetailed(valid_only_quality_all_sessions, extantFigH);
end
title('manually ranked')
ax2 = subplot(1,2,2);
fnPhoMatrixPlotDetailed(auto_plot, ax2)

% fnPhoMatrixPlot(final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning)
% valid_only = ~phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.data_table.isManuallyExcluded;

% final_data_explorer_obj.computedRedTraceLinesAnalyses.autotuning.compTotalAutotuning


% valid_only = ~phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded;
% valid_all_sessions = repmat(valid_only, [3 1]);

%% Filter from 82 cellROIs down to 53 cellROIs.
% That means for the three sessions, there are 53 * 3 = 159 comps while before there was 82 * 3 = 246




title('autotuning algorithm')