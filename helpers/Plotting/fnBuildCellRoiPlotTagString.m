function [curr_tag_string] = fnBuildCellRoiPlotTagString(offsetIndex, cellROIIdentifier)
%FNBUILDCELLROIPLOTTAGSTRING Summary of this function goes here
%   Detailed explanation goes here
    if isnan(offsetIndex)
        % For the fill layer, the edgeOffsetIndex is nan
        curr_tag_string = sprintf('%d_%s_fill', cellROIIdentifier.uniqueRoiIndex, cellROIIdentifier.roiName);
    else
        curr_tag_string = sprintf('%d_%s_edgeOffsetIndex_%d', cellROIIdentifier.uniqueRoiIndex, cellROIIdentifier.roiName, offsetIndex);
    end
end

