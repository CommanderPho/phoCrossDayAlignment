
classdef InteractivePolygonRoiChart < PolygonRoiChart 
	
	events (HasCallbackProperty, NotifyAccess = protected) 
        SelectionChanged % c = InteractivePolygonRoiChart(f,'SelectionChangedFcn',@(o,e)disp('Changed'))
        Clicked % c = MyChart('ClickedFcn',@myfunction)
	
		%  % Execute User callbacks and listeners
    	% notify(obj,'ValueChanged');
	end 


	methods(Access = public)
		function obj = InteractivePolygonRoiChart(plotDataSeries, plotConfig, varargin)
			% Convert x, y, and margin into name-value pairs
			% args = {'plotDataSeries', plotDataSeries};
				
			% Combine args with user-provided name-value pairs
			% args = [args varargin];
			args = varargin;
				
			% Call superclass constructor method
			obj@PolygonRoiChart(plotDataSeries, plotConfig, args{:});
		end

	end % end public methods block


	%% ChartContainer required methods block:
	methods(Access = protected)

		function onPlotAdded(obj, added_index, recently_added_graphics_object)
			% fprintf('InteractivePolygonRoiChart.onPlotAdded(added_index: %d, ...)\n', added_index);
			% Add a callback for clicks on the bottom axes.
            % recently_added_graphics_object.ButtonDownFcn = @(~, ~) click(obj);
			obj.PolygonObjects(added_index).ButtonDownFcn = @obj.onClickCallback;
			% recently_added_graphics_object.ButtonDownFcn = @obj.onClickCallback;
		end


	

		% function setup(~)
		% 	% Don't do anything in setup(~) because Mathworks broke it!
		% 	setup@PolygonRoiChart(obj);
		% end
	
% 		function update(obj)
% 			update@PolygonRoiChart(obj);
% 			ax = getAxes(obj);
% 			% Create a dataTipTextRow for each variable in the timetable.
% %             obj.updateDataTipTemplate(ax, tbl)

% 		end


		function onClickCallback(obj, src, eventData)
			fprintf('InteractivePolygonRoiChart.onClickCallback(...)\n');
			notify(obj,'Clicked');
		end

% 		function updateDataTipTemplate(obj, axes, tbl)
% 			% Create a dataTipTextRow for each variable in the timetable.
% 			timeVariable = tbl.Properties.DimensionNames{1};
% 			rows = dataTipTextRow(timeVariable, tbl.(timeVariable));
% 			for n = 1:numel(tbl.Properties.VariableNames)
% 				rows(n+1,1) = dataTipTextRow(...
% 					tbl.Properties.VariableNames{n}, tbl{:,n});
% 			end
% 			obj.DataTipTemplate.DataTipRows = rows;
% 		end

	end % end main protected method block





end % end classdef