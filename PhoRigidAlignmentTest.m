dataPath = 'E:\PhoHaleScratchFolder';

rawSubpath = 'E:\PhoHaleScratchFolder\20200120_PassiveStim\FoV1Lateral';
rawTifFolder = rawSubpath; % tifs are just directly in this folder. There is also a .h5 file

% rawH5FileName = '20200120_PassiveStimIC_FoV1Lateral_0001-0520.h5';


registeredSubpath = 'E:\PhoHaleScratchFolder\20200120_PassiveStim_Registered\FoV1Lateral\suite2p\plane0';
registeredTifFolder = fullfile(registeredSubpath, 'reg_tif');

imds.raw = imageDatastore(rawTifFolder,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');

imds.registered = imageDatastore(registeredTifFolder,'IncludeSubfolders',false,'FileExtensions','.tif','LabelSource','foldernames');


%% Done loading

%imshow(preview(imds.raw))