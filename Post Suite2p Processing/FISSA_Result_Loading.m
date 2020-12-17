% Load FISSA Neuropil Subtraction Results:
% Pho Hale 12-17-2020

% - `ROIs.cell0.trial0{1}` polygon for the ROI
% - `ROIs.cell0.trial0{2}` polygon for first neuropil region
% - `result.cell0.trial0(1,:)` final extracted cell signal
% - `result.cell0.trial0(2,:)` contaminating signal
% - `raw.cell0.trial0(1,:)` raw measured cell signal
% - `raw.cell0.trial0(2,:)` raw signal from first neuropil region

phoPipelineOptions.default_fissa_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/fissa_suite2p_example/experiment_matlab.mat';
if ~exist('loaded_fissa_data','var')
    fprintf('Loading FISSA .mat output at %s... ', phoPipelineOptions.default_fissa_file_path)
    loaded_fissa_data = load(phoPipelineOptions.default_fissa_file_path);
    disp('done.')
end
[outputs] = process_loaded_FISSA_result(loaded_fissa_data, phoPipelineOptions);


function [outputs] = process_loaded_FISSA_result(fissa_data, phoPipelineOptions)
% process_loaded_FISSA_result description
%
% Syntax:
%    [out1,out2] = myFun(in1,in2)
%
% Inputs:
%    in1 - 
%    in2 - 
%
% Outputs:
%    out1 - 
%    out2 - 
%
% Example:
%    
% See also:
%    
% frames_per_folder = fAll.ops.frames_per_folder; % [78000, 78000, 78000]
% total_number_frames = fAll.ops.nframes; % 234000

    outputs.cellFields = fieldnames(fissa_data.ROIs);
    outputs.numCells = length(outputs.cellFields);
    outputs.tifIdentifierNames = fieldnames(fissa_data.ROIs.(outputs.cellFields{1}));
    outputs.numTifImages = length(outputs.tifIdentifierNames);
    fprintf('Detected %d cells, %d source images for FISSA data.\n', outputs.numCells, outputs.numTifImages);
    % Detected 82 cells, 58 source images for FISSA data.
    
    if ~isfield(fissa_data,'df_raw') || ~isfield(fissa_data,'df_result')
        fprintf('WARNING: the loaded fissa data is missing the computed dF/F data. Did you run the full python script?');
    end
    
    includedCompMask = ~phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.final_is_Excluded;
    filteredCellFields = outputs.cellFields(includedCompMask);
    % filteredCellFieldOriginalIndex: the index that maps to the original [1, 82] range.
    filteredCellFieldOriginalIndicies = 1:outputs.numCells;
    filteredCellFieldOriginalIndicies = filteredCellFieldOriginalIndicies(includedCompMask)';
    filteredNumCells = length(filteredCellFields);
    
    % Loop through the filtered number of cells
    for i = 1:filteredNumCells
        curr_cell_id_name = filteredCellFields{i};
        curr_cell_id_original_index = filteredCellFieldOriginalIndicies(i);

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
            outputs.results.df_raw = zeros([filteredNumCells numCombinedDatapoints]); 
            outputs.results.df_result = zeros([filteredNumCells size(curr_cell.df_result,1) size(curr_cell.df_result,2)]);
            outputs.results.raw = zeros([filteredNumCells size(curr_cell.raw,1) size(curr_cell.raw,2)]); 
            outputs.results.result = zeros([filteredNumCells size(curr_cell.result,1) size(curr_cell.result,2)]);
        end
        
        outputs.results.df_raw(i,:) = curr_cell.df_raw;
        outputs.results.df_result(i,:,:) = curr_cell.df_result;
        outputs.results.raw(i,:,:) = curr_cell.raw;
        outputs.results.result(i,:,:) = curr_cell.result;
    end

    outputs.includedCompMask = includedCompMask;
    outputs.filteredCellFields = filteredCellFields;
    outputs.filteredCellFieldOriginalIndicies = filteredCellFieldOriginalIndicies;
%     length(fieldnames(finalDataStruct.anm265.session_20200117.imgData)) - 82


%     for i = 1:numCells
%         ROIs.cell0.trial0{1}
%     end
% 
%     [currSessionData] = fnPhoSplitSessionPostProcess(curr_sessionPathsInfo, curr_output_fAll, trialLength);

end

