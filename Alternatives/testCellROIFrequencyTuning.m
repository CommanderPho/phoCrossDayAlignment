% Can only plot a single session, such as j=1:
% j = 1;
% temp.currPreferredStimulusAmplitude = squeeze(outputMaps.PreferredStimulusAmplitudes(j,:,:));
% temp.currPreferredStimulusFrequency = squeeze(outputMaps.PreferredStimulusFreqs(j,:,:));
% 
% %Preferred Stimulus Figure:
% [figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, temp.currPreferredStimulusAmplitude, temp.currPreferredStimulusFrequency);



% function [figH] = fnTestStimulusTracesPlot(index)
    temp.cellRoiIndex = 5;
    temp.currAllSessionCompIndicies = final_data_explorer_obj.multiSessionCellRoi_CompListIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    [figH] = fnPlotStimulusTracesForCellROI(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, final_data_explorer_obj.uniqueStimuli, ...
        temp.currAllSessionCompIndicies, temp.cellRoiIndex, final_data_explorer_obj.traceTimebase_t, final_data_explorer_obj.redTraceLinesForAllStimuli);    
     
%     [figH] = fnPlotStimulusTracesForCellROI(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, outputs.traceTimebase_t, final_data_explorer_obj.uniqueStimuli, final_data_explorer_obj.stimuli_mapper.indexMap_StimulusLinear2AmpsFreqsArray, final_data_explorer_obj.redTraceLinesForAllStimuli);
% end