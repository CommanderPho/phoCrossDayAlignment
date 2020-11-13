

%order of operations
%note that the data structure is called ephysData because of historical
%reasons
ephysData=pfaFunExtractEphysSingleFileWS0967; %point matlab to your .h5 wavesurfer file

%now load the correct Fall.mat file, and then append the imaging data to
%the h5 file

%trialLengthInFrames is you guessed it, the trial length in frames. Look at
%the raw (unregistered tifs) if you didn't write this down in your notes
ephysData=pfaAppendSuite2p_v2(ephysData,fAll.F,fAll.Fneu,fAll.iscell,fAll.stat,150);
% Fneu - neuropil fluoresence
% trialLengthInFrames - 150
% Chops of F data into bins of 150, appends to proper trial in struct.

%now you want to append the stimulus protocol info
%currently only works for AM stimulus experiments
[ephysData,pathName] = pfaAppendRZ6SoundInfo('AM',ephysData);

%once you have saved your individual sessions, append them all into a FDS
%format structure using this script

%if this is your first time running this, don't pass a varargin. if you
%want to append to an existing structure however, pass the structure name
%as varargin
[finalDataStruct]=pfaCombineAllAMSessionsForSummary(varargin);


%some useful functions
[sessionList,compList]=makeSessionList_FDS(fdStruct); %make a list of sessions and comps in FDS
finalDataStruct=baselineDFF_fds(finalDataStruct,sessionList,[1,30]);

%plotting
plotTracesForAllStimuli_FDS(finalDataStruct, compList)
plotAMConditions_FDS(finalDataStruct, compList)