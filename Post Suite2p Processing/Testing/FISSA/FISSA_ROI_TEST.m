% 

% PlotData_Cartesian(plot_identifier, should_show, aColor, XData, YData, Colormap)

dataSeries = [PlotData_Cartesian('cellROI', true, 'r'),...
    PlotData_Cartesian('neuropil', true, 'b')];

% clear chart;

% hold off;
% hold off;
chart = PolygonRoiChart(dataSeries);

% chart.dataSeries_labels

activeCellROIIndex = 25;

plottingInfo.roi_alpha = 0.4;
plottingInfo.other_alpha = 0.3;

% plottingInfo.prevent_zoom_in = false;
plottingInfo.prevent_zoom_in = false;

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

