%% Not yet implemented
%% 12-08-2020 by Pho Hale

% [hPropsPane, phoPipelineOptions] = propertiesGUI(0, phoPipelineOptions);

%% Main Status Widget:
[figObj] = fnMakeMainWindow();



% close(figObj);



valid_only_quality = phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_quality_of_tuning;
valid_only_quality(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded) = []; % remove the excluded entries.

[figObj] = fnPhoControllerSlider(figObj, valid_only_quality');



