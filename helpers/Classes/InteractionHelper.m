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
        activeFigure
        imagePlotHandles
        
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
    end %% end methods
    
    %% Backing File Methods Block:
    methods
      
		function tryOpenBackingFile(obj)
			% see if the file exists at the provided path
			if ~exist(obj.BackingFile.fullPath,'file')
                % if it doesn't exist, create it
				disp(['Creating new backing file at ' obj.BackingFile.fullPath])
			else
				disp(['Opening existing backing file at ' obj.BackingFile.fullPath])
				% TODO: load from backing file:
				obj = UserAnnotationsManager.loadFromExistingBackingFile(obj.BackingFile.fullPath); % will this work?
				error('Not yet finished!')
			end
			
			obj.BackingFile.matFile = matfile(obj.BackingFile.fullPath,'Writable',true);
			obj.createBackingFile();
			obj.BackingFile.hasBackingFile = true;

		end
		
		function createBackingFile(obj)
			save(obj.BackingFile.fullPath,'obj','-v7.3');
		end

		function saveToBackingFile(obj)
			save(obj.BackingFile.fullPath,'obj','-v7.3');
		end
		
		function saveToUserSelectableCopyMat(obj)
			% allows the user to select a file path to save a copy of the current annotation object out to a .mat file.
			uisave({'obj'},['UAnnotations-CellROI-', '0', '.mat'])
		end 
        
    end %% end backing file methods block
    
    methods (Static)
      % Creates an explictly typed annotation from a regular one.
      function obj = loadFromExistingBackingFile(backingFilePath)
		if ~exist('backingFilePath','var')
			backingFilePath = 'UserAnnotationsBackingFile.mat';
		end  
		 L = load(backingFilePath,'obj');
		 obj = L.obj;
	  end
	
	end % end methods static
    
end

