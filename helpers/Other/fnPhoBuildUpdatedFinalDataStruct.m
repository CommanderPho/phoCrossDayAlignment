function [finalDataStruct] = fnPhoBuildUpdatedFinalDataStruct(anmID, dateString, ephysData, finalDataStruct)
%FNPHOBUILDUPDATEDFINALDATASTRUCT Factored out of pfaCombineAllAMSessionsForSummary(...) to enable programmatic updating of finalDataStruct with a new session
%   Detailed explanation goes here
    %because you can't have field names starting with numbers

    if ~exist('finalDataStruct')
        finalDataStruct = struct; % Create an empty struct if needed.
    end

    dateString = strcat('session_', dateString);
        
    if ~isfield(finalDataStruct, anmID)
        finalDataStruct.(anmID)=struct;
        finalDataStruct.(anmID).(dateString)=struct;
    else
        finalDataStruct.(anmID).(dateString)=struct;
    end

    %pull out all the comp names and sweep names
    compNames=fieldnames(ephysData.componentData);
    sweepNames=fieldnames(ephysData);
    numTrials=numel(sweepNames)-1;%number of trials in the session
    %[numSamples,~]=size(ephysData.(sweepNames{1}).analogScans);
    %numSamples=numSamples/dsRate; %divide by downsample rate

    %pre-allocate behavior data arrays
    finalDataStruct.(anmID).(dateString).behData.amAmplitude = zeros(numTrials,1);
    finalDataStruct.(anmID).(dateString).behData.amFrequency = zeros(numTrials,1);
    %finalDataStruct.(anmID).(dateString).behData.soundSample = zeros(numTrials,numSamples);

    %go through all the comps
    for b = 1:numel(compNames)
        currentComp=compNames{b}; %get the current component
        
        %pre-allocate imaging data arrays
        [~,numFrames]=size(ephysData.(sweepNames{1}).imagingData.(currentComp));
        finalDataStruct.(anmID).(dateString).imgData.(currentComp).imagingData = zeros(numTrials,numFrames);        
        finalDataStruct.(anmID).(dateString).imgData.(currentComp).imagingDataNeuropil = zeros(numTrials,numFrames);
        %save the component info
        finalDataStruct.(anmID).(dateString).imgData.(currentComp).segmentLabelMatrix = ephysData.componentData.(currentComp).segmentLabelMatrix;
        finalDataStruct.(anmID).(dateString).imgData.(currentComp).neuropilMaskLabelMatrix = ephysData.componentData.(currentComp).neuropilMaskLabelMatrix;
        
        %now save the raw traces and event time stamps for all comps in
        %all sessions from all animals
        for c = 1:numel(sweepNames)-1
            currentSweep = sweepNames{c};
            finalDataStruct.(anmID).(dateString).imgData.(currentComp).imagingData(c,:) = ephysData.(currentSweep).imagingData.(currentComp)(1,:);
            finalDataStruct.(anmID).(dateString).imgData.(currentComp).imagingDataNeuropil(c,:) = ephysData.(currentSweep).imagingDataNeuropil.(currentComp)(1,:);
            finalDataStruct.(anmID).(dateString).behData.amAmplitude(c) = ephysData.(currentSweep).amAmpAndFreq(1);
            finalDataStruct.(anmID).(dateString).behData.amFrequency(c) = ephysData.(currentSweep).amAmpAndFreq(2);
            %finalDataStruct.(anmID).(dateString).behData.soundSample(c,:) = downsample(ephysData.(currentSweep).analogScans(:,1)',dsRate);
            
        end
        
    end

end

