classdef PlotDataBase < handle
    %PlotDataBase Contains information about the potentially displayed plots
    %   Detailed explanation goes here

    properties
      	plot_identifier = '';
	  	should_show = true;
	  % Optional Dataseries Color:
		Color = [1 0 0]; % default to red

    end

	%% Internal Properties
    % properties (Access = protected, Transient, NonCopyable)
    %     % The handle to the figure window
    %     FigureWindow (1,1) matlab.ui.Figure;
                
    % end %properties

	methods (Access = public)

		% function obj = PlotDataBase(plot_identifier, plot_callback, plot_figure_handle)
		function obj = PlotDataBase(plot_identifier, should_show, aColor)
			%PlotDataBase Construct an instance of this class
			%   Detailed explanation goes here
			obj.plot_identifier = plot_identifier;
			obj.should_show = should_show;
			if exist('aColor','var')
				obj.Color = aColor;
			end
		end




    end


end