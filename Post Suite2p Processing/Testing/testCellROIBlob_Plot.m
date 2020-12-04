%% testCellROIBlob_Plot.m
% Plots the cell ROIs using the new CellRoiPlotManager class.

addpath(genpath('../helpers'));

combinedOffsetInsetIndicies = [nan, 0];
% combinedOffsetInsetIndicies = [nan, 3, 2, 1, 0, -1, -2, -3];

 if ~exist('active_selections_backingFile_path','var')
    active_selections_backingFile_path = phoPipelineOptions.default_interactionManager_backingStorePath;
 end
 
 plot_manager_cellRoiPlot = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path);
 plot_manager_cellRoiPlot.activeOffsetInsetIndicies = combinedOffsetInsetIndicies;
 plot_manager_cellRoiPlot.plotTestCellROIBlob();
 plot_manager_cellRoiPlot.updateGraphicalAppearances();
 
  

plot_manager_cellRoiPlot.pho_plot_2d(1);
plot_manager_cellRoiPlot.pho_plot_3d_mesh(1);

plot_manager_cellRoiPlot.pho_plot_stimulus_traces(1);
