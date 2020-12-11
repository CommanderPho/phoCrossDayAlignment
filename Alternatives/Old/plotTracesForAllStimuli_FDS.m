function plotTracesForAllStimuli_FDS(fStruct,compList)
%work in progress plotting all raw traces and average for all stimuli
%this works sort of except I'd like the plot of AM depth to go from left to
%right, low to high but right now it reads from left to right, high to low
%close all

frameRate=30;
smoothValue=5;

for a = 1:numel(compList)
    currentAnm = compList(a).anmID;
    currentSesh = compList(a).date;
    currentComp = compList(a).compName;
    
    %sometimes the current sesh is listed as a num instead of string, so
    %change that if so.
    if ~ischar(currentSesh)
        currentSesh = num2str(currentSesh);
    end
    
    currentSesh=strcat('session_',currentSesh);%make this the same format as in the fds struct
    
    
    imgData = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF; %assumes you have this field
    [numTrials,numFrames]=size(imgData);
    
    if smoothValue>0
        for i = 1:numTrials
            imgData(i,:)=smooth(imgData(i,:),smoothValue);
        end
    end
    
    [~,numFrames]=size(imgData);
    
    stimList(:,1) = fStruct.(currentAnm).(currentSesh).behData.amFrequency;
    stimList(:,2) = fStruct.(currentAnm).(currentSesh).behData.amAmplitude;
    
    %correct the 0 depth condition value glitch here
    zeroVal=find(stimList(:,2)==0);
    stimList(zeroVal,1)=0;
    
    %get the list of unique stimuli
    [uniqueStimuli, ~, ib] = unique(stimList, 'rows');
    
    %reverse these for plotting
    %uniqueStimuli=flip(uniqueStimuli);
    %ib=flip(ib);
    
    %make the zero stimulus the last entry
    %zeroEntry = find(uniqueStimuli(:,1)==0 & uniqueStimuli(:,2)==0);
    %uniqueStimuli(end+1,:)=uniqueStimuli(zeroEntry); %append it
    %uniqueStimuli(zeroEntry,:)=[]; %and delete the entry
    
    tracesForEachStimulus = accumarray(ib, find(ib), [], @(rows){rows});
    
    [numStimuli,~]=size(uniqueStimuli);
    uniqueAmps = unique(uniqueStimuli(:,2));
    uniqueFreqs = unique(uniqueStimuli(:,1));
    
    %pre-allocate
    traceTimebase_t = linspace(0,numFrames/frameRate,numFrames); % make a timebase to plot as xAxis for traces    
    

    
    %generate the dimensions of the subplots
    numRows = numel(nonzeros(uniqueFreqs))+1; %+1 because you have the zero mod condition too
    numCol = numel(nonzeros(uniqueAmps));
    
    %plot this here
    figure;
    
    for b = 1:numStimuli
        %stimulusList = flip(uniqueStimuli);
        tracesToPlot = tracesForEachStimulus{b};
        
        %get the raw data that you're gonna plot
        imgDataToPlot = imgData(tracesToPlot,:);
        
        %make an average
        meanData=mean(imgDataToPlot,1);
        
        subplot(numRows,numCol,numStimuli-b+1);
        plot(traceTimebase_t,imgDataToPlot,'color','black')
        hold on
        plot(traceTimebase_t,meanData,'color','red','linewidth',2);
        title(strcat(currentComp, {' '}, num2str(uniqueStimuli(b,1)),{' '},'Hz',{' '},'at',{' '},num2str(uniqueStimuli(b,2)*100),{' '},'% Depth'))
        
        
    end
    
end


