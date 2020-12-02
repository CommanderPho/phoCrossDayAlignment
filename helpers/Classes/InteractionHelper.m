classdef InteractionHelper < handle & matlab.mixin.CustomDisplay
    %InteractionHelper Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        final_data_explorer_obj % FinalDataExplorer

        %% Selection
        isCellRoiSelected
        
        %% Annotation/Backing Store
        AnnotatingUser
        BackingFile
        
        %% Graphical (TODO: potentially refactor)
        GraphicalSelection
        
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
        
        
        %% Graphical Methods (TODO: potentially refactor):
        function obj = setupGraphicalSelectionFigure(obj, activeFigure, imagePlotHandles)
            %setupGraphicalSelectionFigure 
            %   activeFigure: 
            %   imagePlotHandles: 
            obj.GraphicalSelection.activeFigure = activeFigure;
            obj.GraphicalSelection.imagePlotHandles = imagePlotHandles;
            
            %% Add a Custom Toolbar to allow marking selections
            obj.GraphicalSelection.selectionCustomToolbar = uitoolbar(obj.GraphicalSelection.activeFigure,'Tag','uimgr.uitoolbar_PhoCustom_Selection');

            %% Save User Annotations File
            btn_SaveUserAnnotations = uipushtool(obj.GraphicalSelection.selectionCustomToolbar,'Tag','uimgr.uipushtool_SaveUserAnnotations');
            btn_SaveUserAnnotations.CData = uint8(iconRead('file_save.png'));
            btn_SaveUserAnnotations.Tooltip = 'Save current user annotations out to the pre-specified .MAT file';
%             btn_SaveUserAnnotations.ClickedCallback = @selection_toolbar_btn_SaveUserAnnotations_callback;
            btn_SaveUserAnnotations.ClickedCallback = @(src, event) (obj.selection_toolbar_btn_SaveUserAnnotations_callback(src, event));

        end
        
                
        
    end %% end methods
    
    %% Graphical Callback Methods:
    methods
        % SaveUserAnnotations
        function selection_toolbar_btn_SaveUserAnnotations_callback(obj, src, event)
            disp('Saving out to file...')
            obj.saveToBackingFile();
            disp('Done')
        end
        
    end
    
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
				obj = InteractionHelper.loadFromExistingBackingFile(obj.BackingFile.fullPath); % will this work?
				% warning('Does this work?')
                fprintf('done.\n')
			end
			
			% obj.BackingFile.matFile = matfile(obj.BackingFile.fullPath,'Writable', true);
			% obj.createBackingFile();
			obj.BackingFile.hasBackingFile = true;

		end
		
		function createBackingFile(obj)
			fprintf('Creating new backing file at %s ...', obj.BackingFile.fullPath)
			save(obj.BackingFile.fullPath,'obj','-v7.3');
			fprintf('done.\n')
		end

		function saveToBackingFile(obj)
			fprintf('Saving changes to backing file at %s...', obj.BackingFile.fullPath)
			save(obj.BackingFile.fullPath,'obj','-v7.3');
			fprintf('done.\n')
		end
		
		function saveToUserSelectableCopyMat(obj)
			% allows the user to select a file path to save a copy of the current annotation object out to a .mat file.
			uisave({'obj'},['UAnnotations-CellROI-', '0', '.mat'])
		end 
        
    end %% end backing file methods block
    
    methods (Static)
      % Creates an explictly typed annotation from a regular one.
      function loaded_interaction_helper_obj = loadFromExistingBackingFile(backingFilePath)
		 L = load(backingFilePath, 'obj');
		 loaded_interaction_helper_obj = L.obj;
	  end
	
	end % end methods static
    
end

