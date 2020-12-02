% Testing Interactive
% Pho Hale
% 11-20-2020
%%% Generates an interactive slider that allows one to scroll through the available cellROI values and it displays the correct graph.

% Requires:
% Matlab-Pho-Helper-Tools to be located on the path. Uses: fnBuildCallbackInteractiveSliderController

addpath(genpath('../../helpers'));

%% Options:
should_show_masking_plot = false;

temp.cellRoiIndex = 5;


%% Build a Slider Controller
if exist('slider_controller','var')
%     close(slider_controller.controller.figH); % close the existing figure.
    clear slider_controller;
end
% Build a new slider controller
iscInfo.curr_i = temp.cellRoiIndex;
iscInfo.NumberOfSeries = length(uniqueComps);

% Build or get the figures that will be controlled by the slider.
if should_show_masking_plot
    extantFigH_plot_masking = createFigureWithNameIfNeeded('Slider Controlled Masking Plot');
end
extantFigH_plot_2d = createFigureWithNameIfNeeded('Slider Controlled 2D Plot');
extantFigH_plot_3d = createFigureWithNameIfNeeded('Slider Controlled 3D Mesh Plot');

main_plot_callback = @(curr_i) (pho_plot_interactive_all(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.finalOutPeaksGrid, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_2d, extantFigH_plot_3d, curr_i));
if should_show_masking_plot
    secondary_plot_callback = @(curr_i) (pho_plot_interactive_masking_all(final_data_explorer_obj.dateStrings, final_data_explorer_obj.finalOutComponentSegment, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies, extantFigH_plot_masking, curr_i));
    plot_callbacks = {main_plot_callback, secondary_plot_callback};
else
    plot_callbacks = {main_plot_callback};
end

slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, plot_callbacks);


%% Plot function called as a callback on update
function pho_plot_interactive_all(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_2d, extantFigH_3d, curr_cellRoiIndex)
    pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_2d, curr_cellRoiIndex);
    pho_plot_3d_mesh(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_3d, curr_cellRoiIndex);
end


function pho_plot_interactive_masking_all(dateStrings, finalOutComponentSegment, multiSessionCellRoi_CompListIndicies, extantFigH_masking, curr_cellRoiIndex)
    pho_plot_cell_mask(dateStrings, finalOutComponentSegment, multiSessionCellRoi_CompListIndicies, extantFigH_masking, curr_cellRoiIndex);
end

function plotted_figH = pho_plot_cell_mask(dateStrings, finalOutComponentSegment, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Cell Mask Plots:
    [plotted_figH, ~] = fnPlotCellROIBlobs(dateStrings, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutComponentSegment, extantFigH);
    set(plotted_figH, 'Name', sprintf('Slider Controlled Blobs/ROIs Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted 
end


function plotted_figH = pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI

    % Make 2D Plots (Exploring):    
    [plotted_figH, ~] = fnPlotFlattenedPlotsFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutPeaksGrid, extantFigH);
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



