classdef PlotData_Cartesian < PlotDataBase
    %PlotData_Cartesian Contains information about the potentially displayed plots
    %   Detailed explanation goes here

    properties
	  % Chart x-data.
        XData = NaN
        % Chart y-data.
        YData = NaN
		

		% Optional Chart Colormap
		Colormap = NaN
    end

	%% Internal Properties
    % properties (Access = protected, Transient, NonCopyable)
    %     % The handle to the figure window
    %     FigureWindow (1,1) matlab.ui.Figure;
                
    % end %properties

	methods (Access = public)

		% function obj = PlotData_Cartesian(plot_identifier, plot_callback, plot_figure_handle)
		function obj = PlotData_Cartesian(plot_identifier, should_show, aColor, XData, YData, Colormap, varargin)
			%PlotData_Cartesian Construct an instance of this class
			
			% Call superclass constructor method
			args = varargin;
			obj@PlotDataBase(plot_identifier, should_show, aColor, args{:});

			if exist('XData','var')
				obj.XData = XData;
			end
			if exist('YData','var')
				obj.YData = YData;
			end
			if exist('Colormap','var')
				obj.Colormap = Colormap;
			end

		end


		function obj = updateData(obj, x_data, y_data)
			obj.XData = x_data;
			obj.YData = y_data;
		end


    end


end