function [rawOutpaths, registeredOutpaths] = fnBuildPaths(dateStrings)
%FNBUILDPATHS Summary of this function goes here
%   Detailed explanation goes here

    animalPath = 'Z:\ICPassiveStim\anm265\'; % Common path to the animal folder

    rawSuffix = '_PassiveStim\FoV1Lateral';
    registeredSuffix = '_PassiveStim_Registered\FoV1Lateral\suite2p\plane0';

    numberOfDateFolders = length(dateStrings);

    rawOutpaths = cell(numberOfDateFolders,1);
    registeredOutpaths = cell(numberOfDateFolders,1);

    for i = 1:numberOfDateFolders
        currDateString = dateStrings{i};
        rawPrefix = [currDateString rawSuffix];
        registeredPrefix = [currDateString registeredSuffix];
        currOutpath_raw = fullfile(animalPath, rawPrefix);
        currOutpath_registered = fullfile(animalPath, registeredPrefix);
        % Append to the output arrays
        rawOutpaths{i}.root = currOutpath_raw;
        rawOutpaths{i}.tifFolder = currOutpath_raw; % tifs are just directly in this folder. There is also a .h5 file
        registeredOutpaths{i}.root = currOutpath_registered;
        registeredOutpaths{i}.tifFolder = fullfile(currOutpath_registered, 'reg_tif');
    end

end

