function fnPlotHelper_SetupStimulusSubplot(final_data_explorer_obj, numRows, numCol, curr_linear_stimulus_index, curr_subplot_axes, plotting_options)
    %% fnPlotHelper_SetupStimulusSubplot(...): Sets up the user interaction with the subplot axes objects
        % Used by fnPlotTimingHeatMap_EachStimulusSeparately(...) and other classes
    if ~isfield(plotting_options, 'disableAxesInteractivity')
       plotting_options.disableAxesInteractivity = true; 
    end

	if plotting_options.disableAxesInteractivity
		curr_subplot_axes.Toolbar.Visible = 'off';
		disableDefaultInteractivity(curr_subplot_axes);
	end

	set(curr_subplot_axes, 'Tag', num2str(curr_linear_stimulus_index));
	curr_subplot_axes.ButtonDownFcn = @(hSrc, event) disp(event.Source.Tag);

    
end % end fnPlotHelper_SetupStimulusSubplot



