% Can only plot a single session, such as j=1:
j = 1;
temp.currPreferredStimulusAmplitude = squeeze(outputMaps.PreferredStimulusAmplitude(j,:,:));
temp.currPreferredStimulusFrequency = squeeze(outputMaps.PreferredStimulusFreq(j,:,:));

%Preferred Stimulus Figure:
[figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, temp.currPreferredStimulusAmplitude, temp.currPreferredStimulusFrequency);



% function [figH] = fnTestStimulusTracesPlot(index)
    temp.cellRoiIndex = 1;
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    [figH] = fnPlotStimulusTracesForCellROI(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, outputs.tbImg, outputs.uniqueStimuli, outputs.indexMap_StimulusLinear2AmpsFreqsArray, redTraceLinesForAllStimuli);
% end