%% Not yet implemented
%% 12-08-2020 by Pho Hale

% [hPropsPane, phoPipelineOptions] = propertiesGUI(0, phoPipelineOptions);

%% Main Status Widget:
% [figObj] = fnMakeMainWindow();



% close(figObj);



valid_only_quality = phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_quality_of_tuning;
valid_only_quality(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded) = []; % remove the excluded entries.

[figObj] = fnPhoControllerSlider(figObj, valid_only_quality');



function [figObj] = fnMakeMainWindow()
    % Create a figure with a grid layout
    figObj = uifigure("Position",[100 100 250 225]);
    gridObj = uigridlayout(figObj,[1 1],"BackgroundColor",[.6 .8 1]);

    % Create the widget
    taskStatusWidget = wt.TaskStatusTable(gridObj);

    % Configure the widget
    taskStatusWidget.Items = [
        "Import Data"
        "Preprocess Data"
        "Analyze Data"
        "Plot Results"
        "Save Results"
        ];
    taskStatusWidget.Status = [
        "complete"
        "warning"
        "running"
        "none"
        "none"
        ];
    taskStatusWidget.SelectedIndex = 4;

    % Create the widget
    toolbarWidget1 = wt.Toolbar(gridObj);

    % Create a horizontal section
    section1 = wt.toolbar.HorizontalSection();
    section1.Title = "NORMAL BUTTONS";
    section1.addButton("open_24.png", "Open");
    section1.addButton("save_24.png", "Save");

    % Create a horizontal section with state buttons
    section2 = wt.toolbar.HorizontalSection();
    section2.Title = "STATE BUTTONS";
    stateButton1 = section2.addStateButton("","Mode 1");
    stateButton2 = section2.addStateButton("","Mode 2");
    stateButton3 = section2.addStateButton("","Mode 3");

    % Set the state of the buttons
    stateButton1.Value = true;
    stateButton2.Value = false;
    stateButton3.Value = false;

    % Attach the horizontal sections to the toolbar
    toolbarWidget1.Section = [
        section1
        section2
        ];

    % Assign a callback
    toolbarWidget1.ButtonPushedFcn = @(h,e)disp(e);

end
