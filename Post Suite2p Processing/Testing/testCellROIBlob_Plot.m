%% testCellROIBlob_Plot.m
addpath(genpath('../helpers'));

% % Build Color Matricies
% desiredSize = [512 512];
% black3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.0], desiredSize);
% darkgrey3DArray = fnBuildCDataFromConstantColor([0.3 0.3 0.3], desiredSize);
% lightgrey3DArray = fnBuildCDataFromConstantColor([0.6 0.6 0.6], desiredSize);
% 
% orange3DArray = fnBuildCDataFromConstantColor([0.9 0.3 0.1], desiredSize);
% 
% red3DArray = fnBuildCDataFromConstantColor([1.0 0.0 0.0], desiredSize);
% green3DArray = fnBuildCDataFromConstantColor([0.0 1.0 0.0], desiredSize);
% blue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 1.0], desiredSize);
% 
% darkRed3DArray = fnBuildCDataFromConstantColor([0.6 0.0 0.0], desiredSize);
% darkGreen3DArray = fnBuildCDataFromConstantColor([0.0 0.6 0.0], desiredSize);
% darkBlue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.6], desiredSize);
% 
% colorsArray = {lightgrey3DArray, darkBlue3DArray, darkGreen3DArray, darkRed3DArray, black3DArray, red3DArray, green3DArray, blue3DArray};


% combinedOffsetInsetIndicies = [nan, 0];
combinedOffsetInsetIndicies = [nan, 3, 2, 1, 0, -1, -2, -3];

 if ~exist('active_selections_backingFile_path','var')
    active_selections_backingFile_path = phoPipelineOptions.default_interactionManager_backingStorePath;
 end
 
 plot_manager_cellRoiPlot = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path);
 plot_manager_cellRoiPlot.activeOffsetInsetIndicies = combinedOffsetInsetIndicies;
 plot_manager_cellRoiPlot.plotTestCellROIBlob();
 
  




