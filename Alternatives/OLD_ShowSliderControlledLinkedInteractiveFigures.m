% ShowSliderControlledLinkedInteractiveFigures.m :Testing Interactive
% Pho Hale
% 11-20-2020
%%% Generates an interactive slider that allows one to scroll through the available cellROI values and it displays the correct graph.

% Requires:
% Matlab-Pho-Helper-Tools to be located on the path. Uses: fnBuildCallbackInteractiveSliderController

addpath(genpath('../../helpers'));


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

linkedFigureHandles = [];
plot_callbacks = {};

% Build or get the figures that will be controlled by the slider.
if should_show_2d_plot
	extantFigH_plot_2d = createFigureWithTagIfNeeded('isc2DPlot');
	linkedFigureHandles(end+1) = extantFigH_plot_2d;
	plot_2d_callback = @(curr_i) (pho_plot_2d(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.finalOutPeaksGrid, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_2d, curr_i));
	plot_callbacks{end+1} = plot_2d_callback;
end

if should_show_3d_mesh_plot
	extantFigH_plot_3d = createFigureWithTagIfNeeded('isc3DMeshPlot');
	linkedFigureHandles(end+1) = extantFigH_plot_3d;
	mesh_3d_plot_callback = @(curr_i) (pho_plot_3d_mesh(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.finalOutPeaksGrid, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_3d, curr_i));
	plot_callbacks{end+1} = mesh_3d_plot_callback;
end

if should_show_masking_plot
    extantFigH_plot_masking = createFigureWithTagIfNeeded('iscMaskingPlot');
    linkedFigureHandles(end+1) = extantFigH_plot_masking;
	secondary_plot_callback = @(curr_i) (pho_plot_interactive_masking_all(final_data_explorer_obj.dateStrings, final_data_explorer_obj.compMasks, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_masking, curr_i));
    plot_callbacks{end+1} = secondary_plot_callback;
end

if should_show_stimulus_traces_plot
    extantFigH_plot_stimulus_traces = createFigureWithTagIfNeeded('iscStimulusTracesPlot');
    linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces;
	stimulus_traces_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj, extantFigH_plot_stimulus_traces, curr_i));
    plot_callbacks{end+1} = stimulus_traces_plot_callback;
end

if should_show_stimulus_traces_custom_data_plot
    extantFigH_plot_stimulus_traces_extra = createFigureWithTagIfNeeded('iscStimulusTracesExtendedInfoPlot');
    linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces_extra;
	stimulus_traces_extras_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj, extantFigH_plot_stimulus_traces_extra, curr_i));
	plot_callbacks{end+1} = stimulus_traces_extras_plot_callback;
end

if should_show_stimulus_heatmaps_plot
    extantFigH_plot_stimulus_traces_timing_heatmaps = createFigureWithTagIfNeeded('iscStimulusTracesTimingHeatmapsPlot');
    linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces_timing_heatmaps;
	stimulus_traces_timing_heatmaps_plot_callback = @(curr_i) (pho_plot_timing_heatmaps(final_data_explorer_obj, extantFigH_plot_stimulus_traces_timing_heatmaps, curr_i));
    plot_callbacks{end+1} = stimulus_traces_timing_heatmaps_plot_callback;
end

if should_show_stimulus_summary_stats_plot
    extantFigH_plot_stimulus_traces_summary_stats = createFigureWithTagIfNeeded('iscStimulusTracesSummaryStatsPlot');
    linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces_summary_stats;
	stimulus_traces_summary_stats_plot_callback = @(curr_i) (pho_plot_summary_stats(final_data_explorer_obj, extantFigH_plot_stimulus_traces_summary_stats, curr_i));
    plot_callbacks{end+1} = stimulus_traces_summary_stats_plot_callback;
end


% slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, plot_callbacks);
% slider_controller = PhoInteractiveCallbackSlider(iscInfo, plot_callbacks);
% slider_controller = PhoInteractiveCallbackSlider.getInstance(iscInfo, plot_callbacks);

% slider_controller = PhoInteractiveCallbackSliderDefault.getInstance(iscInfo, plot_callbacks);


valid_only_quality = phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_quality_of_tuning;
valid_only_quality(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded) = []; % remove the excluded entries.

% slider_controller_build_gui_callback = @(app_obj) fnPhoControllerSlider(app_obj.slider_controller.controller.figH, valid_only_quality', {@(updated_i) app_obj.custom_post_update_function([], updated_i)});

% slider_controller_build_gui_callbacks = {@(app_obj) fnPhoControllerSlider(app_obj.slider_controller.controller.figH, valid_only_quality', {@(updated_i) app_obj.custom_post_update_function([], updated_i)})};
% 
linked_plots_config.active_plots.should_show_2d_plot = should_show_2d_plot;
linked_plots_config.active_plots.should_show_3d_mesh_plot = should_show_3d_mesh_plot;
linked_plots_config.active_plots.should_show_masking_plot = should_show_masking_plot;
linked_plots_config.active_plots.should_show_stimulus_traces_plot = should_show_stimulus_traces_plot;
linked_plots_config.active_plots.should_show_stimulus_traces_custom_data_plot = should_show_stimulus_traces_custom_data_plot;
linked_plots_config.active_plots.should_show_stimulus_heatmaps_plot = should_show_stimulus_heatmaps_plot;
linked_plots_config.active_plots.should_show_stimulus_summary_stats_plot = should_show_stimulus_summary_stats_plot;
% toolbarOptions.linkedFigureHandles = linkedFigureHandles;
% % 
% % fnAddActivePlotsToolbar(slider_controller, toolbarOptions);
% 
% slider_controller_build_gui_callbacks{end+1} = @(app_obj) fnAddActivePlotsToolbar(app_obj.slider_controller.controller.figH, toolbarOptions, {@(updated_i) app_obj.custom_post_update_function([], updated_i)});
% 
% slider_controller = PhoInteractiveCallbackSliderCustom.getInstance(iscInfo, plot_callbacks, slider_controller_build_gui_callbacks);


linked_plots_config.linkedFigureHandles = linkedFigureHandles;
linked_plots_config.plot_callbacks = plot_callbacks;


slider_controller = PhoInteractiveCallbackSliderCellROI.getInstance(iscInfo, linked_plots_config, valid_only_quality');



% PhoBuildSpatialTuning;

% Align the figures:
% align_figure(linkedFigureHandles);
figureLayoutManager.figuresSize.width = 880;
figureLayoutManager.figuresSize.height = 600;
figureLayoutManager.verticalSpacing = 30;
figureLayoutManager.horizontalSpacing = 5;

align_figure(linkedFigureHandles, 1, figureLayoutManager.figuresSize.width, figureLayoutManager.figuresSize.height,...
    100, figureLayoutManager.verticalSpacing, figureLayoutManager.horizontalSpacing, 100);

%% Note this FigureLayoutManager is overkill
fig_layout_manager_obj = FigureLayoutManager(linkedFigureHandles);
relative_figHandleIndex = length(linkedFigureHandles);
target_figureHandleRef = slider_controller.SliderControllerFigure;

fig_layout_manager_obj.bindSameWidth(relative_figHandleIndex, target_figureHandleRef)
fig_layout_manager_obj.bindAlignedEdgeLeft(relative_figHandleIndex, target_figureHandleRef)
fig_layout_manager_obj.bindAlignedTopTargetEdgeToBottomReferenceEdge(relative_figHandleIndex, target_figureHandleRef, figureLayoutManager.verticalSpacing)



%% Plot Helper Functions:
%% Plot function called as a callback on update

function [callbackOutput] = pho_plot_cell_mask(dateStrings, compMasks, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    callbackOutput.shouldRemoveCallback = false;
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    if isvalid(extantFigH)
        [callbackOutput.plotted_figH, ~] = fnPlotCellROIBlobs(dateStrings, temp.currAllSessionCompIndicies, curr_cellRoiIndex, compMasks, extantFigH);
        set(callbackOutput.plotted_figH, 'Name', sprintf('Slider Controlled Blobs/ROIs Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted 
    else
        callbackOutput.plotted_figH = extantFigH;
        callbackOutput.shouldRemoveCallback = true;
    end
end

function [callbackOutput] = pho_plot_stimulus_traces(final_data_explorer_obj, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    callbackOutput.shouldRemoveCallback = false;
    % temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    if isvalid(extantFigH)
        % Cell Mask Plots:
        plotting_options.should_plot_all_traces = false; % plotting_options.should_plot_all_traces: if true, line traces for all trials are plotted in addition the mean line
        plotting_options.should_plot_vertical_sound_start_stop_lines = true; % plotting_options.should_plot_vertical_sound_start_stop_lines: if true, vertical start/stop lines are drawn to show when the sound started and stopped.
        plotting_options.should_normalize_to_local_peak = true; % plotting_options.should_normalize_to_local_peak: if true, the y-values are normalized across all stimuli and sessions for a cellRoi to the maximal peak value.
        plotting_options.should_plot_titles_for_each_subplot = false; % plotting_options.should_plot_titles_for_each_subplot: if true, a title is added to each subplot (although it's redundent)
        
        [callbackOutput.plotted_figH] = fnPlotStimulusTracesForCellROI(final_data_explorer_obj, curr_cellRoiIndex, plotting_options, extantFigH);
        set(callbackOutput.plotted_figH, 'Name', sprintf('Slider Controlled Stimuli Traces Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted 
    else
        callbackOutput.plotted_figH = extantFigH;
        callbackOutput.shouldRemoveCallback = true;
    end
end

function [callbackOutput] = pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    callbackOutput.shouldRemoveCallback = false;
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Make 2D Plots (Exploring):   
    if isvalid(extantFigH)
        [callbackOutput.plotted_figH, ~] = fnPlotTunedStimulusPeaks(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutPeaksGrid, extantFigH);
        set(callbackOutput.plotted_figH, 'Name', sprintf('Slider Controlled 2D Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
    else
        callbackOutput.plotted_figH = extantFigH;
        callbackOutput.shouldRemoveCallback = true;
    end
end

function [callbackOutput] = pho_plot_3d_mesh(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    callbackOutput.shouldRemoveCallback = false;
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Make 3D Mesh Plot:
    if isvalid(extantFigH)
        [callbackOutput.plotted_figH, ~] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutPeaksGrid, extantFigH);
    %     zlim([-0.2, 1])
        set(callbackOutput.plotted_figH, 'Name', sprintf('Slider Controlled 3D Mesh Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
    else
        callbackOutput.plotted_figH = extantFigH;
        callbackOutput.shouldRemoveCallback = true;
    end
end

function [callbackOutput] = pho_plot_timing_heatmaps(final_data_explorer_obj, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    callbackOutput.shouldRemoveCallback = false;
    
    plotting_options.should_use_collapsed_heatmaps = true;
    plotting_options.subplotLayoutIsGrid = true; % subplotLayoutIsGrid: if true, the subplots are layed out in a 5x5 grid with an additional subplot for the 0 entry.
        
    plotting_options.debugIncludeColorbars = true;
    
    % Make Timing Heatmap Plot:
    if isvalid(extantFigH)    
%         [callbackOutput.plotted_figH] = fnPlotTimingHeatMap_AllStimulusStacked(final_data_explorer_obj, curr_cellRoiIndex, plotting_options, extantFigH);
        [callbackOutput.plotted_figH] = fnPlotTimingHeatMap_EachStimulusSeparately(final_data_explorer_obj, curr_cellRoiIndex, plotting_options, extantFigH);
        set(callbackOutput.plotted_figH, 'Name', sprintf('Slider Controlled Timing Heatmap Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
    else
        callbackOutput.plotted_figH = extantFigH;
        callbackOutput.shouldRemoveCallback = true;
    end
end

function [callbackOutput] = pho_plot_summary_stats(final_data_explorer_obj, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    callbackOutput.shouldRemoveCallback = false;
    
    plotting_options.subplotLayoutIsGrid = true; % subplotLayoutIsGrid: if true, the subplots are layed out in a 5x5 grid with an additional subplot for the 0 entry.
    plotting_options.should_plot_vertical_sound_start_stop_lines = true; % plotting_options.should_plot_vertical_sound_start_stop_lines: if true, vertical start/stop lines are drawn to show when the sound started and stopped.
    plotting_options.should_normalize_to_local_peak = false; % plotting_options.should_normalize_to_local_peak: if true, the y-values are normalized across all stimuli and sessions for a cellRoi to the maximal peak value.
    plotting_options.should_plot_titles_for_each_subplot = false; % plotting_options.should_plot_titles_for_each_subplot: if true, a title is added to each subplot (although it's redundent)


    % Make Timing Heatmap Plot:
    if isvalid(extantFigH)    
%         [callbackOutput.plotted_figH] = fnPlotTimingHeatMap_AllStimulusStacked(final_data_explorer_obj, curr_cellRoiIndex, plotting_options, extantFigH);
        [callbackOutput.plotted_figH] = fnPlotStimulusTraceSummaryStatsForCellROI(final_data_explorer_obj, curr_cellRoiIndex, plotting_options, extantFigH);
        set(callbackOutput.plotted_figH, 'Name', sprintf('Slider Controlled Summary Statistics Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
    else
        callbackOutput.plotted_figH = extantFigH;
        callbackOutput.shouldRemoveCallback = true;
    end
end

