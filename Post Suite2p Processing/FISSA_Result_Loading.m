% Load FISSA Neuropil Subtraction Results:
% Pho Hale 12-17-2020

% - `ROIs.cell0.trial0{1}` polygon for the ROI
% - `ROIs.cell0.trial0{2}` polygon for first neuropil region
% - `result.cell0.trial0(1,:)` final extracted cell signal
% - `result.cell0.trial0(2,:)` contaminating signal
% - `raw.cell0.trial0(1,:)` raw measured cell signal
% - `raw.cell0.trial0(2,:)` raw signal from first neuropil region

% phoPipelineOptions.fissa.load_fissa_data_and_update_FDS = true;
% phoPipelineOptions.fissa.included_cellROIs_only = false;
% phoPipelineOptions.fissa.default_fissa_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/fissa_suite2p_example/experiment_matlab.mat';

% phoPipelineOptions.fissa.load_fissa_data_and_update_FDS = true;

if phoPipelineOptions.fissa.load_fissa_data_and_update_FDS
    if ~exist('loaded_fissa_data','var')
        fprintf('Loading FISSA .mat output at %s... \n', phoPipelineOptions.fissa.default_fissa_file_path)
        loaded_fissa_data = load(phoPipelineOptions.fissa.default_fissa_file_path);
        disp('done.')
    end
    if ~exist('fissa_outputs','var')
        fprintf('Processing FISSA outputs... \n')
        [fissa_outputs] = process_loaded_FISSA_result(loaded_fissa_data, phoPipelineOptions);
        disp('done.')
    end

    [finalDataStruct] = fnPhoBuildUpdatedFDS_FromFISSA(fissa_outputs, finalDataStruct, phoPipelineOptions);
end


function [finalDataStruct] = fnPhoBuildUpdatedFDS_FromFISSA(fissa_outputs, finalDataStruct, phoPipelineOptions)
    % Takes the finalDataStruct (FDS) object and the FISSA data outputs processed by process_loaded_FISSA_result(...) and produces an updated finalDataStruct
    % Adds df_raw, df_result, raw, and result to each comp on each session within the finalDataStruct
    anmID = phoPipelineOptions.loadedFilteringData.curr_animal;
    
    if ~isfield(finalDataStruct, anmID)
       error('anmID must be a valid animal ID in the finalDataStruct object!') 
    end
    
    sessionFields = fieldnames(finalDataStruct.(anmID));
    % numSessionFields: should be 3
    numSessions = length(sessionFields);
    
    % numTrials: should be 520
    numTrialsPerSession = length(finalDataStruct.(anmID).(sessionFields{1}).behData.amAmplitude);
    
    fds_compNames = fieldnames(finalDataStruct.(anmID).(sessionFields{1}).imgData);
    % numComps: should be 82
    numComps = length(fds_compNames); 
    
    % numFramesPerTrial: should be 150
    numFramesPerTrial = size(finalDataStruct.(anmID).(sessionFields{1}).imgData.(fds_compNames{1}).imagingData, 2);
    
%     % numFramesPerSession: should be 150
%     numFramesPerSession = numFramesPerTrial * numSessionFields;
    
    fprintf('numSessionFields: %d\nnumTrialsPerSession: %d\nnumFramesPerTrial: %d\nnumComps: %d\n', numSessions, numTrialsPerSession, numFramesPerTrial, numComps);
    
    if fissa_outputs.numCells ~= numComps
       error('The number of cells must be the same in both the fissa_outputs and the extant finalDataStruct');
    end
    
    %% Need to reshape the various fissa_outputs to match the expected format of the FDS:
%                   - imagingData: 520x150 double
%                   - imagingDataNeuropil: 520x150 double
%                   - segmentLabelMatrix: 512x512 double
%                   - neuropilMaskLabelMatrix: 512x512 double
%                   - imagingDataDFF: 520x150 double

%     fissa_outputs.results.df_raw % 53x234000
%     fissa_outputs.results.df_result % 53x5x234000
%     fissa_outputs.results.raw % 53x5x234000
%     fissa_outputs.results.result % 53x5x234000

    total_number_frames = size(fissa_outputs.results.df_raw, 2); % 234000

    % Divide into sessions:
    % 234000 / 3 = 78,000
    num_frames_per_session = floor(total_number_frames / numSessions);
    leftover_frames = rem(total_number_frames, numSessions);
    
    % frames_per_session: the number of frames in each session, typically all the same, like [78000, 78000, 78000]
    frames_per_session_list = repmat(num_frames_per_session, [numSessions 1]);
    if leftover_frames ~= 0
        error('leftover_frames > 0: Note that an incomplete session exists');
        frames_per_session_list(end + 1) = frames_per_session_list;
    end
        % Session Indicies:
    cum_session_last_index_array = cumsum(frames_per_session_list);
    cum_session_first_index_array = (cum_session_last_index_array - frames_per_session_list) + 1;
    
    % Divide into trials:
    % 78,000 / 150 = 520
    num_trials_per_session = floor(num_frames_per_session / numFramesPerTrial);
    % frames_per_session: the number of frames in each session, typically all the same, like [78000, 78000, 78000]
    frames_per_trial_per_session_list = repmat(numFramesPerTrial, [numTrialsPerSession 1]); % [150 150 150 ...] % (extended 520 times)
    leftover_trials = rem(num_frames_per_session, numFramesPerTrial);
    if leftover_trials ~= 0
        error('leftover_trials > 0: Note that an incomplete session exists');
    end
    
    if numTrialsPerSession ~= num_trials_per_session
       error('The number of trials per session computed from the FISSA data and that computed from the finalDataStruct differ!'); 
    end
    % Session-relative trial Indicies:
    cum_session_relative_trial_last_index_array = cumsum(frames_per_trial_per_session_list);
    cum_session_relative_trial_first_index_array = (cum_session_relative_trial_last_index_array - frames_per_trial_per_session_list) + 1;
    
    % - `result.cell0.trial0(1,:)` final extracted cell signal
        % - `result.cell0.trial0(2,:)` contaminating signal
        % - `raw.cell0.trial0(1,:)` raw measured cell signal
        % - `raw.cell0.trial0(2,:)` raw signal from first neuropil region
        

    %% Tests:
    
    fprintf('doing new method to compute the fissa_outputs...\n')
     % Divide intial into blocks of 78000.
    % Then Divide Each Block into blocks of 150.
    
    % The ROI Regions are the same for every session, and furthermore for every trial in every session
    curr_session_data.ROI_regions = fissa_outputs.results.ROI_regions;
    curr_session_trial_data.ROI_regions = fissa_outputs.results.ROI_regions;
    
    
    % Need to convert (session_index, trial_index, trial_frame_index) into a linear index into 234000
   for session_index = 1:numSessions
        curr_session_field = sessionFields{session_index};
        curr_session_frame_first_index = cum_session_first_index_array(session_index);
        curr_session_frame_last_index = cum_session_last_index_array(session_index);
        
        curr_session_data.df_raw = squeeze(fissa_outputs.results.df_raw(:,curr_session_frame_first_index:curr_session_frame_last_index));
        curr_session_data.df_result = squeeze(fissa_outputs.results.df_result(:,:,curr_session_frame_first_index:curr_session_frame_last_index));
        curr_session_data.raw = squeeze(fissa_outputs.results.raw(:,:,curr_session_frame_first_index:curr_session_frame_last_index));
        curr_session_data.result = squeeze(fissa_outputs.results.result(:,:,curr_session_frame_first_index:curr_session_frame_last_index));

        %% Pre-allocate for all trials in this specific session
        for comp_index = 1:numComps
            currentComp = fds_compNames{comp_index}; %get the current component
            
            % Remove existing fields first
            does_fissa_field_exist = isfield(finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp), phoPipelineOptions.fissa.fissa_field_names);
            fields_to_remove = phoPipelineOptions.fissa.fissa_field_names(does_fissa_field_exist);
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp) = rmfield(finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp), fields_to_remove);
            
            % Pre-allocate:
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_raw = zeros([num_trials_per_session numFramesPerTrial]); % 520x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result.all = zeros([num_trials_per_session 5 numFramesPerTrial]); % 520x5x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.all = zeros([num_trials_per_session 5 numFramesPerTrial]); % 520x5x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.all = zeros([num_trials_per_session 5 numFramesPerTrial]); % 520x5x150
            
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result.cell_dff = zeros([num_trials_per_session numFramesPerTrial]); % 520x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result.neuropil_region_dff = zeros([num_trials_per_session 4 numFramesPerTrial]); % 520x4x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.measured_cell_signal = zeros([num_trials_per_session numFramesPerTrial]); % 520x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.raw_neuropil_region_signal = zeros([num_trials_per_session 4 numFramesPerTrial]); % 520x4x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.final_extracted_cell_signal = zeros([num_trials_per_session numFramesPerTrial]); % 520x150
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.contaminating_neuropil_region_signal = zeros([num_trials_per_session 4 numFramesPerTrial]); % 520x4x150
                
        end % end for comps
            
        for session_trial_index = 1:num_trials_per_session
            curr_session_trial_frame_first_index = cum_session_relative_trial_first_index_array(session_trial_index);
            curr_session_trial_frame_last_index = cum_session_relative_trial_last_index_array(session_trial_index);
            
            % Using Relative Indexing:
            curr_session_trial_data.df_raw = squeeze(curr_session_data.df_raw(:,curr_session_trial_frame_first_index:curr_session_trial_frame_last_index)); % 82x150
            curr_session_trial_data.df_result = squeeze(curr_session_data.df_result(:,:,curr_session_trial_frame_first_index:curr_session_trial_frame_last_index)); % 82x5x150
            curr_session_trial_data.raw = squeeze(curr_session_data.raw(:,:,curr_session_trial_frame_first_index:curr_session_trial_frame_last_index)); % 82x5x150
            curr_session_trial_data.result = squeeze(curr_session_data.result(:,:,curr_session_trial_frame_first_index:curr_session_trial_frame_last_index)); % 82x5x150
        
            % TEST: if this works, curr_absolute_session_trial_frame_last_index should equal the curr_session_trial_frame_last_index for the last trial

            % Add the current block of the current session to the finalDataStruct
            for comp_index = 1:numComps
                currentComp = fds_compNames{comp_index}; %get the current component
            
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_ROI_regions = curr_session_trial_data.ROI_regions(comp_index, :); % 1x5 cell
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_raw(session_trial_index,:) = squeeze(curr_session_trial_data.df_raw(comp_index,:)); % 1x150 
%                 finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result(session_trial_index,:,:) = squeeze(curr_session_trial_data.df_result(comp_index,:,:)); % 5x150 

                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result.all(session_trial_index,:,:) = squeeze(curr_session_trial_data.df_result(comp_index,:,:)); % 5x150
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.all(session_trial_index,:,:) = squeeze(curr_session_trial_data.raw(comp_index,:,:)); % 5x150
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.all(session_trial_index,:,:) = squeeze(curr_session_trial_data.result(comp_index,:,:)); % 5x150
                
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result.cell_dff(session_trial_index,:) = squeeze(curr_session_trial_data.df_result(comp_index, 1, :));
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result.neuropil_region_dff(session_trial_index,:,:) = squeeze(curr_session_trial_data.df_result(comp_index, 2:end, :));
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.measured_cell_signal(session_trial_index,:) = squeeze(curr_session_trial_data.raw(comp_index, 1, :));
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.raw_neuropil_region_signal(session_trial_index,:,:) = squeeze(curr_session_trial_data.raw(comp_index, 2:end, :));
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.final_extracted_cell_signal(session_trial_index,:) = squeeze(curr_session_trial_data.result(comp_index, 1, :));
                finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.contaminating_neuropil_region_signal(session_trial_index,:,:) = squeeze(curr_session_trial_data.result(comp_index, 2:end, :));

            end % end for comps
        
        end % end for trial in session
        
   end % end for session
    
    
%     
    
    
%     fprintf('done. Adding the reshaped data to the finalDataStruct...\n')
%     for session_index = 1:numSessions
%         curr_session_field = sessionFields{session_index};
%         
%         curr_session_frame_count = frames_per_session_list(session_index);
%         curr_session_frame_first_index = cum_session_first_index_array(session_index);
%         curr_session_frame_last_index = cum_session_last_index_array(session_index);
%         % Testing:
%         % curr_* variables
%         if ~isequal(squeeze(fissa_outputs.results.df_raw(:,curr_session_frame_first_index:curr_session_frame_last_index)), squeeze(curr_df_raw(:,session_index,:)))
%            error('df_raw session error');
%         end
%         
%         if ~isequal(squeeze(fissa_outputs.results.df_result(:,:,curr_session_frame_first_index:curr_session_frame_last_index)), squeeze(curr_df_result(:,:,session_index,:)))
%            error('df_result session error');
%         end
%         
%         % curr_session_* variables
% %         if ~isequal(fissa_outputs.results.df_result(:,:,session_index,curr_session_frame_first_index:curr_session_frame_last_index), curr_session_df_raw(:,:,session_index,:,:))
% %            error('curr_session_df_raw session error');
% %         end
% %         
% %         if ~isequal(fissa_outputs.results.df_result(:,:,session_index,curr_session_frame_first_index:curr_session_frame_last_index), curr_session_df_result(:,:,session_index,:,:))
% %            error('curr_session_df_result session error');
% %         end
%         
%         %go through all the comps
%         for comp_index = 1:numComps
%             currentComp = fds_compNames{comp_index}; %get the current component
%             
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_raw = squeeze(curr_df_raw(comp_index, session_index, :, :));
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result = squeeze(curr_df_result(comp_index, :, session_index, :, :));
% %             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw = squeeze(curr_raw(comp_index, :, session_index, :, :));
% %             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result = squeeze(curr_result(comp_index, :, session_index, :, :));
% 
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.measured_cell_signal = squeeze(curr_raw(comp_index, 1, session_index, :, :));
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.raw_neuropil_region_signal = squeeze(curr_raw(comp_index, 2:end, session_index, :, :));
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.final_extracted_cell_signal = squeeze(curr_result(comp_index, 1, session_index, :, :));
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.contaminating_neuropil_region_signal = squeeze(curr_result(comp_index, 2:end, session_index, :, :));
%             
%         end % end for comps
%     
%     end % end for sessions
    
    
    fprintf('done.\n')
end


function [fissa_outputs] = process_loaded_FISSA_result(fissa_data, phoPipelineOptions)
% process_loaded_FISSA_result: Loads the data exported from fissa 

    fissa_outputs.cellFields = fieldnames(fissa_data.ROIs);
    fissa_outputs.numCells = length(fissa_outputs.cellFields);
    fissa_outputs.tifIdentifierNames = fieldnames(fissa_data.ROIs.(fissa_outputs.cellFields{1}));
    fissa_outputs.numTifImages = length(fissa_outputs.tifIdentifierNames);
    fprintf('Detected %d cells, %d source images for FISSA data.\n', fissa_outputs.numCells, fissa_outputs.numTifImages);
    % Detected 82 cells, 58 source images for FISSA data.
    
    if ~isfield(fissa_data,'df_raw') || ~isfield(fissa_data,'df_result')
        fprintf('WARNING: the loaded fissa data is missing the computed dF/F data. Did you run the full python script?');
    end
    
    if phoPipelineOptions.fissa.included_cellROIs_only
        includedCompMask = ~phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded;

    else
        % Otherwise include all components:
        includedCompMask = ones([fissa_outputs.numCells 1],'logical');
       
    end
    
    filteredCellFields = fissa_outputs.cellFields(includedCompMask);
    % filteredCellFieldOriginalIndex: the index that maps to the original [1, 82] range.
    filteredCellFieldOriginalIndicies = 1:fissa_outputs.numCells;
    filteredCellFieldOriginalIndicies = filteredCellFieldOriginalIndicies(includedCompMask)';
    filteredNumCells = length(filteredCellFields);
    
    % Loop through the filtered number of cells
    for i = 1:filteredNumCells
        curr_cell_id_name = filteredCellFields{i};
%         curr_cell_id_original_index = filteredCellFieldOriginalIndicies(i);

        % - `result.cell0.trial0(1,:)` final extracted cell signal
        % - `result.cell0.trial0(2,:)` contaminating signal
        % - `raw.cell0.trial0(1,:)` raw measured cell signal
        % - `raw.cell0.trial0(2,:)` raw signal from first neuropil region
        
        %% For the ROIs:
        % [cellRoi, trial, region, "part"]
        %   region should always be 5, with 1 being the ROI and 2:5 being the neuropil
        % Each trial field
         % The ROIs are the same across all trials (for the same ROI)
%         figure(1);
%         axis square
%         xlim('manual');
%         ylim('manual');
%         transparency=0.3;  % values between 0 and 1

        
        trial_index = 1;
%         for trial_index = 1:fissa_outputs.numTifImages
            curr_trial_fieldname = fissa_outputs.tifIdentifierNames{trial_index};
            curr_trial_cell_ROI_regions = fissa_data.ROIs.(curr_cell_id_name).(curr_trial_fieldname);
%             fprintf('length(curr_trial_cell_ROIs): %d\n', length(curr_trial_cell_ROI_regions));
% %             temp_sizes(trial_index) = size(curr_trial_cell_ROIs);
%             for region_index = 1:length(curr_trial_cell_ROI_regions)
%                curr_region = curr_trial_cell_ROI_regions{region_index};
%                fprintf('\t length(curr_region): %d\n', length(curr_region));
%                for sub_part_index = 1:length(curr_region)
%                    curr_sub_part = curr_region{sub_part_index};
%                    x = curr_sub_part(:, 2);
%                    y = curr_sub_part(:, 1);
%                    plot(x,y)
%                    fill(x,y,'r')
%                    alpha(transparency);
%                    
%                     xlim([1 512]);
%                     ylim([1 512]);
%         
%                    fprintf('\t\t length(curr_sub_part): %d\n', length(curr_sub_part));
%                end
%             
% %                disp(size(curr_item))
%             end
%         end 

        % The regions for this ROI, always 1x5 cell
        curr_cell.ROI_regions = curr_trial_cell_ROI_regions;
        
        [~, ~, curr_cell.df_raw] = flattenAllFields(fissa_data.df_raw.(curr_cell_id_name), 2);
        numCombinedDatapoints = length(curr_cell.df_raw);
        [~, ~, curr_cell.df_result] = flattenAllFields(fissa_data.df_result.(curr_cell_id_name), 2);        
        [~, ~, curr_cell.raw] = flattenAllFields(fissa_data.raw.(curr_cell_id_name), 2);
        [~, ~, curr_cell.result] = flattenAllFields(fissa_data.result.(curr_cell_id_name), 2);
        
        is_first_cell = (i == 1);
        
        if is_first_cell
            % Pre-allocate the output structures now that we know how big they are:
            fissa_outputs.results.ROI_regions = cell([filteredNumCells length(curr_cell.ROI_regions)]);
            fissa_outputs.results.df_raw = zeros([filteredNumCells numCombinedDatapoints]); 
            fissa_outputs.results.df_result = zeros([filteredNumCells size(curr_cell.df_result,1) size(curr_cell.df_result,2)]);
            fissa_outputs.results.raw = zeros([filteredNumCells size(curr_cell.raw,1) size(curr_cell.raw,2)]); 
            fissa_outputs.results.result = zeros([filteredNumCells size(curr_cell.result,1) size(curr_cell.result,2)]);
        end
        
        fissa_outputs.results.ROI_regions(i,:) = curr_cell.ROI_regions;
        fissa_outputs.results.df_raw(i,:) = curr_cell.df_raw;
        fissa_outputs.results.df_result(i,:,:) = curr_cell.df_result;
        fissa_outputs.results.raw(i,:,:) = curr_cell.raw;
        fissa_outputs.results.result(i,:,:) = curr_cell.result;
    end

    fissa_outputs.includedCompMask = includedCompMask;
    fissa_outputs.filteredCellFields = filteredCellFields;
    fissa_outputs.filteredCellFieldOriginalIndicies = filteredCellFieldOriginalIndicies;

end

function [figH] = plot_ROI_polygon(fissa_data, phoPipelineOptions)
% process_loaded_FISSA_result: Loads the data exported from fissa 
    figH = figure(1);
    axis square
    xlim('manual');
    ylim('manual');
    transparency=0.3;  % values between 0 and 1

    curr_trial_cell_ROI_regions = fissa_data.ROIs.(curr_cell_id_name).(curr_trial_fieldname);
    fprintf('length(curr_trial_cell_ROIs): %d\n', length(curr_trial_cell_ROI_regions));

    for region_index = 1:length(curr_trial_cell_ROI_regions)
       curr_region = curr_trial_cell_ROI_regions{region_index};
       fprintf('\t length(curr_region): %d\n', length(curr_region));
       for sub_part_index = 1:length(curr_region)
           curr_sub_part = curr_region{sub_part_index};
           x = curr_sub_part(:, 2);
           y = curr_sub_part(:, 1);
           plot(x,y)
           fill(x,y,'r')
           alpha(transparency);

            xlim([1 512]);
            ylim([1 512]);

           fprintf('\t\t length(curr_sub_part): %d\n', length(curr_sub_part));
       end % end for sub_part

    end % end for region

end



function [outMasks] = build_ROI_binaryMasks_from_polygon(fissa_data, phoPipelineOptions)
% build_ROI_binaryMasks_from_polygon: Loads the data exported from fissa 
    curr_trial_cell_ROI_regions = fissa_data.ROIs.(curr_cell_id_name).(curr_trial_fieldname);
    
    for region_index = 1:length(curr_trial_cell_ROI_regions)
       curr_region = curr_trial_cell_ROI_regions{region_index};
       for sub_part_index = 1:length(curr_region)
           curr_sub_part = curr_region{sub_part_index};
           x = curr_sub_part(:, 2);
           y = curr_sub_part(:, 1);
           
		   outMasks = poly2mask(x, y, 512, 512);

       end % end for sub_part

    end % end for region

end

