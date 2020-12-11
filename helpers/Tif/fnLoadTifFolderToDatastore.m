function [imds, registered_imageInfo] = fnLoadTifFolderToDatastore(tifFolder)
    %  fnLoadTifFolderToDatastore: loads an entire tifFolder to a new
    %  ImageDatastore object and returns some info about it.
    % Set the datasources
    imds.registered.ReadFcn = @fnCustomTifStackReader;
    
    % Load the datasources
    imds.registered = imageDatastore(tifFolder,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');
    
    % Extract information from the loaded datastores
    registered_imageInfo.count = size(imds.registered.Files, 1);
    
    % Get prev/next index:
    registered_imageInfo.first_index = 1;
    registered_imageInfo.last_index = registered_imageInfo.count;
    
end