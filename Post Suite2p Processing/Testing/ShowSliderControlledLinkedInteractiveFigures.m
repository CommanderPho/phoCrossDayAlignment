% ShowSliderControlledLinkedInteractiveFigures.m :Testing Interactive
% Pho Hale
% 11-20-2020
%%% Generates an interactive slider that allows one to scroll through the available cellROI values and it displays the correct graph.

% Requires:
% Matlab-Pho-Helper-Tools to be located on the path. Uses: fnBuildCallbackInteractiveSliderController

addpath(genpath('../../helpers'));

final_data_explorer_obj = final_data_explorer_obj.computeCurveAnalysis();


%% Options:
should_show_2d_plot = true;
should_show_3d_mesh_plot = false;
should_show_masking_plot = false;
should_show_stimulus_traces_plot = true;
should_show_stimulus_traces_custom_data_plot = true;

temp.cellRoiIndex = 1;


%% Build a Slider Controller
if exist('slider_controller','var')
%     close(slider_controller.controller.figH); % close the existing figure.
    clear slider_controller;
end
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
	stimulus_traces_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.uniqueStimuli, final_data_explorer_obj.traceTimebase_t, final_data_explorer_obj.active_DFF.TracesForAllStimuli, final_data_explorer_obj.redTraceLinesForAllStimuli, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_stimulus_traces, curr_i));
    plot_callbacks{end+1} = stimulus_traces_plot_callback;
end

if should_show_stimulus_traces_custom_data_plot
    extantFigH_plot_stimulus_traces_extra = createFigureWithTagIfNeeded('iscStimulusTracesExtendedInfoPlot');
    linkedFigureHandles(end+1) = extantFigH_plot_stimulus_traces_extra;
	stimulus_traces_extras_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.uniqueStimuli, final_data_explorer_obj.traceTimebase_t, final_data_explorer_obj.active_DFF.TracesForAllStimuli, final_data_explorer_obj.computedRedTraceLinesAnalyses.second_derivative, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_stimulus_traces_extra, curr_i));
    plot_callbacks{end+1} = stimulus_traces_extras_plot_callback;
end


% if should_show_stimulus_traces_plot
%     stimulus_traces_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.uniqueStimuli, final_data_explorer_obj.traceTimebase_t, final_data_explorer_obj.active_DFF.TracesForAllStimuli, final_data_explorer_obj.redTraceLinesForAllStimuli, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_stimulus_traces, curr_i));
%     plot_callbacks{end+1} = stimulus_traces_plot_callback;
% end

% if should_show_stimulus_traces_custom_data_plot
%     stimulus_traces_extras_plot_callback = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.uniqueStimuli, final_data_explorer_obj.traceTimebase_t, final_data_explorer_obj.active_DFF.TracesForAllStimuli, final_data_explorer_obj.computedRedTraceLinesAnalyses.second_derivative, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_stimulus_traces_extra, curr_i));
%     plot_callbacks{end+1} = stimulus_traces_extras_plot_callback;
% end


slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, plot_callbacks);
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
target_figureHandleRef = slider_controller.controller.figH;

fig_layout_manager_obj.bindSameWidth(relative_figHandleIndex, target_figureHandleRef)
fig_layout_manager_obj.bindAlignedEdgeLeft(relative_figHandleIndex, target_figureHandleRef)
fig_layout_manager_obj.bindAlignedTopTargetEdgeToBottomReferenceEdge(relative_figHandleIndex, target_figureHandleRef, figureLayoutManager.verticalSpacing)



%% Plot Helper Functions:
%% Plot function called as a callback on update
% function pho_plot_interactive_all(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_2d, extantFigH_3d, curr_cellRoiIndex)
%     if isvalid(extantFigH_2d)
%         pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_2d, curr_cellRoiIndex);
%     end

%     if isvalid(extantFigH_3d)
%         pho_plot_3d_mesh(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_3d, curr_cellRoiIndex);
%     end
% end


function pho_plot_interactive_masking_all(dateStrings, compMasks, multiSessionCellRoi_CompListIndicies, extantFigH_masking, curr_cellRoiIndex)
    pho_plot_cell_mask(dateStrings, compMasks, multiSessionCellRoi_CompListIndicies, extantFigH_masking, curr_cellRoiIndex);
end

function plotted_figH = pho_plot_cell_mask(dateStrings, compMasks, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Cell Mask Plots:
    [plotted_figH, ~] = fnPlotCellROIBlobs(dateStrings, temp.currAllSessionCompIndicies, curr_cellRoiIndex, compMasks, extantFigH);
    set(plotted_figH, 'Name', sprintf('Slider Controlled Blobs/ROIs Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted 
end


function plotted_figH = pho_plot_stimulus_traces(dateStrings, uniqueAmps, uniqueFreqs, uniqueStimuli, traceTimebase_t, tracesForAllStimuli, redTraceLinesForAllStimuli, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Cell Mask Plots:
    [plotted_figH] = fnPlotStimulusTracesForCellROI(dateStrings, uniqueAmps, uniqueFreqs, uniqueStimuli, ...
        temp.currAllSessionCompIndicies, curr_cellRoiIndex, ...
        traceTimebase_t, tracesForAllStimuli, redTraceLinesForAllStimuli, extantFigH);
    
    set(plotted_figH, 'Name', sprintf('Slider Controlled Stimuli Traces Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted 
end

function plotted_figH = pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Make 2D Plots (Exploring):    
    [plotted_figH, ~] = fnPlotTunedStimulusPeaks(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutPeaksGrid, extantFigH);
    set(plotted_figH, 'Name', sprintf('Slider Controlled 2D Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
end

function plotted_figH = pho_plot_3d_mesh(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Make 3D Mesh Plot:
    [plotted_figH, ~] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutPeaksGrid, extantFigH);
%     zlim([-0.2, 1])
    set(plotted_figH, 'Name', sprintf('Slider Controlled 3D Mesh Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
end



