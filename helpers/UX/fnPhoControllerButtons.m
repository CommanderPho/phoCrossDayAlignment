function [figObj, buttonGridWidget] = fnPhoControllerButtons()
%FNPHOCONTROLLERBUTTONS Summary of this function goes here
%   Detailed explanation goes here
% Create a figure with a grid layout
    figObj = uifigure("Position",[100 100 250 75]);
    gridObj = uigridlayout(figObj,[1 1],"BackgroundColor",[.6 .8 1]);

    % Create the widget
    buttonGridWidget = wt.ButtonGrid(gridObj);

    % Configure the widget
    buttonGridWidget.BackgroundColor = [.6 .8 1];

    % Add optional icons
    buttonGridWidget.Icon = [
        "add_24.png"
        "delete_24.png"
        "play_24.png"
        "pause_24.png"
        "stop_24.png"
        "icon-fa-unlink-ff6347.png"
        ];

    % Add optional text
    buttonGridWidget.Text = [
        "Add"
        "Delete"
        "Play"
        "Pause"
        "Stop"
        "Unlink"
        ];

    % Add optional tooltip
    buttonGridWidget.Tooltip = [
        "Press to Add"
        "Press to Delete"
        "Press to Play"
        "Press to Pause"
        "Press to Stop"
        "Press to Unlink"
        ];

end

