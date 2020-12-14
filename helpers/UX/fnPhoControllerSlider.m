function [figObj] = fnPhoControllerSlider(figH, sliderValues)
%FNPHOCONTROLLERBUTTONS Summary of this function goes here
%   Detailed explanation goes here
% Create a figure with a grid layout
    
    numRepeatedColumns = length(sliderValues);
    
    if ~exist('figH','var') || ~isgraphics(figH)
        figObj = uifigure('Position',[100 100 1080 200]);
    else
        figObj = figH;
    end

    gridSize = [2 1];
    gridObj = uigridlayout(figObj, gridSize, "BackgroundColor", [.6 .8 1]);
%     gridObj.RowHeight = {22,'1x'};
      gridObj.RowHeight = {'1x', 40};
%     gridObj.ColumnWidth = {150,'1x'};

    sliderPanel = uipanel(gridObj,'Title','CellROIs');
    sliderPanel.Layout.Row = 1;
    sliderPanel.Layout.Column = 1;

    
    % Grid in the panel
    
%     [embedded_grid_obj] = fnPhoControllerSlider(sliderP, numRepeatedColumns, @(srcH, evt) fnPhoControllerSlider_OnButtonPushed(srcH, evt));
    [embedded_grid_obj, out_buttons, out_axes] = fnPhoControllerSlider(sliderPanel, numRepeatedColumns, @(srcH, evt) fnPhoControllerSlider_OnSelectedButtonValueChanged(srcH, evt));
    [out_axes] = fnPlotHelper_SetupMatrixDisplayAxes(out_axes, size(sliderValues));
    
    xx = [1:size(sliderValues,1)];
    yy = [1:size(sliderValues,2)];
%     h = imagesc(out_axes, xx, yy, sliderValues, 'AlphaData', .5);
    hIm = imagesc(out_axes, 'XData', xx, 'YData', yy, 'CData', sliderValues, 'AlphaData', .5);
    hIm.ButtonDownFcn = @fnPhoControllerSlider_OnMatrixAreaClicked;
    
    
%     plot(out_axes, sliderValues);
    
    %% Footer:
    grid3 = uigridlayout(gridObj,[1 2]);
    grid3.Layout.Row = 2;
    grid3.Layout.Column = 1;
    grid3.Padding = [0 10 0 10];
    b1 = uibutton(grid3,'Text','Start');
    b2 = uibutton(grid3,'Text','Stop');


    function [embedded_grid_obj, out_buttons, out_axes] = fnPhoControllerSlider(parent, numRepeatedColumns, buttonCallbackEvent)
        embedded_grid_obj = uigridlayout(parent,[2 numRepeatedColumns]);
%         embedded_grid_obj.RowHeight = {22,22,22};
%         embedded_grid_obj.ColumnWidth = {80,'1x'};
%         embedded_grid_obj = uigridlayout(parent,[1 1]);
        
%         embedded_button_group_obj = uibuttongroup(embedded_grid_obj,'Scrollable','on');
%         embedded_button_group_obj.Title = 'Buttons';
%         embedded_button_group_obj.Layout.Row = 1;
%         embedded_button_group_obj.Layout.Column = [1, numRepeatedColumns]; % Span all columns
%         embedded_button_group_obj.SelectionChangedFcn = @(h,e)onButtonPushed(obj,e);
        % Add Label
        button_labels = {};
        button_tooltips = {};
        button_tags = {};
        button_icons = {};
        out_buttons = {};
        
        for i = 1:numRepeatedColumns

            curr_label_text = sprintf('%d',i);
            curr_label_tooltip = sprintf('Select cellROI[%d]',i);
            
            button_icons{i} = '';
            button_tags{i} = curr_label_text;
            button_labels{i} = curr_label_text;
            button_tooltips{i} = curr_label_tooltip;
            
%             curr_button = uibutton('state','Parent',embedded_button_group_obj);
            curr_button = uibutton(embedded_grid_obj, 'state', 'Tag', curr_label_text);
            curr_button.Layout.Row = 1;
            curr_button.Layout.Column = i; % Span single column
            curr_button.Value = false;
            
            curr_button.ValueChangedFcn = @(h,e) buttonCallbackEvent(h,e);
            curr_button.Text = curr_label_text;
            curr_button.Icon = '';
            curr_button.Tooltip = curr_label_tooltip;
            curr_button.IconAlignment = 'top';
            curr_button.WordWrap = 'off';
%             curr_label = uilabel(embedded_grid_obj);
%             curr_label.HorizontalAlignment = 'center';
%             curr_label.Text = curr_label_text;
            out_buttons{i} = curr_button;
        end
        
        
        out_axes = uiaxes(embedded_grid_obj,'Tag','uiaxes_phoControllerSlider');
        out_axes.Layout.Row = 2;
        out_axes.Layout.Column = [1 numRepeatedColumns]; % Span all columns
        
        
        
    end


    function fnPhoControllerSlider_OnMatrixAreaClicked(srcH, event)
        fprintf('fnPhoControllerSlider_OnMatrixAreaClicked(...) pushed!\n');
        curr_hitPoint = event.IntersectionPoint; % [53.0662 0.8300 0]
        curr_plotAxes = event.Source.Parent;
%         curr_plotAxes.XLim % [0.5, 53.5]
%         curr_plotAxes.YLim % [0.5, 1.5]
        
        curr_relative_HitPoint_x = curr_hitPoint(1) - curr_plotAxes.XLim(1);
        curr_relative_HitPoint_y = curr_hitPoint(2) - curr_plotAxes.YLim(1);
        curr_relative_HitPoint = [curr_relative_HitPoint_x curr_relative_HitPoint_y];
        disp(curr_relative_HitPoint)
        
        curr_hit_cell_col = floor(curr_relative_HitPoint_x) + 1;
        curr_hit_cell_row = floor(curr_relative_HitPoint_y) + 1;
        curr_hit_cell_index = [curr_hit_cell_row curr_hit_cell_col];
        disp(curr_hit_cell_index)
        
        fnPhoControllerSlider_OnCellSelected(curr_hit_cell_row, curr_hit_cell_col);
        %% Add Cell Text Labels:
%         disp(event)
%         disp(event.Source)
%         disp(curr_hitPoint)
%         cellROI_pressed_str = event.Tag; 
%         cellROI_pressed = str2num(cellROI_pressed_str);
%         
%         fprintf('\t pressed cellROI: %d\n', cellROI_pressed);
%         disp(event);
    end
    


    function fnPhoControllerSlider_OnCellSelected(i, j)
        
%         cellROI_pressed_str = event.Tag; 
%         cellROI_pressed = str2num(cellROI_pressed_str);
        
        fprintf('fnPhoControllerSlider_OnCellSelected(%d, %d) selected!\n', i, j);
%         fprintf('\t pressed cellROI: %d\n', cellROI_pressed);
%         disp(event);
        
        changed_btn_index = j;
        
        for btnIndex = 1:length(out_buttons)
            if (btnIndex ~= changed_btn_index)
                out_buttons{btnIndex}.Value = false;
            else
                out_buttons{btnIndex}.Value = true;
            end
        end
        
        
    end




    function fnPhoControllerSlider_OnSelectedButtonValueChanged(srcH, event)
        
        cellROI_pressed_str = event.Source.Tag;
        cellROI_pressed = str2num(cellROI_pressed_str);
        cellROI_updatedIsSelected = logical(event.Value);
        
        fprintf('fnPhoControllerSlider_OnSelectedButtonValueChanged(...) pushed!\n');
        fprintf('\t pressed cellROI: %d\n', cellROI_pressed);
        
        disp(srcH)
%         disp(event);
        
        if cellROI_updatedIsSelected
            
        end
%         disp(event.Source.Tag);
    end



    function fnPhoControllerSlider_OnButtonPushed(srcH, event)
        
        cellROI_pressed_str = event.Tag; 
        cellROI_pressed = str2num(cellROI_pressed_str);
        
        fprintf('fnPhoControllerSlider_OnButtonPushed(...) pushed!\n'); fprintf('\t pressed cellROI: %d\n', cellROI_pressed);
%         disp(event);
    end
    


end

