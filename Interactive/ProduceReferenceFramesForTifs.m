%% ProduceReferenceFramesForTifs.m
% Allows the user to interactively open a tifFile/tifFolder to render the frames as a movie after loading.
% Loading tif /Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif/file000_chan0.tif...The file was loaded successfully. Elapsed time : 14.861 s.
% done. Contains 4096 frames.
% 	 Loading tif /Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif/file001_chan0.tif...The file was loaded successfully. Elapsed time : 53.785 s.
% done. Contains 4096 frames.
% 	 Loading tif /Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif/file002_chan0.tif...The file was loaded successfully. Elapsed time : 75.624 s.
% done. Contains 4096 frames.

% benchmarking.loadTimes_preallocate = [14.861, 53.785, 75.624];
% benchmarking.loadTimes_concatenate = [15.610, 46.078, 71.912];
% benchmarking.loadTimes_correctconcatenate = [15.922, 47.310, 56.601];
% 
% benchmarking.totalLoadTimes_preallocate = sum(benchmarking.loadTimes_preallocate) % 144.2700 sec
% benchmarking.totalLoadTimes_concatenate = sum(benchmarking.loadTimes_concatenate) % 133.6000 sec
% benchmarking.totalLoadTimes_correctconcatenate = sum(benchmarking.loadTimes_correctconcatenate) % 119.8330 sec

addpath(genpath('helpers'));

% tifFolder = '/Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif';
% tifFilePath = '/Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif/file000_chan0.tif';
inputs.tifFolder = 'E:\PhoHaleScratchFolder\202001_17-20-24_PassiveStim_Registered\suite2p\plane0\reg_tif';

outputs.TifFolderName = 'reg_tif_aggregates';
outputs.TifRootFolderPath = fullfile(inputs.tifFolder, '../', outputs.TifFolderName);

if ~exist(outputs.TifRootFolderPath, 'dir')
   fprintf('Directory %s does not exist... creating it\n', outputs.TifRootFolderPath);
   mkdir(outputs.TifRootFolderPath);   
end

outputs.stackFileCombinedTifFolderName = 'file_level';
outputs.stackFileCombinedTifFolderPath = fullfile(outputs.TifRootFolderPath, outputs.stackFileCombinedTifFolderName);

if ~exist(outputs.stackFileCombinedTifFolderPath, 'dir')
   fprintf('Directory %s does not exist... creating it\n', outputs.stackFileCombinedTifFolderPath);
   mkdir(outputs.stackFileCombinedTifFolderPath);   
end

%% Build the Output directory for the 2nd-level session aggregated max intensity images:
outputs.stackSessionCombinedTifFolderName = 'session_level';
outputs.stackSessionCombinedTifFolderPath = fullfile(outputs.TifRootFolderPath, outputs.stackSessionCombinedTifFolderName);

if ~exist(outputs.stackSessionCombinedTifFolderPath, 'dir')
   fprintf('Directory %s does not exist... creating it\n', outputs.stackSessionCombinedTifFolderPath);
   mkdir(outputs.stackSessionCombinedTifFolderPath);   
end

outputs.stackSessionPartialCombinedTifFolderName = 'session_partials';
outputs.stackSessionPartialCombinedTifFolderPath = fullfile(outputs.stackSessionCombinedTifFolderPath, outputs.stackSessionPartialCombinedTifFolderName);

if ~exist(outputs.stackSessionPartialCombinedTifFolderPath, 'dir')
   fprintf('Directory %s does not exist... creating it\n', outputs.stackSessionPartialCombinedTifFolderPath);
   mkdir(outputs.stackSessionPartialCombinedTifFolderPath);   
end




%% Build the Output directory for the 3rd-level all aggregated max intensity images:
outputs.stackAllCombinedTifFolderName = 'all_level';
outputs.stackAllCombinedTifFolderPath = fullfile(outputs.TifRootFolderPath, outputs.stackAllCombinedTifFolderName);

if ~exist(outputs.stackAllCombinedTifFolderPath, 'dir')
   fprintf('Directory %s does not exist... creating it\n', outputs.stackAllCombinedTifFolderPath);
   mkdir(outputs.stackAllCombinedTifFolderPath);   
end

framesPerTiff = 4096;
tiffFrameSize = [512 512];




%% Folder Loading Version:
[imds, registered_imageInfo] = fnLoadTifFolderToDatastore(inputs.tifFolder);
% movieFrames = registered_imageInfo.currLoadedImgStack;

numTifFiles = registered_imageInfo.count;
totalCombinedNumFrames = framesPerTiff * numTifFiles;

%% Figure out how the Tiff files align with the sessions.
% There's 78000 frames in each session
% rem(78000, framesPerTiff) is 176
sessionSplit.numSessions = 3;
sessionSplit.numFramesPerSession = 78000;

numFullTiffFilesPerSession = floor(sessionSplit.numFramesPerSession / framesPerTiff);
leftOverFrames = rem(sessionSplit.numFramesPerSession, framesPerTiff);

% Get the frame indicies corresponding to each Tiff file
[tiff_frames_first_index_array, tiff_frames_last_index_array] = fnGetBlockIndexArrays(framesPerTiff, numTifFiles);
% Get the frame indicies corresponding to each session
[sessionSplit.frames_first_index_array, sessionSplit.frames_last_index_array] = fnGetBlockIndexArrays(sessionSplit.numFramesPerSession, sessionSplit.numSessions);
% Build a map that specifies which session a specific tiff file belongs in:

%% TODO: need to re-enable this when not testing:
% sessionSplit.doesTifFileContainSessionSplit = zeros([numTifFiles 1], 'logical');

% 20 and 39 must be excluded
splittingSessions = {};

outputs.tiffFilePaths = cell([numTifFiles, 1]);

% outputs.sessions = cell([sessionSplit.numSessions 1]);
% outputs.sessions.outPaths = {};
outputs.sessions = struct('files_list',{{}});

% Include all Tiffs:
is_tiff_included = ones([numTifFiles, 1], 'logical');

% Include only those files with session splits:
% is_tiff_included = sessionSplit.doesTifFileContainSessionSplit;

% Loop through:
curr_active_file_session.sessionIndex = 1;
curr_active_session.files_list = {};
% outputs.sessions(curr_active_file_session.sessionIndex).files_list = 0.0;

for tiffFileIndex = registered_imageInfo.first_index:registered_imageInfo.last_index
    
    curr_tifFileName = imds.registered.Files{tiffFileIndex};
    inputs.tiffFilePaths{tiffFileIndex} = curr_tifFileName;
    
    curr_max_intensity_filename = sprintf('max_tif_%d.tif', tiffFileIndex);
    curr_output_path.max_intensity = fullfile(outputs.stackFileCombinedTifFolderPath, curr_max_intensity_filename);
    outputs.tiffFilePaths{tiffFileIndex} = curr_output_path.max_intensity;
    
    
    if ~is_tiff_included(tiffFileIndex)
        fprintf('Skipping excluded Tiff with index %d\n', tiffFileIndex);
       continue 
    end
    
    
    
    % Check to see if a give tiff file contains multiple sessions by
    % checking whether there's a session split that falls within its frame
    % indicies.
    curr_tiff_first_index = tiff_frames_first_index_array(tiffFileIndex);
    curr_tiff_last_index = tiff_frames_last_index_array(tiffFileIndex);
    contains_session_split = false;
    currSplittingSession.endingSession.Index = -1;
    currSplittingSession.startingSession.Index = -1;
    
    for sessionIndex = 1:sessionSplit.numSessions
        curr_sessionChangeIndex = sessionSplit.frames_first_index_array(sessionIndex);
       if (curr_tiff_first_index < curr_sessionChangeIndex) && (curr_sessionChangeIndex < curr_tiff_last_index)
           contains_session_split = true;
           currSplittingSession.endingSession.Index = sessionIndex - 1;
           currSplittingSession.startingSession.Index = sessionIndex;
           fprintf('sessionSplitting: fileIndex %d; sessionIndex %d\n', tiffFileIndex, sessionIndex);
           break
       end
    end
    
    if contains_session_split
        sessionSplit.doesTifFileContainSessionSplit(tiffFileIndex) = contains_session_split;
        % Get the frames that were part of the previous session
        sessionStartFrameTiffRelativeOffset = sessionSplit.frames_first_index_array(currSplittingSession.startingSession.Index) - curr_tiff_first_index;
        
        %% Information about saving out the file:
        currSplittingSession.endingSession.max_intensity_filename = sprintf('max_tif_session_%d_ending.tif', currSplittingSession.endingSession.Index);
        currSplittingSession.startingSession.max_intensity_filename = sprintf('max_tif_session_%d_starting.tif', currSplittingSession.startingSession.Index);
        
        currSplittingSession.endingSession.output_path.max_intensity = fullfile(outputs.stackSessionPartialCombinedTifFolderPath, currSplittingSession.endingSession.max_intensity_filename);
        currSplittingSession.startingSession.output_path.max_intensity = fullfile(outputs.stackSessionPartialCombinedTifFolderPath, currSplittingSession.startingSession.max_intensity_filename);
        
        %% Save a session split files:
        [currMovieFrames, ~] = fnLoadTifToMovieFrames(curr_tifFileName); % [512x512x4096]
        currSplittingSession.endingSession.MovieFrames = currMovieFrames(:,:,1:sessionStartFrameTiffRelativeOffset);
        currSplittingSession.startingSession.MovieFrames = currMovieFrames(:,:,(sessionStartFrameTiffRelativeOffset+1):framesPerTiff);
        
        tif_max_intensity = max(currSplittingSession.endingSession.MovieFrames,[],[3]);        
        fprintf('exporting max intensity image to %s...\n', currSplittingSession.endingSession.output_path.max_intensity);
        saveastiff_IfNotExists(tif_max_intensity, currSplittingSession.endingSession.output_path.max_intensity);
        fprintf('\t done.');
        
        tif_max_intensity = max(currSplittingSession.startingSession.MovieFrames,[],[3]);
        fprintf('exporting max intensity image to %s...\n', currSplittingSession.startingSession.output_path.max_intensity);
        saveastiff_IfNotExists(tif_max_intensity, currSplittingSession.startingSession.output_path.max_intensity);
        fprintf('\t done.');
        
        splittingSessions{end+1} = currSplittingSession;
        
        % Add the split file index for the ending and starting sessions to
        % that sessions' file paths array
        outputs.sessions(curr_active_file_session.sessionIndex).files_list = [outputs.sessions(curr_active_file_session.sessionIndex).files_list; currSplittingSession.endingSession.output_path.max_intensity];
                
        % Start a new session:
        curr_active_file_session.sessionIndex = curr_active_file_session.sessionIndex + 1; % Update the active session index so we know the next Tif files belong to the next session
        outputs.sessions(curr_active_file_session.sessionIndex).files_list = { currSplittingSession.startingSession.output_path.max_intensity };
        
    else
        
        outputs.sessions(curr_active_file_session.sessionIndex).files_list = [outputs.sessions(curr_active_file_session.sessionIndex).files_list; curr_output_path.max_intensity];
        
    end
    
   
    
    
    %% Save out the file:
    if ~exist(curr_output_path.max_intensity, 'file')
        % Get the frames:
        [currMovieFrames, ~] = fnLoadTifToMovieFrames(curr_tifFileName); % [512x512x4096]
        % Compute the block output
        tif_max_intensity = max(currMovieFrames,[],[3]);
%     tif_mean_intensity = mean(currMovieFrames, 3);
        fprintf('exporting max intensity image to %s...\n', curr_output_path.max_intensity);
        saveastiff(tif_max_intensity, curr_output_path.max_intensity);
        fprintf('\t done.');
    else
        fprintf('%s exists, skipping.\n', curr_output_path.max_intensity);
    end

end



%% Once Each Individual Tif is processed and saved, create a new imageDatastore from the output path to process them further
[output_imds, output_registered_imageInfo] = fnLoadTifFolderToDatastore(outputs.stackFileCombinedTifFolderPath);
% Loop through the previously saved files to further aggregate the outputs
output_numTifFiles = output_registered_imageInfo.count;
output_totalCombinedNumFrames = numTifFiles;
% Pre-allocate output images:
currMovieFrames = zeros([output_totalCombinedNumFrames 512 512], 'int16');

% Loop through outputs:
for tiffFileIndex = output_registered_imageInfo.first_index:output_registered_imageInfo.last_index
    curr_tifFileName = output_imds.registered.Files{tiffFileIndex};
    % Each tif now is a single 512x512 image instead of a stack
    [currMovieFrames(tiffFileIndex,:,:), ~] = fnLoadTifToMovieFrames(curr_tifFileName); % [512x512]
end


tif_max_intensity = squeeze(max(currMovieFrames,[],1));
%     tif_mean_intensity = mean(currMovieFrames, 3);
%% Save out the file:
curr_max_intensity_filename = 'max_tif_all.tif';
curr_output_path.max_intensity = fullfile(outputs.stackAllCombinedTifFolderPath, curr_max_intensity_filename);
if ~exist(curr_output_path.max_intensity, 'file')
    fprintf('exporting max intensity image to %s...\n', curr_output_path.max_intensity);
    saveastiff(tif_max_intensity, curr_output_path.max_intensity);
    fprintf('\t done.');
else
    fprintf('%s exists, skipping.\n', curr_output_path.max_intensity);
end
    



function [didSave] = saveastiff_IfNotExists(img, savePath)
    if ~exist(savePath, 'file')
        fprintf('exporting image to %s...\n', savePath);
        saveastiff(img, savePath);
        fprintf('\t done.');
        didSave = true;
    else
        didSave = false;
        fprintf('%s exists, skipping.\n', savePath);
    end
    
end


