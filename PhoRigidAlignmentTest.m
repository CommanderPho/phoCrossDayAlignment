addpath(genpath('helpers'));

dataPath = 'E:\PhoHaleScratchFolder';
dateStrings = {'20200117','20200120','20200124'}; % Strings representing each date.
[rawOutpaths, registeredOutpaths] = fnBuildPaths(dateStrings);

numberOfDays = length(registeredOutpaths);

% Allocate output structures:


% Load first and second days:
prevIndex = 1;
nextIndex = 2;

% Get the tif paths for each
registeredTifFolder_prev = registeredOutpaths{prevIndex}.tifFolder;
registeredTifFolder_next = registeredOutpaths{nextIndex}.tifFolder;

% % Set the datasources
% imds.registered_prev.ReadFcn = @fnCustomTifStackReader;
% imds.registered_next.ReadFcn = @fnCustomTifStackReader;
% 
% % Load the datasources
% imds.registered_prev = imageDatastore(registeredTifFolder_prev,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');
% imds.registered_next = imageDatastore(registeredTifFolder_next,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');
% 
% % Extract information from the loaded datastores
% registered_imageInfo_prev.count = size(imds.registered_prev.Files, 1);
% registered_imageInfo_next.count = size(imds.registered_next.Files, 1);
% 
% % Get prev/next index:
% registered_imageInfo_prev.last_index = registered_imageInfo_prev.count;
% registered_imageInfo_next.first_index = 1;
% 
% % Load the current data:
% registered_imageInfo_prev.fileName = imds.registered_prev.Files{registered_imageInfo_prev.last_index}; % Get the last index of the previous one
% registered_imageInfo_prev.currLoadedData = bfOpen3DVolume(registered_imageInfo_prev.fileName);
% registered_imageInfo_prev.currLoadedImgStack = registered_imageInfo_prev.currLoadedData{1,1}{1,1}; % Produces the desired 512x512x2000 (2000 frames per .tif) output
% registered_imageInfo_prev.imgStackSize.numberOfFrames = size(registered_imageInfo_prev.currLoadedImgStack,3);
% 
% registered_imageInfo_next.fileName = imds.registered_next.Files{registered_imageInfo_next.first_index}; % Get the first index of the next one
% registered_imageInfo_next.currLoadedData = bfOpen3DVolume(registered_imageInfo_next.fileName);
% registered_imageInfo_next.currLoadedImgStack = registered_imageInfo_next.currLoadedData{1,1}{1,1}; % Produces the desired 512x512x2000 (2000 frames per .tif) output
% registered_imageInfo_next.imgStackSize.numberOfFrames = size(registered_imageInfo_next.currLoadedImgStack,3);
% 
% %% Individual Frame Level
% % Load the last frame of the prev day and the first frame of the next day
% registered_imageInfo_prev.currRegisteredImage = registered_imageInfo_prev.currLoadedImgStack(:,:,registered_imageInfo_prev.imgStackSize.numberOfFrames); % Get the last from the first prev stack
% registered_imageInfo_next.currRegisteredImage = registered_imageInfo_next.currLoadedImgStack(:,:,1); % Get first frame from the next stack
% 
% % imshow(registered_imageInfo_prev.currRegisteredImage)
% % imshow(registered_imageInfo_next.currRegisteredImage)
% 
% fnPhoMatrixPlot(registered_imageInfo_prev.currRegisteredImage)
% fnPhoMatrixPlot(registered_imageInfo_next.currRegisteredImage)
% 
% % registered_imageInfo_prev.currRegisteredImage = imds.registered_prev.readimage(registered_imageInfo_prev.imgStackSize.numberOfFrames); % Get the last from the first prev stack
% % registered_imageInfo_next.currRegisteredImage = imds.registered_next.readimage(1); % Get first frame from the next stack
% 
% % Original Offset:
% figure
% imshowpair(registered_imageInfo_prev.currRegisteredImage, registered_imageInfo_next.currRegisteredImage)
% title('Original Offsets')

%% Main Loading:
[registered_imageInfo_prev, registered_imageInfo_next] = fnLoadRelevantImages(registeredTifFolder_prev, registeredTifFolder_next);

%% Main Computation:
[offset_first_to_second, debugStructures] = fnPhoComputeRegistrationOffset(registered_imageInfo_prev.currRegisteredImage, registered_imageInfo_next.currRegisteredImage);

% Shows simple offset:
Rfixed = imref2d(size(registered_imageInfo_next.currRegisteredImage));
registered = imwarp(registered_imageInfo_next.currRegisteredImage, tform, 'OutputView', Rfixed);
% imshowpair(registered_imageInfo_next.currRegisteredImage, registered) % Shows change from original next image
% imshow([imagedata1, imagedata2])

figure(2)
subplot(1,2,1)
imshowpair(registered_imageInfo_prev.currRegisteredImage, registered_imageInfo_next.currRegisteredImage)
title('Original Offsets')
subplot(1,2,2)
imshowpair(registered_imageInfo_prev.currRegisteredImage, registered)
title('Fixed Offsets')


function [registered_imageInfo_prev, registered_imageInfo_next] = fnLoadRelevantImages(registeredTifFolder_prev, registeredTifFolder_next)
    % Set the datasources
    imds.registered_prev.ReadFcn = @fnCustomTifStackReader;
    imds.registered_next.ReadFcn = @fnCustomTifStackReader;

    % Load the datasources
    imds.registered_prev = imageDatastore(registeredTifFolder_prev,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');
    imds.registered_next = imageDatastore(registeredTifFolder_next,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');

    % Extract information from the loaded datastores
    registered_imageInfo_prev.count = size(imds.registered_prev.Files, 1);
    registered_imageInfo_next.count = size(imds.registered_next.Files, 1);

    % Get prev/next index:
    registered_imageInfo_prev.last_index = registered_imageInfo_prev.count;
    registered_imageInfo_next.first_index = 1;

    % Load the current data:
    registered_imageInfo_prev.fileName = imds.registered_prev.Files{registered_imageInfo_prev.last_index}; % Get the last index of the previous one
    registered_imageInfo_prev.currLoadedData = bfOpen3DVolume(registered_imageInfo_prev.fileName);
    registered_imageInfo_prev.currLoadedImgStack = registered_imageInfo_prev.currLoadedData{1,1}{1,1}; % Produces the desired 512x512x2000 (2000 frames per .tif) output
    registered_imageInfo_prev.imgStackSize.numberOfFrames = size(registered_imageInfo_prev.currLoadedImgStack,3);

    registered_imageInfo_next.fileName = imds.registered_next.Files{registered_imageInfo_next.first_index}; % Get the first index of the next one
    registered_imageInfo_next.currLoadedData = bfOpen3DVolume(registered_imageInfo_next.fileName);
    registered_imageInfo_next.currLoadedImgStack = registered_imageInfo_next.currLoadedData{1,1}{1,1}; % Produces the desired 512x512x2000 (2000 frames per .tif) output
    registered_imageInfo_next.imgStackSize.numberOfFrames = size(registered_imageInfo_next.currLoadedImgStack,3);

    %% Individual Frame Level
    % Load the last frame of the prev day and the first frame of the next day
    registered_imageInfo_prev.currRegisteredImage = registered_imageInfo_prev.currLoadedImgStack(:,:,registered_imageInfo_prev.imgStackSize.numberOfFrames); % Get the last from the first prev stack
    registered_imageInfo_next.currRegisteredImage = registered_imageInfo_next.currLoadedImgStack(:,:,1); % Get first frame from the next stack

    % imshow(registered_imageInfo_prev.currRegisteredImage)
    % imshow(registered_imageInfo_next.currRegisteredImage)

    fnPhoMatrixPlot(registered_imageInfo_prev.currRegisteredImage)
    fnPhoMatrixPlot(registered_imageInfo_next.currRegisteredImage)

    % registered_imageInfo_prev.currRegisteredImage = imds.registered_prev.readimage(registered_imageInfo_prev.imgStackSize.numberOfFrames); % Get the last from the first prev stack
    % registered_imageInfo_next.currRegisteredImage = imds.registered_next.readimage(1); % Get first frame from the next stack

    % Original Offset:
    figure
    imshowpair(registered_imageInfo_prev.currRegisteredImage, registered_imageInfo_next.currRegisteredImage)
    title('Original Offsets')
end
