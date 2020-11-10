% Second stage in the pipeline after offsets have been computed.
addpath(genpath('helpers'));

registeredRootFolder_ref = registeredOutpaths{1}.root;

% Look for MATLAB fALL file
registeredFallFile_ref = fullfile(registeredRootFolder_ref, 'Fall.mat');
if ~exist(registeredFallFile_ref, 'file')
    error('Failed to find Fall.mat file in the reference folder!')
end
fAll_ref = load(registeredFallFile_ref);


% registeredOutpaths{i}.root
% for i = 1:numberOfOffsets
%     % Load first and second days:
%     prevIndex = refIndicies(i);
%     nextIndex = nextIndicies(i);
% 
%     % Get the tif paths for each
%     registeredTifFolder_prev = registeredOutpaths{prevIndex}.tifFolder;
%     registeredTifFolder_next = registeredOutpaths{nextIndex}.tifFolder;
% 
% end