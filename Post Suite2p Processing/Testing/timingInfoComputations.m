



% final_data_explorer_obj.traceTimebase_t
% final_data_explorer_obj.active_DFF.TracesForAllStimuli
% final_data_explorer_obj.redTraceLinesForAllStimuli
% final_data_explorer_obj.multiSessionCellRoi_CompListIndicies 

% size(final_data_explorer_obj.tracesForAllStimuli) % [159    26    20   150]

% Compute all-trials maximums:
[maxVals, maxInds] = max(final_data_explorer_obj.tracesForAllStimuli,[], 4); % get max of current signal only within the startSound:endSound range
size(maxVals) % [159    26    20]


cellROIIndex = 5;
% figure(1337)


%% Plot a heatmap where each of the 20 trials is a row (for a particular cellROI and stimulus):
% curr_heatMap = squeeze(final_data_explorer_obj.tracesForAllStimuli(cellROIIndex, :, :, :)); % should be [26 20 150]
% curr_heatMap = reshape(curr_heatMap, (26*20), 150);
% % size(curr_heatMap) % [520 150]
% fnPhoMatrixPlot(curr_heatMap');

[outputs] = fnPlotTimingHeatMap_AllStimulusStacked(final_data_explorer_obj, cellROIIndex);
% [outputs] = fnPlotTimingHeatMap_EachStimulusSeparately(final_data_explorer_obj, cellROIIndex);

% %% Loop through all stimuli:
% for stimulusIndex = 1:final_data_explorer_obj.stimuli_mapper.numStimuli
%         
% %     curr_maxVals = squeeze(maxVals(cellROIIndex, stimulusIndex, :));
% %     curr_maxInds = squeeze(maxInds(cellROIIndex, stimulusIndex, :));
% 
%     subplot(final_data_explorer_obj.stimuli_mapper.numStimuli, 1, stimulusIndex);
% 
%     %% Plot a heatmap where each of the 20 trials is a row (for a particular cellROI and stimulus):
%     curr_heatMap = squeeze(final_data_explorer_obj.tracesForAllStimuli(cellROIIndex, stimulusIndex, :, :)); % should be [20 150]
% %     size(curr_heatMap)
%     fnPhoMatrixPlot(curr_heatMap');
% %     title('test heat map')
%     
%     yticks([]);
%     ylabel(sprintf('stim[%d]', stimulusIndex));
%     
%     is_last_stimulus = (final_data_explorer_obj.stimuli_mapper.numStimuli == stimulusIndex);
%     if is_last_stimulus
%         xticks([0 31 90 150]);
%     else
%         xticks([]);
%     end
% end

% outputs.TracesForAllStimuli.imgDataToPlot = zeros([outputs.numStimuli, outputs.numStimulusPairTrialRepetitionsPerSession, outputs.numFramesPerTrial]); % raw traces






% 
% function [figH] = fnPlotCallbackWrapper(final_data_explorer_obj, cellRoiIndex, plotFunction, extantFigH)
%     if ~exist('extantFigH','var')
%         figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
%     else
%         figH = extantFigH; % use the existing provided figure    
%         figure(figH);
%     end
%     
%     clf(figH);
%     plotFunction();
%     
% end