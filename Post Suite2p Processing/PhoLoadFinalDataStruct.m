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

fprintf('> Running PhoLoadFinalDataStruct...\n');

%% Options:
% Uses:
%   phoPipelineOptions.default_FD_file_path
%   phoPipelineOptions.PhoLoadFinalDataStruct.enable_resave
%   phoPipelineOptions.PhoLoadFinalDataStruct.processingOptions.use_neuropil
%   phoPipelineOptions.PhoLoadFinalDataStruct.finalDataStruct_DFF_baselineFrames 
if ~exist('phoPipelineOptions','var')
    warning('phoPipelineOptions is missing! Using defaults specified in PhoLoadFinalDataStruct.m')
    phoPipelineOptions.default_FD_file_path = '';
    phoPipelineOptions.PhoLoadFinalDataStruct.enable_resave = false;
    phoPipelineOptions.PhoLoadFinalDataStruct.processingOptions.use_neuropil = true;
    phoPipelineOptions.PhoLoadFinalDataStruct.finalDataStruct_DFF_baselineFrames = [1, 30]; 
end


if ~exist('finalDataStruct','var')
    if isempty(phoPipelineOptions.default_FD_file_path)
        [filename, path] = uigetfile('*.mat', 'Select a finalDataStruct .mat file');
    else
        [filename, path] = uigetfile(phoPipelineOptions.default_FD_file_path, 'Select a finalDataStruct .mat file');
    end
   
    if isequal(filename,0)
        warning('User selected Cancel');
    else
        FDPath = fullfile(path, filename);
        fprintf('\t Loading %s...',FDPath);
        load(FDPath);
        fprintf('done.\n');
    end
end

% TODO: Check if the fields exist (DFF already computed):
fprintf('\t Running makeSessionList_FDS on finalDataStruct...\n');
[sessionList, compList] = makeSessionList_FDS(finalDataStruct); %make a list of sessions and comps in FDS
fprintf('\t\t done.\n');

%% "FD (final data)" file output:
if phoPipelineOptions.PhoLoadFinalDataStruct.enable_resave
    disp('\t Running baselineDFF_fds on finalDataStruct...')
    finalDataStruct = baselineDFF_fds(finalDataStruct, sessionList, phoPipelineOptions.PhoLoadFinalDataStruct.finalDataStruct_DFF_baselineFrames, phoPipelineOptions.PhoLoadFinalDataStruct.processingOptions); % Adds the DFF baseline to the finalDataStruct
    fprintf('\t writing final data struct with DFF back out to %s... ', FDPath);
    save(FDPath, 'finalDataStruct')  % Save out to the file
end
fprintf('\t done.\n');
% %plotting
% disp('Plotting finalDataStruct...')
% % plotTracesForAllStimuli_FDS(finalDataStruct, compList(4))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(162))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(320))
% plotAMConditions_FDS(finalDataStruct, compList(2:8))

% plotAMConditions_FDS(finalDataStruct, compList(4))


