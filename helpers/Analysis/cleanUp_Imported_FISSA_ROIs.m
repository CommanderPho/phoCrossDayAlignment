function [cleaned_curr_trial_cell_ROI_regions, did_encounter_problem] = cleanUp_Imported_FISSA_ROIs(curr_trial_cell_ROI_regions)
% cleanUp_Imported_FISSA_ROIs: Loads the data exported from fissa
% curr_trial_cell_ROI_regions: 1x5 cell
    did_encounter_problem = false;
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
                        did_encounter_problem = true;
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
        did_encounter_problem = true;
        cleaned_curr_trial_cell_ROI_regions = {process_final_numeric_array(curr_trial_cell_ROI_regions)}; % return it in a cell array before returning
    end


	function [cleaned] = process_final_numeric_array(an_item)
        cleaned = squeeze(an_item);
        if (isnumeric(cleaned) && (size(cleaned,2) == 2))
            % If it's a numeric array of size 2, it's the lowest level of recursion, we just return
            % We're done!
			return
        else
 			warning('Problem with the numeric array!')      % The item coming in is 2x45x2 for some reason
            did_encounter_problem = true;
            curr_cleaned_size = size(cleaned);
            curr_cleaned_num_dims = length(curr_cleaned_size);
            assert((curr_cleaned_size(end) == 2), 'If the last dim is not two, this is irrecoverable');
            % Otherwise, so long as the last dimension is two, just take the last two dimensions
            extra_dims = curr_cleaned_num_dims - 2;
            fprintf('\t WARNING: dropping %d dimensions from the cellROI and continuing\n', extra_dims);
            cleaned = squeeze(cleaned(ones([1 extra_dims]),:,:)); % Get the last two dimensions    
        end
    end


end