%% 12-04-2020 by Pho Hale
% Manually went through all the cellROIs and excluded ones that didn't look right based on their tuning curves.
% For those that did look potentially real, I gave them a qualitative rank on a scale of 1-10 called the 'final_quality_of_tuning'.
% This was done using the plotting helpers I wrote in MATLAB, but the data was entered in the Google Sheet here:
%% https://docs.google.com/spreadsheets/d/1Id0rZAU6EgUj_6t3351eWmhV1BRJSG5U559Okjb_05k/edit?usp=sharing

% From that Google Sheet, I manually copied and pasted the results into new variables that I created using the MATLAB GUI:
%   final_is_Excluded
%   final_quality_of_tuning


% omit_list = [4 5 7 9 10 13 18 20 21 22 24 28];
% % plot_manager_cellRoiPlot.interaction_helper_obj.GraphicalSelection.selectionCustomTableFigure.data_table.
% table_rows = height(plot_manager_cellRoiPlot.interaction_helper_obj.GraphicalSelection.selectionCustomTableFigure.data_table);
% new_is_excluded = logical(zeros(table_rows, 1));
% new_is_excluded(omit_list) = true;
% 
% omit_compIDs = plot_manager_cellRoiPlot.interaction_helper_obj.GraphicalSelection.selectionCustomTableFigure.data_table.compID(omit_list);
% omit_roiNames = plot_manager_cellRoiPlot.interaction_helper_obj.GraphicalSelection.selectionCustomTableFigure.data_table.roiName(omit_list);
% 
% is_excluded_table = table(new_is_excluded);
% 
% debug_table = [plot_manager_cellRoiPlot.interaction_helper_obj.GraphicalSelection.selectionCustomTableFigure.data_table, is_excluded_table]; 



manualRoiFilteringResults.final_is_Excluded = logical(final_is_Excluded);
manualRoiFilteringResults.final_quality_of_tuning = final_quality_of_tuning;

indexArray = 1:num_cellROIs;
manualRoiFilteringResults.data_table = table(indexArray', final_data_explorer_obj.uniqueComps, final_data_explorer_obj.cellROIIndex_mapper.compIDsArray, final_data_explorer_obj.multiSessionCellRoi_CompListIndicies,...
		manualRoiFilteringResults.final_is_Excluded, manualRoiFilteringResults.final_quality_of_tuning, ...
        'VariableNames',{'uniqueCompListIndex', 'roiName', 'compID', 'sessionCompListIndicies', 'isManuallyExcluded', 'manuallyAssignedQualityOfTuning'});
            
manualRoiFilteringResults.excluded_comp_names = manualRoiFilteringResults.data_table.roiName(manualRoiFilteringResults.final_is_Excluded);
manualRoiFilteringResults.included_comp_names = manualRoiFilteringResults.data_table.roiName(~manualRoiFilteringResults.final_is_Excluded);

% included_comp_names:
% {'comp2','comp5','comp6','comp12','comp20','comp28','comp29','comp33','comp34','comp35','comp41','comp45','comp53','comp65','comp66','comp73','comp78','comp80','comp84','comp85','comp88','comp106','comp111','comp134','comp136','comp141','comp152','comp161','comp166','comp169','comp174','comp193','comp233','comp243','comp253','comp258','comp259','comp269','comp291','comp296','comp307','comp337','comp359','comp429','comp452','comp492','comp501','comp504','comp516','comp522','comp551','comp561','comp563'}

% excluded_comp_names:
% {'comp7','comp11','comp16','comp22','comp27','comp30','comp44','comp47','comp49','comp51','comp64','comp74','comp91','comp92','comp116','comp123','comp126','comp129','comp151','comp176','comp177','comp191','comp195','comp201','comp208','comp260','comp264','comp284','comp580'}

% final_quality_of_tuning:
% [4,8,4,0,0,2,0,9,0,0,6,8,0,6,7,8,7,0,6,0,0,0,9,0,3,6,3,0,9,7,6,5,8,0,0,7,8,0,0,0,0,4,5,10,0,2,3,5,8,2,0,0,0,5,0,0,0,2,6,6,8,4,0,0,4,0,5,7,8,8,4,5,6,7,6,7,5,5,5,7,7,0]

% final_is_excluded:
% [false,false,false,true,true,false,true,false,true,true,false,false,true,false,false,false,false,true,false,true,true,true,false,true,false,false,false,true,false,false,false,false,false,true,true,false,false,true,true,true,true,false,false,false,true,false,false,false,false,false,true,true,true,false,true,true,true,false,false,false,false,false,true,true,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true]

