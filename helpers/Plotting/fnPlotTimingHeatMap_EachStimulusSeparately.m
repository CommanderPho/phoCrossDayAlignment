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
    
    
    %% Loop through all stimuli:
    for stimulusIndex = 1:final_data_explorer_obj.stimuli_mapper.numStimuli

    %     curr_maxVals = squeeze(maxVals(cellROIIndex, stimulusIndex, :));
    %     curr_maxInds = squeeze(maxInds(cellROIIndex, stimulusIndex, :));

        subplot(final_data_explorer_obj.stimuli_mapper.numStimuli, 1, stimulusIndex);

        %% Plot a heatmap where each of the 20 trials is a row (for a particular cellROI and stimulus):
        curr_heatMap = squeeze(final_data_explorer_obj.active_DFF.TracesForAllStimuli.imgDataToPlot(curr_cellRoiIndex, stimulusIndex, :, :)); % should be [20 150]
    %     size(curr_heatMap)
        fnPhoMatrixPlot(curr_heatMap');
    %     title('test heat map')

        yticks([]);
        ylabel(sprintf('stim[%d]', stimulusIndex));

        is_last_stimulus = (final_data_explorer_obj.stimuli_mapper.numStimuli == stimulusIndex);
        if is_last_stimulus
            xticks([0 31 90 150]);
        else
            xticks([]);
        end
    end % end for loop

%     outputs.heatmap_h = fnPhoMatrixPlot(curr_heatMap');
    sgtitle(['cellRoi: ' num2str(curr_cellRoiIndex)]);
end