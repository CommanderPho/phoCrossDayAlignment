% Pho Load Final Data Struct: Pipeline Stage 4
% Pho Hale, November 13, 2020
% Uses the finalDataStruct workspace variable and shows results.

%% SPEC: finalDataStruct
% finalDataStruct: 1x1 struct - 1 field: has one field for each animal
%   anm265: 1x1 struct: has one field for each session ("day")
%       - session_20200117: 1x1 struct
%           - behData:  1x1 struct
%               - amAmplitude: 520x1 double
%               - amFrequency: 520x1 double
%           - imgData:  1x1 struct - has one field for each ROI (referred to as a "component" or "comp") named "comp%d" in printf format
%               - comp1:    1x1 struct
%                   - imagingData: 520x150 double
%                   - imagingDataNeuropil: 520x150 double
%                   - segmentLabelMatrix: 512x512 double
%                   - imagingDataDFF: 520x150 double

%% SPEC: sessionList
% sessionList: 1x3 struct - 2 fields:
%   anmID: 'anm265'
%   date:  '20200117'

%% SPEC: compList
% compList: 1x474 struct - 3 fields:
%   anmID: 'anm265'
%   date:  '20200117'
%   compName: 'comp1'




addpath(genpath('../helpers'));

%% Options:
enable_resave = false;
finalDataStruct_DFF_baselineFrames = [1, 30];

if ~exist('finalDataStruct','var')
%    default_FD_file_path = 'Z:\ICPassiveStim\FDStructs\anm265\FDS_anm265.mat';
   default_FD_file_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/FDS_anm265.mat';
%    default_FD_file_path = '*.mat';
   [filename, path] = uigetfile(default_FD_file_path,'Select a finalDataStruct .mat file');
    if isequal(filename,0)
        disp('User selected Cancel');
    else
        FDPath = fullfile(path, filename);
        fprintf('Loading %s...',FDPath);
        load(FDPath);
        disp('done.')
    end
end

% TODO: Check if the fields exist (DFF already computed):
disp('Running makeSessionList_FDS on finalDataStruct...')
[sessionList, compList] = makeSessionList_FDS(finalDataStruct); %make a list of sessions and comps in FDS


%% "FD (final data)" file output:
if enable_resave
    disp('Running baselineDFF_fds on finalDataStruct...')
    finalDataStruct = baselineDFF_fds(finalDataStruct, sessionList, finalDataStruct_DFF_baselineFrames); % Adds the DFF baseline to the finalDataStruct
    fprintf('writing final data struct with DFF back out to %s... ', FDPath);
    save(FDPath, 'finalDataStruct')  % Save out to the file
end
disp('done.')

% %plotting
% disp('Plotting finalDataStruct...')
% % plotTracesForAllStimuli_FDS(finalDataStruct, compList(4))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(162))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(320))
% plotAMConditions_FDS(finalDataStruct, compList(2:8))

% plotAMConditions_FDS(finalDataStruct, compList(4))


