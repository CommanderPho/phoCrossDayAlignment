classdef Chart_Mixin_Selectable < matlab.mixin.SetGet
    %Chart_Mixin_Selectable Contains information about the potentially displayed plots
    %   Detailed explanation goes here


	events (ListenAccess = public, NotifyAccess = protected) 
		% GraphicsObjectCreated

		% GraphicsObjectAdded
		SelectionUpdated % c = InteractivePolygonRoiChart(f,'SelectionUpdatedFcn',@(o,e)disp('Changed'))
	%     LineObjectAdded % c = MyChart('SelectionUpdatedFcn',@myfunction)
		% GraphicsObjectDeleted
		%  % Execute User callbacks and listeners
    	% notify(obj,'SelectionUpdated');

		
	end 



	% properties (Abstract)
	% 	Selectables
	% end

	methods (Abstract)
		% Abstract method without implementation
		result = get_selectables(obj)
   	end

    properties (SetAccess = protected)

		% get_selectables_callback
	
		%% Selection
		% SelectedIndicies (:, 1)
        isItemSelected (:, 1) logical
		% NumSelectableItems (1,1)
    end

	methods %% Setters Method block
    %    function obj = set.get_selectables_callback(obj, value)
    %        obj.get_selectables_callback = value;

    %        % When the get_selectables_callback is set, rebuild the variables.
    %        obj.rebuildSelectables();
    %    end  
    end % end setters method block



 %% Computed Properties:
    properties (Dependent)
        num_selectable_items
        num_selected_items
        % selected_cellROI_uniqueCompListIndicies
        % selected_cellROI_roiNames
    end
    
    methods
       function num_selectable_items = get.num_selectable_items(obj)
          num_selectable_items = numel(obj.isItemSelected);
       end
       function num_selected_items = get.num_selected_items(obj)
          num_selected_items = sum(obj.isItemSelected, 'all');
       end
    end











	methods (Access = public)

		function obj = Chart_Mixin_Selectable(obj)
			% obj.get_selectables_callback = get_selectables_callback;
		end

    end % end Public Methods block


	methods(Access = public)

	    %% Selection Methods:
        function [obj, newIsSelected] = toggleItemIsSelected(obj, itemIndex)
            %toggleItemIsSelected Summary of this method goes here
            %   uniqueCompListIndex: cellROI to update selection status of
            newIsSelected = ~obj.isItemSelected(itemIndex);
            obj.updateItemIsSelected(itemIndex, newIsSelected);
        end
        
        function obj = updateItemIsSelected(obj, itemIndex, newIsSelected)
            %updateItemIsSelected Summary of this method goes here
            %   itemIndex: cellROI to update selection status of
            %   newIsSelected: new selection status
            obj.isCellRoiSelected(itemIndex) = newIsSelected;
			notify(obj,'SelectionUpdated');
        end



		% function mixinContainerDyPropEvtCb(obj, src, evt)
		% 	% fprintf('callback in plottingOptions!\n');
		% end

		% function [obj] = mixinContainerDyPropEvtCb(obj, src, evt)
		% 	fprintf('callback in plottingOptions!');
		% end

	end % end protected Methods block


	methods(Access = protected)

		function [obj] = rebuildSelectables(obj)
			curr_selectables = obj.get_selectables();
			num_new_selectables = length(curr_selectables);
			% num_new_selectables = length(obj.get_selectables_callback());
			obj.isItemSelected = zeros([num_new_selectables 1], 'logical');
			notify(obj,'SelectionUpdated');
		end

	end


end % end classdef PlotData_Mixin_PlottingOptions