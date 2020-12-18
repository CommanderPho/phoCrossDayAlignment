%% Options
%%% General Options:
phoPipelineOptions.default_FD_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/FDS_anm265.mat'; % If empty, user will be prompted interactively
% phoPipelineOptions.default_FD_file_path = 'Z:\ICPassiveStim\FDStructs\anm265\FDS_anm265.mat';
phoPipelineOptions.shouldShowPlots = false;
phoPipelineOptions.shouldSaveFiguresToDisk = false; % Note that this has no effect if phoPipelineOptions.shouldShowPlots is false.

phoPipelineOptions.default_interactionManager_backingStorePath = '/Users/pho/repo/phoCrossDayAlignment/Post Suite2p Processing/Testing/UAnnotations-CellROI-0.mat';

phoPipelineOptions.imageDimensions = [512 512];

% activeNeuropilCompensationMode: specifies which dFF curves to use.
phoPipelineOptions.ActiveNeuropilCompensationModeLabels = {'none','suite2p','fissa'};
phoPipelineOptions.ActiveNeuropilCompensationModes = categorical(phoPipelineOptions.ActiveNeuropilCompensationModeLabels);
phoPipelineOptions.activeNeuropilCompensationMode = 'fissa';



    
% Used to use: phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions
% phoPipelineOptions.PhoLoadFinalDataStruct.processingOptions.use_neuropil = true;

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


%%% PhoPostFinalDataStructAnalysis Options:
phoPipelineOptions.PhoPostFinalDataStructAnalysis.numFramesPerTrial = 150; % the trial length in number of frames
% tuning_max_threshold_criteria: the threshold value for peakDFF
phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria = 0.1;
% Use processingOptions.activeNeuropilCompensationMode instead of the old processingOptions.compute_neuropil_corrected_versions
if strcmpi(phoPipelineOptions.activeNeuropilCompensationMode, 'none')
    phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions = false;
elseif strcmpi(phoPipelineOptions.activeNeuropilCompensationMode, 'suite2p')
    phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions = true;
elseif strcmpi(phoPipelineOptions.activeNeuropilCompensationMode, 'fissa')
    phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions = true;
else
    error('Invalid neuropil mode!')
end
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound = 31;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound = 60;
% phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound = 90;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.sampPeak = 2;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.frameRate = 30;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.smoothValue = 5;

phoPipelineOptions.PhoPostFinalDataStructAnalysis.should_use_neuropil_corrected_version = false;
    
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


phoPipelineOptions.fissa.load_fissa_data_and_update_FDS = false;
phoPipelineOptions.fissa.included_cellROIs_only = false;
phoPipelineOptions.fissa.default_fissa_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/fissa_suite2p_example/experiment_matlab.mat';


[phoPipelineOptions] = fnLoadFilteringData(phoPipelineOptions);
