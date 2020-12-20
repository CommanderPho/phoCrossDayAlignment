classdef PolygonRoiChart < matlab.graphics.chartcontainer.ChartContainer
	properties
		XData = NaN
		YData = NaN
		MarkerSymbol = 'o'
		Color = [1 0 0]

		PlotData (:,1) PlotData_Cartesian
	end

	%% Computed Properties:
	properties (Dependent)
		num_of_dataSeries % FinalDataExplorer
		% number_of_cellROI_plotSubGraphics % The number of graphics objects belonging to each cellROI. For example, these might be the fill, the edge, and several inset/outset edge objects
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
	%    function number_of_cellROI_plotSubGraphics = get.number_of_cellROI_plotSubGraphics(obj)
	%       number_of_cellROI_plotSubGraphics = length(obj.activeOffsetInsetIndicies);
	% 	  if obj.plotting_options.should_plot_neuropil_masks
	% 		number_of_cellROI_plotSubGraphics = number_of_cellROI_plotSubGraphics + 1;
	% 	  end
	%    end
	end

	properties(Access = private,Transient,NonCopyable)
		OutlineBordersLineArray (:,1)
		PolygonObjects
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
		function setup(obj)
			% get the axes
			ax = getAxes(obj);

			% Preallocate the objects array
% 			obj.OutlineBordersLineArray = gobjects(obj.num_of_dataSeries, 1);
% 			obj.PolygonObjects = gobjects(obj.num_of_dataSeries, 1);

			for i = 1:obj.num_of_dataSeries
				% Create Patch and Line objects
				obj.PolygonObjects(i) = patch(ax, NaN, NaN, 'r', 'FaceAlpha', 0.2,...
					'EdgeColor','none');

				hold(ax,'on')
				obj.OutlineBordersLineArray(i) = plot(ax, NaN, NaN, 'DisplayName','Original');
			end % end for loop

			% Turn hold state off
			hold(ax,'off')
		end
		function update(obj)
			% Update XData and YData of Line
			
			% obj.OutlineBordersLineArray = plot(ax,obj.XData,obj.YData);
			% hold(ax,'on')

			for i = 1:obj.num_of_dataSeries
                curr_x = obj.PlotData(i).XData;
                curr_y = obj.PlotData(i).YData;
                 
				obj.OutlineBordersLineArray(i).XData = curr_x;
				obj.OutlineBordersLineArray(i).YData = curr_y;
				
				% Update patch XData and YData
				x = curr_x;
				obj.PolygonObjects(i).XData = [x x(end:-1:1)];
				y = curr_y;
				% c = obj.ConfidenceMargin;
				obj.PolygonObjects(i).YData = [y y(end:-1:1)];
				
				% Update colors
				obj.OutlineBordersLineArray(i).Color = obj.PlotData(i).Color;
				obj.PolygonObjects(i).FaceColor = obj.PlotData(i).Color;
				
				% Update markers
				% obj.OutlineBordersLineArray(i).Marker = obj.MarkerSymbol;
			end % end for loop

			drawnow;

		end
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
				[coord_data, coord_polys, total_num_points, num_polys] = PolygonRoiChart.extractCellPolyCoordinates(activePolys);
				curr_x = coord_data(:, 2);
				curr_y = coord_data(:, 1);
				obj.PlotData(arg_i).updateData(curr_x, curr_y);
			end

			obj.update();

			% drawnow;
			%update_comp_polys:
			% for i = 1:length(activeRoiCells)
			% 	currCellPolys = activeRoiCells{i};
			% 	for j = 1:length(currCellPolys)
			% 		curr_poly = currCellPolys{j};
			% 		x = curr_poly(:, 2);
			% 		y = curr_poly(:, 1);
			% 		plot(x,y)
			% 		fill(x,y,'r')
			% %         alpha(transparency);
			% 		xlim([1 512]);
			% 		ylim([1 512]);
					
			% 	end % end for j
			% end % end for i

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

