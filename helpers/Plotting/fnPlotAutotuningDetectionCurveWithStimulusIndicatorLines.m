function [h] = fnPlotAutotuningDetectionCurveWithStimulusIndicatorLines(autoTuningDetection)
    %fnPlotAutotuningDetectionCurveWithStimulusIndicatorLines Plots a 2D matrix of unnormalized data.
    %   data should be an autoTuningDetection struct with the appropriate properties.
    figure(99);

    startSoundFrame = autoTuningDetection.period.during.startIndex;
    endSoundFrame = autoTuningDetection.period.during.endIndex;

    y = [-1 1]; % the same y-values are used for both lines (as they are the same height)
    [h] = fnAddStimulusStartStopIndicatorLines(autoTuningDetection.period.post.endIndex, startSoundFrame, endSoundFrame, y);
    
    % Plot the actual curve:
    h = plot(autoTuningDetection.detectionCurve);
    title('Autotuning Detection Curve')
end

