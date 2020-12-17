addpath(genpath('helpers'));
addpath(genpath('Interactive'));
addpath(genpath('Pre-Suite2p Alignment'));
addpath(genpath('Post Suite2p Processing'));


use_interactive_pipeline_gui = true;

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

