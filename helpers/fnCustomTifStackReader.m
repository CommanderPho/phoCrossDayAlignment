function currLoadedImgStack = fnCustomTifStackReader(filename)
    % currLoadedImgStack: 512x512xnumberOfFrames (numberOfFrames frames per .tif) output
    
%     currLoadedData = bfOpen3DVolume(filename);
%     currLoadedImgStack = currLoadedData{1,1}{1,1};     
    currLoadedImgStack = loadtiff(filename);
end

