function [figH] = fnPlotTimingHeatMap_EachStimulusSeparately(final_data_explorer_obj, curr_cellRoiIndex, extantFigH)
    %% fnPlotTimingHeatMap_EachStimulusSeparately: Plot a heatmap where:
        % (for a particular cellROI and stimulus)
        % There are numStimuli vertically stacked subplots, each containing their trials represented as rows.
    
       
    % Options for tightening up the subplots:
    plotting_options.should_use_custom_subplots = true;
    
    if plotting_options.should_use_custom_subplots
        plotting_options.subtightplot.gap = [0.01/26 0.1]; % [intra_graph_vertical_spacing, intra_graph_horizontal_spacing]
        plotting_options.subtightplot.width_h = [0.01 0.05]; % Looks like [padding_bottom, padding_top]
        plotting_options.subtightplot.width_w = [0.12 0.01];
        plotting_options.opt = {plotting_options.subtightplot.gap, plotting_options.subtightplot.width_h, plotting_options.subtightplot.width_w}; % {gap, width_h, width_w}
        subplot_cmd = @(m,n,p) subtightplot(m, n, p, plotting_options.opt{:});
%         SetupCustomSubplots
    else
        subplot_cmd = @(m,n,p) subplot(m, n, p);
    end
    
    
    
    if ~exist('extantFigH','var')
        figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end
    
    clf(figH);
    
    plotting_options.useGlobalColorLims = true;
    
    curr_cellROI_heatMap = squeeze(final_data_explorer_obj.active_DFF.TracesForAllStimuli.imgDataToPlot(curr_cellRoiIndex, :, :, :)); % should be [26 20 150]
    
    
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

        subplot_cmd(final_data_explorer_obj.stimuli_mapper.numStimuli, 1, stimulusIndex);

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
    %     title('test heat map')
        yticks([]);
        
        activeStr = [final_data_explorer_obj.stimuli_mapper.getFormattedString_Depth(depthValue) ' ' final_data_explorer_obj.stimuli_mapper.getFormattedString_Freq(freqValue)];
%         activeStr = sprintf('%d, %d Hz', depthValue, freqValue);
        
%         t_currLabelH = ylabel({sprintf('stim[%d]', stimulusIndex), activeStr});
        t_currLabelH = ylabel([sprintf('stim[%d] ', stimulusIndex), activeStr]);
        set(t_currLabelH, 'Rotation', 0, 'VerticalAlignment', 'middle', 'HorizontalAlignment','right'); % 'right' horizontal alignment will position it in the far left margin
        temp_currTextPosition = get(t_currLabelH, 'Position');
%         temp_currTextPosition(1) = 0;
        % Update text position
%         set(t_currLabelH, 'Position', temp_currTextPosition);
        
        is_last_stimulus = (final_data_explorer_obj.stimuli_mapper.numStimuli == stimulusIndex);
        if is_last_stimulus
            xticks([0 31 90 150]);
        else
            xticks([]);
        end
    end % end for loop

    sgtitle(['cellRoi: ' num2str(curr_cellRoiIndex)]);
end