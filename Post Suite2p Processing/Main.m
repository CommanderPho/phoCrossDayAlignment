% Runs the entire pho processing pipeline:
addpath(genpath('../helpers'));

%% Options
%%% General Options:
phoPipelineOptions.shouldShowPlots = false;
phoPipelineOptions.default_FD_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/FDS_anm265.mat'; % If empty, user will be prompted interactively
% phoPipelineOptions.default_FD_file_path = 'Z:\ICPassiveStim\FDStructs\anm265\FDS_anm265.mat';
phoPipelineOptions.shouldSaveFiguresToDisk = false; % Note that this has no effect if phoPipelineOptions.shouldShowPlots is false.

%%% PhoLoadFinalDataStruct Options:
phoPipelineOptions.PhoLoadFinalDataStruct.enable_resave = false;
phoPipelineOptions.PhoLoadFinalDataStruct.finalDataStruct_DFF_baselineFrames = [1, 30];

%%% PhoPostFinalDataStructAnalysis Options:
phoPipelineOptions.PhoPostFinalDataStructAnalysis.curr_animal = 'anm265';
% tuning_max_threshold_criteria: the threshold value for peakDFF
phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria = 0.1;

% phoPipelineState.indentLevelString = '';

%% Main
fprintf('Pho Post-Suite2p Processing Pipeline\n');
if ~phoPipelineOptions.shouldShowPlots
    fprintf('Note: Plots Disabled\n')
    if phoPipelineOptions.shouldSaveFiguresToDisk
       fprintf('\t Note: phoPipelineOptions.shouldSaveFiguresToDisk is true, but phoPipelineOptions.shouldShowPlots is false so no figures will be plotted.\n') 
    end
end


PhoLoadFinalDataStruct
PhoPostFinalDataStructAnalysis
PhoTuningMeshExplorer
PhoBuildSpatialTuning
