
%function to import wavesurfer data from 2-photon 
function [allEphysData,headerInfo] = pfaFunExtractEphysSingleFileWS0967(h5_file_path)

if ~exist('h5_file_path','var')
    [file_name,path_name] = uigetfile('*.h5') ; % if no h5 file path is passed in, prompt the user for the file
    h5_file_path = strcat(path_name,file_name) ;
end
data = ws.loadDataFile(h5_file_path,'double') ;
strNames=(fieldnames(data));

%this needs to be a cell array for compatibility with sweep browser.
headerInfo{1} = data.header;

% Get out sampling rate
% Get out sampling rate
fs = data.header.AcquisitionSampleRate ;  % Hz
dt = 1/fs ;  % sec

% Get out channel names
rawAnalogChannelNames = data.header.AIChannelNames ;
analogChannelNames = strtrim(rawAnalogChannelNames) ;
rawDigitalChannelNames = data.header.DIChannelNames ;
digitalChannelNames = strtrim(rawDigitalChannelNames) ;

%Create an absolute epoch time for the file in which the sweeps are
%located
absoluteEpochTime = (data.header.ClockAtRunStart(:,4)*60*60)+(data.header.ClockAtRunStart(:,5)*60)...
    +data.header.ClockAtRunStart(:,6) ;


% Find the first sweep in the structure
sweep_index_to_try = 0 ;
did_find_first_sweep = false ;
while ~did_find_first_sweep 
    sweep_index_to_try = sweep_index_to_try + 1 ;
    field_name = sprintf('sweep_%04d',sweep_index_to_try) ;
    did_find_first_sweep = isfield(data, field_name);
    this_is_first_sweep = sweep_index_to_try ;
end
first_sweep_index = sweep_index_to_try ;
sweep_index = first_sweep_index ;
does_sweep_exist = true ;
while does_sweep_exist
    % plot stuff
    sweep_field_name = sprintf('sweep_%04d',sweep_index) ;
    this_sweep = data.(sweep_field_name) ;
    scans = this_sweep.analogScans ;
    nChannels = size(scans,2) ;
    nTimePoints = size(scans,1) ;
    %create timeline
    t = dt * (0:(nTimePoints-1))' ;
    
    %this saves the traces and some important header information.
    savedTraces.(sweep_field_name) = data.(sweep_field_name) ;
    savedTraces.(sweep_field_name).ephysTimeBase = t ;
    savedTraces.(sweep_field_name).AreSweepsContinuous = data.header.AreSweepsContinuous ;
    savedTraces.(sweep_field_name).sampleRate = fs ;
    savedTraces.(sweep_field_name).sweepLengthIfContinuous = data.header.SweepDuration ;
    savedTraces.(sweep_field_name).sweepLengthIfFinite = data.header.SweepDurationIfFinite ;
    savedTraces.(sweep_field_name).analogChannelNames = analogChannelNames ;
    savedTraces.(sweep_field_name).digitalChannelNames = digitalChannelNames ;
%    savedTraces.(sweep_field_name).festoCommand = savedTraces.(sweep_field_name).analogScans(:,5); %hardcoding this for a quick hack 20180627
    
    %pull out the digital channel data. Pierre, you should really name
    %these things dynamically based on digitalChannelNames values, not
    %hardcoded. - PFA 20161017.
%     try
%         savedTraces.(sweep_field_name).festoCommand = bitget(savedTraces.(sweep_field_name).digitalScans,1) ;
%         savedTraces.(sweep_field_name).touchSensorOnlineTriggerThreshold = bitget(savedTraces.(sweep_field_name).digitalScans,2) ;
%         savedTraces.(sweep_field_name).stateChanges = bitget(savedTraces.(sweep_field_name).digitalScans,3) ;
%     catch
%         savedTraces.(sweep_field_name).festoCommand = 1:length(savedTraces.(sweep_field_name).analogScans(:,1)) ;
%         savedTraces.(sweep_field_name).festoCommand = savedTraces.(sweep_field_name).festoCommand' ;
%         savedTraces.(sweep_field_name).festoCommand = savedTraces.(sweep_field_name).festoCommand * 0 ;
%         
%         savedTraces.(sweep_field_name).touchSensorOnlineTriggerThreshold = 1:length(savedTraces.(sweep_field_name).analogScans(:,1)) ;
%         savedTraces.(sweep_field_name).touchSensorOnlineTriggerThreshold = savedTraces.(sweep_field_name).touchSensorOnlineTriggerThreshold' ;
%         savedTraces.(sweep_field_name).touchSensorOnlineTriggerThreshold = savedTraces.(sweep_field_name).touchSensorOnlineTriggerThreshold * 0 ;
%         
%         savedTraces.(sweep_field_name).stateChanges = [] ;
%         savedTraces.(sweep_field_name).stateChanges = 1:length(savedTraces.(sweep_field_name).analogScans(:,1)) ;
%         savedTraces.(sweep_field_name).stateChanges = savedTraces.(sweep_field_name).stateChanges' ;
%         savedTraces.(sweep_field_name).stateChanges = savedTraces.(sweep_field_name).stateChanges * 0 ;
%     end
    
    %this calls the function 'pfabitcode' which, as you guessed,
    %extracts the Solo Machine behavior trial number from the bitcode
    %channel in the current sweep. Currently bitcode channel is
    %hardcoded as channel 4. Because that is how it is on my rig.
    %If it doesn't find anything on ch4, behavior trial is set to 0.
    
%     try
%         currentBitcodeTrace = data.(sweep_field_name).analogScans(:,4) ;
%         
%         %edited 20170724. This version is for use with
%         %ExperPrtNewClient20170627. This is code written by JPL to pull
%         %out all sorts of good stuff from the bitcode data, and stores
%         %into array called self. This nomenclature is due to
%         %me pulling the code straight out of JPL's scripts.
%         [self] = pfabitcode4(currentBitcodeTrace,fs) ;
%         
%         savedTraces.(sweep_field_name).behaviorBoxTrialNumber = self.behavData.trialNum ;
%         savedTraces.(sweep_field_name).trialType = self.behavData.trialType ;
%         savedTraces.(sweep_field_name).poleIDFromBitcode = self.behavData.poleIds_assigned ;
%         %savedTraces.(sweep_field_name).poleIDFromBitcode = actualPoleID ;
%         
%         %this is here so that this script can be backwards compatible with
%         %previous data that wasn't acquired with Bpod. pfa 20170808.
%         if self.behavData.poleIds_assigned == 0
%             try
%                 [trialNum,rewardSide,trialType,stimOnOff,predictionMisMatch,poleID] = pfabitcode2(currentBitcodeTrace,fs);
%                 savedTraces.(sweep_field_name).poleIDFromBitcode = poleID;
%             catch
%                 display('pole ID is set to 0 even after running multiple different versions of pfabitcode, what gives?')
%             end
%         end
%         
%     catch
%         savedTraces.(sweep_field_name).behaviorBoxTrialNumber = 0 ;
%         savedTraces.(sweep_field_name).trialType = 0 ;
%         savedTraces.(sweep_field_name).poleIDFromBitcode = 0 ;
%         display('didnt find anything on channel 4. behaviorBoxTrialNumber set to zero for all trials.')
%     end
    
    %this code creates a low-pass and high-pass filtered version of the
    %Vm data. This is primarily useful for juxtacellular recordings
    %so you can extract the spikes and lfp.
    
    %originalVmTrace = data.(sweep_field_name).analogScans(:,1) ;
    
    %this is your spike data.
    %hpCutoff = 300 ; %cutoff frequency for high-pass filter in Hz.
    %hpOrder = 1 ; %order of high-pass filter. Modify as needed.
    
    %adding a lp cutoff at 8khz to try and clean up the background
    %noise a bit.
    %lpCutoffHi = 8000 ;
    %lpOrderHi = 1 ;
    
    %run the filters
    %savedTraces.(sweep_field_name).highPassVmTrace = lopass_butterworth(originalVmTrace,lpCutoffHi,fs,lpOrderHi) ;
    %savedTraces.(sweep_field_name).highPassVmTrace = hipass_butterworth(savedTraces.(sweep_field_name).highPassVmTrace,hpCutoff,fs,hpOrder) ;
    
    %lpCutoff = 50 ; %cutoff frequency for low-pass filter in Hz.
    %lpOrder = 4 ; %order of low-pass filter. Modify as needed.
    %hpCutoff_lp = 2 ; % 2 Hz high-pass for lfp traces
    %hpOrder_lp = 4 ; %ditto
    %savedTraces.(sweep_field_name).lowPassVmTrace = lopass_butterworth(originalVmTrace,lpCutoff,fs,lpOrder) ;
    %savedTraces.(sweep_field_name).lowPassVmTrace = hipass_butterworth(savedTraces.(sweep_field_name).lowPassVmTrace, hpCutoff_lp,fs,hpOrder_lp); %high-pass that shit at 1 Hz.
    
    %         %gamma band filter
    %         lpCutoff_gamma = 70 ;
    %         lpOrder_gamma = 4 ;
    %         hpCutoff_gamma = 30 ;
    %         hpOrder_gamma = 4 ;
    %         savedTraces.(sweep_field_name).gammaBandVmTrace = hipass_butterworth(originalVmTrace,hpCutoff_gamma,fs,hpOrder_gamma) ;
    %         savedTraces.(sweep_field_name).gammaBandVmTrace = lopass_butterworth(savedTraces.(sweep_field_name).gammaBandVmTrace,lpCutoff_gamma,fs,lpOrder_gamma) ;
    %
    %         %mua
    %         lpCutoff_mua = 10000 ;
    %         lpOrder_mua = 4 ;
    %         hpCutoff_mua = 600 ;
    %         hpOrder_mua = 4 ;
    %         savedTraces.(sweep_field_name).muaTrace = hipass_butterworth(originalVmTrace,hpCutoff_mua,fs,hpOrder_mua) ;
    %         savedTraces.(sweep_field_name).muaTrace = lopass_butterworth(savedTraces.(sweep_field_name).muaTrace,lpCutoff_mua,fs,lpOrder_mua) ;
    
    %touch sensor filter. Because there's this high frequency noise
    %somewhere that's causing glitches downstream of online BP
    %filtering. - PFA 20161013
%     try
%         lpCutoff_touchSensor = 2000 ;
%         lpOrder_touchSensor = 1 ;
%         savedTraces.(sweep_field_name).touchSensorFilteredAt2000Hz = lopass_butterworth(savedTraces.(sweep_field_name).analogScans(:,5),lpCutoff_touchSensor,fs,lpOrder_touchSensor) ;
%     catch
%         display('no touch sensor data, touchSensorFilteredAt2000Hz set to zeros')
%         savedTraces.(sweep_field_name).touchSensorFilteredAt2000Hz = 1:length(savedTraces.(sweep_field_name).analogScans(:,1)) ;
%         savedTraces.(sweep_field_name).touchSensorFilteredAt2000Hz = savedTraces.(sweep_field_name).touchSensorFilteredAt2000Hz' ;
%         savedTraces.(sweep_field_name).touchSensorFilteredAt2000Hz = savedTraces.(sweep_field_name).touchSensorFilteredAt2000Hz * 0 ;
%     end
    
    %this calculates a deltaTimeStamp and absoluteTimeStamp
    %variable for each trace. This is critical for hand syncing
    %wavesurfer and scan image files if the yoking function was not
    %enabled and the experimenter goofed with the sweep numbering.
    
    prevSweepTimestamp=0;
    
    if sweep_index - this_is_first_sweep == 0 ;
        g = 2 ;
        savedTraces.(sweep_field_name).deltaTimestamp = 0 ;
        savedTraces.(sweep_field_name).absoluteTimestamp= savedTraces.(sweep_field_name).timestamp + absoluteEpochTime ;
        savedTraces.(sweep_field_name).sweepNumber = sweep_index ;
    else
        previousSweepNumber = sweep_index - 1 ;
        previous_sweep_field_name = sprintf('sweep_%04d',previousSweepNumber) ;
        prevSweepTimestamp = savedTraces.(previous_sweep_field_name).timestamp ;
        currentSweepTimestamp = savedTraces.(sweep_field_name).timestamp ;
        savedTraces.(sweep_field_name).deltaTimestamp = currentSweepTimestamp - prevSweepTimestamp ;
        savedTraces.(sweep_field_name).absoluteTimestamp= savedTraces.(sweep_field_name).timestamp + absoluteEpochTime ;
        savedTraces.(sweep_field_name).sweepNumber = sweep_index ;
        if savedTraces.(sweep_field_name).deltaTimestamp < 0
            savedTraces.(sweep_field_name).deltaTimestamp = 0 ;
        end
    end
    
    % check for next sweep
    sweep_index = sweep_index + 1 ;
    field_name = sprintf('sweep_%04d',sweep_index) ;
    does_sweep_exist = isfield(data, field_name) ;
end
%all this code here is when you have to load multiple files that have different names. If the files don't have different names or you don't have multiple files, ignore this.
% currentFile = file_name_list{i} ;
% currentFile2 = strsplit(currentFile,'.h5') ;
% replaceDashWithUnderScore = strrep(currentFile2(1),'-','_') ;
% replaceDashWithUnderScore = char(replaceDashWithUnderScore) ;
% savedTracesB.(replaceDashWithUnderScore) = savedTraces;

allEphysData = [];
%rename this to savedTraces if you are dealing with single files
allEphysData = savedTraces ;
%allEphysData= pfaFunDetectFestoRise(allEphysData); %run the detect festo rise time function right now because you always end up running it anyway.
%allEphysData = pfaFunMakeRedFlag(allEphysData); %make the redFlag variable and set it to 0 for all sweeps.
end