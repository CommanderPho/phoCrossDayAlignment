function [pipelineInteractionObject] = fnInteractiveMainPipelineGui(phoPipelineOptions)
    %% Main Status Widget:


    pipelineInteractionObject = PipelineInteractionState.getInstance(phoPipelineOptions);

    pipelineCallbacks = {};
    % pipelineCallbacks{end+1} = @(anObj, currIndex) fprintf('PipelineA stage %d execution complete!\n', anObj.pipelineCurrentStage);
    % pipelineCallbacks{end+1} = @(anObj, currIndex) fprintf('PipelineB stage %d execution complete!\n', anObj.pipelineCurrentStage);
    % pipelineCallbacks{end+1} = @(anObj, currIndex) fprintf('PipelineC stage %d execution complete!\n', anObj.pipelineCurrentStage);
    % pipelineCallbacks{end+1} = @(anObj, currIndex) fprintf('PipelineD stage %d execution complete!\n', anObj.pipelineCurrentStage);


    % pipelineCallbacks{end+1} = @(anObj, currIndex) PhoLoadFinalDataStruct;
    % pipelineCallbacks{end+1} = @(anObj, currIndex) PhoPostFinalDataStructAnalysis;
    % pipelineCallbacks{end+1} = @(anObj, currIndex) PhoBuildSpatialTuning;
    % pipelineCallbacks{end+1} = @(anObj, currIndex) fprintf('Pipeline stage %d execution complete!\n', anObj.pipelineCurrentStage);


    pipelineCallbacks{end+1} = @(anObj, currIndex) evalin('base','PhoLoadFinalDataStruct');
    pipelineCallbacks{end+1} = @(anObj, currIndex) evalin('base','PhoPostFinalDataStructAnalysis');
    pipelineCallbacks{end+1} = @(anObj, currIndex) evalin('base','PhoBuildSpatialTuning');
    pipelineCallbacks{end+1} = @(anObj, currIndex) fprintf('Pipeline stage %d execution complete!\n', anObj.pipelineCurrentStage);


    % pipelineCallbacks{end+1} = @(obj) PhoLoadFinalDataStruct();
    % pipelineCallbacks{end+1} = @(obj) PhoPostFinalDataStructAnalysis();
    % pipelineCallbacks{end+1} = @(obj) PhoBuildSpatialTuning();
    % pipelineCallbacks{end+1} = @(obj) fprintf('Pipeline execution complete!\n');


    % pipelineInteractionObject.SetupPipeline({ 'PhoLoadFinalDataStruct', 'PhoPostFinalDataStructAnalysis', 'PhoBuildSpatialTuning', 'Finished' }, ...
    %     { @() PhoLoadFinalDataStruct, @() PhoPostFinalDataStructAnalysis, @() PhoBuildSpatialTuning, @() fprintf('Pipeline execution complete!\n')});

    pipelineInteractionObject.SetupPipeline({ 'PhoLoadFinalDataStruct', 'PhoPostFinalDataStructAnalysis', 'PhoBuildSpatialTuning', 'Finished' }, pipelineCallbacks);

    % [finalDataStruct, activeSessionList, activeCompList] = fnPhoLoadFinalDataStruct(finalDataStruct, phoPipelineOptions);


    % pipelineInteractionObject.SetupUI();
    % pipelineInteractionObject.startStage(1);

    % [figObjTest] = fnMakeMainWindow();

    % close(figObj);

    % valid_only_quality = phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_quality_of_tuning;
    % valid_only_quality(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded) = []; % remove the excluded entries.
    % 
    % [figObj] = fnPhoControllerSlider(figObj, valid_only_quality');

end
