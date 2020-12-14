function [figObj] = fnPhoControllerSlider(figH)
%FNPHOCONTROLLERBUTTONS Summary of this function goes here
%   Detailed explanation goes here
% Create a figure with a grid layout
    
    numRepeatedColumns = 15;

    if ~exist('figH','var')
        figObj = uifigure('Position',[100 100 440 100]);
    else
        figObj = figH;
    end

    gridSize = [2 1];
    gridObj = uigridlayout(figObj, gridSize, "BackgroundColor", [.6 .8 1]);
%     gridObj.RowHeight = {22,'1x'};
      gridObj.RowHeight = {'1x', 40};
%     gridObj.ColumnWidth = {150,'1x'};

    sliderP = uipanel(gridObj,'Title','Configuration');
    sliderP.Layout.Row = 1;
    sliderP.Layout.Column = 1;

    
    % Grid in the panel
    [embedded_grid_obj] = fnPhoControllerSlider(sliderP, numRepeatedColumns);
    
    
%     grid2 = uigridlayout(sliderP,[3 2]);
%     grid2.RowHeight = {22,22,22};
%     grid2.ColumnWidth = {80,'1x'};
%     grid2.ColumnWidth = {'1x',80};

%     % Device label
%     dlabel = uilabel(grid2);
%     dlabel.HorizontalAlignment = 'right';
%     dlabel.Text = 'Device';
% 
%     % Device drop-down
%     devicedd = uidropdown(grid2);
%     devicedd.Items = {'Select a device'};
% 
%     % Channel label
%     chlabel = uilabel(grid2);
%     chlabel.HorizontalAlignment = 'right';
%     chlabel.Text = 'Channel';
% 
%     % Channel drop-down
%     channeldd = uidropdown(grid2);
%     channeldd.Items = {'Channel 1', 'Channel 2'};
% 
%     % Rate Label
%     ratelabel = uilabel(grid2);
%     ratelabel.HorizontalAlignment = 'right';
%     ratelabel.Text = 'Rate (scans/s)';
% 
%     % Rate edit field
%     ef = uieditfield(grid2, 'numeric');
%     ef.Value = 50;


    %% Footer:
    grid3 = uigridlayout(gridObj,[1 2]);
    grid3.Layout.Row = 2;
    grid3.Layout.Column = 1;
    grid3.Padding = [0 10 0 10];
    b1 = uibutton(grid3,'Text','Start');
    b2 = uibutton(grid3,'Text','Stop');


    function [embedded_grid_obj] = fnPhoControllerSlider(parent, numRepeatedColumns)
        embedded_grid_obj = uigridlayout(parent,[2 numRepeatedColumns]);
%         embedded_grid_obj.RowHeight = {22,22,22};
%         embedded_grid_obj.ColumnWidth = {80,'1x'};
%         embedded_grid_obj = uigridlayout(parent,[1 1]);
        
        % Add Label
        button_labels = {};
        button_tooltips = {};
        
        for i = 1:numRepeatedColumns

            curr_label_text = sprintf('%d',i);
            curr_label_tooltip = sprintf('Select cellROI[%d]',i);
            
            button_labels{i} = curr_label_text;
            button_tooltips{i} = curr_label_tooltip;
            
%             curr_label = uilabel(embedded_grid_obj);
%             curr_label.HorizontalAlignment = 'center';
%             curr_label.Text = curr_label_text;
        end
    
        buttonGridWidget = wt.ButtonGrid(embedded_grid_obj);
        buttonGridWidget.Layout.Row = 1;
        buttonGridWidget.Layout.Column = [1, numRepeatedColumns]; % Span all columns
        buttonGridWidget.BackgroundColor = [.6 .8 1];     
        buttonGridWidget.Text = button_labels;
        buttonGridWidget.Tooltip = button_tooltips;
        buttonGridWidget.Icon = {};
        
    end
    

%     function [embedded_grid_obj] = fnPhoControllerSlider_OnButtonPushed(parent, numRepeatedColumns)
%         
%     end
    


end

