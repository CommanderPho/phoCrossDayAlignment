classdef PolygonRoiChart < matlab.graphics.chartcontainer.ChartContainer
    properties
        XData = NaN
        YData = NaN
        ConfidenceMargin = 0.15
        MarkerSymbol = 'o'
        Color = [1 0 0]
    end
    properties(Access = private,Transient,NonCopyable)
        OutlineBordersLineArray (:,1) matlab.graphics.chart.primitive.Line
        PolygonObjects (:,1) matlab.graphics.chart.primitive.Patch
    end
    methods(Access = protected)
        function setup(obj)
            % get the axes
            ax = getAxes(obj);
            
            % Create Patch and Line objects
            obj.PatchObject = patch(ax,NaN,NaN,'r','FaceAlpha',0.2,...
                'EdgeColor','none');

			obj.PolygonObjects = patch(ax,NaN,NaN,'r','FaceAlpha',0.2,...
                'EdgeColor','none');

            hold(ax,'on')
            obj.OutlineBordersLineArray = plot(ax,NaN,NaN);
            
            % Turn hold state off
            hold(ax,'off')
        end
        function update(obj)
            % Update XData and YData of Line
			
			% obj.OutlineBordersLineArray = plot(ax,obj.XData,obj.YData);
            % hold(ax,'on')

            obj.OutlineBordersLineArray.XData = obj.XData;
            obj.OutlineBordersLineArray.YData = obj.YData;
            
            % Update patch XData and YData
            x = obj.XData;
            obj.PolygonObjects.XData = [x x(end:-1:1)];
            y = obj.YData;
            c = obj.ConfidenceMargin;
            obj.PolygonObjects.YData = [y+c y(end:-1:1)-c];
            
            % Update colors
            obj.OutlineBordersLineArray.Color = obj.Color;
            obj.PolygonObjects.FaceColor = obj.Color;
            
            % Update markers
            obj.OutlineBordersLineArray.Marker = obj.MarkerSymbol;
        end
    end

	methods(Access = public)

		function update_comp_polys(activeRoiCells)
			%update_comp_polys:
			for i = 1:length(activeRoiCells)
				currCellPolys = activeRoiCells{i};
				for j = 1:length(currCellPolys)
					curr_poly = currCellPolys{j};
					x = curr_poly(:, 2);
					y = curr_poly(:, 1);
					plot(x,y)
					fill(x,y,'r')
			%         alpha(transparency);
					xlim([1 512]);
					ylim([1 512]);
					
				end % end for j
			end % end for i

		end % end function update_comp_polys


	end % end public methods block


end % end classdef

