% ShowSliderControlledLinkedInteractiveFigures.m :Testing Interactive
% Pho Hale
% 11-20-2020
%%% Generates an interactive slider that allows one to scroll through the available cellROI values and it displays the correct graph.

% Requires:
% Matlab-Pho-Helper-Tools to be located on the path. Uses: fnBuildCallbackInteractiveSliderController

addpath(genpath('../../helpers'));

combinedOffsetInsetIndicies = [nan, 0];
% combinedOffsetInsetIndicies = [nan, 3, 2, 1, 0, -1, -2, -3];
 if ~exist('active_selections_backingFile_path','var')
    active_selections_backingFile_path = phoPipelineOptions.default_interactionManager_backingStorePath;
 end
 
 %% Build a new plot manager object:
 plot_manager_cellRoiPlot = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path);
 plot_manager_cellRoiPlot.activeOffsetInsetIndicies = combinedOffsetInsetIndicies;
 
%% Options:
should_show_2d_plot = false;
should_show_3d_mesh_plot = false;
should_show_masking_plot = false;
should_show_stimulus_traces_plot = true;
should_show_stimulus_traces_custom_data_plot = false;
should_show_stimulus_heatmaps_plot = true;
should_show_stimulus_summary_stats_plot = true;

temp.cellRoiIndex = 1;


%% Build a Slider Controller
% if exist('slider_controller','var')
%     clear slider_controller;
% end
% Build a new slider controller
iscInfo.slider_identifier = 'ShowSliderControlledLinkedInteractiveFigures';
iscInfo.curr_i = temp.cellRoiIndex;
iscInfo.NumberOfSeries = length(final_data_explorer_obj.uniqueComps);

% linkedFigureHandles = [];
% plot_callbacks = {};

plotFigureStates = {};

% plotFigureStates{end+1} = PlotFigureState('isc2DPlot', should_show_2d_plot, ...
%     @(extantFigH, curr_i) (pho_plot_2d(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.finalOutPeaksGrid, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH, curr_i)));
% 
% plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesPlot', should_show_stimulus_traces_plot, ...
%     @(extantFigH, curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj, extantFigH, curr_i)));


plotFigureStates{end+1} = PlotFigureState('isc2DPlot', should_show_2d_plot, ...
    @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_2d(curr_i)));

plotFigureStates{end+1} = PlotFigureState('isc3DMeshPlot', should_show_3d_mesh_plot, ...
    @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_3d_mesh(curr_i)));

plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesPlot', should_show_stimulus_traces_plot, ...
    @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_stimulus_traces(curr_i)));

plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesExtendedInfoPlot', should_show_stimulus_traces_custom_data_plot, ...
    @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_stimulus_traces(curr_i)));

plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesTimingHeatmapsPlot', should_show_stimulus_heatmaps_plot, ...
    @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_timing_heatmaps(curr_i)));

plotFigureStates{end+1} = PlotFigureState('iscStimulusTracesSummaryStatsPlot', should_show_stimulus_summary_stats_plot, ...
    @(extantFigH, curr_i) (plot_manager_cellRoiPlot.pho_plot_summary_stats(curr_i)));



%     plot_manager_cellRoiPlot.pho_plot_2d(i);
%     figH_2d = plot_manager_cellRoiPlot.extantFigH_plot_2d;
    
%     plot_manager_cellRoiPlot.pho_plot_3d_mesh(i);
%     figH_3dMesh = plot_manager_cellRoiPlot.extantFigH_plot_3d;

%     plot_manager_cellRoiPlot.pho_plot_stimulus_traces(i);
%     figH_StimulusTraces = plot_manager_cellRoiPlot.extantFigH_plot_stimulus_traces;
% 
%     plot_manager_cellRoiPlot.pho_plot_timing_heatmaps(i);
%     figH_StimulusHeatmaps = plot_manager_cellRoiPlot.extantFigH_plot_heatmap_traces;

 
% 
% % Build or get the figures that will be controlled by the slider.
% if should_show_2d_plot
% 	extantFigH_plot_2d = createFigureWithTagIfNeeded('isc2DPlot');
% 	linkedFigureHandles(end+1) = extantFigH_plot_2d;
% 	plot_2d_callback = @(curr_i) (pho_plot_2d(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.finalOutPeaksGrid, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_2d, curr_i));
% 	plot_callbacks{end+1} = plot_2d_callback;
% end
% 
% if should_show_3d_mesh_plot
% 	extantFigH_plot_3d = createFigureWithTagIfNeeded('isc3DMeshPlot');
% 	linkedFigureHandles(end+1) = extantFigH_plot_3d;
% 	mesh_3d_plot_callback = @(curr_i) (pho_plot_3d_mesh(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.finalOutPeaksGrid, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_3d, curr_i));
% 	plot_callbacks{end+1} = mesh_3d_plot_callback;
% end
% 
% if should_show_masking_plot
%     extantFigH_plot_masking = createFigureWithTagIfNeeded('iscMaskingPlot');
%     linkedFigureHandles(end+1) = extantFigH_plot_masking;
% 	secondary_plot_callback = @(curr_i) (pho_plot_interactive_masking_all(final_data_explorer_obj.dateStrings, final_data_explorer_obj.compMasks, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_masking, curr_i));
%     plot_callbacks{end+1} = secondary_plot_callback;
% end
% 
% if should_show_stimulus_traces_plot
%     extantFigH_plot_stimulus_traces = createFigureWithTagIfNeeded('iscStimulusTracesPlot');
%     linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces;
% 	stimulus_traces_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj, extantFigH_plot_stimulus_traces, curr_i));
%     plot_callbacks{end+1} = stimulus_traces_plot_callback;
% end
% 
% if should_show_stimulus_traces_custom_data_plot
%     extantFigH_plot_stimulus_traces_extra = createFigureWithTagIfNeeded('iscStimulusTracesExtendedInfoPlot');
%     linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces_extra;
% 	stimulus_traces_extras_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj, extantFigH_plot_stimulus_traces_extra, curr_i));
% 	plot_callbacks{end+1} = stimulus_traces_extras_plot_callback;
% end
% 
% if should_show_stimulus_heatmaps_plot
%     extantFigH_plot_stimulus_traces_timing_heatmaps = createFigureWithTagIfNeeded('iscStimulusTracesTimingHeatmapsPlot');
%     linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces_timing_heatmaps;
% 	stimulus_traces_timing_heatmaps_plot_callback = @(curr_i) (pho_plot_timing_heatmaps(final_data_explorer_obj, extantFigH_plot_stimulus_traces_timing_heatmaps, curr_i));
%     plot_callbacks{end+1} = stimulus_traces_timing_heatmaps_plot_callback;
% end
% 
% if should_show_stimulus_summary_stats_plot
%     extantFigH_plot_stimulus_traces_summary_stats = createFigureWithTagIfNeeded('iscStimulusTracesSummaryStatsPlot');
%     linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces_summary_stats;
% 	stimulus_traces_summary_stats_plot_callback = @(curr_i) (pho_plot_summary_stats(final_data_explorer_obj, extantFigH_plot_stimulus_traces_summary_stats, curr_i));
%     plot_callbacks{end+1} = stimulus_traces_summary_stats_plot_callback;
% end
% 
% 
% % slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, plot_callbacks);
% % slider_controller = PhoInteractiveCallbackSlider(iscInfo, plot_callbacks);
% % slider_controller = PhoInteractiveCallbackSlider.getInstance(iscInfo, plot_callbacks);
% 
% % slider_controller = PhoInteractiveCallbackSliderDefault.getInstance(iscInfo, plot_callbacks);
% 
% 
% valid_only_quality = phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_quality_of_tuning;
% valid_only_quality(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded) = []; % remove the excluded entries.
% 
% % slider_controller_build_gui_callback = @(app_obj) fnPhoControllerSlider(app_obj.slider_controller.controller.figH, valid_only_quality', {@(updated_i) app_obj.custom_post_update_function([], updated_i)});
% 
% % slider_controller_build_gui_callbacks = {@(app_obj) fnPhoControllerSlider(app_obj.slider_controller.controller.figH, valid_only_quality', {@(updated_i) app_obj.custom_post_update_function([], updated_i)})};
% % 
% linked_plots_config.active_plots.should_show_2d_plot = should_show_2d_plot;
% linked_plots_config.active_plots.should_show_3d_mesh_plot = should_show_3d_mesh_plot;
% linked_plots_config.active_plots.should_show_masking_plot = should_show_masking_plot;
% linked_plots_config.active_plots.should_show_stimulus_traces_plot = should_show_stimulus_traces_plot;
% linked_plots_config.active_plots.should_show_stimulus_traces_custom_data_plot = should_show_stimulus_traces_custom_data_plot;
% linked_plots_config.active_plots.should_show_stimulus_heatmaps_plot = should_show_stimulus_heatmaps_plot;
% linked_plots_config.active_plots.should_show_stimulus_summary_stats_plot = should_show_stimulus_summary_stats_plot;
% % toolbarOptions.linkedFigureHandles = linkedFigureHandles;
% % % 
% % % fnAddActivePlotsToolbar(slider_controller, toolbarOptions);
% % 
% % slider_controller_build_gui_callbacks{end+1} = @(app_obj) fnAddActivePlotsToolbar(app_obj.slider_controller.controller.figH, toolbarOptions, {@(updated_i) app_obj.custom_post_update_function([], updated_i)});
% % 
% % slider_controller = PhoInteractiveCallbackSliderCustom.getInstance(iscInfo, plot_callbacks, slider_controller_build_gui_callbacks);
% 
% 
% linked_plots_config.linkedFigureHandles = linkedFigureHandles;
% linked_plots_config.plot_callbacks = plot_callbacks;
% 
% 

slider_controller = PhoInteractiveSliderCellROIPlotManager.getInstance(iscInfo, plot_manager_cellRoiPlot, valid_only_quality');

