function [phoPipelineOptions] = fnLoadFilteringData(phoPipelineOptions)
    % fnLoadFilteringData: called to load the filtering data from the .mat file, and updates phoPipelineOptions.loadedFilteringData with the results
    phoPipelineOptions.loadedFilteringData = load(phoPipelineOptions.PhoLoadFinalDataStruct.filtering.specFilePath, 'manualRoiFilteringResults');
    phoPipelineOptions.loadedFilteringData.curr_animal = 'anm265';
end