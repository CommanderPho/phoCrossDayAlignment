classdef ConfidenceChart < matlab.graphics.chartcontainer.ChartContainer
    properties
        XData = NaN
        YData = NaN
        ConfidenceMargin = 0.15
        MarkerSymbol = 'o'
        Color = [1 0 0]
    end
    properties(Access = private,Transient,NonCopyable)
        LineObject
        PatchObject
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

