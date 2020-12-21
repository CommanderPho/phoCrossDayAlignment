% 

% PlotData_Cartesian(plot_identifier, should_show, aColor, XData, YData, Colormap)


cellROI_plottingOptionsStruct.main_alpha = 0.4;
cellROI_plottingOptionsStruct.other_alpha = 0.3;
cellROI_plottingOptionsStruct.prevent_zoom_in = false;
cellROI_plottingOptionsStruct.show_outline_line = false;
cellROI_plottingOptionsStruct.show_patch = true;

cellROI_plottingOptionsStruct.EdgeColor = 'black';

neuropil_plottingOptionsStruct = cellROI_plottingOptionsStruct;

% neuropil_plottingOptionsStruct.show_outline_line = false;
% neuropil_plottingOptionsStruct.show_patch = true;

% test = PlotData_Mixin_PlottingOptions(plottingOptionsStruct);


dataSeries = [PlotData_Cartesian('cellROI', true, 'r', [], [], [], cellROI_plottingOptionsStruct),...
    PlotData_Cartesian('neuropil', true, 'b', [], [], [], neuropil_plottingOptionsStruct)];

plottingInfo.roi_alpha = 0.4;
plottingInfo.other_alpha = 0.3;
% plottingInfo.prevent_zoom_in = false;
plottingInfo.prevent_zoom_in = false;

% clear chart;

% hold off;
% hold off;
chart = PolygonRoiChart(dataSeries);
openvar('chart')
% chart.dataSeries_labels

activeCellROIIndex = 29;



% Note that this gets all comps (all sessions), not all ROIs
activeCompCells = final_data_explorer_obj.compMasks.Polygons; % Only want good polys, in the first session.
activeCompNeuropilCells = final_data_explorer_obj.compNeuropilMasks.Polygons; % Only want good polys, in the first session.

numLoop = length(activeCompCells);
% numLoop = length(final_data_explorer_obj.num_cellROIs);

% Loop through all cell ROIs
for i = 1:numLoop
    activeCompIndicies = final_data_explorer_obj.cellROIIndex_mapper.getCompListIndicies(activeCellROIIndex);
%     isCompMember = (sum(ismember(i, activeCompIndicies),'all') > 0);
%     isPlotted = isCompMember; % For testing whether all sessions are the same for a specific cellROI
    isPlotted = (i == activeCellROIIndex); % For testing a specific cellROI
    if isPlotted    
        currCellPolys = activeCompCells{i};
        currCellNeuropilPolys = activeCompNeuropilCells{i};
        
        chart = chart.update_comp_polys(currCellPolys, currCellNeuropilPolys);
    end
end

% chart

