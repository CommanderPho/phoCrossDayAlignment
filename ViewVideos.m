%% ViewVideos.m
% Allows the user to interactively open a tifFile/tifFolder to render the frames as a movie after loading.

addpath(genpath('helpers'));

tifFolder = '/Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif';
tifFilePath = '/Volumes/Storage/Databases/PierreSecondRotation/202001_17-20-24_PassiveStim_Registered/suite2p/plane0/reg_tif/file000_chan0.tif';

% loadtiff

% [imds, registered_imageInfo] = fnLoadTifToMovieFrames(tifFolder);
% movieFrames = registered_imageInfo.currLoadedImgStack;


[movieFrames, imgStackSize] = fnLoadTifToMovieFrames(tifFilePath);
svpConfig.VidPlayer.frameRate = 30; %Default to 30fps
svpConfig.VidPlayer.videoSource = movieFrames; % From workspace variable
svpConfig.DataPlot.x = 1:imgStackSize.numberOfFrames;


[svp, svpSettings] = SliderVideoPlayer(svpConfig);


function [imds, registered_imageInfo] = fnLoadTifFolderToMovieFrames(registeredTifFolder)
    % Set the datasources
    imds.registered_prev.ReadFcn = @fnCustomTifStackReader;
    
    % Load the datasources
    imds.registered_prev = imageDatastore(registeredTifFolder,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');
    
    % Extract information from the loaded datastores
    registered_imageInfo.count = size(imds.registered_prev.Files, 1);
    
    % Get prev/next index:
    registered_imageInfo.first_index = 1;
    registered_imageInfo.last_index = registered_imageInfo.count;
    
    % Load the current data:
    registered_imageInfo.fileName = imds.registered_prev.Files{registered_imageInfo.first_index}; % Get the last index of the previous one

    [registered_imageInfo.currLoadedImgStack, registered_imageInfo.imgStackSize] = fnLoadTifToMovieFrames(registered_imageInfo.fileName);
    %     registered_imageInfo.currLoadedData = bfOpen3DVolume(registered_imageInfo.fileName);
%     registered_imageInfo.currLoadedImgStack = registered_imageInfo.currLoadedData{1,1}{1,1}; % Produces the desired 512x512x2000 (2000 frames per .tif) output
%     registered_imageInfo.imgStackSize.numberOfFrames = size(registered_imageInfo.currLoadedImgStack,3);

end


function [currLoadedImgStack, imgStackSize] = fnLoadTifToMovieFrames(tifFile)
    fprintf('\t Loading tif %s...', tifFile);
%     currLoadedData = bfOpen3DVolume(tifFile);
%     currLoadedImgStack = currLoadedData{1,1}{1,1}; % Produces the desired 512x512xnumberOfFrames (numberOfFrames frames per .tif) output
    currLoadedImgStack = loadtiff(tifFile);
    imgStackSize.numberOfFrames = size(currLoadedImgStack,3);
    fprintf('done. Contains %d frames.\n', imgStackSize.numberOfFrames);
end