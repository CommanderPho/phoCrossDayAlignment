% Load FISSA Neuropil Subtraction Results:
% Pho Hale 12-17-2020

% - `ROIs.cell0.trial0{1}` polygon for the ROI
% - `ROIs.cell0.trial0{2}` polygon for first neuropil region
% - `result.cell0.trial0(1,:)` final extracted cell signal
% - `result.cell0.trial0(2,:)` contaminating signal
% - `raw.cell0.trial0(1,:)` raw measured cell signal
% - `raw.cell0.trial0(2,:)` raw signal from first neuropil region

phoPipelineOptions.fissa_included_cellROIs_only = false;
phoPipelineOptions.default_fissa_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/fissa_suite2p_example/experiment_matlab.mat';
if ~exist('loaded_fissa_data','var')
    fprintf('Loading FISSA .mat output at %s... \n', phoPipelineOptions.default_fissa_file_path)
    loaded_fissa_data = load(phoPipelineOptions.default_fissa_file_path);
    disp('done.')
end
if ~exist('fissa_outputs','var')
    fprintf('Processing FISSA outputs... \n')
    [fissa_outputs] = process_loaded_FISSA_result(loaded_fissa_data, phoPipelineOptions);
    disp('done.')
end

[finalDataStruct] = fnPhoBuildUpdatedFDS_FromFISSA(fissa_outputs, finalDataStruct, phoPipelineOptions);


function [finalDataStruct] = fnPhoBuildUpdatedFDS_FromFISSA(fissa_outputs, finalDataStruct, phoPipelineOptions)
    % Takes the finalDataStruct (FDS) object and the FISSA data outputs processed by process_loaded_FISSA_result(...) and produces an updated finalDataStruct
    % Adds df_raw, df_result, raw, and result to each comp on each session within the finalDataStruct
    anmID = phoPipelineOptions.loadedFilteringData.curr_animal;
    
    if ~isfield(finalDataStruct, anmID)
       error('anmID must be a valid animal ID in the finalDataStruct object!') 
    end
    
    sessionFields = fieldnames(finalDataStruct.(anmID));
    % numSessionFields: should be 3
    numSessionFields = length(sessionFields);
    % numTrials: should be 520
    numTrialsPerSession = length(finalDataStruct.(anmID).(sessionFields{1}).behData.amAmplitude);
    
    fds_compNames = fieldnames(finalDataStruct.(anmID).(sessionFields{1}).imgData);
    % numComps: should be 82
    numComps = length(fds_compNames); 
    
    % numFramesPerTrial: should be 150
    numFramesPerTrial = size(finalDataStruct.(anmID).(sessionFields{1}).imgData.(fds_compNames{1}).imagingData, 2);
    
    % numFramesPerSession: should be 150
    numFramesPerSession = numFramesPerTrial * numSessionFields;
    
    fprintf('numSessionFields: %d\nnumTrialsPerSession: %d\nnumFramesPerTrial: %d\nnumComps: %d\n', numSessionFields, numTrialsPerSession, numFramesPerTrial, numComps);
    
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

    % Divide into sessions:
    % 234000 / 3 = 78,000

    % Divide into trials:
    % 78,000 / 150 = 520
    
    % - `result.cell0.trial0(1,:)` final extracted cell signal
        % - `result.cell0.trial0(2,:)` contaminating signal
        % - `raw.cell0.trial0(1,:)` raw measured cell signal
        % - `raw.cell0.trial0(2,:)` raw signal from first neuropil region
        
    fprintf('reshaping the fissa_outputs...\n')
    curr_df_raw = reshape(fissa_outputs.results.df_raw, [numComps, 3, 520, 150]);
    curr_df_result = reshape(fissa_outputs.results.df_result, [numComps, 5, 3, 520, 150]);
    curr_raw = reshape(fissa_outputs.results.raw, [numComps, 5, 3, 520, 150]);
    curr_result = reshape(fissa_outputs.results.result, [numComps, 5, 3, 520, 150]);        
    fprintf('done. Adding the reshaped data to the finalDataStruct...\n')
    for session_index = 1:numSessionFields
        curr_session_field = sessionFields{session_index};
        %go through all the comps
        for comp_index = 1:numComps
            currentComp = fds_compNames{comp_index}; %get the current component
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_raw = squeeze(curr_df_raw(comp_index, session_index, :, :));
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_df_result = squeeze(curr_df_result(comp_index, :, session_index, :, :));
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw = squeeze(curr_raw(comp_index, :, session_index, :, :));
%             finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result = squeeze(curr_result(comp_index, :, session_index, :, :));

            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.measured_cell_signal = squeeze(curr_raw(comp_index, 1, session_index, :, :));
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_raw.raw_neuropil_region_signal = squeeze(curr_raw(comp_index, 2:end, session_index, :, :));
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.final_extracted_cell_signal = squeeze(curr_result(comp_index, 1, session_index, :, :));
            finalDataStruct.(anmID).(curr_session_field).imgData.(currentComp).fissa_result.contaminating_neuropil_region_signal = squeeze(curr_result(comp_index, 2:end, session_index, :, :));
            
        end % end for comps
    
    end % end for sessions
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
    
    if phoPipelineOptions.fissa_included_cellROIs_only
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

        [~, ~, curr_cell.df_raw] = flattenAllFields(fissa_data.df_raw.(curr_cell_id_name), 2);
        numCombinedDatapoints = length(curr_cell.df_raw);
        [~, ~, curr_cell.df_result] = flattenAllFields(fissa_data.df_result.(curr_cell_id_name), 2);        
        [~, ~, curr_cell.raw] = flattenAllFields(fissa_data.raw.(curr_cell_id_name), 2);
        [~, ~, curr_cell.result] = flattenAllFields(fissa_data.result.(curr_cell_id_name), 2);
        
        is_first_cell = (i == 1);
        
        if is_first_cell
            % Pre-allocate the output structures now that we know how big they are:
            fissa_outputs.results.df_raw = zeros([filteredNumCells numCombinedDatapoints]); 
            fissa_outputs.results.df_result = zeros([filteredNumCells size(curr_cell.df_result,1) size(curr_cell.df_result,2)]);
            fissa_outputs.results.raw = zeros([filteredNumCells size(curr_cell.raw,1) size(curr_cell.raw,2)]); 
            fissa_outputs.results.result = zeros([filteredNumCells size(curr_cell.result,1) size(curr_cell.result,2)]);
        end
        
        fissa_outputs.results.df_raw(i,:) = curr_cell.df_raw;
        fissa_outputs.results.df_result(i,:,:) = curr_cell.df_result;
        fissa_outputs.results.raw(i,:,:) = curr_cell.raw;
        fissa_outputs.results.result(i,:,:) = curr_cell.result;
    end

    fissa_outputs.includedCompMask = includedCompMask;
    fissa_outputs.filteredCellFields = filteredCellFields;
    fissa_outputs.filteredCellFieldOriginalIndicies = filteredCellFieldOriginalIndicies;

end

