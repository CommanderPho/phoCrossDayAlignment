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

		function obj = setupGraphicalSelectionToolbar(obj, activeFigure, graphical_update_callback)
			%% setupGraphicalSelectionToolbar: adds the toolbar to the activeFigure
			obj.graphical_update_callback = graphical_update_callback;

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
			
			% User Marked Bad:
	%         final_is_marked_bad = svp.userAnnotations.isMarkedBad(curr_video_frame);
			
	% 		[~, doesAnnotationExist] = svp.userAnnotations.uaMan.tryGetAnnotation('BadUnspecified', curr_video_frame);
	% 		final_is_marked_bad = doesAnnotationExist;
			
	% 		final_is_marked_bad_index = 0;
	% 		if final_is_marked_bad
	% 		final_is_marked_bad_index = 2;
	% 		else
	% 		final_is_marked_bad_index = 1;
	% 		end
			% obj.GraphicalSelection.selectionControls.btnMarkBad.CData = iconRead(obj.GraphicalSelection.selectionControls.btnMarkBad_imagePaths{final_is_marked_bad_index});
	% % 		btn_LogFrame.CData = iconRead(btn_LogFrame_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('Log', curr_video_frame) + 1)});        
			
	% 		btnMarkUnusual.CData = iconRead(btnMarkUnusual_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('UnusualFrame', curr_video_frame) + 1)});
	% 		btnMarkNeedsReview.CData = iconRead(btnMarkNeedsReview_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('NeedsReview', curr_video_frame) + 1)});
	% 		btnMarkTransition.CData = iconRead(btnMarkTransition_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('EventChange', curr_video_frame) + 1)});
	% 		btnMarkList.CData = iconRead(btnMarkList_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('AccumulatedListA', curr_video_frame) + 1)});

			% obj.GraphicalSelection.selectionControls.btn_TogglePupilCircleOverlay.CData = iconRead(obj.GraphicalSelection.selectionControls.btn_TogglePupilCircleOverlay_imagePaths{(svpSettings.shouldShowPupilOverlay + 1)});
			
			obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay.CData = iconRead(obj.GraphicalSelection.selectionControls.btn_ToggleEyePolyOverlay_imagePaths{(obj.selectionOptions.shouldHideSelectedRois + 1)});
			
		end

    end % end UX methods block


    %% UX Callback Methods Block:
    methods
        function selection_toolbar_btn_LoadUserSelections_callback(obj, src, event)
            fprintf('Loading from file %s...', obj.BackingFile.fullPath)
            obj.loadFromExistingBackingFile();
            fprintf('Done.\n')
			obj.graphical_update_callback();
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
			% if svpSettings.shouldShowEyePolygonOverlay
			%    svpSettings.shouldShowEyePolygonOverlay = false;
			%    disp('    toggled off');
			%    currAxes = svp.vidPlayer.Visual.Axes;
			%    hExistingPlot = findobj(currAxes, 'Tag','eyePolyPlotHandle');
			%    delete(hExistingPlot) % Remove existing plot
			
			% else
			%    svpSettings.shouldShowEyePolygonOverlay = true;
			%    disp('    toggled on');
			%    % TODO: update button icon, refresh displayed plot
			% end
			obj.selectionOptions.shouldHideSelectedRois = ~obj.selectionOptions.shouldHideSelectedRois;
			disp(obj.selectionOptions.shouldHideSelectedRois);
			obj.selection_toolbar_update_custom_toolbar_buttons_appearance();
			obj.graphical_update_callback();
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

