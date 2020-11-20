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
slider_controller = fnBuildCallbackInteractiveSliderController(iscInfo, @(extantFigH, curr_i) (pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoiCompIndicies, extantFigH, curr_i)) );

%% Plot function called as a callback on update
function plotted_figH = pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoiCompIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoiCompIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI
%     temp.firstCompSessionIndex = temp.currAllSessionCompIndicies(1);
%     temp.firstCompSessionMask = squeeze(finalOutComponentSegmentMasks(temp.firstCompSessionIndex,:,:));

    % Make 2D Plots (Exploring):    
    [plotted_figH, ~] = fnPlotFlattenedPlotsFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutPeaksGrid, extantFigH);

end


