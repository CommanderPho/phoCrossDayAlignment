classdef PlotData_Mixin_PlottingOptions < matlab.mixin.SetGet
    %PlotData_Mixin_PlottingOptions Contains information about the potentially displayed plots
    %   Detailed explanation goes here
	% properties (Hidden)
    %   propertyAddedListener
	%   propertyRemovedListener
   	% end

    properties
        plottingOptions (:,1) DynamicPlottingOptionsContainer
    end

	%% Internal Properties
    % properties (Access = protected, Transient, NonCopyable)
    %     % The handle to the figure window
    %     FigureWindow (1,1) matlab.ui.Figure;
                
    % end %properties

	methods (Access = public)

		function obj = PlotData_Mixin_PlottingOptions(varargin)

			% Convert x, y, and margin into name-value pairs
			% args = {'plotDataSeries', plotDataSeries};
				
			% Combine args with user-provided name-value pairs
			% args = [args varargin];
			args = varargin;
			% obj.plottingOptions = DynamicPlottingOptionsContainer(@(src, evt) (obj.mixinContainerDyPropEvtCb(src, evt)), args{:});
			obj.plottingOptions = DynamicPlottingOptionsContainer( {@(src, evt) obj.mixinContainerDyPropEvtCb(src, evt)} );

			% obj.plottingOptions = DynamicPlottingOptionsContainer(@mixinContainerDyPropEvtCb);
			% obj.plottingOptions = DynamicPlottingOptionsContainer();
			obj.plottingOptions.addVariableArgumentsList(args{:});
		end

    end % end Public Methods block


	methods(Access = public)

		function mixinContainerDyPropEvtCb(obj, src, evt)
			% fprintf('callback in plottingOptions!\n');
		end

		% function [obj] = mixinContainerDyPropEvtCb(obj, src, evt)
		% 	fprintf('callback in plottingOptions!');
		% end

	end % end protected Methods block

end % end classdef PlotData_Mixin_PlottingOptions