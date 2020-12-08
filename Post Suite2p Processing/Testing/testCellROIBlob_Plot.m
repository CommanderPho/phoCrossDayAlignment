%% testCellROIBlob_Plot.m
% Plots the cell ROIs using the new CellRoiPlotManager class.

addpath(genpath('../helpers'));

combinedOffsetInsetIndicies = [nan, 0];
% combinedOffsetInsetIndicies = [nan, 3, 2, 1, 0, -1, -2, -3];

 if ~exist('active_selections_backingFile_path','var')
    active_selections_backingFile_path = phoPipelineOptions.default_interactionManager_backingStorePath;
 end
 
 %% Build a new plot manager object:
 plot_manager_cellRoiPlot = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path);
 plot_manager_cellRoiPlot.activeOffsetInsetIndicies = combinedOffsetInsetIndicies;
 
%  plot_manager_cellRoiPlot.plotTestCellROIBlob();
%  plot_manager_cellRoiPlot.updateGraphicalAppearances();
%  
%  plot_manager_cellRoiPlot.interaction_helper_obj.isCellRoiSelected
  
phoPipelineOptions.shouldSaveFiguresToDisk = true;
export_extension = 'fig';
% export_extension = 'png';
        
%% Export All:
num_rois_to_plot = plot_manager_cellRoiPlot.final_data_explorer_obj.num_cellROIs;
for i = 1:num_rois_to_plot
    
    temp.currRoiName = plot_manager_cellRoiPlot.final_data_explorer_obj.cellROIIndex_mapper.getRoiNameFromUniqueCompIndex(i);
%     plot_manager_cellRoiPlot.final_data_explorer_obj.cellROIIndex_mapper.uniqueComps(
 
    fprintf('> Plotting figures for cellROI[%d/%d]: %s ...\n', i, num_rois_to_plot, temp.currRoiName);
    
    plot_manager_cellRoiPlot.pho_plot_2d(i);
    figH_2d = plot_manager_cellRoiPlot.extantFigH_plot_2d;
    
%     plot_manager_cellRoiPlot.pho_plot_3d_mesh(i);
%     figH_3dMesh = plot_manager_cellRoiPlot.extantFigH_plot_3d;

    plot_manager_cellRoiPlot.pho_plot_stimulus_traces(i);
    figH_StimulusTraces = plot_manager_cellRoiPlot.extantFigH_plot_stimulus_traces;

    %% Optional Export to disk:
    if phoPipelineOptions.shouldSaveFiguresToDisk

        %% Export plots:
        fig_name = sprintf('cellROI_%d_%s_2d.%s', i, temp.currRoiName, export_extension);
        curr_fig_export_path = fullfile(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, fig_name);
        fprintf('\t Saving to file %s ...\n', fig_name);
        savefig(figH_2d, curr_fig_export_path,'compact');
%         close(figH_2d);

        fig_name = sprintf('cellROI_%d_%s_StimulusTraces_Tuning.%s', i, temp.currRoiName, export_extension);
        curr_fig_export_path = fullfile(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, fig_name);
        fprintf('\t Saving to file %s ...\n', fig_name);
        savefig(figH_StimulusTraces, curr_fig_export_path,'compact');
%         close(figH_StimulusTraces);
    end
    
    fprintf('\t done.\n')

end