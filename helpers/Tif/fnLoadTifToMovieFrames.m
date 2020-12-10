function [currLoadedImgStack, imgStackSize] = fnLoadTifToMovieFrames(tifFile)
    fprintf('\t Loading tif %s...\n', tifFile);
%     currLoadedData = bfOpen3DVolume(tifFile);
%     currLoadedImgStack = currLoadedData{1,1}{1,1}; % Produces the desired 512x512xnumberOfFrames (numberOfFrames frames per .tif) output
    currLoadedImgStack = loadtiff(tifFile);
    imgStackSize.numberOfFrames = size(currLoadedImgStack,3);
    fprintf('\t \t done. Contains %d frames.\n', imgStackSize.numberOfFrames);
end