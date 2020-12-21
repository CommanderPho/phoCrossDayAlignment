classdef PolygonRoiChart < matlab.graphics.chartcontainer.ChartContainer & ...
        matlab.mixin.CustomDisplay %& ...
        %     matlab.graphics.chartcontainer.mixin.Legend
        
    
	properties
		Color = [1 0 0]

		PlotData (:,1) PlotData_Cartesian
    end

    properties (Access = protected)
		numInitializedPlots = 0;
    end

    
	%% Computed Properties:


	properties(Access = private, Transient, NonCopyable)
		OutlineBordersLineArray (:,1) matlab.graphics.chart.primitive.Line
		PolygonObjects (:,1) matlab.graphics.primitive.Patch
    end

    
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
    
    
    

	methods
		function obj = PolygonRoiChart(plotDataSeries, varargin)
			% Check for at least three inputs
			if nargin < 1
				error('Not enough inputs');
			end
				
			% Convert x, y, and margin into name-value pairs
			% args = {'plotDataSeries', plotDataSeries};
				
			% Combine args with user-provided name-value pairs
			% args = [args varargin];
			args = varargin;
				
			% Call superclass constructor method
			obj@matlab.graphics.chartcontainer.ChartContainer(args{:});

			obj.PlotData = plotDataSeries;
            
		end
	end



	methods(Access = protected)
		function setup(~)
			% get the axes
% 			obj.buildNeededPlots();
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

					show_line = obj.PlotData(i).show_outline_line;
					show_patch = obj.PlotData(i).show_patch;

					if show_line
						obj.OutlineBordersLineArray(i).XData = curr_x;
						obj.OutlineBordersLineArray(i).YData = curr_y;
					end

                    % Update patch XData and YData
					if show_patch
						x = curr_x(:,1);
						active_x = [x x(end:-1:1)];
						y = curr_y(:,1);
						% c = obj.ConfidenceMargin;
                        active_y = [y y(end:-1:1)];
                        
                        curr_color_data = repmat(obj.PlotData(i).CData, size(curr_x));
                        
%                         obj.PolygonObjects(i).XData = active_x;
% 						obj.PolygonObjects(i).YData = active_y;
                        obj.PolygonObjects(i).XData = curr_x;
						obj.PolygonObjects(i).YData = curr_y;
                        obj.PolygonObjects(i).CData = curr_color_data;
                        
%                         set(obj.PolygonObjects(i), 'FaceAlpha', obj.PlotData(i).main_alpha, 'EdgeColor', obj.PlotData(i).EdgeColor);
                        
					end

                    % Update colors
					if show_line
                    	obj.OutlineBordersLineArray(i).Color = obj.PlotData(i).Color;
					end

					if show_patch
                    	obj.PolygonObjects(i).FaceColor = obj.PlotData(i).Color;
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

		function buildNeededPlots(obj)

            fprintf('buildNeededPlots()\n');
            
            curr_needed_plots = obj.num_of_dataSeries - obj.numInitializedPlots;
            fprintf('\t curr_needed_plots: %d\n', curr_needed_plots);
            
			ax = getAxes(obj);

			for i = 1:curr_needed_plots
				% Create Patch and Line objects
				obj.PolygonObjects(i) = patch(ax, NaN, NaN, 'g');
				hold(ax,'on')
				obj.OutlineBordersLineArray(i) = plot(ax, NaN, NaN, 'DisplayName','Original');
                
                obj.numInitializedPlots = obj.numInitializedPlots + 1;
                fprintf('\t initialized one plot!\n');
                fprintf('\t\t obj.numInitializedPlots: %d\n', obj.numInitializedPlots);
			end % end for loop
            
            axis(ax, 'square');
%             axis(ax, [-1, 1, -1, 1] * 1.3);
			% Turn hold state off
			hold(ax,'off')
        end
        

		%% matlab.mixin.CustomDisplay Overrides:
		% See https://www.mathworks.com/help/matlab/matlab_oop/ways-to-approach-customization.html
		function header = getHeader(obj)
			if ~isscalar(obj)
				% List for array of objects
				header = getHeader@matlab.mixin.CustomDisplay(obj);
			else
				headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
				headerStr = [headerStr,' with Customized Display'];
				header = sprintf('%s\n',headerStr);
			end
		end % end getHeader(...)


		function s = getFooter(obj)
			% The default implementation returns an empty char vector
            s = 'Here is my custom footer';
			% if ~isscalar(obj)
			% 	header = getHeader@matlab.mixin.CustomDisplay(obj);
			% else
			% 	headerStr = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
			% 	headerStr = [headerStr,' with Customized Display'];
			% 	header = sprintf('%s\n',headerStr);
			% end

        end % end getFooter(...)

    	% Called when this class is displayed
		function propgrp = getPropertyGroups(obj)
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


       

        

	end % end main protected method block

	methods(Access = public)

		function [obj] = update_comp_polys(obj, varargin)
			% Check for at least three inputs
			if nargin < 1
				error('Not enough inputs');
            end

            % nargin: This returns 3 for some reason!
			for arg_i = 1:length(varargin)	
				activePolys = varargin{arg_i};
				[coord_data, coord_polys, num_points_per_poly, num_polys] = PolygonRoiChart.extractCellPolyCoordinates(activePolys, true);
                
                [x_array, y_array, num_polys] = PolygonRoiChart.computeFilledCellPolyCoordinates(activePolys);
                
%                 [poly_coord_data, num_points_per_poly, num_polys] = PolygonRoiChart.extractCellPolyCoordinates(activePolys, true);
                
                % Use max_num_points to allocate an array filled with NaNs
%                 max_num_points = max(num_points_per_poly,[],'all');
%                 
%                 x_array = zeros([max_num_points, num_polys]);
%                 y_array = zeros([max_num_points, num_polys]);
%                 
%                 for poly_i = 1:num_polys
% %                     active_coord_data = poly_coord_data{poly_i};
%                     active_coord_data = coord_data(coord_polys == poly_i, :);
%                     curr_size = size(active_coord_data, 1);
%                     
%                     curr_remaining_points = max_num_points - curr_size;
%                     remaining_column_points = nan([curr_remaining_points, 1]);
%                     
%                     curr_x = active_coord_data(:, 2);
%                     curr_y = active_coord_data(:, 1);
%                                         
%                     x_array(:,poly_i) = [curr_x; remaining_column_points];
%                     y_array(:,poly_i) = [curr_y; remaining_column_points];
%                     
%                 end
 
                % The x-coordinates of the patch vertices, specified as a vector or a matrix. If XData is a matrix, then each column represents the x-coordinates of a single face of the patch. In this case, XData, YData, and ZData must have the same dimensions.
				obj.PlotData(arg_i).updateData(x_array, y_array);

			end

		end % end function update_comp_polys
        

        


	end % end public methods block

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
%             x_array = fillmissing(x_array,'previous'); % replace NaNs with the previous value
%             y_array = fillmissing(y_array,'previous'); % replace NaNs with the previous value
        end % end function computeFilledCellPolyCoordinates(...)
        
        
		function [coord_data, coord_polys, num_points_per_poly, num_polys] = extractCellPolyCoordinates(polys, shouldEnsureClosedPolys)
			% plotCellPolys:
			num_polys = length(polys);
			
            num_points_per_poly = zeros([1 num_polys]);
%             total_num_points = 0;
            
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
% 				total_num_points = total_num_points + num_points_per_poly(j);
			end % end for
		end


		function [poly_coord_data, num_points_per_poly, num_polys] = extractCellPerPolyCoordinates(polys, shouldEnsureClosedPolys)
			% plotCellPolys:
			num_polys = length(polys);
			
            num_points_per_poly = zeros([1 num_polys]);            
			poly_coord_data = cell([1, num_polys]);
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
                    end
                end
                
                poly_coord_data{j} = curr_poly;
                num_points_per_poly(j) = size(curr_poly, 1);
			end % end for
        end

		% function [last_patches, last_lines, num_polys] = plotCellPolys(polys, plottingInfo)
		% 		% plotCellPolys:
		% 		num_polys = length(polys);
		% 		last_lines = gobjects(num_polys, 1);
		% 		last_patches = gobjects(num_polys, 1);
				
				
		% 		% Loop through all polygons within this cellROI
		% 		for j = 1:num_polys
		% 			curr_poly = polys{j};
		% 			if iscell(curr_poly)
		% 				fprintf('\t WARNING: poly[%d] is double wrapped!\n', j);
		% 				curr_poly = curr_poly{1}; 
		% 			end
		% 			x = curr_poly(:, 2);
		% 			y = curr_poly(:, 1);
		% 			% Can add the x and y vectors as the next column of the deferred_plotting_matricies
		% 			%%% on second thought, building x and y data vectors won't work well because the returned x and y are of variable size!
		% 			%%%%%  True, but an almagamation mask can be added easily!
		% 			%%%%%  OR, could concatenate all of them into x, y vectors. Nah, they'd still be of different length
					
		% 			num_points = length(x);
		% 			fprintf('\t poly[%d]: %d\n', j, num_points);
					
		% 			is_first_poly_in_cell = (j == 1);
		% 			if is_first_poly_in_cell
		% 				last_patches(j) = fill(x, y, plottingInfo.patch_color, 'Tag', plottingInfo.curr_cell_name);
		% 				alpha(plottingInfo.roi_alpha);
		% 			else
		% 				last_patches(j) = fill(x, y, plottingInfo.patch_color, 'Tag', plottingInfo.curr_cell_name);
		% 				alpha(plottingInfo.other_alpha); 
		% 			end
					
		% 			if plottingInfo.plot_lines
		% 				last_lines(j) = plot(x,y,'black','Tag', plottingInfo.curr_cell_name);
		% 			else
		% 				set(last_patches(j), 'EdgeColor','none');
		% 			end
					
		% 			if plottingInfo.prevent_zoom_in
		% 				xlim([1 512]);
		% 				ylim([1 512]);
		% 			else
		% 				axis square
		% 			end
					
		% 		end % end for
		% end
		
	end % end Static methods block

end % end classdef

