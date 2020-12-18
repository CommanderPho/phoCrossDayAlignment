% Runs the entire pho processing pipeline:
addpath(genpath('../helpers'));
addpath(genpath('../data'));

PhoPipelineOptions; % Get the pipeline options

%% Build Autotuning Detection:
autoTuningDetection.period.pre.startIndex = 1;
autoTuningDetection.period.pre.endIndex = phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound - 1;

autoTuningDetection.period.during.startIndex = phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound;
autoTuningDetection.period.during.endIndex = phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound;

autoTuningDetection.period.post.startIndex = autoTuningDetection.period.during.endIndex + 1;
autoTuningDetection.period.post.endIndex = phoPipelineOptions.PhoPostFinalDataStructAnalysis.numFramesPerTrial;

detectionCurvePath = '../data/detection_curve.mat';
% save(detectionCurvePath, 'detectionCurve');
temp.S = load(detectionCurvePath, 'detectionCurve');
autoTuningDetection.detectionCurve = temp.S.detectionCurve;

%% Plot the detectionCurve with the stimulus indicator lines:
% fnPlotAutotuningDetectionCurveWithStimulusIndicatorLines(autoTuningDetection)

%% Main
fprintf('Pho Post-Suite2p Processing Pipeline\n');
if ~phoPipelineOptions.shouldShowPlots
    fprintf('Note: Plots Disabled\n')
    if phoPipelineOptions.shouldSaveFiguresToDisk
       fprintf('\t Note: phoPipelineOptions.shouldSaveFiguresToDisk is true, but phoPipelineOptions.shouldShowPlots is false so no figures will be plotted.\n') 
    end
end


% [hPropsPane, phoPipelineOptions] = propertiesGUI(0, phoPipelineOptions);
% 
% %% Main Status Widget:
% [figObj] = fnMakeMainWindow();


use_interactive_pipeline_gui = false;

if use_interactive_pipeline_gui
    if ~exist('pipelineInteractionObject','var')
       clear pipelineInteractionObject; 
    end
    [pipelineInteractionObject] = fnInteractiveMainPipelineGui(phoPipelineOptions);
    
else
    %% 
    % PhoPostSuite2pSessionSplitting; %% This script is used to create split sessions from the fAll.mat file output by Suite2p
    PhoLoadFinalDataStruct %% If the PhoPostSuite2pSessionSplitting script has already been ran and produced a combined data struct, you can load this from disk.
    PhoPostFinalDataStructAnalysis
    PhoBuildSpatialTuning
end



fprintf('Pipeline execution complete!\n')