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

%% Build the Output directory for the 2nd-level aggregated max intensity images:
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

% Loop through:
for i = registered_imageInfo.first_index:registered_imageInfo.last_index
    curr_tifFileName = imds.registered.Files{i};
    currStartIndex = (framesPerTiff * i) + 1;
    currEndIndex = (currStartIndex + framesPerTiff)-1;
    [currMovieFrames, ~] = fnLoadTifToMovieFrames(curr_tifFileName); % [512x512x4096]
    
    tif_max_intensity = max(currMovieFrames,[],[3]);
%     tif_mean_intensity = mean(currMovieFrames, 3);
    
    %% Save out the file:
    curr_max_intensity_filename = sprintf('max_tif_%d.tif', i);
    curr_output_path.max_intensity = fullfile(outputs.stackFileCombinedTifFolderPath, curr_max_intensity_filename);
    fprintf('exporting max intensity image to %s...\n', curr_output_path.max_intensity);
    saveastiff(tif_max_intensity, curr_output_path.max_intensity);
    fprintf('\t done.');

end

%% Once Each Individual Tif is processed and saved, create a new imageDatastore from the output path to process them further
[output_imds, output_registered_imageInfo] = fnLoadTifFolderToDatastore(outputs.stackFileCombinedTifFolderPath);
% Loop through the previously saved files to further aggregate the outputs
output_numTifFiles = output_registered_imageInfo.count;
output_totalCombinedNumFrames = numTifFiles;
% Pre-allocate output images:
currMovieFrames = zeros([output_totalCombinedNumFrames 512 512], 'int16');

% Loop through outputs:
for i = output_registered_imageInfo.first_index:output_registered_imageInfo.last_index
    curr_tifFileName = output_imds.registered.Files{i};
    % Each tif now is a single 512x512 image instead of a stack
    [currMovieFrames(i,:,:), ~] = fnLoadTifToMovieFrames(curr_tifFileName); % [512x512]
end


tif_max_intensity = squeeze(max(currMovieFrames,[],1));
%     tif_mean_intensity = mean(currMovieFrames, 3);
%% Save out the file:
curr_max_intensity_filename = 'max_tif_all.tif';
curr_output_path.max_intensity = fullfile(outputs.stackAllCombinedTifFolderPath, curr_max_intensity_filename);
fprintf('exporting max intensity image to %s...\n', curr_output_path.max_intensity);
saveastiff(tif_max_intensity, curr_output_path.max_intensity);
fprintf('\t done.');





