% Can only plot a single session, such as j=1:
j = 1;
temp.currPreferredStimulusAmplitude = squeeze(outputMaps.PreferredStimulusAmplitude(j,:,:));
temp.currPreferredStimulusFrequency = squeeze(outputMaps.PreferredStimulusFreq(j,:,:));

%Preferred Stimulus Figure:
[figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, temp.currPreferredStimulusAmplitude, temp.currPreferredStimulusFrequency);



% function [figH] = fnTestStimulusTracesPlot(index)
    temp.cellRoiIndex = 5;
    temp.currAllSessionCompIndicies = final_data_explorer_obj.multiSessionCellRoi_CompListIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    [figH] = fnPlotStimulusTracesForCellROI(final_data_explorer_obj.dateStrings, final_data_explorer_obj.uniqueAmps, final_data_explorer_obj.uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, outputs.tbImg, final_data_explorer_obj.uniqueStimuli, final_data_explorer_obj.stimuli_mapper.indexMap_StimulusLinear2AmpsFreqsArray, final_data_explorer_obj.redTraceLinesForAllStimuli);
% end