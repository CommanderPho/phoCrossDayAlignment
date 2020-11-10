% Takes alignment offsets computed by the previous stage in the pipeline
% and applies them to the registered .tifs

addpath(genpath('helpers'));

clear aacTifOutputOptions;
% aacTifOutputOptions.compress = 'lzw';
aacTifOutputOptions.color = false;

load('output.mat','dateStrings','outputRegistrationCorrections');
[rawOutpaths, registeredOutpaths] = fnBuildPaths(dateStrings);

numberOfDays = length(registeredOutpaths);
numberOfOffsets = numberOfDays-1;

refIndicies = ones(numberOfOffsets,1); % All index 1
nextIndicies = 2:numberOfDays;

% Loop through the registered folder for each offset
for i = 1:numberOfOffsets
    % Load first and second days:
    nextIndex = nextIndicies(i);

    % Get the tif paths for each
    registeredRootFolder = registeredOutpaths{nextIndex}.root;
    registeredTifFolder_next = registeredOutpaths{nextIndex}.tifFolder;

    % Create a corrected tif path next to the current one
    correctedRegisteredTifFolder = fullfile(registeredRootFolder, 'reg_tif_aligned'); 
    
    if ~exist(correctedRegisteredTifFolder,'dir')
        mkdir(correctedRegisteredTifFolder)
    end
    
    % Load the datasources
    imds = imageDatastore(registeredTifFolder_next,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames','ReadFcn', @fnCustomTifStackReader);
    % Extract information from the loaded datastores
    filesCount = size(imds.Files, 1);

    % Get the current transform
    curr_offset_first_to_second = outputRegistrationCorrections.translation_offset_first_to_second(i,:);
    [curr_tform] = fnBuildTranslationOnlyAffineTransform(curr_offset_first_to_second(1), curr_offset_first_to_second(2));
    
    % Build the augmented datastore
    %auimds = augmentedImageDatastore(outputSize, imds.registered_next)
    transformedImds = transform(imds, @(x) imwarp(x, curr_tform, 'OutputView', imref2d(size(x))));
    fprintf('Writing %d transformed files to %s!\n', filesCount, correctedRegisteredTifFolder);
    
    % Only works on 2020b or later:
    % writeall(transformedImds, correctedRegisteredTifFolder, 'OutputFormat','tif', 'Folderlayout', 'flatten')
    for datastoreFileIndex = 1:filesCount
        [curr_data, curr_info] = read(transformedImds);
        % Save to new filename
        [filepath, name, ext] = fileparts(curr_info.Filename);
        curr_out_filename = [name ext];
        curr_out_filepath = fullfile(correctedRegisteredTifFolder, curr_out_filename);
        fprintf('Writing file %d of %d (%s) out to disk... ', datastoreFileIndex, filesCount, curr_out_filepath);
        % Error using writetif (line 40) Writing TIFFs with 2000 components is not supported with IMWRITE.  Use Tiff instead.  Type "help Tiff" for more information.
%         imwrite(curr_data, curr_out_filepath); % Write the file out to disk
        saveastiff(curr_data, curr_out_filepath, aacTifOutputOptions);
        fprintf('done. \n');
    end
    
    fprintf('Done! Wrote transformed files to %s!\n', correctedRegisteredTifFolder);
end

% % Save the results if needed:
% save('output.mat','dateStrings','outputRegistrationCorrections','-mat')