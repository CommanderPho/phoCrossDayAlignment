% Runs the entire pho processing pipeline:
addpath(genpath('../helpers'));

%% Options
%%% General Options:
phoPipelineOptions.default_FD_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/FDS_anm265.mat'; % If empty, user will be prompted interactively
% phoPipelineOptions.default_FD_file_path = 'Z:\ICPassiveStim\FDStructs\anm265\FDS_anm265.mat';
phoPipelineOptions.shouldShowPlots = true;
phoPipelineOptions.shouldSaveFiguresToDisk = false; % Note that this has no effect if phoPipelineOptions.shouldShowPlots is false.

%%% PhoLoadFinalDataStruct Options:
phoPipelineOptions.PhoLoadFinalDataStruct.enable_resave = false;
phoPipelineOptions.PhoLoadFinalDataStruct.processingOptions.use_neuropil = true;
phoPipelineOptions.PhoLoadFinalDataStruct.finalDataStruct_DFF_baselineFrames = [1, 30];

%%% PhoPostFinalDataStructAnalysis Options:
phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal = 'anm265';
% tuning_max_threshold_criteria: the threshold value for peakDFF
phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria = 0.1;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.compute_neuropil_corrected_versions = true;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.startSound=31;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.endSound=90;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.sampPeak = 2;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.frameRate=30;
phoPipelineOptions.PhoPostFinalDataStructAnalysis.processingOptions.smoothValue = 5;
    
    
%%% PhoTuningMeshExplorer Options:
phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ROI Results/Figures';
phoPipelineOptions.PhoTuningMeshExplorer.should_show_neuropil_corrected_version = true;
phoPipelineOptions.PhoTuningMeshExplorer.numToCompare = 0;

% phoPipelineOptions.PhoTuningMeshExplorer.cellRoisToPlot = [];


%%% PhoBuildSpatialTuning Options:
phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ROI Results/Figures/cellROI_General';
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria = false; % If true, the cell region will be rendered with an opacity proporitional to the number of days it met the threshold critiera    
phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode = false; % If true, colorful borders are drawn around each cellROI to represent its preferred stimuli for each day.
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

%% 
% PhoPostSuite2pSessionSplitting; %% This script is used to create split sessions from the fAll.mat file output by Suite2p
PhoLoadFinalDataStruct %% If the PhoPostSuite2pSessionSplitting script has already been ran and produced a combined data struct, you can load this from disk.
PhoPostFinalDataStructAnalysis
PhoTuningMeshExplorer
PhoBuildSpatialTuning

fprintf('Pipeline execution complete!\n')
