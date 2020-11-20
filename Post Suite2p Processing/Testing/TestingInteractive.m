% Testing Interactive
addpath(genpath('../../helpers'));

% currAllSessionCompIndicies

temp.cellRoiIndex = 5;

% USES:
% dateStrings
% uniqueAmps
% uniqueFreqs
% multiSessionCellRoiCompIndicies
% finalOutComponentSegmentMasks
% finalOutPeaksGrid
% 
% 
% 
% 
% 
% 




%% Build a Slider Controller
if exist('slider_controller','var')
%     close(slider_controller.controller.figH); % close the existing figure.
    clear slider_controller;
end
% Build a new slider controller
iscInfo.curr_i = temp.cellRoiIndex;
iscInfo.NumberOfSeries = length(uniqueComps);
% curr_callback = 
slider_controller = build_slider_controller(iscInfo, @(extantFigH, curr_i) (pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoiCompIndicies, extantFigH, curr_i)) );

%% Plot function called as a callback on update
function plotted_figH = pho_plot_2d(dateStrings, uniqueAmps, uniqueFreqs, finalOutPeaksGrid, multiSessionCellRoiCompIndicies, extantFigH, curr_cellRoiIndex)
    % COMPUTED
    temp.currAllSessionCompIndicies = multiSessionCellRoiCompIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI
%     temp.firstCompSessionIndex = temp.currAllSessionCompIndicies(1);
%     temp.firstCompSessionMask = squeeze(finalOutComponentSegmentMasks(temp.firstCompSessionIndex,:,:));

    % Make 2D Plots (Exploring):    
    [plotted_figH, ~] = fnPlotFlattenedPlotsFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, curr_cellRoiIndex, finalOutPeaksGrid, extantFigH);

end


function slider_controller = build_slider_controller(iscInfo, update_plot_callback)

    % create a new figure to host the controller (slider)
    slider_controller.controller.figH = figure('Name','Slider Controller','NumberTitle','off');
    slider_controller.controller.update_plot_callback = update_plot_callback;
    
    %% Slider:
    % Gets the slider position from the figure
    pisSettings.sliderWidth = slider_controller.controller.figH.Position(3) - 20;
    pisSettings.sliderHeight = 23;
    pisSettings.sliderX = 0;
    pisSettings.sliderY = 0;

	maxSliderValue = iscInfo.NumberOfSeries;
	minSliderValue = 1;
	theRange = maxSliderValue - minSliderValue;
	pisSettings.steps = [1/theRange, 10/theRange];

    % svp.Slider = uicontrol(svp.Figure,'Style','slider',...
    slider_controller.controller.Slider = uicontrol(slider_controller.controller.figH,'Style','slider',...
                    'Min',1,'Max',iscInfo.NumberOfSeries,'Value',iscInfo.curr_i,...
					'SliderStep',pisSettings.steps,...
                    'Position', [pisSettings.sliderX,pisSettings.sliderY,pisSettings.sliderWidth,pisSettings.sliderHeight]);

    slider_controller.controller.Slider.Units = "normalized"; %Change slider units to normalized so that it scales with the video window.
    addlistener(slider_controller.controller.Slider, 'Value', 'PostSet', @slider_post_update_function);
    
    % Current index: i
	setappdata(slider_controller.controller.figH,'curr_i', iscInfo.curr_i); % Set the app data to the initial value:
	iscInfo.curr_i = getappdata(slider_controller.controller.figH,'curr_i'); % Set the pisInfo.curr_i value from the app data.
    
    % create a new *controlled* figure to host the content that will be updated when the slider is adjusted
    slider_controller.controlled.plotted_figH = figure;
    
    % Update the plots now:
	update_plots(iscInfo.curr_i);
    
   
    %% Slider callback function:
	function slider_post_update_function(~, event_obj)
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure

        % get the current index from the slider
        iscInfo.curr_i = round(event_obj.AffectedObject.Value);
		% Update the app data:
		setappdata(slider_controller.controller.figH,'curr_i', iscInfo.curr_i);
		% Update the plots now:
		update_plots(iscInfo.curr_i);
	end

	function update_plots(curr_i)
		% Update the plot:
        fprintf('update_plots(%d): called\n', curr_i);
        figure(slider_controller.controlled.plotted_figH);
        slider_controller.controlled.plotted_figH = slider_controller.controller.update_plot_callback(slider_controller.controlled.plotted_figH, curr_i);

	end

end