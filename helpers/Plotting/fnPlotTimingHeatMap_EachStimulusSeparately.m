function [figH] = fnPlotTimingHeatMap_EachStimulusSeparately(final_data_explorer_obj, curr_cellRoiIndex, plotting_options, extantFigH)
    %% fnPlotTimingHeatMap_EachStimulusSeparately: Plot a heatmap where:
        % (for a particular cellROI and stimulus)
        % There are numStimuli vertically stacked subplots, each containing their trials represented as rows.
    
    if ~isfield(plotting_options, 'should_use_custom_subplots')
        plotting_options.should_use_custom_subplots = true;
    end
        
    if ~isfield(plotting_options, 'useGlobalColorLims')
        plotting_options.useGlobalColorLims = true;
    end
    
    if ~isfield(plotting_options, 'useSingleSharedColorbar')
        plotting_options.useSingleSharedColorbar = true;
    end
    
    if ~isfield(plotting_options, 'should_use_collapsed_heatmaps')
       plotting_options.should_use_collapsed_heatmaps = false; 
    end
    
    if ~isfield(plotting_options, 'subplotLayoutIsGrid')
        plotting_options.subplotLayoutIsGrid = false; % subplotLayoutIsGrid: if true, the subplots are layed out in a 5x5 grid with an additional subplot for the 0 entry.
    end
    
    if ~isfield(plotting_options, 'should_plot_titles_for_each_subplot')
        plotting_options.should_plot_titles_for_each_subplot = false;
    end
    
    if ~isfield(plotting_options, 'debugIncludeColorbars')
       plotting_options.debugIncludeColorbars = false; 
    end
    
    % Options for tightening up the subplots:
    if plotting_options.should_use_custom_subplots
        if plotting_options.subplotLayoutIsGrid
            plotting_options.subtightplot.gap = [0.01 0.01]; % [intra_graph_vertical_spacing, intra_graph_horizontal_spacing]
            plotting_options.subtightplot.width_h = [0.01 0.05]; % Looks like [padding_bottom, padding_top]
            plotting_options.subtightplot.width_w = [0.025 0.01];
        else
            plotting_options.subtightplot.gap = [0.01/26 0.1]; % [intra_graph_vertical_spacing, intra_graph_horizontal_spacing]
            plotting_options.subtightplot.width_h = [0.01 0.05]; % Looks like [padding_bottom, padding_top]
            plotting_options.subtightplot.width_w = [0.12 0.01];
        end
    
        plotting_options.opt = {plotting_options.subtightplot.gap, plotting_options.subtightplot.width_h, plotting_options.subtightplot.width_w}; % {gap, width_h, width_w}
        subplot_cmd = @(m,n,p) subtightplot(m, n, p, plotting_options.opt{:});
    else
        subplot_cmd = @(m,n,p) subplot(m, n, p);
    end
    
    plotting_options.useGlobalColorLims = true;
    
    if (~exist('extantFigH','var') || isempty(extantFigH))
        figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
%         set(groot,'CurrentFigure',figNumber);
    end
    
    clf(figH);
    
    %generate the dimensions of the subplots
    if plotting_options.subplotLayoutIsGrid
        % A grid
        numRows = numel(nonzeros(final_data_explorer_obj.uniqueFreqs))+1; %+1 because you have the zero mod condition too
        numCol = numel(nonzeros(final_data_explorer_obj.uniqueAmps));
    else
        % a vertical stack with 26 rows
        numRows = final_data_explorer_obj.stimuli_mapper.numStimuli; %+1 because you have the zero mod condition too
        numCol = 1;
    end
    
    % final_data_explorer_obj.tracesForAllStimuli: [159    26    20   150]
    % final_data_explorer_obj.active_DFF.redTraceLinesForAllStimuli: [159    26   150]
    
    if plotting_options.should_use_collapsed_heatmaps
        % [159 26 150]
        curr_cellROI_heatMap = squeeze(final_data_explorer_obj.active_DFF.redTraceLinesForAllStimuli(curr_cellRoiIndex, :, :)); % should be [26 150]
        
    else
        curr_cellROI_heatMap = squeeze(final_data_explorer_obj.tracesForAllStimuli(curr_cellRoiIndex, :, :, :)); % should be [26 20 150]
    end
    % Get global color lims
    if plotting_options.useGlobalColorLims
       [maxVals] = max(curr_cellROI_heatMap,[], 'all'); % get max of current cellROI heatmap (for this single day)
       [minVals] = min(curr_cellROI_heatMap,[], 'all'); % get min of current cellROI heatmap (for this single day)
       globalCLims = [minVals maxVals];
       
    end
    
    %% Loop through all stimuli:
    for stimulusIndex = 1:final_data_explorer_obj.stimuli_mapper.numStimuli
        [~, ~, depthValue, freqValue] = final_data_explorer_obj.stimuli_mapper.getDepthFreqIndicies(stimulusIndex);
        
    %     curr_maxVals = squeeze(maxVals(cellROIIndex, stimulusIndex, :));
    %     curr_maxInds = squeeze(maxInds(cellROIIndex, stimulusIndex, :));

        if plotting_options.subplotLayoutIsGrid
            curr_linear_subplot_index = final_data_explorer_obj.stimuli_mapper.numStimuli-stimulusIndex+1;
            curr_ax = subplot_cmd(numRows, numCol, curr_linear_subplot_index);
        else
            curr_ax = subplot_cmd(numRows, numCol, stimulusIndex);
        end
        
        %% Plot a heatmap where each of the 20 trials is a vertical column within a single row (for a particular cellROI and stimulus):
        curr_heatMap = squeeze(curr_cellROI_heatMap(stimulusIndex, :, :)); % should be [20 150]
    %     size(curr_heatMap)
        dim.x = size(curr_heatMap, 1);
        dim.y = size(curr_heatMap, 2);

        xx = [1:dim.x];
        yy = [1:dim.y];
        if plotting_options.useGlobalColorLims
            h = imagesc(xx, yy, curr_heatMap, globalCLims);
        else
            h = imagesc(xx, yy, curr_heatMap);
        end
		set(h, 'PickableParts','none'); % Disable picking the image, so the clicks will be passed through
    %     title('test heat map')
        yticks([]);
        
		fnPlotHelper_SetupStimulusSubplot(final_data_explorer_obj, numRows, numCol, stimulusIndex, curr_ax, plotting_options);
        
        if plotting_options.subplotLayoutIsGrid
            fnPlotHelper_StimulusGridLabels(final_data_explorer_obj, numRows, numCol, stimulusIndex, plotting_options);
        
        else
            activeStr = [final_data_explorer_obj.stimuli_mapper.getFormattedString_Depth(depthValue) ' ' final_data_explorer_obj.stimuli_mapper.getFormattedString_Freq(freqValue)];
    %         activeStr = sprintf('%d, %d Hz', depthValue, freqValue);

    %         t_currLabelH = ylabel({sprintf('stim[%d]', stimulusIndex), activeStr});
            t_currLabelH = ylabel([sprintf('stim[%d] ', stimulusIndex), activeStr]);
            set(t_currLabelH, 'Rotation', 0, 'VerticalAlignment', 'middle', 'HorizontalAlignment','right'); % 'right' horizontal alignment will position it in the far left margin
            temp_currTextPosition = get(t_currLabelH, 'Position');
    %         temp_currTextPosition(1) = 0;
            % Update text position
    %         set(t_currLabelH, 'Position', temp_currTextPosition);

        end
        
        is_last_stimulus = (final_data_explorer_obj.stimuli_mapper.numStimuli == stimulusIndex);
        if is_last_stimulus
            xticks([0 31 90 150]);
        else
            xticks([]);
        end
        
        if plotting_options.debugIncludeColorbars
            if ~plotting_options.useSingleSharedColorbar
                % Only add the subplot colorbar if we're not using the shared global one
                colorbar(); 
            end
        end
        
    end % end for loop
    
    if (plotting_options.debugIncludeColorbars && plotting_options.useSingleSharedColorbar)
        %% Plot the single large colorbar at the bottom if those options are checked
        last_subplot_position = get(gca,'Position');
        
        colorbar_h_offset = 0.01;
        desired_colorbar_position = last_subplot_position;
        desired_colorbar_position(1) = desired_colorbar_position(1) + last_subplot_position(3) + colorbar_h_offset; % Offset by its width
        desired_colorbar_position(3) = 0.758208955223879; % Width
        desired_colorbar_position(4) = 0.019511860929457; % Height
        desired_colorbar_position(2) = -desired_colorbar_position(4) + last_subplot_position(4); % y-position
                
        c = colorbar('Location','south','Position', desired_colorbar_position);

    end

    sgtitle(['cellRoi: ' num2str(curr_cellRoiIndex)]);
end