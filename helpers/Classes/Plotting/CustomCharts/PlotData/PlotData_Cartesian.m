classdef PlotData_Cartesian < PlotDataBase % & PlotData_Mixin_Selectable
    %PlotData_Cartesian Contains information about the potentially displayed plots
    %   Detailed explanation goes here

    properties
	  % Chart x-data.
        XData = NaN
        % Chart y-data.
        YData = NaN
		
		% Optional Chart Colormap
		ColorData = NaN
    end

	properties (Dependent)
		num_datapoints
	end
	methods
		function num_datapoints = get.num_datapoints(obj)
          num_datapoints = length(obj.XData);
       end
	end % end Dependent properties method block




	%% Internal Properties
    % properties (Access = protected, Transient, NonCopyable)
    %     % The handle to the figure window
    %     FigureWindow (1,1) matlab.ui.Figure;
                
    % end %properties

	methods (Access = public)

		% function obj = PlotData_Cartesian(plot_identifier, plot_callback, plot_figure_handle)
		function obj = PlotData_Cartesian(plot_identifier, should_show, aColor, XData, YData, ColorData, varargin)
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
			if exist('ColorData','var')
				obj.ColorData = ColorData;
			end

		end


		function obj = updateData(obj, x_data, y_data, c_data)
			obj.XData = x_data;
			obj.YData = y_data;
			
			if exist('c_data','var')
				obj.ColorData = c_data;
			else
				obj.ColorData = repmat(obj.plottingOptions.CData, size(obj.XData));
			end

			% if obj.plottingOptions.CData
			% 	curr_color_data = repmat(obj.plottingOptions.CData, size(obj.XData));
			% 	obj.plottingOptions.CData = curr_color_data;
			% end
		end


    end



end