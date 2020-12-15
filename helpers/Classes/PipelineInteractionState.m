classdef (Sealed) PipelineInteractionState < handle
    %PipelineInteractionState A wrapper around a handle object with a 'Position' property, like a figure
    % Access via:
	%	 sobj = PipelineInteractionState.getInstance(phoPipelineOptions);

    properties
        pipelineOptions
		pipelineStageNames = {};
		pipelineStageCallbacks = {};
		pipelineStageStatus = {};
		pipelineCurrentStage = -1;
    end
    
	%% Internal Properties
    properties (Access = private, Transient, NonCopyable)
        MainFigure (1,1) matlab.ui.Figure
        % Grid for task items
        TaskGrid (1,1) matlab.ui.container.GridLayout
		TaskStatusTableWidget (1,1) wt.TaskStatusTable
        
    end %properties

	properties (Access = private, Transient, NonCopyable)
        PipelineMenu                   matlab.ui.container.Menu
        ReloadWorkspaceMenu            matlab.ui.container.Menu
        ExitMenu                       matlab.ui.container.Menu
        AnalysisMenu                   matlab.ui.container.Menu
        RecomputePostLoadingStatsMenu  matlab.ui.container.Menu
        InteractiveMenu                matlab.ui.container.Menu
        ShowCellROIInteractiveSliderMenu  matlab.ui.container.Menu
        ResetInteractiveFiguresMenu    matlab.ui.container.Menu
        CloseAllFiguresMenu            matlab.ui.container.Menu
        HelpMenu                       matlab.ui.container.Menu
        ShowHelpMenu                   matlab.ui.container.Menu
    end



    % Computed Properties:
    properties (Dependent)
        numStages
    end
    
    methods
       function numStages = get.numStages(obj)
          numStages = length(obj.pipelineStageNames);
       end
    end
    
	methods (Access = private)
	  function obj = PipelineInteractionState(pipelineOptions)
		obj.pipelineOptions = pipelineOptions;
		obj.SetupUI();
	  end
   end

    % Main methods block:
    methods

        function SetupPipeline(obj, stageNames, stageCallbacks) 
			obj.pipelineStageNames = stageNames;
			obj.pipelineStageCallbacks = stageCallbacks;
			obj.pipelineStageStatus = {};
			for i = 1:length(obj.pipelineStageNames)
				obj.pipelineStageStatus{i} = 'none';
			end
			obj.pipelineCurrentStage = 1;
			
			if obj.numStages >= 1
				obj.startStage(1);
			end
		end


    end



    methods

        

		function updateUI(obj)
            if ~isvalid(obj.TaskStatusTableWidget)
                obj.SetupUI();
            end
			obj.TaskStatusTableWidget.Items = obj.pipelineStageNames;
			obj.TaskStatusTableWidget.Status = obj.pipelineStageStatus;
			obj.TaskStatusTableWidget.SelectedIndex = obj.pipelineCurrentStage;
		end

		function onTaskButtonPushed(obj, evt)
            % Triggered on button pushed
            buttonEvent = evt.Value;
			disp(buttonEvent);

			% "Back"
            
        end %function


		function startStage(obj, stage_index)
			fprintf('startStage(stage_index: %d)\n', stage_index);
			obj.pipelineCurrentStage = stage_index;
			obj.pipelineStageStatus{stage_index} = 'running';		
			obj.updateUI();
			obj.performStageCallback(obj.pipelineCurrentStage);
		end


		
    end


	methods (Access = protected)

		

		function completeStage(obj, stage_index, finish_status)
			if ~exist('finish_status','var')
				finish_status = 'complete';
			end
			completed_stage_index = stage_index;
			obj.pipelineStageStatus{completed_stage_index} = finish_status;
			
			next_stage_index = completed_stage_index + 1;
			if (next_stage_index < length(obj.pipelineStageNames))
				obj.startStage(next_stage_index);
			else
% 				warning('index exceeds max pipeline stages!')
				obj.updateUI();
			end
		end


		function performStageCallback(obj, stage_index)
			fprintf('performStageCallback(stage_index: %d)\n', stage_index);
			curr_callback = obj.pipelineStageCallbacks{stage_index};
            PipelineInteractionState.EnhancedCallback(obj, stage_index, curr_callback);
            
			% curr_callback(obj);
% 			updated_callback = @(thisObj, currIndex) (curr_callback(thisObj, currIndex); thisObj.completeStage(currIndex));
% 			fprintf('done.\n');			
%             
%             updated_callback = @(thisObj, currIndex) (curr_callback(thisObj, currIndex); thisObj.completeStage(currIndex));
%             
%             
% 			updated_callback(obj, stage_index);
			% obj.completeStage(stage_index);
		end


		% function updatePipelineStage(obj)
		% 	completed_stage_index = obj.TaskStatusTableWidget.SelectedIndex;
		% 	obj.pipelineStageStatus{completed_stage_index} = 'complete';
		% 	next_stage_index = completed_stage_index + 1;
		% 	obj.pipelineStageStatus{next_stage_index} = 'running';
		% 	obj.pipelineCurrentStage = obj.pipelineCurrentStage + 1;
		% 	obj.updateUI();
		% end


		function SetupUI(obj)
			% Create a figure with a grid layout
			needs_create_new_fig = true;
			if needs_create_new_fig
				obj.MainFigure = uifigure('Position',[100 100 350 625],'Name','phoMainWindow','HandleVisibility','on');
            end

			obj.TaskGrid = uigridlayout(obj.MainFigure,[2 1],"BackgroundColor",[.6 .8 1]);

			% Create the menu:
			% obj.mainPipelineMenu = MainPipelineMenu(obj.MainFigure);
			obj.createMenuComponents();

			% Create the widget
			obj.TaskStatusTableWidget = wt.TaskStatusTable(obj.TaskGrid);
			obj.TaskStatusTableWidget.Layout.Row = 1;
    		obj.TaskStatusTableWidget.Layout.Column = 1;
% %     		obj.TaskGrid.Padding = [0 10 0 10];

			% Configure the widget
			obj.TaskStatusTableWidget.Items = obj.pipelineStageNames;
			obj.TaskStatusTableWidget.Status = obj.pipelineStageStatus;
            if obj.pipelineCurrentStage > 0
                obj.TaskStatusTableWidget.SelectedIndex = obj.pipelineCurrentStage;
            end
			% Assign a callback
			obj.TaskStatusTableWidget.ButtonPushedFcn = @(h,e) obj.onTaskButtonPushed(e);

			%% Add Footer:
			grid3 = uigridlayout(obj.TaskGrid, [1 2]);
			grid3.Layout.Row = 2;
			grid3.Layout.Column = 1;
			grid3.Padding = [0 0 0 0];
			b1 = uibutton(grid3,'Text','Start');
			b2 = uibutton(grid3,'Text','Stop');

				

        end

        
        
        
   end





    % Callbacks that handle component events
    methods (Access = protected)

		% Menu Creation
        function createMenuComponents(obj)

            % % Create UIFigure and hide until all components are created
            % obj.UIFigure = uifigure('Visible', 'off');
            % obj.UIFigure.Position = [100 100 640 480];
            % obj.UIFigure.Name = 'MATLAB obj';

            % Create PipelineMenu
            obj.PipelineMenu = uimenu(obj.MainFigure);
            obj.PipelineMenu.Text = 'Pipeline';

            % Create ReloadWorkspaceMenu
            obj.ReloadWorkspaceMenu = uimenu(obj.PipelineMenu);
            % obj.ReloadWorkspaceMenu.MenuSelectedFcn = createCallbackFcn(obj, @ReloadWorkspaceMenuSelected, true);
			obj.ReloadWorkspaceMenu.MenuSelectedFcn = @(h,e) obj.ReloadWorkspaceMenuSelected(h,e);
            obj.ReloadWorkspaceMenu.Text = 'Reload Workspace';

            % Create ExitMenu
            obj.ExitMenu = uimenu(obj.PipelineMenu);
            % obj.ExitMenu.MenuSelectedFcn = createCallbackFcn(obj, @ExitMenuSelected, true);
            obj.ExitMenu.Text = 'Exit';

            % Create AnalysisMenu
            obj.AnalysisMenu = uimenu(obj.MainFigure);
            obj.AnalysisMenu.Text = 'Analysis';

            % Create RecomputePostLoadingStatsMenu
            obj.RecomputePostLoadingStatsMenu = uimenu(obj.AnalysisMenu);
            % obj.RecomputePostLoadingStatsMenu.MenuSelectedFcn = createCallbackFcn(obj, @RecomputePostLoadingStatsMenuSelected, true);
            obj.RecomputePostLoadingStatsMenu.Text = 'Recompute Post Loading Stats';

            % Create InteractiveMenu
            obj.InteractiveMenu = uimenu(obj.MainFigure);
            obj.InteractiveMenu.Text = 'Interactive';

            % Create ShowCellROIInteractiveSliderMenu
            obj.ShowCellROIInteractiveSliderMenu = uimenu(obj.InteractiveMenu);
            % obj.ShowCellROIInteractiveSliderMenu.MenuSelectedFcn = createCallbackFcn(obj, @ShowCellROIInteractiveSliderMenuSelected, true);
            obj.ShowCellROIInteractiveSliderMenu.Separator = 'on';
            obj.ShowCellROIInteractiveSliderMenu.Text = 'Show CellROI Interactive Slider';

            % Create ResetInteractiveFiguresMenu
            obj.ResetInteractiveFiguresMenu = uimenu(obj.InteractiveMenu);
            % obj.ResetInteractiveFiguresMenu.MenuSelectedFcn = createCallbackFcn(obj, @ResetInteractiveFiguresMenuSelected, true);
            obj.ResetInteractiveFiguresMenu.Text = 'Reset Interactive Figures';

            % Create CloseAllFiguresMenu
            obj.CloseAllFiguresMenu = uimenu(obj.InteractiveMenu);
            % obj.CloseAllFiguresMenu.MenuSelectedFcn = createCallbackFcn(obj, @CloseAllFiguresMenuSelected, true);
			obj.CloseAllFiguresMenu.MenuSelectedFcn = @(h,e) obj.CloseAllFiguresMenuSelected(h,e);
            obj.CloseAllFiguresMenu.Text = 'Close All Figures';

            % Create HelpMenu
            obj.HelpMenu = uimenu(obj.MainFigure);
            obj.HelpMenu.Text = 'Help';

            % Create ShowHelpMenu
            obj.ShowHelpMenu = uimenu(obj.HelpMenu);
            % obj.ShowHelpMenu.MenuSelectedFcn = createCallbackFcn(obj, @ShowHelpMenuSelected, true);
            obj.ShowHelpMenu.Text = 'Show Help';

            % Show the figure after all components are created
            % obj.MainFigure.Visible = 'on';
        end



        % Menu selected function: ShowCellROIInteractiveSliderMenu
        function ShowCellROIInteractiveSliderMenuSelected(obj, src, event)
            
        end

        % Menu selected function: CloseAllFiguresMenu
        function CloseAllFiguresMenuSelected(obj, src, event)
            close all;
            
        end

        % Menu selected function: ExitMenu
        function ExitMenuSelected(obj, src, event)
            % close(obj.UIFigure)
        end

        % Menu selected function: ReloadWorkspaceMenu
        function ReloadWorkspaceMenuSelected(obj, src, event)
            
        end

        % Menu selected function: RecomputePostLoadingStatsMenu
        function RecomputePostLoadingStatsMenuSelected(obj, src, event)
            
        end

        % Menu selected function: ResetInteractiveFiguresMenu
        function ResetInteractiveFiguresMenuSelected(obj, src, event)
            
        end

        % Menu selected function: ShowHelpMenu
        function ShowHelpMenuSelected(obj, src, event)
            
        end
    end






	methods (Static)
	  function singleObj = getInstance(pipelineOptions)
		 persistent localObj
		 if isempty(localObj) || ~isvalid(localObj)
			localObj = PipelineInteractionState(pipelineOptions);
		 end
		 singleObj = localObj;
      end
      
      function EnhancedCallback(currObj, currIndex, original_callback)
            original_callback(currObj, currIndex);
            fprintf('done.\n');	
            currObj.completeStage(currIndex)
      end
        
   end



end

