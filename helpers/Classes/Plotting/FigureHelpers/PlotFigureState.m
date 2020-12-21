classdef PlotFigureState < handle
    %PlotFigureState Contains information about the potentially displayed plots
    %   Detailed explanation goes here

    properties
      plot_identifier
	  plot_update_callback_function
	  should_show = true;
    end

	%% Internal Properties
    properties (Access = protected, Transient, NonCopyable)
        % The handle to the figure window
        FigureWindow (1,1) matlab.ui.Figure;
                
    end %properties

	methods (Access = public)

		% function obj = PlotFigureState(plot_identifier, plot_callback, plot_figure_handle)
		function obj = PlotFigureState(plot_identifier, should_show, plot_callback)
			%PlotFigureState Construct an instance of this class
			%   Detailed explanation goes here
			obj.plot_identifier = plot_identifier;
			obj.should_show = should_show;
			
			% obj.FigureWindow = plot_figure_handle;
			% obj.plot_update_callback_function = plot_callback;

			obj.FigureWindow = createUIFigureWithTagIfNeeded(obj.plot_identifier);
			% obj.FigureWindow = createFigureWithTagIfNeeded(obj.plot_identifier);
			obj.plot_update_callback_function = @(curr_i) plot_callback(obj.FigureWindow, curr_i);
			% obj.plot_update_callback_function = @(curr_i) (pho_plot_stimulus_traces(final_data_explorer_obj, obj.FigureWindow, curr_i));

			obj.closeFig(obj.FigureWindow);

		end


		function obj = Update(obj, curr_i)
			obj.FigureWindow.Visible = obj.should_show;
			if obj.should_show
				obj.plot_update_callback_function(curr_i);
			end
		end


		function closeFig(obj, fig)
			fig.CloseRequestFcn = @(fig,event)my_closereq(fig);

			function my_closereq(fig, selection)
				selection = uiconfirm(fig,'Close the figure window?','Confirmation');
				switch selection
					case 'OK'
						delete(fig)
					case 'Cancel'
						return
				end % end switch
			end % end my_closereq


		end % end closeFig


		function setMousePointer(obj, fig)
			fig.WindowButtonMotionFcn = @mouseMoved;

			btn = uibutton(fig);
			btnX = 50;
			btnY = 50;
			btnWidth = 100;
			btnHeight = 22;
			btn.Position = [btnX btnY btnWidth btnHeight];
			btn.Text = 'Submit Changes';

			function mouseMoved(src,event)
				mousePos = fig.CurrentPoint;

				if  (mousePos(1) >= btnX) && (mousePos(1) <= btnX + btnWidth) ...
								&& (mousePos(2) >= btnY) && (mousePos(2) <= btnY + btnHeight)

					fig.Pointer = 'hand';
				else

					fig.Pointer = 'arrow';
				end

			end % end mouseMoved

		end % end setMousePointer

    end


	methods (Static)
	  function singleObj = getInstance(pipelineOptions)
		 persistent localObj
		 if isempty(localObj) || ~isvalid(localObj)
			localObj = PipelineInteractionState(pipelineOptions);
		 end
		 singleObj = localObj;
      end
      
      function EnhancedCallback(currObj, currIndex, original_callback)
            original_callback(currObj, currIndex);
            fprintf('done.\n');	
            currObj.completeStage(currIndex)
      end
        
   end


end % end classdef PlotFigureState