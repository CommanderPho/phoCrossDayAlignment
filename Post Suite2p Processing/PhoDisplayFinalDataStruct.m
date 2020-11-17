% Pho Display Final Data Struct: Pipeline Stage 4
% Pho Hale, November 13, 2020
% Uses the finalDataStruct workspace variable and shows results.

addpath(genpath('..\helpers'));

%% Options:
enable_resave = false;
finalDataStruct_DFF_baselineFrames = [1, 30];

if ~exist('finalDataStruct','var')
   default_FD_file_path = 'Z:\ICPassiveStim\FDStructs\anm265\FDS_anm265.mat';
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


