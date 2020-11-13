% Pho Compute ROI Testing
% Pho Hale, November 10, 2020
% Tries to compute cell ROIs in MATLAB using a custom algorithm
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
% for i = 1:numberOfOffsets
    i = 1;
    % Load first and second days:
    nextIndex = nextIndicies(i);

    % Get the tif paths for each
    registeredRootFolder = registeredOutpaths{nextIndex}.root;
    registeredTifFolder_next = registeredOutpaths{nextIndex}.tifFolder;

    % Create a corrected tif path next to the current one
    correctedRegisteredTifFolder = fullfile(registeredRootFolder, 'reg_tif_aligned'); 
    
    if ~exist(correctedRegisteredTifFolder,'dir')
        error(correctedRegisteredTifFolder)
    end
    
    % Load the datasources
    imds = imageDatastore(correctedRegisteredTifFolder,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames','ReadFcn', @fnCustomTifStackReader);
    % Extract information from the loaded datastores
    filesCount = size(imds.Files, 1);

    fprintf('Computing ROIs for %s!\n', correctedRegisteredTifFolder);
    
    % Only works on 2020b or later:
    % writeall(transformedImds, correctedRegisteredTifFolder, 'OutputFormat','tif', 'Folderlayout', 'flatten')
%     for datastoreFileIndex = 1:filesCount
        datastoreFileIndex = 1;
        [curr_data, curr_info] = read(imds); %Hopefully I don't need an index here
        % Do computation on the curr_date
        framesCount = size(curr_data, 3);
        
        % Compute diff
        curr_data_diff = diff(curr_data,1,3);
        
        curr_data_roi_landscape = curr_data_diff.^2;
        curr_data_roi_landscape_collapsed = sum(curr_data_roi_landscape,3);
        fnPhoMatrixPlot(curr_data_roi_landscape_collapsed);
        title('ROI Testing')
        
%         surf(curr_data_roi_landscape_collapsed, curr_data_roi_landscape_collapsed);
        
        
%         figure(1)
%         clf
%         dim.x = size(curr_data_roi_landscape_collapsed, 1);
%         dim.y = size(curr_data_roi_landscape_collapsed, 2);
% 
%         % [xx, yy] = meshgrid(1:dim.x, 1:dim.y);
%         % h = plot3(xx, yy, data);
% 
%         xx = [1:dim.x];
%         yy = [1:dim.y];
% %         h = imagesc(xx, yy, curr_data_roi_landscape_collapsed);
%         h = surf(xx, yy, curr_data_roi_landscape_collapsed,'FaceLighting','gouraud','FaceAlpha',0.8);
%         set(h,'LineStyle','none');
%         
%         colormap jet                        % <— Specify ‘colormap’ To Override Default 
%         colorbar
        
        fprintf('done. \n');
%     end
    
%     fprintf('Done! Wrote transformed files to %s!\n', correctedRegisteredTifFolder);
% end

% % Save the results if needed:
% save('output.mat','dateStrings','outputRegistrationCorrections','-mat')