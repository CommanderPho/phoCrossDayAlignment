%% ViewVideos.m
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

tifFolder = '/Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif';
% tifFilePath = '/Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif/file000_chan0.tif';

framesPerTiff = 4096;
tiffFrameSize = [512 512];

shouldShowVideoPlayer = true;

%% Folder Loading Version:
[imds, registered_imageInfo] = fnLoadTifFolderToMovieFrames(tifFolder);
% movieFrames = registered_imageInfo.currLoadedImgStack;

numTifFiles = registered_imageInfo.count;

for i = registered_imageInfo.first_index:registered_imageInfo.last_index
    curr_tifFileName = imds.registered_prev.Files{i};
    temp.currStartIndex = (framesPerTiff * i) + 1;
    temp.currEndIndex = (temp.currStartIndex + framesPerTiff)-1;
%     [movieFrames(:,:,temp.currStartIndex:temp.currEndIndex), ~] = fnLoadTifToMovieFrames(curr_tifFileName);
    [currMovieFrames, ~] = fnLoadTifToMovieFrames(curr_tifFileName);
    if (i == registered_imageInfo.first_index)
        movieFrames = currMovieFrames;
    else
        movieFrames = cat(3, movieFrames, currMovieFrames);
%         movieFrames = [movieFrames; currMovieFrames];
    end
end

%% Single tifFile version:
% [movieFrames, imgStackSize] = fnLoadTifToMovieFrames(tifFilePath);

if shouldShowVideoPlayer
    svpConfig.VidPlayer.frameRate = 30; %Default to 30fps
    svpConfig.VidPlayer.videoSource = movieFrames; % From workspace variable
    svpConfig.DataPlot.x = 1:imgStackSize.numberOfFrames;

    [svp, svpSettings] = SliderVideoPlayer(svpConfig);
end

function [imds, registered_imageInfo] = fnLoadTifFolderToMovieFrames(tifFolder)
    %  fnLoadTifFolderToMovieFrames: loads an entire tifFolder
    % Set the datasources
    imds.registered_prev.ReadFcn = @fnCustomTifStackReader;
    
    % Load the datasources
    imds.registered_prev = imageDatastore(tifFolder,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');
    
    % Extract information from the loaded datastores
    registered_imageInfo.count = size(imds.registered_prev.Files, 1);
    
    % Get prev/next index:
    registered_imageInfo.first_index = 1;
    registered_imageInfo.last_index = registered_imageInfo.count;
    
%     % Load the current data:
%     registered_imageInfo.fileName = imds.registered_prev.Files{registered_imageInfo.first_index};
% 
%     [registered_imageInfo.currLoadedImgStack, registered_imageInfo.imgStackSize] = fnLoadTifToMovieFrames(registered_imageInfo.fileName);
end


function [currLoadedImgStack, imgStackSize] = fnLoadTifToMovieFrames(tifFile)
    fprintf('\t Loading tif %s...\n', tifFile);
%     currLoadedData = bfOpen3DVolume(tifFile);
%     currLoadedImgStack = currLoadedData{1,1}{1,1}; % Produces the desired 512x512xnumberOfFrames (numberOfFrames frames per .tif) output
    currLoadedImgStack = loadtiff(tifFile);
    imgStackSize.numberOfFrames = size(currLoadedImgStack,3);
    fprintf('\t \t done. Contains %d frames.\n', imgStackSize.numberOfFrames);
end