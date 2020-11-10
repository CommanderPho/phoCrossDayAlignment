function currLoadedImgStack = fnCustomTifStackReader(filename)
    currLoadedData = bfOpen3DVolume(filename);
    currLoadedImgStack = currLoadedData{1,1}{1,1}; % Produces the desired 512x512x2000 (2000 frames per .tif) output
%     imgStackSize.numberOfFrames = size(currLoadedImgStack,3);
    
%     t = Tiff(filename,'r');
%     offsets = getTag(t,'SubIFD');
%     dirNum = 1; 
%     setDirectory(t,dirNum);
%     setSubDirectory(t,offsets(1));
%     subimage_one = read(t);
%     close(t);
end

