%% testCellROIBlob_TableShow.m
% 

addpath(genpath('../helpers'));

 if ~exist('plot_manager_cellRoiPlot','var')
    combinedOffsetInsetIndicies = [nan, 0];
    % combinedOffsetInsetIndicies = [nan, 3, 2, 1, 0, -1, -2, -3];
    active_selections_backingFile_path = phoPipelineOptions.default_interactionManager_backingStorePath;
    %% Build a new plot manager object:
    plot_manager_cellRoiPlot = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path);
    plot_manager_cellRoiPlot.activeOffsetInsetIndicies = combinedOffsetInsetIndicies;
 end
 
plot_manager_cellRoiPlot.setupGraphicalSelectionTable();
% plot_manager_cellRoiPlot.interaction_helper_obj.updateGraphicalSelectionTable();

   

% plot_manager_cellRoiPlot.interaction_helper_obj.GraphicalSelection.selectionCustomTableFigure.data_table.is_excluded = );
% plot_manager_cellRoiPlot.interaction_helper_obj.isCellRoiSelected;
%  
%  
%  % % Add the roiNameColumn to the table:
% % roiNameColumn = table(final_data_explorer_obj.uniqueComps,'VariableNames',{'roiName'});
% % compTable = [compTable roiNameColumn];
% 
% indexArray = 1:final_data_explorer_obj.num_cellROIs;
% data_table = table(indexArray', final_data_explorer_obj.uniqueComps, final_data_explorer_obj.cellROIIndex_mapper.compIDsArray, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies,...
%     'VariableNames',{'uniqueCompListIndex', 'roiName', 'compID', 'sessionCompListIndicies'});
% 
% % Add an index column to the table:
% isSelectedColumn = table(plot_manager_cellRoiPlot.interaction_helper_obj.isCellRoiSelected,'VariableNames',{'isCellRoiSelected'});
% data_table = [data_table isSelectedColumn];
% 
% 
% % 
% % final_data_explorer_obj.multiSessionCellRoi_CompListIndicies
% % 
% % final_data_explorer_obj.roiComputedProperties.areas
% 
% 
% % data_table = final_data_explorer_obj.cellROIIndex_mapper.compTable;
% % data_table = table(LastName,Age,Weight,Height,Smoker, ...
% %           SelfAssessedHealthStatus);
% fig = uifigure('Position',[500 500 750 350]);
% uit = uitable(fig,'Data',data_table);
% uit.Position = [20 20 710 310];
% uit.ColumnEditable = [false, false, false, false, true];
% uit.DisplayDataChangedFcn = @updatePlot;
% uit.CellEditCallback = @(src, eventdata) (selectionChangedChecked(src, eventdata, plot_manager_cellRoiPlot));


% uit.Data = data_table;

% function selectionChangedChecked(src, eventdata, plot_manager_cellRoiPlot)
%     if (eventdata.Indices(2) == 5)% check if 'isCellRoiSelected' column
%        selected_row_index = eventdata.Indices(1);
%        selected_row_updated_value = eventdata.NewData;
%        fprintf('row[%d]: isCellRoiSelected changed to %d\n', selected_row_index, selected_row_updated_value);
%        plot_manager_cellRoiPlot.interaction_helper_obj.updateCellRoiIsSelected(selected_row_index, selected_row_updated_value);
% %        tableData = src.Data;
% %        tableData{eventdata.Indices(1), eventdata.Indices(2)} = eventdata.PreviousData;
% %        src.Data = tableData;                              % set the data back to its original value
%     end
% end
% 
% 
% function updatePlot(src, event)
%     disp('updatePlot(...)')
% end

 
  





function updatePlot(src, event)
    disp('updatePlot(...)')
end

