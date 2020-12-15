function [pipelineInteractionObject] = fnInteractiveMainPipelineGui(phoPipelineOptions)
    %% fnInteractiveMainPipelineGui: Renders and interactive pipeline GUI that shows the current execution step    
    pipelineInteractionObject = PipelineInteractionState.getInstance(phoPipelineOptions);

    pipelineCallbacks = {};
    pipelineCallbacks{end+1} = @(anObj, currIndex) evalin('base','PhoLoadFinalDataStruct');
    pipelineCallbacks{end+1} = @(anObj, currIndex) evalin('base','PhoPostFinalDataStructAnalysis');
    pipelineCallbacks{end+1} = @(anObj, currIndex) evalin('base','PhoBuildSpatialTuning');
    pipelineCallbacks{end+1} = @(anObj, currIndex) fprintf('Pipeline stage %d execution complete!\n', anObj.pipelineCurrentStage);
    pipelineInteractionObject.SetupPipeline({ 'PhoLoadFinalDataStruct', 'PhoPostFinalDataStructAnalysis', 'PhoBuildSpatialTuning', 'Finished' }, pipelineCallbacks);
    
    
end
