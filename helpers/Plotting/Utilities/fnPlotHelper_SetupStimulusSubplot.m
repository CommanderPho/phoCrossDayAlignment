function fnPlotHelper_SetupStimulusSubplot(final_data_explorer_obj, numRows, numCol, curr_linear_stimulus_index, curr_subplot_axes, plotting_options)
    %% fnPlotHelper_SetupStimulusSubplot(...): Sets up the user interaction with the subplot axes objects
        % Used by fnPlotTimingHeatMap_EachStimulusSeparately(...) and other classes
    if ~isfield(plotting_options, 'disableAxesInteractivity')
       plotting_options.disableAxesInteractivity = true; 
    end

	if plotting_options.disableAxesInteractivity
		% curr_subplot_axes.Toolbar.Visible = 'off'; # Disabled, as this takes 6+ seconds
		% Might be able to set the default value factoryFigureToolBar
		disableDefaultInteractivity(curr_subplot_axes);
	end

	set(curr_subplot_axes, 'Tag', num2str(curr_linear_stimulus_index));

	axesInfo.Type = 'stimulusAxes'; % Information stored in axes userdata indicating that these are date axes
	axesInfo.Index = curr_linear_stimulus_index;
	set(curr_subplot_axes, 'UserData', axesInfo);

% 	curr_subplot_axes.ButtonDownFcn = @(hSrc, event) disp(event.Source.Tag);
    curr_subplot_axes.ButtonDownFcn = @(hSrc, event) SimpleSelectionSyncrhonizer.fnPlotHelper_ToggleSubplotSelection(event.Source);


    % function [updatedSelectionStatus] = fnPlotHelper_ToggleSubplotSelection(curr_subplot_axes)
    %     stimulusTagNum = str2num(curr_subplot_axes.Tag); 
    %     fprintf('fnPlotHelper_ToggleSubplotSelection(...): subplot corresponding to stimulus %d\n', stimulusTagNum);
    %     prev_was_selected = curr_subplot_axes.Selected;
    %     updatedSelectionStatus = ~prev_was_selected;
    %     fnPlotHelper_UpdateSelectedSubplot(curr_subplot_axes, updatedSelectionStatus);
    % end

    % function fnPlotHelper_UpdateSelectedSubplot(curr_subplot_axes, is_selected)
    %     curr_subplot_axes.Selected = is_selected;
    %     if curr_subplot_axes.Selected
    %         box(curr_subplot_axes,'on');
    %         % Set the remaining axes properties
    %         set(curr_subplot_axes,'BoxStyle','full','LineWidth',2,'Color',[0.941176470588235 0.941176470588235 0.941176470588235],'XColor',...
    %             [0.301960784313725 0.745098039215686 0.933333333333333],'YColor',...
    %             [0.301960784313725 0.749019607843137 0.929411764705882]);
    %     else
    %         box(curr_subplot_axes,'off');
    %         % Set the remaining axes properties
    %         set(curr_subplot_axes,'BoxStyle','full','LineWidth',0.5,'Color',[1 1 1],'XColor',...
    %             [0.15,0.15,0.15],'YColor',...
    %             [0.15,0.15,0.15]);
    %     end
        
    % end
    
end % end fnPlotHelper_SetupStimulusSubplot



