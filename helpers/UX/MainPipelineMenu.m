classdef MainPipelineMenu < handle

    % Properties that correspond to app components
    properties (Access = public, Transient, NonCopyable)
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

	events
		ShowCellROIInteractiveSlider
		CloseAllFigures
		Exit
		ReloadWorkspace
		RecomputePostLoadingStats
		ResetInteractiveFigures
		ShowHelp
	end


    % Callbacks that handle component events
    methods (Access = protected)

        % Menu selected function: ShowCellROIInteractiveSliderMenu
        function ShowCellROIInteractiveSliderMenuSelected(obj, event)
            
        end

        % Menu selected function: CloseAllFiguresMenu
        function CloseAllFiguresMenuSelected(obj, event)
			notify(obj,'CloseAllFigures');
            close all;
        end

        % Menu selected function: ExitMenu
        function ExitMenuSelected(obj, event)
            % close(obj.UIFigure)
        end

        % Menu selected function: ReloadWorkspaceMenu
        function ReloadWorkspaceMenuSelected(obj, event)
            % lh = addlistener(obj.ReloadWorkspaceMenu,'ToggleState',@RespondToToggle.handleEvnt);
			notify(obj,'ReloadWorkspace')
        end

        % Menu selected function: RecomputePostLoadingStatsMenu
        function RecomputePostLoadingStatsMenuSelected(obj, event)
            
        end

        % Menu selected function: ResetInteractiveFiguresMenu
        function ResetInteractiveFiguresMenuSelected(obj, event)
            
        end

        % Menu selected function: ShowHelpMenu
        function ShowHelpMenuSelected(obj, event)
            
        end
    end





    % Component initialization
    methods (Access = protected)

        % Create UIFigure and components
        function createComponents(obj, figH)

            % % Create UIFigure and hide until all components are created
            % obj.UIFigure = uifigure('Visible', 'off');
            % obj.UIFigure.Position = [100 100 640 480];
            % obj.UIFigure.Name = 'MATLAB obj';

            % Create PipelineMenu
            obj.PipelineMenu = uimenu(figH);
            obj.PipelineMenu.Text = 'Pipeline';

            % Create ReloadWorkspaceMenu
            obj.ReloadWorkspaceMenu = uimenu(obj.PipelineMenu);
			obj.ReloadWorkspaceMenu.MenuSelectedFcn = @ReloadWorkspaceMenuSelected;
            obj.ReloadWorkspaceMenu.Text = 'Reload Workspace';

            % Create ExitMenu
            obj.ExitMenu = uimenu(obj.PipelineMenu);
            obj.ExitMenu.MenuSelectedFcn = @ExitMenuSelected;
            obj.ExitMenu.Text = 'Exit';

            % Create AnalysisMenu
            obj.AnalysisMenu = uimenu(figH);
            obj.AnalysisMenu.Text = 'Analysis';

            % Create RecomputePostLoadingStatsMenu
            obj.RecomputePostLoadingStatsMenu = uimenu(obj.AnalysisMenu);
            obj.RecomputePostLoadingStatsMenu.MenuSelectedFcn = @RecomputePostLoadingStatsMenuSelected;
            obj.RecomputePostLoadingStatsMenu.Text = 'Recompute Post Loading Stats';

            % Create InteractiveMenu
            obj.InteractiveMenu = uimenu(figH);
            obj.InteractiveMenu.Text = 'Interactive';

            % Create ShowCellROIInteractiveSliderMenu
            obj.ShowCellROIInteractiveSliderMenu = uimenu(obj.InteractiveMenu);
            obj.ShowCellROIInteractiveSliderMenu.MenuSelectedFcn = @ShowCellROIInteractiveSliderMenuSelected;
            obj.ShowCellROIInteractiveSliderMenu.Separator = 'on';
            obj.ShowCellROIInteractiveSliderMenu.Text = 'Show CellROI Interactive Slider';

            % Create ResetInteractiveFiguresMenu
            obj.ResetInteractiveFiguresMenu = uimenu(obj.InteractiveMenu);
            obj.ResetInteractiveFiguresMenu.MenuSelectedFcn = @ResetInteractiveFiguresMenuSelected;
            obj.ResetInteractiveFiguresMenu.Text = 'Reset Interactive Figures';

            % Create CloseAllFiguresMenu
            obj.CloseAllFiguresMenu = uimenu(obj.InteractiveMenu);
			obj.CloseAllFiguresMenu.MenuSelectedFcn = @CloseAllFiguresMenuSelected;
            obj.CloseAllFiguresMenu.Text = 'Close All Figures';

            % Create HelpMenu
            obj.HelpMenu = uimenu(figH);
            obj.HelpMenu.Text = 'Help';

            % Create ShowHelpMenu
            obj.ShowHelpMenu = uimenu(obj.HelpMenu);
            % obj.ShowHelpMenu.MenuSelectedFcn = createCallbackFcn(obj, @ShowHelpMenuSelected, true);
            obj.ShowHelpMenu.Text = 'Show Help';

            % Show the figure after all components are created
            figH.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function obj = MainPipelineMenu(figH)

            % Create UIFigure and components
            obj.createComponents(figH);

            % Register the obj with obj Designer
            % registerApp(app, app.UIFigure)

            % if nargout == 0
            %     clear app
            % end

        end

        % % Code that executes before app deletion
        % function delete(app)

        %     % Delete UIFigure when app is deleted
        %     delete(app.UIFigure)
        % end

    end
end

