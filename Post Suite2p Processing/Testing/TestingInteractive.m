% Testing Interactive
% Pho Hale
% 11-20-2020
%%% Generates an interactive slider that allows one to scroll through the available cellROI values and it displays the correct graph.

% Requires:
% Matlab-Pho-Helper-Tools to be located on the path. Uses: fnBuildCallbackInteractiveSliderController

addpath(genpath('../../helpers'));

temp.cellRoiIndex = 5;


%% Build a Slider Controller
if exist('slider_controller','var')
%     close(slider_controller.controller.figH); % close the existing figure.
    clear slider_controller;
end
% Build a new slider controller
iscInfo.curr_i = temp.cellRoiIndex;
iscInfo.NumberOfSeries = length(uniqueComps);
% curr_callback = 
% slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, @(extantFigH, curr_i) (pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH, curr_i)) );

extantFigH_plot_2d = figure('Name','Slider Controlled 2D Plot','NumberTitle','off');
extantFigH_plot_3d = figure('Name','Slider Controlled 3D Mesh Plot','NumberTitle','off');
% slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, @(curr_i) (pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_plot_2d, curr_i)) );
slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, @(curr_i) (pho_plot_interactive_all(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_plot_2d, extantFigH_plot_3d, curr_i)) );


%% Plot function called as a callback on update
function pho_plot_interactive_all(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_2d, extantFigH_3d, curr_cellRoiIndex)
    pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_2d, curr_cellRoiIndex);
    pho_plot_3d_mesh(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoi_CompListIndicies, extantFigH_3d, curr_cellRoiIndex);
end




function plotted_figH = pho_plot_cell_mask(dateStrings, multiSessionCellRoi_CompListIndicies, extantFigH, curr_cellRoiIndex)
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



