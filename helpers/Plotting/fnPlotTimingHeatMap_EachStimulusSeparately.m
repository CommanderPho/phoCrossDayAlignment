function [figH] = fnPlotTimingHeatMap_EachStimulusSeparately(final_data_explorer_obj, curr_cellRoiIndex, extantFigH)
    %% fnPlotTimingHeatMap_EachStimulusSeparately: Plot a heatmap where:
        % (for a particular cellROI and stimulus)
        % There are numStimuli vertically stacked subplots, each containing their trials represented as rows.
    
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
        [depthIndex, freqIndex, depthValue, freqValue] = final_data_explorer_obj.stimuli_mapper.getDepthFreqIndicies(stimulusIndex);
        
    %     curr_maxVals = squeeze(maxVals(cellROIIndex, stimulusIndex, :));
    %     curr_maxInds = squeeze(maxInds(cellROIIndex, stimulusIndex, :));

        subplot(final_data_explorer_obj.stimuli_mapper.numStimuli, 1, stimulusIndex);

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
        ylabel({sprintf('stim[%d]', stimulusIndex), sprintf('%d, %d Hz', depthValue, freqValue)});

        is_last_stimulus = (final_data_explorer_obj.stimuli_mapper.numStimuli == stimulusIndex);
        if is_last_stimulus
            xticks([0 31 90 150]);
        else
            xticks([]);
        end
    end % end for loop

    sgtitle(['cellRoi: ' num2str(curr_cellRoiIndex)]);
end