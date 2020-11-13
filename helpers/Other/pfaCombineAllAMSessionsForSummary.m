function [finalDataStruct]=pfaCombineAllAMSessionsForSummary(varargin)
%combines all datasets in a folder into finalDataStruct. This is useful if
%you want to do transformations and analysis on datasets across multiple
%sessions. Currently saving only the event detection and DF/F data, but in
%principle you can save anything you want. If you don't pass any arguments
%it returns finalDataStruct. If you pass it an existing finalDataStruct the
%script will append the new data to the existing structure.

%pfa 20200425

%to do list
%double check to make sure there's no comps with multiple segments
%double check to make sure that events rasters aren't synchronous across
%comps (you checked this with fluo data but do again with event rasters)

%downsampling lick trace because it's way too long
dsRate = 50; %by what factor do you want to downsample?

if isempty(varargin)
    finalDataStruct =struct;
else
    finalDataStruct=varargin{1};
end

%initialized arrays
allSoundExcited=[];
allSoundInhibited=[];
allAnsExcited=[];
allAnsInhibited=[];

%point to the path to the master folder
pathName = uigetdir('please point me to the directory containing your curated sessions');
cd(pathName);
fileDir = dir(fullfile(pwd, '**\*.*')); %list everything and everything
fileDir = fileDir(~[fileDir.isdir]); %remove folders
%now you got a list of all files in all subdirectories

for a =1:numel(fileDir)
    fullFilePath = strcat(fileDir(a).folder,'\',fileDir(a).name);
    
    %get date and animal name
    fileNameParts = strsplit(fileDir(a).name,'_');
    dateString = fileNameParts{1};
    anmID = fileNameParts{2};
    
    if contains(anmID,'.mat')
        splitAnmID = strsplit(anmID,'.');
        anmID = splitAnmID{1};
    end
    
    disp(strcat('now loading','_',anmID,'_session_',dateString))
    
    load(fullFilePath,'ephysData'); %load the files
    disp(strcat('loaded_',anmID,'session_',dateString))
    
    %because you can't have field names starting with numbers
    dateString = strcat('session_',dateString);
    
    if ~isfield(finalDataStruct,anmID)
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
        %disp(strcat('starting_',currentComp))
        
        %pre-allocate imaging data arrays
        [~,numFrames]=size(ephysData.(sweepNames{1}).imagingData.(currentComp));
        finalDataStruct.(anmID).(dateString).imgData.(currentComp).imagingData = zeros(numTrials,numFrames);        
        finalDataStruct.(anmID).(dateString).imgData.(currentComp).imagingDataNeuropil = zeros(numTrials,numFrames);
        %save the component info
        finalDataStruct.(anmID).(dateString).imgData.(currentComp).segmentLabelMatrix = ephysData.componentData.(currentComp).segmentLabelMatrix;
        
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
    %finalDataStruct.(anmID).(dateString).behData.analogSampleRate = ephysData.(sweepNames{1}).sampleRate/dsRate;%what's the actual sample rate?
end
end



