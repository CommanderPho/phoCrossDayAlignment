% 
addpath(genpath('../../../helpers'));

% PlotData_Cartesian(plot_identifier, should_show, aColor, XData, YData, Colormap)
phoFinalChartFigure = PlotFigureState('phoFinalChartFigure_FissaRoi', true, ...
    @(extantFigH, ~) (plotFissaRoiNewChart(final_data_explorer_obj, extantFigH)));

phoFinalChartFigure.Update(0);

% clear chart;
% [chart] = plotFissaRoiNewChart(final_data_explorer_obj);

% neuropil_plottingOptionsStruct.show_outline_line = false;
% neuropil_plottingOptionsStruct.show_patch = true;

% test = PlotData_Mixin_PlottingOptions(plottingOptionsStruct);

% dataSeries = [PlotData_Cartesian('cellROI', true, 'r', [], [], [], cellROI_plottingOptionsStruct),...
%     PlotData_Cartesian('neuropil', true, 'b', [], [], [], neuropil_plottingOptionsStruct)];

% plottingInfo.roi_alpha = 0.4;
% plottingInfo.other_alpha = 0.3;
% plottingInfo.prevent_zoom_in = false;
% plottingInfo.prevent_zoom_in = false;

% clear chart;

% hold off;
% hold off;

% chart.dataSeries_labels


% chart
function [chart] = plotFissaRoiNewChart(final_data_explorer_obj, extantFigH)

    number_of_cellROI_plotSubGraphics = 2; % One for the regular cellROI and one for the neuropil
    plotting_options.should_plot_neuropil_masks = true;
    
    
    % Note that this gets all comps (all sessions), not all ROIs
    activeCompCells = final_data_explorer_obj.compMasks.Polygons; % Only want good polys, in the first session.
    activeCompNeuropilCells = final_data_explorer_obj.compNeuropilMasks.Polygons; % Only want good polys, in the first session.

    chartConfigStruct.prevent_zoom_in = true;

    num_pixels = 512;
    grid_line_offsets = num_pixels / 16;

    % chartConfigStruct.Axis.Layer = 'top'; % Place the ticks and grid lines on top of the plot
    chartConfigStruct.Axis.GridAlpha = 0.5;
    chartConfigStruct.Axis.Box = 'on';
    chartConfigStruct.Axis.BoxStyle = 'full'; % Only affects 3D views
    % chartConfigStruct.Axis.YDir = 'reverse'; % Reverse the y-axis direction, so the origin is at the top left corner.
    chartConfigStruct.Axis.XTick = 1:grid_line_offsets:num_pixels;
    chartConfigStruct.Axis.XTickLabel = {};
    chartConfigStruct.Axis.YTick = 1:grid_line_offsets:num_pixels;
    chartConfigStruct.Axis.YTickLabel = {};
    chartConfigStruct.Axis.YLim = [1 num_pixels];
    chartConfigStruct.Axis.YGrid = 'on';
    chartConfigStruct.Axis.XLim = [1 num_pixels];
    chartConfigStruct.Axis.XGrid = 'on';
    % chartConfigStruct.Axis.Toolbar.Visible = 'off'; % we know this can be slow, check the actual performance.

    curr_chart_config = DynamicPlottingOptionsContainer();
    curr_chart_config.addStructAsDynamicProperties(chartConfigStruct);


    % plotConfig = DynamicPlottingOptionsContainer({}, plotConfig);

%     cellROI_plottingOptionsStruct.main_alpha = 0.4;
%     cellROI_plottingOptionsStruct.other_alpha = 0.3;
    cellROI_plottingOptionsStruct.prevent_zoom_in = false;
    cellROI_plottingOptionsStruct.show_outline_line = false;
    cellROI_plottingOptionsStruct.show_patch = true;

    cellROI_plottingOptionsStruct.Color = [1 0 0];
    cellROI_plottingOptionsStruct.CData = [1 0 0];

    cellROI_plottingOptionsStruct.Patch.Tag = '';
    cellROI_plottingOptionsStruct.Patch.UserData = [];
    cellROI_plottingOptionsStruct.Patch.EdgeColor = 'black';
    cellROI_plottingOptionsStruct.Patch.EdgeAlpha = 0.3;
    cellROI_plottingOptionsStruct.Patch.FaceColor = cellROI_plottingOptionsStruct.Color;
    cellROI_plottingOptionsStruct.Patch.FaceAlpha = 0.4;
%     cellROI_plottingOptionsStruct.Patch.CData = cellROI_plottingOptionsStruct.Color;
    
    
    neuropil_plottingOptionsStruct = cellROI_plottingOptionsStruct;
    neuropil_plottingOptionsStruct.Color = [0 0 1];
    neuropil_plottingOptionsStruct.CData = [0 0 1];
    neuropil_plottingOptionsStruct.Patch.FaceColor = neuropil_plottingOptionsStruct.Color;
    

    dataSeries = [PlotData_Cartesian('cellROI', true, 'r', [], [], [], cellROI_plottingOptionsStruct),...
        PlotData_Cartesian('neuropil', true, 'b', [], [], [], neuropil_plottingOptionsStruct)];
    
    num_cell_rois = final_data_explorer_obj.num_cellROIs;
    
    
%       dataSeries = PlotData_Cartesian.empty(num_cell_rois,2); % At least one dimension must be zero.

%     dataSeries = PlotData_Cartesian(num_cell_rois,2); % At least one dimension must be zero.
    dataSeries = repmat(dataSeries, [num_cell_rois, 1]);
      
%     dataSeries
    % Loop through all cell ROIs
    for i = 1:num_cell_rois
        cellROIIdentifier.uniqueRoiIndex = i;
        cellROIIdentifier.roiName = final_data_explorer_obj.cellROIIndex_mapper.getRoiNameFromUniqueCompIndex(i);
        
        for plotImageIndex = 1:number_of_cellROI_plotSubGraphics
            currPlotSubGraphicsIdentifier.cellROIIdentifier = cellROIIdentifier;

            is_neuropil_index = (plotting_options.should_plot_neuropil_masks && (number_of_cellROI_plotSubGraphics == plotImageIndex));
            if is_neuropil_index
                % Neuropil Mask Plotting (optional):
                currPlotSubGraphicsIdentifier.edgeOffsetIndex = nan;
                currPlotSubGraphicsIdentifier.type = 'NeuropilMask';
    
                curr_tag_string = fnBuildCellRoiPlotTagString(cellROIIdentifier, nan, 'FissaNeuropilPolygons');
                neuropil_plottingOptionsStruct.Patch.Tag = curr_tag_string;
                neuropil_plottingOptionsStruct.Patch.UserData = currPlotSubGraphicsIdentifier;
                [x_array, y_array, num_polys] = PolygonRoiChart.computeFilledCellPolyCoordinates(activeCompNeuropilCells{i});
                curr_CData = repmat(neuropil_plottingOptionsStruct.CData, size(x_array));   
                curr_updated_data_series = PlotData_Cartesian(curr_tag_string, true, 'b', x_array, y_array, curr_CData, neuropil_plottingOptionsStruct);

            else
                % Non-neuropil layer:
                currPlotSubGraphicsIdentifier.edgeOffsetIndex = nan;

                if isnan(currPlotSubGraphicsIdentifier.edgeOffsetIndex)
                    % For the fill layer, the edgeOffsetIndex is nan
                    currPlotSubGraphicsIdentifier.type = 'Fill';
                    
                else
                    currPlotSubGraphicsIdentifier.type = 'Edge'; 
                end

                curr_tag_string = fnBuildCellRoiPlotTagString(cellROIIdentifier, nan, 'FissaCellRoiPolygons');
                cellROI_plottingOptionsStruct.Patch.Tag = curr_tag_string;
                cellROI_plottingOptionsStruct.Patch.UserData = currPlotSubGraphicsIdentifier;
                [x_array, y_array, num_polys] = PolygonRoiChart.computeFilledCellPolyCoordinates(activeCompCells{i});
                curr_CData = repmat(cellROI_plottingOptionsStruct.CData, size(x_array));
                curr_updated_data_series = PlotData_Cartesian(curr_tag_string, true, 'r', x_array, y_array, curr_CData, cellROI_plottingOptionsStruct);

            end % end if is_neuropil_index
            
%             dataSeries(end+1) = curr_updated_data_series;
           
%             set(curr_updated_data_series.plotting_options, 'UserData', currPlotSubGraphicsIdentifier);
%             set(curr_updated_data_series.plotting_options, 'Tag', curr_tag_string);
            
            dataSeries(i, plotImageIndex) = curr_updated_data_series;
%             set(imagePlotHandles(i, plotImageIndex), 'UserData', currPlotSubGraphicsIdentifier);
%             set(imagePlotHandles(i, plotImageIndex), 'Tag', curr_tag_string);

        end % end for number_of_cellROI_plotSubGraphics

    end % end for cellROIs 

%     chart = chart.update_comp_polys(currCellPolys, currCellNeuropilPolys);
    
    dataSeries = reshape(dataSeries, [(num_cell_rois * 2), 1]);
    
    if ~exist('extantFigH','var')    
        error('no figure!')
    end
    chart = PolygonRoiChart(dataSeries, curr_chart_config, 'Parent', extantFigH);
%     chart = InteractivePolygonRoiChart(dataSeries, curr_chart_config);
%     openvar('chart')
    
    
end
