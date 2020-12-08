classdef CellRoiPlotManager < PlotManager
    %CELLROIPLOTMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        interaction_helper_obj % InteractionHelper
        
        %% Graphical:
        Colors
		GraphicalSelection
		plottingSettings
        
        testCellROIBlob_Plot_figH
		activeOffsetInsetIndicies = []; % activeOffsetInsetIndicies: the insets to display
		acitveColorsArray = {}; % acitveColorsArray: the colors corresponding to the edge Offset/Insets in activeOffsetInsetIndicies

        extantFigH_plot_2d
        extantFigH_plot_3d
        extantFigH_plot_stimulus_traces

    end
    
    %% Computed Properties:
    properties (Dependent)
        final_data_explorer_obj % FinalDataExplorer
		number_of_cellROI_plotSubGraphics % The number of graphics objects belonging to each cellROI. For example, these might be the fill, the edge, and several inset/outset edge objects
        

    end
    methods
       function final_data_explorer_obj = get.final_data_explorer_obj(obj)
          final_data_explorer_obj = obj.interaction_helper_obj.final_data_explorer_obj;
       end
       function number_of_cellROI_plotSubGraphics = get.number_of_cellROI_plotSubGraphics(obj)
          number_of_cellROI_plotSubGraphics = length(obj.activeOffsetInsetIndicies);
		  if obj.plottingSettings.should_plot_neuropil_masks
			number_of_cellROI_plotSubGraphics = number_of_cellROI_plotSubGraphics + 1;
		  end
       end
%        function extantFigH_plot_2d = get.extantFigH_plot_2d(obj)
%           extantFigH_plot_2d = createFigureWithTagIfNeeded('CellRoiPlotManager_ROI_Plot_2D'); % generate a new figure to plot the sessions.
%        end
% 	   function extantFigH_plot_3d = get.extantFigH_plot_3d(obj)
%           extantFigH_plot_3d = createFigureWithTagIfNeeded('CellRoiPlotManager_ROI_Plot_3D_Mesh'); % generate a new figure to plot the sessions.
%        end
% 	   function extantFigH_plot_stimulus_traces = get.extantFigH_plot_stimulus_traces(obj)
%           extantFigH_plot_stimulus_traces = createFigureWithTagIfNeeded('CellRoiPlotManager_ROI_Plot_StimulusTraces'); % generate a new figure to plot the sessions.
%        end
    end
    
    
    %% Main Methods Block:
    methods
        function obj = CellRoiPlotManager(final_data_explorer_obj, active_selections_backingFile_path)
            %CELLROIPLOTMANAGER Construct an instance of this class
            %   Detailed explanation goes here
            
            % Call PlotManager constructor:
            obj@PlotManager([]);
            
            %% Build Interaction Helper Object:
            obj.interaction_helper_obj = InteractionHelper(final_data_explorer_obj, 'Pho', active_selections_backingFile_path);
%             active_selections_backingFile_path = obj.interaction_helper_obj.BackingFile.fullPath;

			obj.plottingSettings.should_plot_neuropil_masks = true;

            % Build Colors Arrays:
			obj = obj.SetupColors();
            
        end
        
        function obj = SetupColors(obj)
			% SetupColors: Build Color Matricies
			desiredSize = [512 512];
			obj.Colors.black3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.0], desiredSize);
			obj.Colors.darkgrey3DArray = fnBuildCDataFromConstantColor([0.3 0.3 0.3], desiredSize);
			obj.Colors.lightgrey3DArray = fnBuildCDataFromConstantColor([0.6 0.6 0.6], desiredSize);

			obj.Colors.orange3DArray = fnBuildCDataFromConstantColor([0.9 0.3 0.1], desiredSize);

			obj.Colors.red3DArray = fnBuildCDataFromConstantColor([1.0 0.0 0.0], desiredSize);
			obj.Colors.green3DArray = fnBuildCDataFromConstantColor([0.0 1.0 0.0], desiredSize);
			obj.Colors.blue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 1.0], desiredSize);

			obj.Colors.darkRed3DArray = fnBuildCDataFromConstantColor([0.6 0.0 0.0], desiredSize);
			obj.Colors.darkGreen3DArray = fnBuildCDataFromConstantColor([0.0 0.6 0.0], desiredSize);
			obj.Colors.darkBlue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.6], desiredSize);

			obj.acitveColorsArray = {obj.Colors.lightgrey3DArray, ...
				obj.Colors.darkBlue3DArray, obj.Colors.darkGreen3DArray, obj.Colors.darkRed3DArray, ...
				obj.Colors.black3DArray, ...
				obj.Colors.red3DArray, obj.Colors.green3DArray, obj.Colors.blue3DArray};
        end
        
    end % ends MAIN Methods Block

    %% Graphical Methods Block:
    methods 

		function obj = setupGraphicalSelectionTable(obj)
			% Add the toolbar for selection operations:
			obj.interaction_helper_obj.setupGraphicalSelectionTable();
		end

        function obj = setupGraphicalSelectionFigure(obj, activeFigure, imagePlotHandles)
            %setupGraphicalSelectionFigure 
            %   activeFigure: 
            %   imagePlotHandles: 
			obj.interaction_helper_obj.selectionOptions.shouldHideSelectedRois = false;

            obj.GraphicalSelection.activeFigure = activeFigure;
            obj.GraphicalSelection.imagePlotHandles = imagePlotHandles;

			% Add the toolbar for selection operations:
			obj.interaction_helper_obj.setupGraphicalSelectionToolbar(activeFigure, @() (obj.updateGraphicalAppearances()) );
		end	

		%% Update Selections graphically:
		function obj = updateGraphicalAppearance(obj, uniqueCompIndex)
            %updateGraphicalSelection: updates a single cellROI 
			curr_cellROI_IsSelected = obj.interaction_helper_obj.isCellRoiSelected(uniqueCompIndex);

			curr_imagePlot_handles = obj.GraphicalSelection.imagePlotHandles(uniqueCompIndex, :);
            are_invalid_plot_handles = ~isvalid(curr_imagePlot_handles);
            num_invalid_plot_handles = sum(are_invalid_plot_handles,'all');
            if (num_invalid_plot_handles > 0)
               fprintf('%d plot handles were invalid. removing them...\n', num_invalid_plot_handles);
%                obj.GraphicalSelection.imagePlotHandles(uniqueCompIndex, are_invalid_plot_handles) = []; % Remove from the array
               obj.GraphicalSelection.imagePlotHandles(uniqueCompIndex, :) = [];
%                curr_imagePlot_handles = obj.GraphicalSelection.imagePlotHandles(uniqueCompIndex, :);
               curr_imagePlot_handles = [];
            end
            
			for plotImageIndex = 1:length(curr_imagePlot_handles)
%                 if isvalid(curr_imagePlot_handles(plotImageIndex))
                    curr_cellROI_appearance = obj.getGraphicalAppearance(uniqueCompIndex, plotImageIndex);
                    curr_im_h = curr_imagePlot_handles(plotImageIndex);
                    %         set(curr_sel_fill_im_h,'CData', updated_color_data, 'AlphaData', curr_cellROI_appearance.AlphaData);
                    set(curr_im_h,'CData', curr_cellROI_appearance.CData, 'Visible', curr_cellROI_appearance.is_visible);
%                 else
%                     % Probably remove it so this doesn't happen again
%                     continue
%                 end % end if isvalid

            end % end for

        end

		function obj = updateGraphicalAppearances(obj)
            %updateGraphicalAppearances 
            disp('CellRoiPlotManager.updateGraphicalAppearances()')
            % Loop through all cellROIs and update the graphical selection according to the isSelectedIndex
			for i = 1:size(obj.GraphicalSelection.imagePlotHandles, 1)
				obj = obj.updateGraphicalAppearance(i);
			end
			drawnow;
            % update the table:
			obj.interaction_helper_obj.updateGraphicalSelectionTable();
        end

		%% Update Selections graphically:
		function [graphicalAppearance] = getGraphicalAppearance(obj, uniqueCompIndex, plotImageIndex)
            %updateGraphicalSelection: updates a single cellROI 
			% returns:
			% graphicalAppearance
			%	is_visible
			% 	CData: optional
			%	AlphaData: optional

			graphicalAppearance.is_visible = true;

			is_neuropil_layer = (obj.plottingSettings.should_plot_neuropil_masks && (obj.number_of_cellROI_plotSubGraphics == plotImageIndex));
			if is_neuropil_layer
				
				updated_color_data = obj.Colors.darkgrey3DArray;

			else

				edgeOffsetIndex = obj.activeOffsetInsetIndicies(plotImageIndex);
				is_fill_layer = isnan(edgeOffsetIndex);

				curr_cellROI_IsSelected = obj.interaction_helper_obj.isCellRoiSelected(uniqueCompIndex);
				% updated_alpha_data = obj.interaction_helper_obj.final_data_explorer_obj.getFillRoiMask(uniqueCompIndex);

				if is_fill_layer
					% If it's a fill layer:
					if curr_cellROI_IsSelected
			%             updated_alpha_data = updated_alpha_data .* 0.9;
						updated_color_data = obj.Colors.orange3DArray;
						if obj.interaction_helper_obj.selectionOptions.shouldHideSelectedRois
							graphicalAppearance.is_visible = false;
						end
					else
			%             updated_alpha_data = updated_alpha_data .* 0.5;
						updated_color_data = obj.Colors.lightgrey3DArray;
					end
				else
					% If it's an edge, use its edge color
					updated_color_data = obj.acitveColorsArray{plotImageIndex};
					if curr_cellROI_IsSelected
						if obj.interaction_helper_obj.selectionOptions.shouldHideSelectedRois
							graphicalAppearance.is_visible = false;
						end
					end
					
				end


			end

			graphicalAppearance.CData = updated_color_data;
			% graphicalAppearance.AlphaData = updated_alpha_data;
        end
    end % end graphical update methods
    
    
    %% Plots Methods Block:
    methods

		% Primary Plot Function
		function [obj] = plotTestCellROIBlob(obj)
			obj.testCellROIBlob_Plot_figH = createFigureWithNameIfNeeded('CellROI Blobs Testing'); % generate a new figure to plot the sessions.
			clf(obj.testCellROIBlob_Plot_figH);

			imagePlotHandles = gobjects(obj.final_data_explorer_obj.num_cellROIs, obj.number_of_cellROI_plotSubGraphics);

			for i = 1:obj.final_data_explorer_obj.num_cellROIs
				cellROIIdentifier.uniqueRoiIndex = i;
				cellROIIdentifier.roiName = obj.final_data_explorer_obj.cellROIIndex_mapper.getRoiNameFromUniqueCompIndex(i);

				for plotImageIndex = 1:obj.number_of_cellROI_plotSubGraphics
					currPlotSubGraphicsIdentifier.cellROIIdentifier = cellROIIdentifier;
					
					is_neuropil_index = (obj.plottingSettings.should_plot_neuropil_masks && (obj.number_of_cellROI_plotSubGraphics == plotImageIndex));
					if is_neuropil_index
						% Neuropil Mask Plotting (optional):
						currPlotSubGraphicsIdentifier.edgeOffsetIndex = nan;
						currPlotSubGraphicsIdentifier.type = 'NeuropilMask';
						imagePlotHandles(i, plotImageIndex) = image('CData', obj.Colors.darkgrey3DArray, 'AlphaData', (0.9 * obj.final_data_explorer_obj.getNeuropilRoiMask(i)));
						curr_tag_string = fnBuildCellRoiPlotTagString(cellROIIdentifier, nan, 'NeuropilMask');

					else
						% Non-neuropil layer:
						currPlotSubGraphicsIdentifier.edgeOffsetIndex = obj.activeOffsetInsetIndicies(plotImageIndex);

						if isnan(currPlotSubGraphicsIdentifier.edgeOffsetIndex)
							% For the fill layer, the edgeOffsetIndex is nan
							currPlotSubGraphicsIdentifier.type = 'Fill';
							imagePlotHandles(i, plotImageIndex) = image('CData', obj.acitveColorsArray{plotImageIndex}, 'AlphaData', (0.5 * obj.final_data_explorer_obj.getFillRoiMask(i)));
						else
							currPlotSubGraphicsIdentifier.type = 'Edge';
							imagePlotHandles(i, plotImageIndex) = image('CData', obj.acitveColorsArray{plotImageIndex}, 'AlphaData', obj.final_data_explorer_obj.getEdgeOffsetRoiMasks(currPlotSubGraphicsIdentifier.edgeOffsetIndex, i));
						end

						curr_tag_string = fnBuildCellRoiPlotTagString(cellROIIdentifier, obj.activeOffsetInsetIndicies(plotImageIndex));

					end % end if is_neuropil_index

					set(imagePlotHandles(i, plotImageIndex), 'UserData', currPlotSubGraphicsIdentifier);
					set(imagePlotHandles(i, plotImageIndex), 'Tag', curr_tag_string);

				end % end for number_of_cellROI_plotSubGraphics


			end % end for cellROIs
			
			title('Combined Insets and Outsets')
			set(gca,'xtick',[],'YTick',[])
			set(gca,'xlim',[1 512],'ylim',[1 512])

			%% Build Interaction Helper Object:
			obj.setupGraphicalSelectionFigure(obj.testCellROIBlob_Plot_figH, imagePlotHandles);

			dcm = datacursormode(obj.testCellROIBlob_Plot_figH);
			dcm.Enable = 'on';
			dcm.DisplayStyle = 'window';
			if exist('slider_controller','var')
				dcm.UpdateFcn = @(figH, info) (obj.testCellROIBlob_Plot_Callback(figH, info, obj.interaction_helper_obj, slider_controller));
			else
				dcm.UpdateFcn = @(figH, info) (obj.testCellROIBlob_Plot_Callback(figH, info, obj.interaction_helper_obj));
			end

		end % end plotTestCellROIBlob


		function [obj] = pho_plot_2d(obj, curr_cellRoiIndex)
			obj.extantFigH_plot_2d = createFigureWithTagIfNeeded('CellROI 2D Plot'); % generate a new figure to plot the sessions.
			clf(obj.extantFigH_plot_2d);

			temp.currAllSessionCompIndicies = obj.final_data_explorer_obj.multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI
			% Make 2D Plots (Exploring):    
			[plotted_figH, ~] = fnPlotTunedStimulusPeaks(obj.final_data_explorer_obj.dateStrings, obj.final_data_explorer_obj.uniqueAmps, obj.final_data_explorer_obj.uniqueFreqs, ...
				 temp.currAllSessionCompIndicies, curr_cellRoiIndex, ...
				 obj.final_data_explorer_obj.finalOutPeaksGrid, obj.extantFigH_plot_2d);

			set(plotted_figH, 'Name', sprintf('CellROI 2D Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
		end

		function [obj] = pho_plot_3d_mesh(obj, curr_cellRoiIndex)
            obj.extantFigH_plot_3d = createFigureWithTagIfNeeded('CellRoiPlotManager_ROI_Plot_3D_Mesh'); % generate a new figure to plot the sessions.
			clf(obj.extantFigH_plot_3d);

			temp.currAllSessionCompIndicies = obj.final_data_explorer_obj.multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI
			% Make 3D Mesh Plot:  
			[plotted_figH, ~] = fnPlotMeshFromPeaksGrid(obj.final_data_explorer_obj.dateStrings, obj.final_data_explorer_obj.uniqueAmps, obj.final_data_explorer_obj.uniqueFreqs, ...
				 temp.currAllSessionCompIndicies, curr_cellRoiIndex, ...
				 obj.final_data_explorer_obj.finalOutPeaksGrid, obj.extantFigH_plot_3d);

			%     zlim([-0.2, 1])
			set(plotted_figH, 'Name', sprintf('CellROI 3D Mesh Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
		end

		function [obj] = pho_plot_stimulus_traces(obj, curr_cellRoiIndex)
            obj.extantFigH_plot_stimulus_traces = createFigureWithTagIfNeeded('CellRoiPlotManager_ROI_Plot_StimulusTraces'); % generate a new figure to plot the sessions.
			clf(obj.extantFigH_plot_stimulus_traces);

			% temp.currAllSessionCompIndicies = obj.final_data_explorer_obj.multiSessionCellRoi_CompListIndicies(curr_cellRoiIndex,:); % Gets all sessions for the current ROI
			% Make Stimuli Traces Plot:  
			% [plotted_figH] = fnPlotStimulusTracesForCellROI(obj.final_data_explorer_obj.dateStrings, obj.final_data_explorer_obj.uniqueAmps, obj.final_data_explorer_obj.uniqueFreqs, obj.final_data_explorer_obj.uniqueStimuli, ...
			% 	temp.currAllSessionCompIndicies, curr_cellRoiIndex, ...
			% 	obj.final_data_explorer_obj.traceTimebase_t, obj.final_data_explorer_obj.active_DFF.TracesForAllStimuli, obj.final_data_explorer_obj.redTraceLinesForAllStimuli, ...
			% 	obj.extantFigH_plot_stimulus_traces);

			[plotted_figH] = fnPlotStimulusTracesForCellROI(obj.final_data_explorer_obj, curr_cellRoiIndex, obj.extantFigH_plot_stimulus_traces);
			set(plotted_figH, 'Name', sprintf('CellROI Stimuli Traces Plot: cellROI - %d', curr_cellRoiIndex)); % Update the title to reflect the cell ROI plotted
		end

	end % end graphical methods block


    %% Graphical Callback Methods Block:
    methods
		%% Custom ToolTip callback function that displays the clicked cell ROI as well as the x,y position.
		function txt = testCellROIBlob_Plot_Callback(obj, figH, info, interaction_helper_obj, activeSliderController)
			% interaction_helper_obj.final_data_explorer_obj
			x = info.Position(1);
			y = info.Position(2);
			uniqueCompIndex = interaction_helper_obj.final_data_explorer_obj.amalgamationMasks.cellROI_LookupMask(y, x); % Figure out explicitly what index type is assigned here.
			cellROIString = '';
			if uniqueCompIndex > 0
				fprintf('selected cellROI: %d...\n', uniqueCompIndex);
				cellROI_CompName = interaction_helper_obj.final_data_explorer_obj.uniqueComps{uniqueCompIndex};
				cellROIString = ['[' num2str(uniqueCompIndex) ']' cellROI_CompName];

				% Ask interaction_helper_obj to toggle the selection status.
				[interaction_helper_obj, curr_cellROI_IsSelected] = interaction_helper_obj.toggleCellRoiIsSelected(uniqueCompIndex);

				%% Update Selections graphically:
				obj.updateGraphicalAppearance(uniqueCompIndex);
				drawnow

				cellROI_PreferredLinearStimulusIndicies = squeeze(interaction_helper_obj.final_data_explorer_obj.preferredStimulusInfo.PreferredStimulus_LinearStimulusIndex(uniqueCompIndex,:)); % These are the linear stimulus indicies for this all sessions of this datapoint.

				cellROI_PreferredAmpsFreqsIndicies = interaction_helper_obj.final_data_explorer_obj.stimuli_mapper.indexMap_StimulusLinear2AmpsFreqsArray(cellROI_PreferredLinearStimulusIndicies',:);

				cellROI_PreferredAmps = interaction_helper_obj.final_data_explorer_obj.uniqueAmps(cellROI_PreferredAmpsFreqsIndicies(:,1));
				cellROI_PreferredFreqs = interaction_helper_obj.final_data_explorer_obj.uniqueFreqs(cellROI_PreferredAmpsFreqsIndicies(:,2));

				cellROI_PreferredAmpsFreqsValues = [cellROI_PreferredAmps, cellROI_PreferredFreqs];
				disp(cellROI_PreferredAmpsFreqsValues);
				txt = {['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString], ['prefAmps: ' num2str(cellROI_PreferredAmps')], ['prefFreqs: ' num2str(cellROI_PreferredFreqs')]};

			else
				fprintf('selected no cells.\n');
				cellROIString = 'None';
				txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];
			end

			if exist('activeSliderController','var')
				fprintf('updating activeSliderController programmatically to value %d...\n', uniqueCompIndex);
				activeSliderController.controller.Slider.Value = uniqueCompIndex;
			end
		end % end function


	end % end graphical callbacks methods block

end

