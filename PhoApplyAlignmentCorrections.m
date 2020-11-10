% Takes alignment offsets computed by the previous stage in the pipeline
% and applies them to the registered .tifs

addpath(genpath('helpers'));

% Loop through the registered folder for each offset
% for i = 1:numberOfOffsets
    i = 2;
    % Load first and second days:
    nextIndex = nextIndicies(i);

    % Get the tif paths for each
    registeredTifFolder_next = registeredOutpaths{nextIndex}.tifFolder;

    % Create a corrected tif path next to the current one
    correctedRegisteredTifFolder = fullfile(registeredTifFolder_next, '..', 'reg_tif_aligned'); 
    
    if ~exist(correctedRegisteredTifFolder,'dir')
        mkdir(correctedRegisteredTifFolder)
    end
    
    % Load the datasources
    imds = imageDatastore(registeredTifFolder_next,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');
    % Extract information from the loaded datastores
    corrected_imageInfo.count = size(imds.Files, 1);

    % Get the current transform
    curr_offset_first_to_second = outputRegistrationCorrections.translation_offset_first_to_second(i,:);
    [curr_tform] = fnBuildTranslationOnlyAffineTransform(curr_offset_first_to_second(1), curr_offset_first_to_second(2));
    
    % Build the augmented datastore
    %auimds = augmentedImageDatastore(outputSize, imds.registered_next)
    
    transformedImds = transform(imds, @(x) imwarp(x, curr_tform, 'OutputView', imref2d(size(x))));
    fprintf('Writing %d transformed files to %s!\n', corrected_imageInfo.count, correctedRegisteredTifFolder);
    
    writeall(transformedImds, correctedRegisteredTifFolder, 'Folderlayout', 'flatten')
    fprintf('Done! Wrote transformed files to %s!\n', correctedRegisteredTifFolder);
    
    
%     Rfixed = imref2d(size(registered_imageInfo_next.currRegisteredImage));
    %transformedImds = transform(imds, @(x) imwarp(x, curr_tform, 'OutputView', Rfixed));
    
    % TODO: Also benchmark J = imtranslate(I,[25.3, -10.1],'FillValues',255);
    
%     % Load the current data:
%     registered_imageInfo_next.fileName = imds.registered_next.Files{registered_imageInfo_next.first_index}; % Get the first index of the next one
%     registered_imageInfo_next.currLoadedData = bfOpen3DVolume(registered_imageInfo_next.fileName);
%     registered_imageInfo_next.currLoadedImgStack = registered_imageInfo_next.currLoadedData{1,1}{1,1}; % Produces the desired 512x512x2000 (2000 frames per .tif) output
%     registered_imageInfo_next.imgStackSize.numberOfFrames = size(registered_imageInfo_next.currLoadedImgStack,3);
% 
%     %% Individual Frame Level
%     % Load the last frame of the prev day and the first frame of the next day
%     registered_imageInfo_prev.currRegisteredImage = registered_imageInfo_prev.currLoadedImgStack(:,:,registered_imageInfo_prev.imgStackSize.numberOfFrames); % Get the last from the first prev stack
%     registered_imageInfo_next.currRegisteredImage = registered_imageInfo_next.currLoadedImgStack(:,:,1); % Get first frame from the next stack

    
    
%     %% Main Loading:
%     [registered_imageInfo_prev, registered_imageInfo_next] = fnLoadRelevantImages(registeredTifFolder_prev, registeredTifFolder_next);
% 
%     %% Main Computation:
%     [offset_first_to_second, debugStructures] = fnPhoComputeRegistrationOffset(registered_imageInfo_prev.currRegisteredImage, registered_imageInfo_next.currRegisteredImage);
%     outputRegistrationCorrections.translation_offset_first_to_second(i,:) = offset_first_to_second;
% 
%     % Shows simple offset:
%     Rfixed = imref2d(size(registered_imageInfo_next.currRegisteredImage));
%     registered = imwarp(registered_imageInfo_next.currRegisteredImage, debugStructures.tform, 'OutputView', Rfixed);
% 
%     figure(2)
%     subplot(1,2,1)
%     imshowpair(registered_imageInfo_prev.currRegisteredImage, registered_imageInfo_next.currRegisteredImage)
%     title('Original Offsets')
%     subplot(1,2,2)
%     imshowpair(registered_imageInfo_prev.currRegisteredImage, registered)
%     title('Fixed Offsets')
%     disp('done.')
    
% end

% % Save the results if needed:
% save('output.mat','dateStrings','outputRegistrationCorrections','-mat')