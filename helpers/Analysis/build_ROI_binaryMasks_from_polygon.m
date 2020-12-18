function [outMasks] = build_ROI_binaryMasks_from_polygon(curr_trial_cell_ROI_regions)
% build_ROI_binaryMasks_from_polygon: Loads the data exported from fissa
% curr_trial_cell_ROI_regions: 1x5 cell

    if iscell(curr_trial_cell_ROI_regions)
        num_regions = length(curr_trial_cell_ROI_regions);
        outMasks = zeros([num_regions 512 512], 'logical');

        for region_index = 1:num_regions
           curr_region = curr_trial_cell_ROI_regions{region_index};

           if iscell(curr_region)
                for sub_part_index = 1:length(curr_region)
                   curr_sub_part = curr_region{sub_part_index};
                    % Combine all the parts additively: 
                   temp_curr_bw_mask = build_ROI_binaryMasks_from_polygon_numeric(curr_sub_part);
                   outMasks(region_index, :, :) = squeeze(outMasks(region_index, :, :)) + temp_curr_bw_mask;
               end % end for sub_part
           else
               outMasks(region_index, :, :) = build_ROI_binaryMasks_from_polygon_numeric(curr_region);
           end

        end % end for region
    
    else
        % curr_trial_cell_ROI_regions is already a numeric
        num_regions = 1;
        outMasks = zeros([num_regions 512 512], 'logical');
        outMasks(1, :, :) = build_ROI_binaryMasks_from_polygon_numeric(curr_trial_cell_ROI_regions);
        
    end
    
    function [curr_bw_mask] = build_ROI_binaryMasks_from_polygon_numeric(curr_polygon_numeric_array)
        % curr_polygon_numeric_array: an N x 2 array
        % Actual numeric array
           x = curr_polygon_numeric_array(:, 2);
           y = curr_polygon_numeric_array(:, 1);

           % Combine all the parts additively:
           curr_bw_mask = poly2mask(x, y, 512, 512); % 512x512
    end

end