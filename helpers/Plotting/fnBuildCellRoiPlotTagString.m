function [curr_tag_string] = fnBuildCellRoiPlotTagString(cellROIIdentifier, offsetIndex, custom_override_suffix)
%FNBUILDCELLROIPLOTTAGSTRING Summary of this function goes here
%   Detailed explanation goes here
% custom_override_suffix: if exists and is non-empty, ignores the offsetIndex and appends custom_override_suffix to the end of the tag string instead.
	if (exist('custom_override_suffix','var') && ~isempty(custom_override_suffix))
		curr_tag_string = sprintf('%d_%s_%s', cellROIIdentifier.uniqueRoiIndex, cellROIIdentifier.roiName, custom_override_suffix);
	else
		if isnan(offsetIndex)
			% For the fill layer, the edgeOffsetIndex is nan
			curr_tag_string = sprintf('%d_%s_fill', cellROIIdentifier.uniqueRoiIndex, cellROIIdentifier.roiName);
		else
			curr_tag_string = sprintf('%d_%s_edgeOffsetIndex_%d', cellROIIdentifier.uniqueRoiIndex, cellROIIdentifier.roiName, offsetIndex);
		end
	end


end

