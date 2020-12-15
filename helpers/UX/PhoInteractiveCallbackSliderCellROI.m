classdef PhoInteractiveCallbackSliderCellROI < PhoInteractiveCallbackSliderBase

    properties
      cellRoiValues
    end

   methods (Access = protected)

		function obj = PhoInteractiveCallbackSliderCellROI(iscInfo, update_plot_callbacks, cellRoiSliderValues)
			%PhoInteractiveCallbackSliderCellROI Construct an instance of this class
			%   Detailed explanation goes here
			obj@PhoInteractiveCallbackSliderBase(iscInfo, update_plot_callbacks);
            
            obj.cellRoiValues = cellRoiSliderValues;

			% Once that's done, build the slider GUI:
			obj.build_controller_gui();

			% Update the plots now:
			obj.update_plots(obj.curr_i);
		end

   end % end private methods block

   
   %% Internal Properties
    properties (Access = protected)
        
%         % Grid for task items
        RootGrid (1,1) matlab.ui.container.GridLayout
%         
%         % Task Labels
%         Label (1,:) matlab.ui.control.Label
%         
%         % Edit control
%         Icon (1,:) matlab.ui.control.Image
        
        % Back Button
        CellRoiButton (1,:) matlab.ui.control.StateButton
        
%         % Status Label
%         StatusLabel (1,1) matlab.ui.control.Label
%         
%         % Forward Button
%         ForwardButton (1,1) matlab.ui.control.Button
        
    end %properties
    
    
    
   
   
   
   
	%% Abstract methods
	methods (Access = public)

		%% Slider callback function:
		function custom_post_update_function(obj, src, updated_i)
			% src    Object that is responsible for the update. Not currently used.
			% updated_i    Object containing event data structure

			obj.curr_i = updated_i;
			% Update the plots now:
			obj.update_plots(obj.curr_i)
		end

	end


	%% Abstract methods
	methods (Access = protected)

		function build_controller_gui(obj)
			% Just calls the custom functions:
            if ~exist('obj.slider_controller','var') || ~isvalid(obj.slider_controller.controller.figH) || ~isgraphics(obj.slider_controller.controller.figH)
                obj.slider_controller.controller.figH = uifigure('Position',[100 100 1080 280],'Name','phoMainCellROISliderFigure','HandleVisibility','on');
            else
                obj.slider_controller.controller.figH = figH;
            end
            
            
            gridSize = [3 1];
            obj.RootGrid = uigridlayout(obj.slider_controller.controller.figH, gridSize, "BackgroundColor", [.6 .8 1]);
            obj.RootGrid.Padding = [0 0 0 0];
%             obj.RootGrid.RowHeight = {'1x', 40};
            obj.RootGrid.RowHeight = {100, '1x', 40};

            obj.build_controller_gui_header();
            
            obj.build_controller_gui_slider();
            
            %% Footer:
            grid3 = uigridlayout(obj.RootGrid,[1 2]);
            grid3.Layout.Row = 3;
            grid3.Layout.Column = 1;
%             obj.RootGrid.RowHeight = {40};
            grid3.Padding = [0 10 0 10];
            b1 = uibutton(grid3,'Text','Start');
            b2 = uibutton(grid3,'Text','Stop'); 
            
		end % end build_controller_gui(...)

        function build_controller_gui_header(obj)
            toolbarWidget = wt.Toolbar(obj.RootGrid);
            toolbarWidget.Layout.Row = 1;
            toolbarWidget.Layout.Column = 1;

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
            toolbarWidget.Section = [
                section1
                section2
                ];

            % Assign a callback
            toolbarWidget.ButtonPushedFcn = @(h,e)disp(e);
        end
        
        
        function build_controller_gui_slider(obj)
            numRepeatedColumns = length(obj.cellRoiValues);
            
            sliderPanel = uipanel(obj.RootGrid,'Title','CellROIs');
            sliderPanel.Layout.Row = 2;
            sliderPanel.Layout.Column = 1;

            % Grid in the panel
            embedded_grid_obj = uigridlayout(sliderPanel, [2 numRepeatedColumns]);
            embedded_grid_obj.Padding = [0 0 0 0];
            
            for i = 1:numRepeatedColumns
                curr_label_text = sprintf('%d',i);
                curr_label_tooltip = sprintf('Select cellROI[%d]',i);

                curr_button = uibutton(embedded_grid_obj, 'state', 'Tag', curr_label_text);
                curr_button.Layout.Row = 1;
                curr_button.Layout.Column = i; % Span single column
                if i == 1
                    curr_button.Value = true;
                else
                    curr_button.Value = false;
                end
                curr_button.ValueChangedFcn = @(h,event) obj.fnPhoControllerSlider_OnSelectedButtonValueChanged(h,event);
                curr_button.Text = curr_label_text;
                curr_button.Icon = '';
                curr_button.Tooltip = curr_label_tooltip;
                curr_button.IconAlignment = 'top';
                curr_button.WordWrap = 'off';
%                 out_buttons{i} = curr_button;
                obj.CellRoiButton(1,i) = curr_button;
            end

            out_axes = uiaxes(embedded_grid_obj,'Tag','uiaxes_phoControllerSlider');
            out_axes.Layout.Row = 2;
            out_axes.Layout.Column = [1 numRepeatedColumns]; % Span all columns
            [out_axes] = fnPlotHelper_SetupMatrixDisplayAxes(out_axes, size(obj.cellRoiValues));

            xx = [1:size(obj.cellRoiValues,1)];
            yy = [1:size(obj.cellRoiValues,2)];
            hIm = imagesc(out_axes, 'XData', xx, 'YData', yy, 'CData', obj.cellRoiValues, 'AlphaData', .5);
            hIm.ButtonDownFcn = @(h,event) obj.fnPhoControllerSlider_OnMatrixAreaClicked(h, event);
        end

        function fnPhoControllerSlider_OnSelectedButtonValueChanged(obj, srcH, event)

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
        
        function fnPhoControllerSlider_OnMatrixAreaClicked(obj, srcH, event)
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

            obj.fnPhoControllerSlider_OnCellSelected(curr_hit_cell_row, curr_hit_cell_col);
        end

        function fnPhoControllerSlider_OnCellSelected(obj, i, j)
            fprintf('fnPhoControllerSlider_OnCellSelected(%d, %d) selected!\n', i, j);
            changed_btn_index = j;
            obj.custom_post_update_function([], changed_btn_index);
            
            % Update the buttons:
            for btnIndex = 1:length(obj.CellRoiButton)
                if (btnIndex ~= changed_btn_index)
%                     out_buttons{btnIndex}.Value = false;
                    obj.CellRoiButton(1,btnIndex).Value = false;
                else
%                     out_buttons{btnIndex}.Value = true;
                    obj.CellRoiButton(1,btnIndex).Value = true;
                end
            end


        end
    
    
    end % end protected methods block



	methods (Static, Access = public)

		function singleObj = getInstance(iscInfo, update_plot_callbacks, sliderValues)
			persistent localInstanceMap
			needs_instance_initialization = true;

			if isempty(localInstanceMap) || ~isvalid(localInstanceMap)
				localInstanceMap = containers.Map; % Initializes a new map

			else
				does_extant_instance_exist = isKey(localInstanceMap, iscInfo.slider_identifier);
				if does_extant_instance_exist
					extant_instance_obj = localInstanceMap(iscInfo.slider_identifier);
					if isvalid(extant_instance_obj)
						fprintf('returning extant PhoInteractiveCallbackSliderCellROI instance with id: %s\n', iscInfo.slider_identifier);
						singleObj = extant_instance_obj;
						needs_instance_initialization = false;
					end
				end
			end

			if needs_instance_initialization
				% Create a new instance
				fprintf('Initializing NEW PhoInteractiveCallbackSliderCellROI instance with id: %s\n', iscInfo.slider_identifier);
				singleObj = PhoInteractiveCallbackSliderCellROI(iscInfo, update_plot_callbacks, sliderValues);
				localInstanceMap(iscInfo.slider_identifier) = singleObj; % Add the new instance to the map
			end

		end %% getInstance(iscInfo, update_plot_callbacks)


   end % end static block
   
   
   
   methods (Static, Access = protected)

        


   end % end static block
   
   





end