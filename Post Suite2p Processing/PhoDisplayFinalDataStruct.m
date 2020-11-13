% Pho Display Final Data Struct: Pipeline Stage 4
% Pho Hale, November 13, 2020
% Uses the finalDataStruct workspace variable and shows results.

addpath(genpath('..\helpers'));

%% Options:
finalDataStruct_DFF_baselineFrames = [1, 30];

if ~exist('finalDataStruct','var')
   [filename, path] = uigetfile('*.mat','Select a finalDataStruct .mat file');
   FDPath = fullfile(path, filename);
   fprintf('Loading %s...',FDPath);
   load(FDPath);
   disp('done.')
end

% TODO: Check if the fields exist (DFF already computed):
disp('Running makeSessionList_FDS on finalDataStruct...')
[sessionList, compList] = makeSessionList_FDS(finalDataStruct); %make a list of sessions and comps in FDS
disp('Running makeSessionList_FDS on finalDataStruct...')
finalDataStruct = baselineDFF_fds(finalDataStruct, sessionList, finalDataStruct_DFF_baselineFrames); % Adds the DFF baseline to the finalDataStruct

%% "FD (final data)" file output:
fprintf('writing final data struct with DFF back out to %s... ', FDPath);
save(FDPath, 'finalDataStruct')  % Save out to the file
disp('done.')

% %plotting
% disp('Plotting finalDataStruct...')
% plotTracesForAllStimuli_FDS(finalDataStruct, compList)
% plotAMConditions_FDS(finalDataStruct, compList)

