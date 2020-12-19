classdef ConfidenceChart < matlab.graphics.chartcontainer.ChartContainer
%% Most Modern 2020b Format
    properties
        XData = NaN
        YData = NaN
        ConfidenceMargin = 0.15
        MarkerSymbol = 'o'
        Color (1,3) double {mustBeGreaterThanOrEqual(Color,0),...
            mustBeLessThanOrEqual(Color,1)} = [1 0 0]
    end
    properties(Access = private,Transient,NonCopyable)
        LineObject (1,1) matlab.graphics.chart.primitive.Line
        PatchObject (1,1) matlab.graphics.primitive.Patch
    end

	methods
		function obj = ConfidenceChart(x,y,margin,varargin)
			% Check for at least three inputs
			if nargin < 3
				error('Not enough inputs');
			end
				
			% Convert x, y, and margin into name-value pairs
			args = {'XData', x, 'YData', y, 'ConfidenceMargin', margin};
				
			% Combine args with user-provided name-value pairs
			args = [args varargin];
				
			% Call superclass constructor method
			obj@matlab.graphics.chartcontainer.ChartContainer(args{:});
		end
	end

    methods(Access = protected)
        function setup(obj)
            % get the axes
            ax = getAxes(obj);
            
            % Create Patch and Line objects
            obj.PatchObject = patch(ax,NaN,NaN,'r','FaceAlpha',0.2,...
                'EdgeColor','none');
            hold(ax,'on')
            obj.LineObject = plot(ax,NaN,NaN);
            
            % Turn hold state off
            hold(ax,'off')
        end
        function update(obj)
            % Update XData and YData of Line
            obj.LineObject.XData = obj.XData;
            obj.LineObject.YData = obj.YData;
            
            % Update patch XData and YData
            x = obj.XData;
            obj.PatchObject.XData = [x x(end:-1:1)];
            y = obj.YData;
            c = obj.ConfidenceMargin;
            obj.PatchObject.YData = [y+c y(end:-1:1)-c];
            
            % Update colors
            obj.LineObject.Color = obj.Color;
            obj.PatchObject.FaceColor = obj.Color;
            
            % Update markers
            obj.LineObject.Marker = obj.MarkerSymbol;
        end
    end
end

