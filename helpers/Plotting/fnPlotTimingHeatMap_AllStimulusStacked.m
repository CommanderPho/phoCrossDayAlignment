function [figH] = fnPlotTimingHeatMap_AllStimulusStacked(final_data_explorer_obj, curr_cellRoiIndex, plotting_options, extantFigH)
    %% fnPlotTimingHeatMap_AllStimulusStacked: Plot a heatmap where:
        % each of the trials for each of the stimuli are plotted as a single row (for a particular cellROI and stimulus): 
    if ~exist('extantFigH','var')
        figH = figure(1337 + curr_cellRoiIndex); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end
    
    clf(figH);
    
    %% 
    curr_heatMap = squeeze(final_data_explorer_obj.tracesForAllStimuli(curr_cellRoiIndex, :, :, :)); % should be [26 20 150]
%     curr_heatMap = cat(curr_heatMap, 1);
    
    curr_heatMap = reshape(curr_heatMap, (26*20), 150);
    % size(curr_heatMap) % [520 150]
%     flat_heatMap = zeros(520, 150);
%     for i = 1:size(curr_heatMap, 1)
%         flat_heatMap(i
%     end
    fnPhoMatrixPlot(curr_heatMap);
    ylabel('Stimulus x Trial Index')
    xlabel('Trial Time')
    
    sgtitle(['cellRoi: ' num2str(curr_cellRoiIndex)]);
    
end