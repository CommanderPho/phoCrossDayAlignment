classdef InteractionHelper < handle
    %InteractionHelper Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        final_data_explorer_obj % FinalDataExplorer

        %% Selection
        isCellRoiSelected
        
        %% Annotation/Backing Store
        AnnotatingUser
        BackingFile
        
		selectionOptions
        %% Graphical (TODO: potentially refactor)
        GraphicalSelection
		Colors
		graphical_update_callback %% Stores the callback to update the graphics after a toolbar item is clicked or other UX input
        
    end
    
    methods %% Setters Method Block
       function obj = set.final_data_explorer_obj(obj, value)
           obj.final_data_explorer_obj = value;
           % When the final_data_explorer_obj is set, rebuild the variables.
           obj.isCellRoiSelected = zeros([obj.final_data_explorer_obj.num_cellROIs 1], 'logical');
           
       end  

    end % end setters method block

    %% Computed Properties:
    properties (Dependent)
        num_cellROIs
        num_selectedCellROIs
        selected_cellROI_uniqueCompListIndicies
        selected_cellROI_roiNames
    end
    
    methods
       function num_cellROIs = get.num_cellROIs(obj)
          num_cellROIs = obj.final_data_explorer_obj.num_cellROIs;
       end
       function num_selectedCellROIs = get.num_selectedCellROIs(obj)
          num_selectedCellROIs = sum(obj.isCellRoiSelected, 'all');
       end
       function selected_cellROI_uniqueCompListIndicies = get.selected_cellROI_uniqueCompListIndicies(obj)
          selected_cellROI_uniqueCompListIndicies = find(obj.isCellRoiSelected);
       end
       function selected_cellROI_roiNames = get.selected_cellROI_roiNames(obj)
          selected_cellROI_roiNames = obj.final_data_explorer_obj.cellROIIndex_mapper.getRoiNameFromUniqueCompIndex(obj.selected_cellROI_uniqueCompListIndicies);
       end
    end
    
    %% Main Methods Block:
    methods
        function obj = InteractionHelper(final_data_explorer_obj, annotatingUser, backingFilePath)
            %InteractionHelper Construct an instance of this class
            %   Detailed explanation goes here
            obj.final_data_explorer_obj = final_data_explorer_obj;
            
            if ~exist('annotatingUser','var')
                annotatingUser = 'Anonymous';
            end  
            obj.AnnotatingUser = annotatingUser;
            if (~exist('backingFilePath','var') || isempty(backingFilePath))
				[filename, path, ~] = uiputfile('*.mat','User CellROI Annotations Backing File',['UAnnotations-CellROI-', '0', '.mat']);
				if isequal(filename,0) || isequal(path,0)
				   error('User clicked Cancel.')
                end
				backingFilePath = fullfile(path,filename);
            end
            % Setup backing file
			obj.BackingFile.fullPath = backingFilePath;
			obj.BackingFile.hasBackingFile = false;
            obj.BackingFile.shouldAutosaveToBackingFile = true;
            obj.tryOpenBackingFile();
			
        end

        %% Selection Methods:
        function [obj, newIsSelected] = toggleCellRoiIsSelected(obj, uniqueCompListIndex)
            %toggleCellRoiIsSelected Summary of this method goes here
            %   uniqueCompListIndex: cellROI to update selection status of
            newIsSelected = ~obj.isCellRoiSelected(uniqueCompListIndex);
            obj.updateCellRoiIsSelected(uniqueCompListIndex, newIsSelected);
        end
        
        function obj = updateCellRoiIsSelected(obj, uniqueCompListIndex, newIsSelected)
            %updateCellRoiIsSelected Summary of this method goes here
            %   uniqueCompListIndex: cellROI to update selection status of
            %   newIsSelected: new selection status
            obj.isCellRoiSelected(uniqueCompListIndex) = newIsSelected;
        end
 
    end %% end methods
    

    %% UX Methods Block:
    methods 

		function obj = setupGraphicalSelectionTable(obj, graphical_update_callback)
			if exist('graphical_update_callback','var')
                obj.graphical_update_callback = graphical_update_callback;
			end

			indexArray = 1:obj.num_cellROIs;
			obj.GraphicalSelection.selectionCustomTableFigure.data_table = table(indexArray', obj.final_data_explorer_obj.uniqueComps, obj.final_data_explorer_obj.cellROIIndex_mapper.compIDsArray, obj.final_data_explorer_obj.multiSessionCellRoi_CompListIndicies,...
				'VariableNames',{'uniqueCompListIndex', 'roiName', 'compID', 'sessionCompListIndicies'});

			% Add an index column to the table:
			isSelectedColumn = table(obj.isCellRoiSelected,'VariableNames',{'isCellRoiSelected'});
			obj.GraphicalSelection.selectionCustomTableFigure.data_table = [obj.GraphicalSelection.selectionCustomTableFigure.data_table isSelectedColumn];


			valueset = repmat({'unknown'}, obj.num_cellROIs, 1);
			cnames = categorical(valueset, {'inhibitory','unknown','excitatory'});
			excitatoryInhibitoryTypeColumn = table(cnames,'VariableNames',{'excitatoryInhibitoryType'});
			obj.GraphicalSelection.selectionCustomTableFigure.data_table = [obj.GraphicalSelection.selectionCustomTableFigure.data_table excitatoryInhibitoryTypeColumn];

            
            valueset = repmat({'unknown'}, obj.num_cellROIs, 1);
			cnames = categorical(valueset, {'on','other','off','unknown'});
			stimulusLockingTypeColumn = table(cnames,'VariableNames',{'stimulusLocking'});
			obj.GraphicalSelection.selectionCustomTableFigure.data_table = [obj.GraphicalSelection.selectionCustomTableFigure.data_table stimulusLockingTypeColumn];

            % valueset = repmat({'unknown'}, obj.num_cellROIs, 1);
			% cnames = categorical(valueset, {'on','other','off','unknown'});
			% stimulusLockingTypeColumn = table(cnames,'VariableNames',{'stimulusLocking'});
			% obj.GraphicalSelection.selectionCustomTableFigure.data_table = [obj.GraphicalSelection.selectionCustomTableFigure.data_table stimulusLockingTypeColumn];

			tuning_array = zeros([obj.num_cellROIs, 1]);
			stimulusStrongestTuningTypeColumn = table(tuning_array,'VariableNames',{'strongestStimuliTuning'});
			obj.GraphicalSelection.selectionCustomTableFigure.data_table = [obj.GraphicalSelection.selectionCustomTableFigure.data_table stimulusStrongestTuningTypeColumn];

            foundExtantTableFigure = findall(0,'Type','figure','tag','uimgr.uifigure_PhoCustom_SelectionTable'); % Get the handle.
			if ~isempty(foundExtantTableFigure) && isgraphics(foundExtantTableFigure)
                fprintf('found existing table figure. re-using...\n');
				obj.GraphicalSelection.selectionCustomTableFigure.Figure = foundExtantTableFigure;
                delete(obj.GraphicalSelection.selectionCustomTableFigure.Figure);                
                obj.GraphicalSelection.selectionCustomTableFigure.Figure = uifigure('Position',[500 500 750 350],'Name','cellROI Table','Tag','uimgr.uifigure_PhoCustom_SelectionTable');
            else
                fprintf('no existing table found. building new...\n');
				obj.GraphicalSelection.selectionCustomTableFigure.Figure = uifigure('Position',[500 500 750 350],'Name','cellROI Table','Tag','uimgr.uifigure_PhoCustom_SelectionTable');
                
                %% Add a Custom Toolbar to allow loading/saving selections
                foundExtantToolbar = findobj(obj.GraphicalSelection.selectionCustomTableFigure.Figure,'Tag','uimgr.uitoolbar_PhoCustom_TableSaving');
                if ~isempty(foundExtantToolbar) && isgraphics(foundExtantToolbar)
                    obj.GraphicalSelection.tableCustomToolbar = foundExtantToolbar;
                    delete(obj.GraphicalSelection.tableCustomToolbar);                
                    obj.GraphicalSelection.tableCustomToolbar = uitoolbar(obj.GraphicalSelection.selectionCustomTableFigure.Figure,'Tag','uimgr.uitoolbar_PhoCustom_TableSaving');
                else
                    obj.GraphicalSelection.tableCustomToolbar = uitoolbar(obj.GraphicalSelection.selectionCustomTableFigure.Figure,'Tag','uimgr.uitoolbar_PhoCustom_TableSaving');
                end

                %% Load User Annotations File
                obj.GraphicalSelection.tableControls.btn_LoadUserAnnotations = uipushtool(obj.GraphicalSelection.tableCustomToolbar,'Tag','uimgr.uipushtool_LoadUserAnnotationsTable');
                obj.GraphicalSelection.tableControls.btn_LoadUserAnnotations.CData = iconRead('file_open.png');
                obj.GraphicalSelection.tableControls.btn_LoadUserAnnotations.Tooltip = 'Load current user annotations out to the pre-specified .MAT file';
                obj.GraphicalSelection.tableControls.btn_LoadUserAnnotations.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_LoadUserSelections_callback(src, event));

                %% Save User Annotations File
                obj.GraphicalSelection.tableControls.btn_SaveUserAnnotations = uipushtool(obj.GraphicalSelection.tableCustomToolbar,'Tag','uimgr.uipushtool_SaveUserAnnotationsTable');
                obj.GraphicalSelection.tableControls.btn_SaveUserAnnotations.CData = iconRead('file_save.png');
                obj.GraphicalSelection.tableControls.btn_SaveUserAnnotations.Tooltip = 'Save current user annotations out to the pre-specified .MAT file';
                obj.GraphicalSelection.tableControls.btn_SaveUserAnnotations.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_SaveUserSelections_callback(src, event));

            end

			obj.GraphicalSelection.selectionCustomTableFigure.Table = uitable(obj.GraphicalSelection.selectionCustomTableFigure.Figure, 'Data', obj.GraphicalSelection.selectionCustomTableFigure.data_table,...
                'Tag','uimgr.uitable_PhoCustom_SelectionTable');
			obj.GraphicalSelection.selectionCustomTableFigure.Table.RowName = 'numbered';
			obj.GraphicalSelection.selectionCustomTableFigure.Table.Position = [20 20 710 310];
			obj.GraphicalSelection.selectionCustomTableFigure.Table.ColumnEditable = [false, false, false, false, true, true, true, true];
			obj.GraphicalSelection.selectionCustomTableFigure.Table.ColumnWidth = {'auto','auto','auto','auto','auto','auto','auto','auto'};

			% obj.GraphicalSelection.selectionCustomTableFigure.Table.DisplayDataChangedFcn = @updatePlot;
			obj.GraphicalSelection.selectionCustomTableFigure.Table.CellEditCallback = @(src, eventdata) (obj.selection_table_checkSelectedToggled_callback(src, eventdata));
		end


		function obj = addTableColumn(obj, columnName, columnData)

			table_data = get(obj.GraphicalSelection.selectionCustomTableFigure.Table, 'Data');
			table_is_column_editable = get(obj.GraphicalSelection.selectionCustomTableFigure.Table, 'ColumnEditable');
			
			table_data(:,end+1) = columnData;
			table_is_column_editable(end+1) = true;


			% table_data(:,end+1) = num2cell(false(10,1));
			% isEditable=[false(1, size(table_data,2)-1) true];
			
			set(obj.GraphicalSelection.selectionCustomTableFigure.Table,'Data', table_data);
			set(obj.GraphicalSelection.selectionCustomTableFigure.Table,'ColumnEditable', table_is_column_editable);

			% set(h, 'Data',[num2cell(c1) num2cell(c2)], ...
    		% 'ColumnFormat',[repmat({[]},1,size(c1,2)),'logical'], ...
    		% 'ColumnEditable',[false(1,size(c1,2)),true])


		end

		function obj = updateGraphicalSelectionTable(obj)
            % updateGraphicalSelectionTable(): called to update the table values
			fprintf('updateGraphicalSelectionTable() called. \n')
			
% 			foundExtantTableObj = findobj('Tag','uimgr.uitable_PhoCustom_SelectionTable');
            foundExtantTableObj = findall(0,'Type','uitable','tag','uimgr.uitable_PhoCustom_SelectionTable');
			if ~isempty(foundExtantTableObj) && isgraphics(foundExtantTableObj)
                fprintf('found table!');
				foundExtantTableObj.Data.isCellRoiSelected = obj.isCellRoiSelected;
			else
				warning('could not find table!')
			end
			% obj.GraphicalSelection.selectionCustomTableFigure.Table.Data.isCellRoiSelected = obj.isCellRoiSelected;
		end


		function obj = setupGraphicalSelectionToolbar(obj, activeFigure, graphical_update_callback)
			%% setupGraphicalSelectionToolbar: adds the toolbar to the activeFigure
            if exist('graphical_update_callback','var')
               fprintf('setting graphical_update_callback...\n');
               obj.graphical_update_callback = graphical_update_callback; 
            end

            %% Add a Custom Toolbar to allow marking selections
			foundExtantToolbar = findobj(activeFigure,'Tag','uimgr.uitoolbar_PhoCustom_Selection');
			if ~isempty(foundExtantToolbar) && isgraphics(foundExtantToolbar)
				obj.GraphicalSelection.selectionCustomToolbar = foundExtantToolbar;
                delete(obj.GraphicalSelection.selectionCustomToolbar);                
                obj.GraphicalSelection.selectionCustomToolbar = uitoolbar(activeFigure,'Tag','uimgr.uitoolbar_PhoCustom_Selection');
			else
				obj.GraphicalSelection.selectionCustomToolbar = uitoolbar(activeFigure,'Tag','uimgr.uitoolbar_PhoCustom_Selection');
			end

			%% Load User Annotations File
            obj.GraphicalSelection.selectionControls.btn_LoadUserAnnotations = uipushtool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_LoadUserAnnotations');
            obj.GraphicalSelection.selectionControls.btn_LoadUserAnnotations.CData = iconRead('file_open.png');
            obj.GraphicalSelection.selectionControls.btn_LoadUserAnnotations.Tooltip = 'Load current user annotations out to the pre-specified .MAT file';
            obj.GraphicalSelection.selectionControls.btn_LoadUserAnnotations.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_LoadUserSelections_callback(src, event));

            %% Save User Annotations File
            obj.GraphicalSelection.selectionControls.btn_SaveUserAnnotations = uipushtool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_SaveUserAnnotations');
            obj.GraphicalSelection.selectionControls.btn_SaveUserAnnotations.CData = iconRead('file_save.png');
            obj.GraphicalSelection.selectionControls.btn_SaveUserAnnotations.Tooltip = 'Save current user annotations out to the pre-specified .MAT file';
            obj.GraphicalSelection.selectionControls.btn_SaveUserAnnotations.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_SaveUserSelections_callback(src, event));

            
			%% Toggle Eye Area overlay:
			obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay_imagePaths = {'HideEyePoly.png', 'ShowEyePoly.png'};
			obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay = uitoggletool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_ToggleEyePolyOverlay');
			obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay.CData = iconRead(obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay_imagePaths{1});
			obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay.Tooltip = 'Toggle the eye polygon area on or off';
			obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_ToggleEyePolyOverlay_callback(src, event));

			%% Toggle MarkBad
			obj.GraphicalSelection.selectionControls.btnMarkBad = uipushtool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_MarkBad');
			obj.GraphicalSelection.selectionControls.btnMarkBad_imagePaths = {'MarkBad.png', 'MarkGood.png'};
			obj.GraphicalSelection.selectionControls.btnMarkBad.CData = iconRead(obj.GraphicalSelection.selectionControls.btnMarkBad_imagePaths{(1)});
			obj.GraphicalSelection.selectionControls.btnMarkBad.Tooltip = 'Mark current frame bad';
			obj.GraphicalSelection.selectionControls.btnMarkBad.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_MarkBad_callback(src, event));
			
			%% Toggle MarkUnusual
			obj.GraphicalSelection.selectionControls.btnMarkUnusual = uipushtool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_MarkUnusual');
			obj.GraphicalSelection.selectionControls.btnMarkUnusual_imagePaths = {'MarkUnusual.png', 'ClearUnusual.png'};
			obj.GraphicalSelection.selectionControls.btnMarkUnusual.CData = iconRead(obj.GraphicalSelection.selectionControls.btnMarkUnusual_imagePaths{(1)});
			obj.GraphicalSelection.selectionControls.btnMarkUnusual.Tooltip = 'Mark current frame unusual';
			obj.GraphicalSelection.selectionControls.btnMarkUnusual.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_MarkUnusual_callback(src, event));
			
			%% Toggle Needs Review
			obj.GraphicalSelection.selectionControls.btnMarkNeedsReview = uipushtool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_MarkNeedsReview');
			obj.GraphicalSelection.selectionControls.btnMarkNeedsReview_imagePaths = {'MarkNeedsReview.png', 'ClearNeedsReview.png'};
			obj.GraphicalSelection.selectionControls.btnMarkNeedsReview.CData = iconRead(obj.GraphicalSelection.selectionControls.btnMarkNeedsReview_imagePaths{(1)});
			obj.GraphicalSelection.selectionControls.btnMarkNeedsReview.Tooltip = 'Mark current frame NeedsReview';
			obj.GraphicalSelection.selectionControls.btnMarkNeedsReview.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_MarkNeedsReview_callback(src, event));

			%% Toggle MarkList
			obj.GraphicalSelection.selectionControls.btnMarkList = uipushtool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_MarkList');
			obj.GraphicalSelection.selectionControls.btnMarkList_imagePaths = {'ListAdd.png', 'ListRemove.png'};
			obj.GraphicalSelection.selectionControls.btnMarkList.CData = iconRead(obj.GraphicalSelection.selectionControls.btnMarkList_imagePaths{(1)});
			obj.GraphicalSelection.selectionControls.btnMarkList.Tooltip = 'Mark current frame list member';
			obj.GraphicalSelection.selectionControls.btnMarkList.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_MarkList_callback(src, event));

			obj.selection_toolbar_update_custom_toolbar_buttons_appearance()
        end

		%% Updates the state of the toolbar buttons:
		function selection_toolbar_update_custom_toolbar_buttons_appearance(obj)
			
			obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay.CData = iconRead(obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay_imagePaths{(obj.selectionOptions.shouldHideSelectedRois + 1)});
			
		end

    end % end UX methods block


    %% UX Callback Methods Block:
    methods
        function selection_toolbar_btn_LoadUserSelections_callback(obj, src, event)
            fprintf('Loading from file %s...', obj.BackingFile.fullPath)
            obj.loadFromExistingBackingFile();
            fprintf('Done.\n')
			% Perform user callbacks:
			obj.perform_graphics_update_callbacks();
        end

        % SaveUserAnnotations
        function selection_toolbar_btn_SaveUserSelections_callback(obj, src, event)
            fprintf('Saving out to file %s...', obj.BackingFile.fullPath)
            obj.saveToBackingFile();
            fprintf('Done.\n')
        end

        function selection_toolbar_btn_MarkBad_callback(obj, src, event)
			obj.selection_toolbar_update_custom_toolbar_buttons_appearance();
        end
        
		function selection_toolbar_btn_MarkUnusual_callback(obj, src, event)
			obj.selection_toolbar_update_custom_toolbar_buttons_appearance();
		end

		function selection_toolbar_btn_MarkNeedsReview_callback(obj, src, event)
			obj.selection_toolbar_update_custom_toolbar_buttons_appearance();
		end

		function selection_toolbar_btn_MarkList_callback(obj, src, event)
			obj.selection_toolbar_update_custom_toolbar_buttons_appearance();
		end


		function selection_toolbar_btn_ToggleEyePolyOverlay_callback(obj, src, event)
			disp('btnToggleEyePolyOverlay callback hit!');
			obj.selectionOptions.shouldHideSelectedRois = ~obj.selectionOptions.shouldHideSelectedRois;
			disp(obj.selectionOptions.shouldHideSelectedRois);
			obj.selection_toolbar_update_custom_toolbar_buttons_appearance();
			% Perform user callbacks:
            obj.perform_graphics_update_callbacks();
		end

		function selection_table_checkSelectedToggled_callback(obj, src, eventdata)
			disp('selection_table_checkSelectedToggled_callback callback hit!');
			
			if (eventdata.Indices(2) == 5) % check if 'isCellRoiSelected' column
				selected_row_index = eventdata.Indices(1);
				selected_row_updated_value = eventdata.NewData;
				fprintf('row[%d]: isCellRoiSelected changed to %d\n', selected_row_index, selected_row_updated_value);
				obj.updateCellRoiIsSelected(selected_row_index, selected_row_updated_value);
				obj.perform_graphics_update_callbacks();
			end


        end
        
        function [obj] = perform_graphics_update_callbacks(obj)
            % Perform user callbacks:
            
            obj.updateGraphicalSelectionTable();
            
            if isprop(obj, 'graphical_update_callback')
                obj.graphical_update_callback();
            else
                warning('callback not defined for InteractionHelper')
            end
            
%             
%             if length(obj.graphical_update_callbacks) == 1
% %                 obj.graphical_update_callbacks();
%                 curr_callback = obj.graphical_update_callbacks{1};
%                 curr_callback();
%                 
%             else
%                 for i = 1:length(obj.graphical_update_callbacks)
% %                     curr_callback = obj.graphical_update_callbacks(i);
%                     curr_callback = obj.graphical_update_callbacks{1};
%                     curr_callback();
%                 end
%             end
        end


    

    end % end UX callbacks methods block
    
    %% Backing File Methods Block:
    methods
      
		function [obj] = tryOpenBackingFile(obj)
			% see if the file exists at the provided path
			if ~exist(obj.BackingFile.fullPath,'file')
                % if it doesn't exist, create it
				fprintf('Backing file at %s does not exist. Creating new backing file.\n', obj.BackingFile.fullPath)
				obj.createBackingFile();
			else
				fprintf('Opening existing backing file at %s...', obj.BackingFile.fullPath)
				% TODO: load from backing file:
				% obj = InteractionHelper.loadFromExistingBackingFile(obj.BackingFile.fullPath); % will this work?
				obj = obj.loadFromExistingBackingFile(); % will this work?
				% warning('Does this work?')
                fprintf('done.\n')
			end
			
			% obj.BackingFile.matFile = matfile(obj.BackingFile.fullPath,'Writable', true);
			% obj.createBackingFile();
			obj.BackingFile.hasBackingFile = true;

		end
		
		function createBackingFile(obj)
			fprintf('Creating new backing file at %s ...\n', obj.BackingFile.fullPath)
            obj.saveToBackingFile();
			fprintf('done.\n')
		end

		function [obj] = loadFromExistingBackingFile(obj)
			fprintf('Loading from existing backing file at %s...', obj.BackingFile.fullPath)
			L = load(obj.BackingFile.fullPath);
			% obj.isCellRoiSelected = L.isCellRoiSelected;
			% Use "deal" to distribute them to the variables.
			[obj.isCellRoiSelected, obj.AnnotatingUser] = deal(L.isCellRoiSelected, L.AnnotatingUser);

			fprintf('done.\n')
	  	end


		function saveToBackingFile(obj)
			fprintf('Saving changes to backing file at %s...', obj.BackingFile.fullPath)
			save_struct.AnnotatingUser = obj.AnnotatingUser;
            save_struct.isCellRoiSelected = obj.isCellRoiSelected;
			save_struct.selected_cellROI_uniqueCompListIndicies = obj.selected_cellROI_uniqueCompListIndicies;
			save_struct.selected_cellROI_roiNames = obj.selected_cellROI_roiNames;

			% save(obj.BackingFile.fullPath,'isCellRoiSelected','-v7.3');
			save(obj.BackingFile.fullPath,'-struct','save_struct','-v7.3');
			fprintf('done.\n')
		end
		
		function saveToUserSelectableCopyMat(obj)
			% allows the user to select a file path to save a copy of the current annotation object out to a .mat file.
			uisave({'obj'},['UAnnotations-CellROI-', '0', '.mat'])
		end 
        
    end %% end backing file methods block
    
    methods (Static)
    %   function loaded_interaction_helper_obj = loadFromExistingBackingFile(backingFilePath)
	% 	 L = load(backingFilePath, 'obj');
	% 	 loaded_interaction_helper_obj = L.obj;
	%   end
	
	end % end methods static
    
end

