function [mainWindowFigObj] = fnMakeMainWindow()
    % Create a figure with a grid layout
    mainWindowFigObj = uifigure("Position",[100 100 350 625],"Name","phoMainWindow");
    gridObj = uigridlayout(mainWindowFigObj,[1 1],"BackgroundColor",[.6 .8 1]);

    % Create the widget
    taskStatusWidget = wt.TaskStatusTable(gridObj);

    % Configure the widget
    taskStatusWidget.Items = [
        "Load FinalDataStruct"
        "Preprocess Data"
        "Analyze Data"
        "Plot Results"
        "Save Results"
        ];
    taskStatusWidget.Status = [
        "none"
        "none"
        "none"
        "none"
        "none"
        ];
    taskStatusWidget.SelectedIndex = 1;
    % Assign a callback
    taskStatusWidget.ButtonPushedFcn = @(h,e)disp(e);

%     "complete"
%         "warning"
%         "running"
%         "none"
%         "none"
        
    
    
%     PhoLoadFinalDataStruct
    
    
    
%     % Create the widget
%     toolbarWidget1 = wt.Toolbar(gridObj);
% 
%     % Create a horizontal section
%     section1 = wt.toolbar.HorizontalSection();
%     section1.Title = "NORMAL BUTTONS";
%     section1.addButton("open_24.png", "Open");
%     section1.addButton("save_24.png", "Save");
% 
%     % Create a horizontal section with state buttons
%     section2 = wt.toolbar.HorizontalSection();
%     section2.Title = "STATE BUTTONS";
%     stateButton1 = section2.addStateButton("","Mode 1");
%     stateButton2 = section2.addStateButton("","Mode 2");
%     stateButton3 = section2.addStateButton("","Mode 3");
% 
%     % Set the state of the buttons
%     stateButton1.Value = true;
%     stateButton2.Value = false;
%     stateButton3.Value = false;
% 
%     % Attach the horizontal sections to the toolbar
%     toolbarWidget1.Section = [
%         section1
%         section2
%         ];
% 
%     % Assign a callback
%     toolbarWidget1.ButtonPushedFcn = @(h,e)disp(e);

end
