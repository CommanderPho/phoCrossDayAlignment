classdef PolygonRoiChart < matlab.graphics.chartcontainer.ChartContainer
	properties
		% XData = NaN
		% YData = NaN
		MarkerSymbol = 'o'
		Color = [1 0 0]

		PlotData (:,:) PlotData_Cartesian
    end
	properties(Access = private, Transient, NonCopyable)
		OutlineBordersLineArray (:,:) matlab.graphics.chart.primitive.Line
		PolygonObjects (:,:) matlab.graphics.primitive.Patch
    end
    
    
    properties (Access = protected)
		numInitializedPlots = [];
    end

    
	%% Computed Properties:
	properties (Dependent)
		num_of_dataSeries % FinalDataExplorer
% 		number_of_dataSeries_SubGraphics % The number of graphics objects belonging to each cellROI. For example, these might be the fill, the edge, and several inset/outset edge objects
		dataSeries_labels

	end
	methods
	   function num_of_dataSeries = get.num_of_dataSeries(obj)
		  num_of_dataSeries = size(obj.PlotData, 1);
       end
        
       
		function dataSeries_labels = get.dataSeries_labels(obj)
			dataSeries_labels = cell([obj.num_of_dataSeries 1]);
			for i = 1:obj.num_of_dataSeries
				dataSeries_labels{i} = obj.PlotData(i,1).plot_identifier;
			end
		end
% 	   function number_of_dataSeries_SubGraphics = get.number_of_dataSeries_SubGraphics(obj)
%           number_of_dataSeries_SubGraphics = zeros([obj.num_of_dataSeries 1]);
%           for i = 1:size(obj.PlotData, 1)
%             number_of_dataSeries_SubGraphics(i) = length(obj.PlotData(i,:));
%           end
% 	   end
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

            numDataSeries = length(plotDataSeries);
            
            obj.numInitializedPlots = zeros([numDataSeries 1]);
            obj.PlotData(:,:) = repmat(plotDataSeries, [1 5]);
           
            
		end
	end



	methods(Access = protected)
		function setup(~)
			% get the axes
% 			obj.buildNeededPlots();
		end
		function update(obj)
			% Update XData and YData of Line
			
			% obj.OutlineBordersLineArray = plot(ax,obj.XData,obj.YData);
			% hold(ax,'on')

			obj.buildNeededPlots();
            
%             isvalid(obj.OutlineBordersLineArray);
            

			for i = 1:obj.num_of_dataSeries
                curr_data_row = obj.PlotData(i,:);
                for j = 1:length(curr_data_row)
                    curr_data = obj.PlotData(i,j);
                    
                    curr_plot_is_visible = curr_data.should_show;

                    if curr_plot_is_visible
                        curr_x = curr_data.XData;
                        curr_y = curr_data.YData;

                        obj.OutlineBordersLineArray(i).XData = curr_x;
                        obj.OutlineBordersLineArray(i).YData = curr_y;

                        % Update patch XData and YData
                        x = curr_x;
                        obj.PolygonObjects(i).XData = [x x(end:-1:1)];
                        y = curr_y;
                        % c = obj.ConfidenceMargin;
                        obj.PolygonObjects(i).YData = [y y(end:-1:1)];

                        % Update colors
                        obj.OutlineBordersLineArray(i).Color = curr_data.Color;
                        obj.PolygonObjects(i).FaceColor = curr_data.Color;

                        obj.OutlineBordersLineArray(i).Visible = 'on';
                        obj.PolygonObjects(i).Visible = 'on';
                    else
                        obj.OutlineBordersLineArray(i).Visible = 'off';
                        obj.PolygonObjects(i).Visible = 'off';
                    end

                
                end % end for length(curr_data) loop
                
			end % end for num_of_dataSeries loop

% 			drawnow;
        end

        
		function buildNeededPlots(obj)
            fprintf('buildNeededPlots()\n');
            curr_num_additional_plot_rows = obj.num_of_dataSeries - obj.numInitializedPlots(1);
            fprintf('\t curr_num_additional_plot_rows: %d\n', curr_num_additional_plot_rows);
            
            ax = getAxes(obj);
            for row_index = 1:obj.num_of_dataSeries
                
                if row_index > size(obj.numInitializedPlots,1)
                   % Allocate a whole new row: 
                   obj.numInitializedPlots(row_index) = 0;
                end
                
                curr_row_data = obj.PlotData(row_index,:);
                curr_row_num_initialized_plots = obj.numInitializedPlots(row_index);
                curr_row_num_required_plots = length(curr_row_data);
                curr_row_num_additional_plots = curr_row_num_required_plots - curr_row_num_initialized_plots;
                fprintf('\t curr_row_num_additional_plots[%d]: %d\n', row_index, curr_num_additional_plot_rows);
                            
                for new_col_index = 1:curr_row_num_additional_plots
                    % Create Patch and Line objects
                    col_index = curr_row_num_initialized_plots + new_col_index;
%                     [obj, ax] = perform_allocate_specific_subgraphics_plot(obj, ax, row_index, col_index);                    
                    obj.PolygonObjects(row_index, col_index) = patch(ax, NaN, NaN, 'r', 'FaceAlpha', 0.2,'EdgeColor','none');
                    hold(ax,'on')
                    obj.OutlineBordersLineArray(row_index, col_index) = plot(ax, NaN, NaN, 'DisplayName','Original');
                    obj.numInitializedPlots(row_index) = obj.numInitializedPlots(row_index) + 1;
                    fprintf('\t initialized one plot!\n');

                end
                
            end % end for loop
            
			% Preallocate the objects array
            
% 			for i = 1:curr_needed_plots  
% % 				% Create Patch and Line objects
% % 				obj.PolygonObjects(i) = patch(ax, NaN, NaN, 'r', 'FaceAlpha', 0.2,'EdgeColor','none');
% % 				hold(ax,'on')
% % 				obj.OutlineBordersLineArray(i) = plot(ax, NaN, NaN, 'DisplayName','Original');
% %                 
% %                 obj.numInitializedPlots = obj.numInitializedPlots + 1;
% %                 fprintf('\t initialized one plot!\n');
% %                 fprintf('\t\t obj.numInitializedPlots: %d\n', obj.numInitializedPlots);
% 			end % end for loop

%             Turn hold state off
			hold(ax,'off')
            
%             function [obj, ax] = perform_allocate_specific_subgraphics_plot(obj, ax, row_index, col_index)
%                % Create Patch and Line objects
% 				obj.PolygonObjects(row_index, col_index) = patch(ax, NaN, NaN, 'r', 'FaceAlpha', 0.2,'EdgeColor','none');
% 				hold(ax,'on')
% 				obj.OutlineBordersLineArray(row_index, col_index) = plot(ax, NaN, NaN, 'DisplayName','Original');
%                 obj.numInitializedPlots(row_index) = obj.numInitializedPlots(row_index) + 1;
%                 fprintf('\t initialized one plot!\n');
% %                 fprintf('\t\t obj.numInitializedPlots: %d\n', obj.numInitializedPlots);
%             end

        end
        
        
        % Called when this class is displayed
        function propgrp = getPropertyGroups(obj)
            if ~isscalar(obj)
                % List for array of objects
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);    
            else
                % List for scalar object
                propList = {'PlotData','dataSeries_labels','num_of_dataSeries','numInitializedPlots','PolygonObjects','OutlineBordersLineArray'};
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

%             numInitializedPlots
%             updatedRequiredPlots = zeros([length(varargin), 1]);
            
            % nargin: This returns 3 for some reason!
			for arg_i = 1:length(varargin)	
				activePolys = varargin{arg_i};
				[coord_data, coord_polys, total_num_points, num_polys] = PolygonRoiChart.extractCellPolyCoordinates(activePolys);
                
%                 updatedRequiredPlots(arg_i) = num_polys;
                curr_row_data = obj.PlotData(arg_i,:);
                curr_row_num_initialized_columns = length(curr_row_data);
                curr_row_num_required_columns = num_polys;
                curr_row_num_additional_data_columns = curr_row_num_required_columns - curr_row_num_initialized_columns;
                fprintf('\t curr_row_num_additional_plots[%d]: %d\n', arg_i, curr_row_num_additional_data_columns);
                
                if curr_row_num_additional_data_columns > 0
                    extant_data_element = curr_row_data(1);
                    additional_elements = repmat(extant_data_element, [1 curr_row_num_additional_data_columns]);
                    num_updated_row_columns = curr_row_num_initialized_columns + curr_row_num_additional_data_columns;
%                     obj.PlotData(arg_i, :) = [obj.PlotData(arg_i, :) additional_elements];
%                     obj.PlotData(arg_i, curr_row_num_initialized_columns:num_updated_row_columns) = [curr_row_data additional_elements];
                    
                    for new_data_column_idx = 1:curr_row_num_additional_data_columns
                         obj.PlotData(arg_i, end+1) = extant_data_element;
                    end
                end
                
                for poly_i = 1:num_polys
                    active_coord_data = coord_data(coord_polys == poly_i, :);
                    curr_x = active_coord_data(:, 2);
                    curr_y = active_coord_data(:, 1);
                    obj.PlotData(arg_i, poly_i).updateData(curr_x, curr_y);
                end
                
%                 if isprop(obj,'PlotData')
%                     curr_width = size(obj.PlotData, 2);
%                     if curr_width < num_polys)
%                        % Allocate more polys!
%                        fprintf('need to allocate more polys for arg[%d]\n', arg_i);
%                     end
%                 else
%                     
%                     
%                 end
%                 
%                 
% 				curr_x = coord_data(:, 2);
% 				curr_y = coord_data(:, 1);
% 				obj.PlotData(arg_i).updateData(curr_x, curr_y);
			end

		end % end function update_comp_polys
        

        


	end % end public methods block

	methods(Static)

		function [coord_data, coord_polys, total_num_points, num_polys] = extractCellPolyCoordinates(polys)
			% plotCellPolys:
			num_polys = length(polys);
			total_num_points = 0;
			coord_polys = [];
			coord_data = [];
			% Loop through all polygons within this cellROI
			for j = 1:num_polys
				curr_poly = polys{j};
				if iscell(curr_poly)
					fprintf('\t WARNING: poly[%d] is double wrapped!\n', j);
					curr_poly = curr_poly{1}; 
				end
				num_points = size(curr_poly, 1);
				coord_polys = [coord_polys; repmat(j, [num_points 1])];
				coord_data = [coord_data; curr_poly];
				total_num_points = total_num_points + num_points;
			end % end for
		end

		
	end % end Static methods block

end % end classdef

