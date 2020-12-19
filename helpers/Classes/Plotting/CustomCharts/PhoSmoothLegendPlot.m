classdef PhoSmoothLegendPlot < matlab.graphics.chartcontainer.ChartContainer & ...
        matlab.graphics.chartcontainer.mixin.Legend
	%% Most Modern 2020b Format
    properties
        XData (1,:) double = NaN
        YData (1,:) double = NaN
        SmoothColor (1,3) double {mustBeGreaterThanOrEqual(SmoothColor,0),...
            mustBeLessThanOrEqual(SmoothColor,1)} = [0.9290 0.6940 0.1250]
        SmoothWidth (1,1) double = 2
    end
    properties(Access = private,Transient,NonCopyable)
        OriginalLine (1,1) matlab.graphics.chart.primitive.Line
        SmoothLine (1,1) matlab.graphics.chart.primitive.Line
    end
    
    methods(Access = protected)
        function setup(obj)
            ax = getAxes(obj);
            
            % Create line objects. Define line styles and legend names.
            obj.OriginalLine = plot(ax,NaN,NaN,'LineStyle',':',...
                'DisplayName','Original');
            hold(ax,'on')
            obj.SmoothLine = plot(ax,NaN,NaN,...
                'DisplayName','Smooth');
            
            % Make legend visible
            obj.LegendVisible = 'on';
            
            % Get legend and set text color, edge color, and line width
            lgd = getLegend(obj);
            lgd.TextColor = [.3 .3 .3];
            lgd.EdgeColor = [.8 .8 .8];
            lgd.LineWidth = .7;
            hold(ax,'off')
        end
        function update(obj)
            % Update Line data
            obj.OriginalLine.XData = obj.XData;
            obj.OriginalLine.YData = obj.YData;
            obj.SmoothLine.XData = obj.XData;
            obj.SmoothLine.YData = createSmoothData(obj);
            
            % Adjust smooth line appearance
            obj.SmoothLine.LineWidth = obj.SmoothWidth;
            obj.SmoothLine.Color = obj.SmoothColor;
        end
        function sm = createSmoothData(obj)
            % Calculate smoothed data
            v = ones(1,10)*0.1;
            sm = conv(obj.YData,v,'same');
        end
    end
end