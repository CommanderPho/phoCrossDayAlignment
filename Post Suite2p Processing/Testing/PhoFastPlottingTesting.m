addpath(genpath('../../helpers'));
 
% to clear global variables:
% clear global plot_manager_cellRoiPlot

 
 if ~exist('plot_manager_cellRoiPlot','var')
    global plot_manager_cellRoiPlot; 
    combinedOffsetInsetIndicies = [nan, 0];
    % combinedOffsetInsetIndicies = [nan, 3, 2, 1, 0, -1, -2, -3];
    active_selections_backingFile_path = phoPipelineOptions.default_interactionManager_backingStorePath;
    %% Build a new plot manager object:
    plot_manager_cellRoiPlot = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path);
    plot_manager_cellRoiPlot.activeOffsetInsetIndicies = combinedOffsetInsetIndicies;
 end
 
 
 updatePlot(9);

%  %% Options:
% should_show_2d_plot = false;
% should_show_3d_mesh_plot = false;
% should_show_masking_plot = false;
% should_show_stimulus_traces_plot = true;
% should_show_stimulus_traces_custom_data_plot = false;
% should_show_stimulus_heatmaps_plot = true;
% should_show_stimulus_summary_stats_plot = true;
% 
% temp.cellRoiIndex = 1;
% 
% %% Build a Slider Controller
% iscInfo.slider_identifier = 'ShowSliderControlledLinkedInteractiveFigures';
% iscInfo.curr_i = temp.cellRoiIndex;
% iscInfo.NumberOfSeries = length(final_data_explorer_obj.uniqueComps);
% 
% plotFigureStates = {};
% 
% % plotFigureStates{end+1} = PlotFigureState('isc2DPlot', should_show_2d_plot, ...
% %     @(extantFigH, curr_i) (pho_plot_2d(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.finalOutPeaksGrid, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH, curr_i)));
% % 
% % plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesPlot', should_show_stimulus_traces_plot, ...
% %     @(extantFigH, curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj, extantFigH, curr_i)));
% 
% plotFigureStates{end+1} = PlotFigureState('isc2DPlot', should_show_2d_plot, ...
%     @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_2d(curr_i)));
% 
% plotFigureStates{end+1} = PlotFigureState('isc3DMeshPlot', should_show_3d_mesh_plot, ...
%     @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_3d_mesh(curr_i)));
% 
% plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesPlot', should_show_stimulus_traces_plot, ...
%     @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_stimulus_traces(curr_i)));
% 
% plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesExtendedInfoPlot', should_show_stimulus_traces_custom_data_plot, ...
%     @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_stimulus_traces(curr_i)));
% 
% plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesTimingHeatmapsPlot', should_show_stimulus_heatmaps_plot, ...
%     @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_timing_heatmaps(curr_i)));
% 
% plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesSummaryStatsPlot', should_show_stimulus_summary_stats_plot, ...
%     @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_summary_stats(curr_i)));



