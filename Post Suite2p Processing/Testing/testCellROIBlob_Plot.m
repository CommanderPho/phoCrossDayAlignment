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
% export_extension = 'fig';
% export_extension = 'png';
export_extension = 'pdf';
        
%% Export All:
set(groot, 'DefaultFigureVisible', 'off');
num_rois_to_plot = plot_manager_cellRoiPlot.final_data_explorer_obj.num_cellROIs;
for i = 1:num_rois_to_plot
    
    temp.currRoiName = plot_manager_cellRoiPlot.final_data_explorer_obj.cellROIIndex_mapper.getRoiNameFromUniqueCompIndex(i);
%     plot_manager_cellRoiPlot.final_data_explorer_obj.cellROIIndex_mapper.uniqueComps(
 
    fprintf('> Plotting figures for cellROI[%d/%d]: %s ...\n', i, num_rois_to_plot, temp.currRoiName);
    fprintf('\t \t figures will be saved out to %s \n', phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path);
%     plot_manager_cellRoiPlot.pho_plot_2d(i);
%     figH_2d = plot_manager_cellRoiPlot.extantFigH_plot_2d;
    
%     plot_manager_cellRoiPlot.pho_plot_3d_mesh(i);
%     figH_3dMesh = plot_manager_cellRoiPlot.extantFigH_plot_3d;

    plot_manager_cellRoiPlot.pho_plot_stimulus_traces(i);
    figH_StimulusTraces = plot_manager_cellRoiPlot.extantFigH_plot_stimulus_traces;

    plot_manager_cellRoiPlot.pho_plot_timing_heatmaps(i);
    figH_StimulusHeatmaps = plot_manager_cellRoiPlot.extantFigH_plot_heatmap_traces;
    
    
    %% Optional Export to disk:
    if phoPipelineOptions.shouldSaveFiguresToDisk

        %% Export plots:
        if exist('figH_2d','var')
            fig_name = sprintf('cellROI_%d_%s_2d.%s', i, temp.currRoiName, export_extension);
            [~] = performExportFigure(figH_2d, fig_name, export_extension, phoPipelineOptions);
            %         close(figH_2d);
        end
        
        fig_name = sprintf('cellROI_%d_%s_StimulusTraces_Tuning.%s', i, temp.currRoiName, export_extension);
        [~] = performExportFigure(figH_StimulusTraces, fig_name, export_extension, phoPipelineOptions);
        
%         curr_fig_export_path = fullfile(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, fig_name);
%         fprintf('\t Saving to file %s ...\n', fig_name);
%         savefig(figH_StimulusTraces, curr_fig_export_path,'compact');
%         close(figH_StimulusTraces);

        fig_name = sprintf('cellROI_%d_%s_StimulusTraces_Heatmaps.%s', i, temp.currRoiName, export_extension);
        [~] = performExportFigure(figH_StimulusHeatmaps, fig_name, export_extension, phoPipelineOptions);
        
    end
    
    fprintf('\t done.\n')
    set(groot, 'DefaultFigureVisible', 'on');
    

    
end


function [curr_fig_export_path] = performExportFigure(figH, fig_name, export_extension, phoPipelineOptions)
        % Add the toolbar for selection operations:
    curr_fig_export_path = fullfile(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, fig_name);
    fprintf('\t Saving to file %s ...\n', fig_name);
    if strcmpi(export_extension, 'fig')
        savefig(figH, curr_fig_export_path, 'compact');
    else
%         exportgraphics(figH, curr_fig_export_path);
        exportgraphics(figH, curr_fig_export_path,'BackgroundColor','none','ContentType','vector');
        
    end
     
end
