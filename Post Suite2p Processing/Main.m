% Runs the entire pho processing pipeline:
addpath(genpath('../helpers'));

%% Options
%%% General Options:
phoPipelineOptions.default_FD_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/FDS_anm265.mat'; % If empty, user will be prompted interactively
% phoPipelineOptions.default_FD_file_path = 'Z:\ICPassiveStim\FDStructs\anm265\FDS_anm265.mat';
phoPipelineOptions.shouldShowPlots = true;
phoPipelineOptions.shouldSaveFiguresToDisk = false; % Note that this has no effect if phoPipelineOptions.shouldShowPlots is false.

phoPipelineOptions.default_interactionManager_backingStorePath = '/Users/pho/repo/phoCrossDayAlignment/Post Suite2p Processing/Testing/UAnnotations-CellROI-0.mat';

phoPipelineOptions.imageDimensions = [512 512];


% % phoPipelineOptions.ignoredCellROIs = [];
% % phoPipelineOptions.ignoredCellROI_Indicies = [3, 50, 132, 157, 116];
% phoPipelineOptions.ignoredCellROI_CompNames = {'comp4','comp123','comp625','comp677','comp480'};
% % phoPipelineOptions.ignoredCellROI_Indicies = [phoPipelineOptions.ignoredCellROI_Indicies [70, 79, 102]];
% phoPipelineOptions.ignoredCellROI_CompNames = [phoPipelineOptions.ignoredCellROI_CompNames {'comp198','comp237','comp370'}];

% find(backup.uniqueComps(strcmpi({backup.uniqueComps}, {'comp198','comp237','comp370'})))
% find(strcmpi(backup.uniqueComps, 'comp370'))
% neuropil_mask_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/exported_neuropil.mat';
% should_load_neuropil_masks = false;
% 
% if should_load_neuropil_masks
%    fprintf('Loading neuropil masks from %s...', neuropil_mask_path);
%    neuropil_masks = load(neuropil_mask_path).neuropil; 
%    fprintf('.done.\n')
% end
% Need to map each component (like 'comp674') to the neuropil in the loaded mask.


%%% PhoLoadFinalDataStruct Options:
phoPipelineOptions.PhoLoadFinalDataStruct.enable_resave = false;
phoPipelineOptions.PhoLoadFinalDataStruct.processingOptions.use_neuropil = true;
phoPipelineOptions.PhoLoadFinalDataStruct.finalDataStruct_DFF_baselineFrames = [1, 30];

%% Filtering:
phoPipelineOptions.PhoLoadFinalDataStruct.filtering.specFilePath = fullfile('../data','manualRoiFilteringResults-12_04_2020.mat');
phoPipelineOptions.loadedFilteringData = load(phoPipelineOptions.PhoLoadFinalDataStruct.filtering.specFilePath, 'manualRoiFilteringResults');
phoPipelineOptions.loadedFilteringData.curr_animal = 'anm265';


%%% PhoPostFinalDataStructAnalysis Options:
phoPipelineOptions.PhoPostFinalDataStructAnalysis.numFramesPerTrial = 150; % the trial length in number of frames
% tuning_max_threshold_criteria: the threshold value for peakDFF
phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria = 0.1;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions = true;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound = 31;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound = 60;
% phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound = 90;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.sampPeak = 2;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.frameRate = 30;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.smoothValue = 5;

phoPipelineOptions.PhoPostFinalDataStructAnalysis.should_use_neuropil_corrected_version = false;
    

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
figure(99);

% horizontal origin line:
x = [0 150];
y = [0 0];
line(x, y,'Color','black','LineStyle','-')
hold on;

startSoundFrame = phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound;
endSoundFrame = phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound;

y = [-1 1]; % the same y-values are used for both lines (as they are the same height)
% sound start/on line:
x = [startSoundFrame startSoundFrame];
line(x, y,'Color','green','LineStyle','-')
hold on;
% sound end/off line:
x = [endSoundFrame endSoundFrame];
line(x, y,'Color','red','LineStyle','-')
hold on;
plot(autoTuningDetection.detectionCurve);

    

%%% PhoTuningMeshExplorer Options:
% phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ROI Results/Figures';
phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ROI Results/Figures/New';


% phoPipelineOptions.PhoTuningMeshExplorer.should_show_neuropil_corrected_version = true;
phoPipelineOptions.PhoTuningMeshExplorer.numToCompare = 0;

% phoPipelineOptions.PhoTuningMeshExplorer.cellRoisToPlot = [];


%%% PhoBuildSpatialTuning Options:
% phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ROI Results/Figures/cellROI_General';
phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ROI Results/Figures/New';
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria = false; % If true, the cell region will be rendered with an opacity proporitional to the number of days it met the threshold critiera    
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityFilteredByInterSessionConsistencyCriteria = false; % If true, only plots cellROIs that are consistent across a specified number of the session days. 
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode = true; % If true, colorful borders are drawn around each cellROI to represent its preferred stimuli for each day.
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.edge_layering_is_outset_mode = false; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw    
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCentroidPoints = false;
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCellROILabels = false;

% phoPipelineState.indentLevelString = '';

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


%% 
% PhoPostSuite2pSessionSplitting; %% This script is used to create split sessions from the fAll.mat file output by Suite2p
PhoLoadFinalDataStruct %% If the PhoPostSuite2pSessionSplitting script has already been ran and produced a combined data struct, you can load this from disk.
PhoPostFinalDataStructAnalysis
PhoBuildSpatialTuning

fprintf('Pipeline execution complete!\n')



