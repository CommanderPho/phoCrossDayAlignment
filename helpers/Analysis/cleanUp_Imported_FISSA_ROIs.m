function [cleaned_curr_trial_cell_ROI_regions] = cleanUp_Imported_FISSA_ROIs(curr_trial_cell_ROI_regions)
% cleanUp_Imported_FISSA_ROIs: Loads the data exported from fissa
% curr_trial_cell_ROI_regions: 1x5 cell

    if iscell(curr_trial_cell_ROI_regions)
        num_regions = length(curr_trial_cell_ROI_regions);

        for region_index = 1:num_regions
           curr_region = curr_trial_cell_ROI_regions{region_index};

           if iscell(curr_region)
		   		% The current region is nested an extra layer deep, into "subparts", which will need to be combined.
				curr_cleaned_region = cell(size(curr_region));
                for sub_part_index = 1:length(curr_region)
                   curr_sub_part = curr_region{sub_part_index};
                    % Combine all the parts additively: 
					if isnumeric(curr_sub_part)
						curr_cleaned_sub_part = process_final_numeric_array(curr_sub_part);
						curr_cleaned_region{sub_part_index} = curr_cleaned_sub_part; % Add the cleaned region back into the array

					else
						error('This is as deep as we go!')					
					end

               	end % end for sub_part
				cleaned_curr_trial_cell_ROI_regions{region_index} = curr_cleaned_region; % do not need to wrap in a cell array because it already is one.

           else
		   		% Numeric! Clean it up
				[cleaned_curr_trial_cell_ROI_regions{region_index}] = {process_final_numeric_array(curr_region)}; % wrap it in a cell array before returning
           end

        end % end for region
    
    else
        % curr_trial_cell_ROI_regions is already a numeric
		error('This should not happen!')
        cleaned_curr_trial_cell_ROI_regions = {process_final_numeric_array(curr_trial_cell_ROI_regions)}; % return it in a cell array before returning
    end


	function [cleaned] = process_final_numeric_array(an_item)
        cleaned = squeeze(an_item);
        if (isnumeric(cleaned) && (size(cleaned,2) == 2))
            % If it's a numeric array of size 2, it's the lowest level of recursion, we just return
            % We're done!
			return
        else
			error('Problem with the numeric array!')      
			cleaned = [];      
        end
    end


end