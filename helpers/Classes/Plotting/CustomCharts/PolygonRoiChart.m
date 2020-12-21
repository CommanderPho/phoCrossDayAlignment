classdef PolygonRoiChart < matlab.graphics.chartcontainer.ChartContainer & ...
        matlab.mixin.CustomDisplay %& ...
        %     matlab.graphics.chartcontainer.mixin.Legend
        
    
	properties
		Color = [1 0 0]
		PlotData (:,1) PlotData_Cartesian
		PlotConfig (1,1) DynamicPlottingOptionsContainer
    end

    properties (Access = protected)
		numInitializedPlots = 0;
    end

	properties(Access = private, Transient, NonCopyable)
		OutlineBordersLineArray (:,1) matlab.graphics.chart.primitive.Line
		PolygonObjects (:,1) matlab.graphics.primitive.Patch
    end


	%% Computed Properties:    
    properties (Dependent)
		num_of_dataSeries
		dataSeries_labels
	end
	methods
	   function num_of_dataSeries = get.num_of_dataSeries(obj)
		  num_of_dataSeries = length(obj.PlotData);
	   	end
		function dataSeries_labels = get.dataSeries_labels(obj)
			dataSeries_labels = cell([obj.num_of_dataSeries 1]);
			for i = 1:obj.num_of_dataSeries
				dataSeries_labels{i} = obj.PlotData(i).plot_identifier;
			end
        end
    end
    

	methods(Access = public)
		function obj = PolygonRoiChart(plotDataSeries, plotConfig, varargin)
			% Check for at least three inputs
			if nargin < 2
				error('Not enough inputs');
			end
				
			% Convert x, y, and margin into name-value pairs
			% args = {'plotDataSeries', plotDataSeries};
				
			% Combine args with user-provided name-value pairs
			% args = [args varargin];
			args = varargin;
				
			% Call superclass constructor method
			obj@matlab.graphics.chartcontainer.ChartContainer(args{:});

			obj.PlotConfig = plotConfig;
			
			obj.PlotData = plotDataSeries;
            
		end

		function [obj] = update_comp_polys(obj, varargin)
		% update_comp_polys: main update function called with a new PlotData object.
			% Check for at least three inputs
			if nargin < 1
				error('Not enough inputs');
            end
            % nargin: This returns 3 for some reason!
			for arg_i = 1:length(varargin)	
				activePolys = varargin{arg_i};
                [x_array, y_array, num_polys] = PolygonRoiChart.computeFilledCellPolyCoordinates(activePolys);
                % The x-coordinates of the patch vertices, specified as a vector or a matrix. If XData is a matrix, then each column represents the x-coordinates of a single face of the patch. In this case, XData, YData, and ZData must have the same dimensions.
				obj.PlotData(arg_i).updateData(x_array, y_array);
			end
		end % end function update_comp_polys

	end % end public methods block


	%% ChartContainer required methods block:
	methods(Access = protected)
		function setup(~)
			% Don't do anything in setup(~) because Mathworks broke it!
		end
	
		function update(obj)
			% Update XData and YData of Line
			is_visible_array = {'off','on'};

			obj.buildNeededPlots();
            
			for i = 1:obj.num_of_dataSeries               
                curr_plot_is_visible = obj.PlotData(i).should_show;

                if curr_plot_is_visible
	
                    curr_x = obj.PlotData(i).XData;
                    curr_y = obj.PlotData(i).YData;

					show_line = obj.PlotData(i).plottingOptions.show_outline_line;
					show_patch = obj.PlotData(i).plottingOptions.show_patch;

					if show_line
						obj.OutlineBordersLineArray(i).XData = curr_x;
						obj.OutlineBordersLineArray(i).YData = curr_y;
					end

                    % Update patch XData and YData
					if show_patch
                        curr_color_data = repmat(obj.PlotData(i).plottingOptions.CData, size(curr_x));                        
                        obj.PolygonObjects(i).XData = curr_x;
						obj.PolygonObjects(i).YData = curr_y;
                        obj.PolygonObjects(i).CData = curr_color_data;
                        
                        set(obj.PolygonObjects(i), 'FaceAlpha', obj.PlotData(i).plottingOptions.main_alpha, 'EdgeColor', obj.PlotData(i).plottingOptions.EdgeColor);
                        
					end

                    % Update colors
					if show_line
                    	obj.OutlineBordersLineArray(i).Color = obj.PlotData(i).plottingOptions.Color;
					end

					if show_patch
                    	obj.PolygonObjects(i).FaceColor = obj.PlotData(i).plottingOptions.Color;
                    end

                    if (show_line)
                        obj.OutlineBordersLineArray(i).Visible = 'on';
                    else
                        obj.OutlineBordersLineArray(i).Visible = 'off';
                    end
                    
                    if (show_patch)
                        obj.PolygonObjects(i).Visible = 'on';
                    else
                        obj.PolygonObjects(i).Visible = 'off';
                    end

                else
                    obj.OutlineBordersLineArray(i).Visible = 'off';
                    obj.PolygonObjects(i).Visible = 'off';
                end


                
			end % end for num_of_dataSeries loop

		end

	end % end main protected method block


	%% Secondary protected methods block
	methods(Access = protected)

		function buildNeededPlots(obj)
            % buildNeededPlots: Used to build the graphics objects corresponding to the current number of data series
			fprintf('buildNeededPlots()\n');
            curr_needed_plots = obj.num_of_dataSeries - obj.numInitializedPlots;
            fprintf('\t curr_needed_plots: %d\n', curr_needed_plots);
            
			ax = getAxes(obj);

			if obj.PlotConfig.prevent_zoom_in
				xlim(ax, 'manual');
				ylim(ax, 'manual');
			end

			for i = 1:curr_needed_plots
				% Create Patch and Line objects
				obj.PolygonObjects(i) = patch(ax, NaN, NaN, 'g');
				hold(ax,'on')
				obj.OutlineBordersLineArray(i) = plot(ax, NaN, NaN, 'DisplayName','Original');
                
                obj.numInitializedPlots = obj.numInitializedPlots + 1;
                fprintf('\t initialized one plot!\n');
                fprintf('\t\t obj.numInitializedPlots: %d\n', obj.numInitializedPlots);
			end % end for loop
            
            % axis(ax, 'square');
			%             axis(ax, [-1, 1, -1, 1] * 1.3);

			if obj.PlotConfig.prevent_zoom_in
				xlim(ax, [1 512]);
				ylim(ax, [1 512]);
			else
				axis(ax, 'square');
            end

%             ax.GridAlpha
            set(ax, obj.PlotConfig.Axis);

			% Turn hold state off
			hold(ax,'off')
        end % end buildNeededPlots(...)
        

		function propgrp = getPropertyGroups(obj)
			% getPropertyGroups: Called when this class is displayed
			if ~isscalar(obj)
				% List for array of objects
				propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
			else
				% List for scalar object
				propList = {'PlotData','dataSeries_labels','num_of_dataSeries','numInitializedPlots','PolygonObjects','OutlineBordersLineArray'};
				% propList = struct('PlotData',obj.Department,...
				% 	'dataSeries_labels',obj.JobTitle,...
				% 	'num_of_dataSeries',obj.Name,...
				% 	'numInitializedPlots','Not available',...
				% 	'Password',pd);
				propgrp = matlab.mixin.util.PropertyGroup(propList);
			end
		end % end getPropertyGroups(...)

	end % end main protected methods block


	%% Begin Static methods block:
	methods(Static)

        function [x_array, y_array, num_polys] = computeFilledCellPolyCoordinates(polys)
            %             fill_mode = 'nan';
            fill_mode = 'repeat_last';
            
			[coord_data, coord_polys, num_points_per_poly, num_polys] = PolygonRoiChart.extractCellPolyCoordinates(polys, true);
            %                 [poly_coord_data, num_points_per_poly, num_polys] = PolygonRoiChart.extractCellPolyCoordinates(activePolys, true);
                
            % Use max_num_points to allocate an array filled with NaNs
            max_num_points = max(num_points_per_poly,[],'all');

            x_array = zeros([max_num_points, num_polys]);
            y_array = zeros([max_num_points, num_polys]);

            for poly_i = 1:num_polys
                %                     active_coord_data = poly_coord_data{poly_i};
                active_coord_data = coord_data(coord_polys == poly_i, :);
                curr_size = size(active_coord_data, 1);

                curr_remaining_points = max_num_points - curr_size;

                if strcmpi(fill_mode,'repeat_last')
                    last_row = active_coord_data(end,:);                    
                    remaining_column_points = repmat(last_row, [curr_remaining_points, 1]);

                    active_coord_data  = [active_coord_data; remaining_column_points];
                    fprintf('poly[%d]: Adding %d rows\n', poly_i, curr_remaining_points);
                    curr_x = active_coord_data(:, 2);
                    curr_y = active_coord_data(:, 1);
                    x_array(:,poly_i) = curr_x;
                    y_array(:,poly_i) = curr_y;

                else
                    remaining_column_points = nan([curr_remaining_points, 1]);
                    curr_x = active_coord_data(:, 2);
                    curr_y = active_coord_data(:, 1);

                    x_array(:,poly_i) = [curr_x; remaining_column_points];
                    y_array(:,poly_i) = [curr_y; remaining_column_points];
                end

            end % end for num_polys
        end % end function computeFilledCellPolyCoordinates(...)
        
        
		function [coord_data, coord_polys, num_points_per_poly, num_polys] = extractCellPolyCoordinates(polys, shouldEnsureClosedPolys)
			% plotCellPolys:
			num_polys = length(polys);
			
            num_points_per_poly = zeros([1 num_polys]);
            
			coord_polys = [];
			coord_data = [];
			% Loop through all polygons within this cellROI
			for j = 1:num_polys
				curr_poly = polys{j};
				if iscell(curr_poly)
					fprintf('\t WARNING: poly[%d] is double wrapped!\n', j);
					curr_poly = curr_poly{1}; 
                end
                
                if shouldEnsureClosedPolys
                    first_point = curr_poly(1,:);
                    last_point = curr_poly(end,:);
                    if (first_point ~= last_point)
                        curr_poly(end+1,:) = first_point; % Add the first_point back at the end of the array to make it closed
                        fprintf('Adding point to close polygon!\n');
                    end
                end
                
				num_points_per_poly(j) = size(curr_poly, 1);
				coord_polys = [coord_polys; repmat(j, [num_points_per_poly(j) 1])];
				coord_data = [coord_data; curr_poly];
			end % end for
		end

	end % end Static methods block

end % end classdef

