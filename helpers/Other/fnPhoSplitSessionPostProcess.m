function [currSessionData] = fnPhoSplitSessionPostProcess(sessionPathsInfo, curr_output_fAll, trialLength)
%FNPHOSPLITSESSIONPOSTPROCESS Does the post-processing outlined in
%"orderOfOperations.m"
%   Detailed explanation goes here

    if ~exist('trialLength','var')
        trialLength = 150;
    end
    
    disp('Running pfaFunExtractEphysSingleFileWS0967 on session...')
    currSessionData.ephysData = pfaFunExtractEphysSingleFileWS0967(sessionPathsInfo.curr_folder_h5_path); %point matlab to your .h5 wavesurfer file
    
    disp('Running pfaAppendSuite2p_v2 on session...')
    %trialLengthInFrames is you guessed it, the trial length in frames. Look at
    %the raw (unregistered tifs) if you didn't write this down in your notes
    currSessionData.ephysData = pfaAppendSuite2p_v2(currSessionData.ephysData, curr_output_fAll.F, curr_output_fAll.Fneu, curr_output_fAll.iscell, curr_output_fAll.neuropil_masks, curr_output_fAll.stat, trialLength);

    disp('Running pfaAppendRZ6SoundInfo on session...')
    [currSessionData.ephysData, ~] = pfaAppendRZ6SoundInfo('AM',currSessionData.ephysData, sessionPathsInfo.audioParametersFolder);
    
end

