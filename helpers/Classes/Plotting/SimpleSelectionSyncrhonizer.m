classdef SimpleSelectionSyncrhonizer < handle
    %SimpleSelectionSyncrhonizer A wrapper around a handle object with a 'Position' property, like a figure
    %   TODO: this should really be refactored into a pure object, not one based on the handle.
    
    properties
        handle
    end
    
    %% Computed Properties:
    properties (Dependent)
        position
        x
        y
        width
        height
    end
    
    methods
       function position = get.position(obj)
          position = get(obj.handle, 'Position');
       end
       function x = get.x(obj)
          x = obj.position(1);
       end
       function y = get.y(obj)
          y = obj.position(2);
       end
       function width = get.width(obj)
          width = obj.position(3);
       end
       function height = get.height(obj)
          height = obj.position(4);
       end
    end
    
    % Main methods block:
    methods
        function obj = SimpleSelectionSyncrhonizer(figureH)
            %SimpleSelectionSyncrhonizer Construct an instance of this class
            %   Detailed explanation goes here
            obj.handle = figureH;
        end
        
    end






	methods (Static)

		function out = fnPlotHelper_RegisterSelectionSynchronizingFigure(curr_figure, should_remove)
            if ~exist('should_remove','var')
               should_remove = false; 
            end
            
			persistent SynchronizedFiguresList
			if isempty(SynchronizedFiguresList)
                if should_remove
                   error('Tried to remove a figure from an empty SynchronizedFiguresList');
                end
				if (nargin > 0)
					SynchronizedFiguresList = [curr_figure];
				else
					SynchronizedFiguresList = [];
				end
			else
				if (nargin > 0)
                    if should_remove
                        figure_index_to_remove = -1;
                        for i = 1:length(SynchronizedFiguresList)
                           if (SynchronizedFiguresList(i) == curr_figure)
                               figure_index_to_remove = i;
                               break;
                           end
                        end
                        
                        if figure_index_to_remove > 0
                            fprintf('Removing figure with index %d from SynchronizedFiguresList.\n', figure_index_to_remove);
                            SynchronizedFiguresList(figure_index_to_remove) = [];
                        else
                            error('could not remove the figure specified!');
                        end
                    else
                        % Otherwise we're adding the figure
                        SynchronizedFiguresList(end+1) = curr_figure; % Add the current figure to the end
                    end
				end
			end
			out = SynchronizedFiguresList;
        end

        function out = fnPlotHelper_UnregisterSelectionSynchronizingFigure(a_figure)
			out = SimpleSelectionSyncrhonizer.fnPlotHelper_RegisterSelectionSynchronizingFigure(a_figure, true);
        end

        % TODO: refactor how this is done
%         function out = fnPlotHelper_UnregisterAllInvalidSelectionSynchronizingFigures()
%             curr_registered_figures = SimpleSelectionSyncrhonizer.fnPlotHelper_RegisterSelectionSynchronizingFigure;
%             is_figure_valid = (isvalid(curr_registered_figures) && isgraphics(curr_registered_figures));
% 			out = SimpleSelectionSyncrhonizer.fnPlotHelper_RegisterSelectionSynchronizingFigure(a_figure, true);
%         end                

		function fnPlotHelper_UpdateSelectionsForAllRegisteredFigures(initiating_update_figH)
			[~, updated_desired_is_selected] = SimpleSelectionSyncrhonizer.fnPlotHelper_FindSelectedSubplots(initiating_update_figH);
			curr_registered_figures = SimpleSelectionSyncrhonizer.fnPlotHelper_RegisterSelectionSynchronizingFigure;
            found_invalid_figures = [];
			for i = 1:length(curr_registered_figures)
				curr_reg_fig_H = curr_registered_figures(i);
                if isvalid(curr_reg_fig_H) && isgraphics(curr_reg_fig_H)
                    if (initiating_update_figH ~= curr_reg_fig_H) % If it differs from the figure that triggered the update
                        SimpleSelectionSyncrhonizer.fnPlotHelper_SetSubplotSelections(curr_reg_fig_H, updated_desired_is_selected);
                    end
                else
                    % Otherwise remove the invalid figure
                    found_invalid_figures(end+1) = curr_reg_fig_H;
                    
                end
            end % end for
            
            % Remove invalid figures
            for i = 1:length(found_invalid_figures)
               curr_reg_invalid_fig_H = found_invalid_figures(i);
               SimpleSelectionSyncrhonizer.fnPlotHelper_UnregisterSelectionSynchronizingFigure(curr_reg_invalid_fig_H);
            end
		end


		function [updatedSelectionStatus] = fnPlotHelper_ToggleSubplotSelection(curr_subplot_axes)
			stimulusTagNum = str2num(curr_subplot_axes.Tag); 
			% fprintf('fnPlotHelper_ToggleSubplotSelection(...): subplot corresponding to stimulus %d\n', stimulusTagNum);
			prev_was_selected = curr_subplot_axes.Selected;
			updatedSelectionStatus = ~prev_was_selected;
			SimpleSelectionSyncrhonizer.fnPlotHelper_UpdateSelectedSubplot(curr_subplot_axes, updatedSelectionStatus);
			SimpleSelectionSyncrhonizer.fnPlotHelper_UpdateSelectionsForAllRegisteredFigures(curr_subplot_axes.Parent); %% TODO: get the figure from the curr_subplot_axes in the future
		end

		function fnPlotHelper_UpdateSelectedSubplot(curr_subplot_axes, is_selected)
			curr_subplot_axes.Selected = is_selected;
			if curr_subplot_axes.Selected
				box(curr_subplot_axes,'on');
				% Set the remaining axes properties
				set(curr_subplot_axes,'BoxStyle','full','LineWidth',2,'Color',[0.941176470588235 0.941176470588235 0.941176470588235],'XColor',...
					[0.301960784313725 0.745098039215686 0.933333333333333],'YColor',...
					[0.301960784313725 0.749019607843137 0.929411764705882]);
			else
				box(curr_subplot_axes,'off');
				% Set the remaining axes properties
				set(curr_subplot_axes,'BoxStyle','full','LineWidth',0.5,'Color',[1 1 1],'XColor',...
					[0.15,0.15,0.15],'YColor',...
					[0.15,0.15,0.15]);
			end
			
		end

		
		function [imagePlotHandles, desiredSelections] = fnPlotHelper_SetSubplotSelections(curr_figure, desiredSelections)
			[imagePlotHandles, curr_selected] = SimpleSelectionSyncrhonizer.fnPlotHelper_FindSelectedSubplots(curr_figure);
			if length(curr_selected) ~= length(desiredSelections)
				error('desiredSelections and curr_selected should be the same length!');
			end

			for i = 1:length(desiredSelections)
				did_selection_change = (curr_selected(i) ~= desiredSelections(i));
				if did_selection_change
					SimpleSelectionSyncrhonizer.fnPlotHelper_UpdateSelectedSubplot(imagePlotHandles(i), desiredSelections(i));
				end
			end
		end


		function [imagePlotHandles, is_selected] = fnPlotHelper_FindSelectedSubplots(curr_figure)
			found_axHandles = findall(curr_figure,'Type','axes');
			num_desired_axes = 26;

			imagePlotHandles = gobjects(num_desired_axes, 1);
			is_selected = zeros([length(imagePlotHandles) 1]);
			num_found_axes = 0;

			for i = 1:length(found_axHandles)
				curr_axH = found_axHandles(i);
				foundUserData = curr_axH.UserData;
% 				disp(foundUserData)
				if ~isempty(foundUserData) && strcmpi(foundUserData.Type, 'stimulusAxes')
					% stimulusTagNum = str2num(curr_axH.Tag);
					stimulusTagNum = foundUserData.Index;
					imagePlotHandles(stimulusTagNum) = curr_axH;
					is_selected(stimulusTagNum) = curr_axH.Selected;
					num_found_axes = num_found_axes + 1;
				else
					fprintf('Warning: found_axHandle %d was not correct. Skipping.\n', i);
				end
			end % end for

			if (num_found_axes < num_desired_axes)
				warning('Could not get all of the axes!');
			end

		end




	end % end methods static





end