% Pho Post Suite2p Testing Live Script: Pipeline Stage 3
% Pho Hale, November 13, 2020
% Loads the Fall.mat output by Suite2p and performs analysis

% clear all;
addpath(genpath('..\helpers'));
% Processing Options
dateStrings = {'20200117','20200120','20200124'}; % Strings representing each date.
trialLength = 150;
animalID = 'anm265';
outputFolder = 'E:\PhoHaleScratchFolder\202001_17-20-24_PassiveStim_Registered\suite2p';
% outputFolder = 'Z:\ICPassiveStim\anm265\20200117_PassiveStim_Registered\FoV1Lateral\suite2p';

fAllPath = fullfile(outputFolder,'plane0\Fall.mat');
fAllSplitOutputPath = fullfile(outputFolder,'plane0\days_split');
if ~exist(fAllSplitOutputPath,'dir')
    mkdir(fAllSplitOutputPath) % make the output dir in the folder
end

[rawOutpaths, registeredOutpaths] = fnBuildPaths(dateStrings);
% rawOutpaths{i}.audioParametersFolder
% 'Z:\ICPassiveStim\anm265\20200117_PassiveStim\AudioParameters'


% Get the folder name as the directory just above suite2p
temp.splitStr = split(outputFolder, '\');
activeFolderName = '';
for i = flip(1:length(temp.splitStr)) % Run the for loop from last index to first, for efficiencies sake
    temp.curr_str = temp.splitStr{i};
    if strcmpi(temp.curr_str,'suite2p') % Look for the element just prior to 'suite2p' in the path.
        activeFolderName = temp.splitStr{i-1}; % The answer is the previous element
    end
end

% Loads the fAll
fAll = load(fAllPath);

% fAll.ops
folders_count = length(fAll.ops.frames_per_folder); % Number of input folders, corresponding to the number of recording days

frames_per_folder = fAll.ops.frames_per_folder;
total_number_frames = fAll.ops.nframes;

% see also in fAll.ops:
% frames_per_file;

potential_rois_count = length(fAll.iscell); % The initial number of ROIs Suite2p generated via its analysis
isROIConfirmed = fAll.iscell(:,1); % Boolean list of length potential_rois_count indicating whether a potential ROI is believed to be a cell
confirmed_rois_count = sum(isROIConfirmed); % The number of potential ROIs that are confirmed to be cells
fprintf('Loaded Fall.mat from %s:\n', activeFolderName)
% Filter to get only the valid ROIs
fprintf('\t Contains %d valid ROIs (of %d total)\n', confirmed_rois_count, potential_rois_count);

cum_last_index_array = cumsum(frames_per_folder);
cum_first_index_array = (cum_last_index_array - frames_per_folder) + 1;

fprintf('\t Processing %d day folders:\n', folders_count);

% Start by copying the common fields to the output struct
curr_output_fAll.stat = fAll.stat;
% curr_output_fAll.ops = fAll.ops; % Currently don't include the ops, because they are for the combined file
curr_output_fAll.iscell = fAll.iscell;
curr_output_fAll.redcell = fAll.redcell;
    
for i = 1:folders_count
    curr_folder = fAll.ops.data_path(i,:);
    curr_folder_date_string = dateStrings{i};
    fprintf('\t \t Processing folder[%d]: %s (of %d total) with assumed date %s\n', i, curr_folder, folders_count, curr_folder_date_string);
    curr_frame_count = frames_per_folder(i);
    curr_frame_first_index = cum_first_index_array(i);
    curr_frame_last_index = cum_last_index_array(i);
    % Add the session specific variables
    curr_output_fAll.F = fAll.F(:, curr_frame_first_index:curr_frame_last_index);
    curr_output_fAll.Fneu = fAll.Fneu(:, curr_frame_first_index:curr_frame_last_index);
    curr_output_fAll.spks = fAll.spks(:, curr_frame_first_index:curr_frame_last_index);

    curr_sessionPathsInfo = rawOutpaths{i};
    
    % Build the output filename
    curr_output_fAll_Name = ['fAll_' curr_folder_date_string '.mat'];
    curr_sessionPathsInfo.curr_output_fAll_Path = fullfile(fAllSplitOutputPath, curr_output_fAll_Name);
    fprintf('\t \t \t writing out to %s...\n', curr_sessionPathsInfo.curr_output_fAll_Path);
    
    if ~exist(curr_sessionPathsInfo.curr_output_fAll_Path, 'file')
        save(curr_sessionPathsInfo.curr_output_fAll_Path,'curr_output_fAll');
        disp('done.')
    else
        warning(['File ' curr_sessionPathsInfo.curr_output_fAll_Path ' already exists! Refusing to overwrite!']);
        %TODO: in the future, load the extant file so everything is
        %consistant?
    end
    
    curr_folder_h5_search_string = fullfile(curr_sessionPathsInfo.tifFolder, '*.h5');
    curr_folder_h5_search_fileList = dir(curr_folder_h5_search_string);
    curr_sessionPathsInfo.curr_folder_h5_path = fullfile(curr_folder_h5_search_fileList(1).folder, curr_folder_h5_search_fileList(1).name);
    
    [currSessionData] = fnPhoSplitSessionPostProcess(curr_sessionPathsInfo, curr_output_fAll, trialLength);
    
    %Like '20190506_anm090.mat'
    ephysDataOutputFilename = sprintf('%s_%s.mat', curr_folder_date_string, animalID);

    %Like 'Z:\ICPassiveStim\toLoad\anm090'
    curr_output_toLoad_animal_folder = fullfile('Z:\ICPassiveStim\toLoad', animalID);
    if ~exist(curr_output_toLoad_animal_folder, 'dir')
        mkdir(curr_output_toLoad_animal_folder);
    end
    %Like 'Z:\ICPassiveStim\toLoad\anm090\20190506'
    curr_output_toLoad_session_folder = fullfile(curr_output_toLoad_animal_folder, curr_folder_date_string);
    if ~exist(curr_output_toLoad_session_folder, 'dir')
        mkdir(curr_output_toLoad_session_folder);
    end

    %Like 'Z:\ICPassiveStim\toLoad\anm090\20190506\20190506_anm090.mat'
    curr_sessionPathsInfo.ephysDataOutputPath = fullfile(curr_output_toLoad_session_folder, ephysDataOutputFilename);
    
    fprintf('\t \t \t writing out to %s... ', curr_sessionPathsInfo.ephysDataOutputPath);
    S.ephysData = currSessionData.ephysData;
    S.sessionPathsInfo = curr_sessionPathsInfo;
    S.date_string = curr_folder_date_string;
    save(curr_sessionPathsInfo.ephysDataOutputPath, '-struct', 'S')  % Save out to the file
    disp('done.')
    
    
    final_sessions_info{i} = curr_sessionPathsInfo;
    final_sessions_fAll{i} = curr_output_fAll;
    final_sessions_ephysData{i} = currSessionData.ephysData;
    
end

%once you have saved your individual sessions, append them all into a FDS
%format structure using this script

%if this is your first time running this, don't pass a varargin. if you
%want to append to an existing structure however, pass the structure name
%as varargin
[finalDataStruct]=pfaCombineAllAMSessionsForSummary(varargin);
