% Can only plot a single session, such as j=1:
j = 1;
temp.currPreferredStimulusAmplitude = squeeze(outputMaps.PreferredStimulusAmplitude(j,:,:));
temp.currPreferredStimulusFrequency = squeeze(outputMaps.PreferredStimulusFreq(j,:,:));

%Preferred Stimulus Figure:
[figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, temp.currPreferredStimulusAmplitude, temp.currPreferredStimulusFrequency);
