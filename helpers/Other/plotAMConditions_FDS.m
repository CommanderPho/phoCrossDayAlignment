function plotAMConditions_FDS(fStruct,compList)
%pfa 20200529 need to comment this function. basically plotting data for a
%comp as a function of rate and depth
%also need to add title for figs

%close all

startSound=31;
endSound=90;
sampPeak = 2;
frameRate=30;
smoothValue = 5;

for a = 1:numel(compList)
    currentAnm=compList(a).anmID;
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
    
    stimList(:,1) = fStruct.(currentAnm).(currentSesh).behData.amFrequency;
    stimList(:,2) = fStruct.(currentAnm).(currentSesh).behData.amAmplitude;
    
    [uniqueStimuli, ~, ib] = unique(stimList, 'rows');
    %correct the 0 depth condition value glitch here
    zeroVal=find(uniqueStimuli(:,2)==0);
    uniqueStimuli(zeroVal,1)=0;
    
    tracesForEachStimulus = accumarray(ib, find(ib), [], @(rows){rows});
    
    [numStimuli,~]=size(uniqueStimuli);
    uniqueAmps = unique(uniqueStimuli(:,2));
    uniqueFreqs = unique(uniqueStimuli(:,1));
    
    %pre-allocate
    imgDataToPlot = zeros(numStimuli,numFrames);
    tbImg = linspace(0,numFrames/frameRate,numFrames); % make a timebase to plot as xAxis for traces
    peakSignal=zeros(numStimuli,1);
    
    for b = 1:numStimuli
        tracesToPlot = tracesForEachStimulus{b};
        
        imgDataToPlot(b,:)=mean(imgData(tracesToPlot,:));
        [~,maxInd]=max(imgDataToPlot(b,startSound:endSound));
        maxInd=maxInd+startSound-1;
        peakSignal(b)=mean(imgDataToPlot(b,maxInd-sampPeak:maxInd+sampPeak)); % looks like this averages over all trials?
    end
    
    figure;
    
    %specify colormaps for your figure. This is important!!
    amplitudeColorMap = winter(numel(uniqueAmps));
    frequencyColorMap = spring(numel(uniqueFreqs));
    
    %% Generate the left two subplots
    % uniqueAmps: the [0%, 20%, 40%, 60%, 80%, 100%] data series
    for c=1:numel(uniqueAmps)
        
        %plot peak amplitude as a function fo AM freq, with different AM
        %depths as different colors
        currentAmpIdx = find(uniqueStimuli(:,2)==uniqueAmps(c)); % this varies in size. for the 0 element it's 1x1, but for index 2 for example it's 5x1
        thesePeaks = peakSignal(currentAmpIdx);
        theseFreqs = uniqueStimuli(currentAmpIdx,1);
        
        %plot it!
        subplot(2,2,1)
        ylabel('Peak DF/F')
        xlabel('AM Rate (Hz)')
        if uniqueAmps(c)==0
            plot(theseFreqs,thesePeaks,'x','Color','black','MarkerSize',20)
        else
            plot(theseFreqs,thesePeaks,'Color',amplitudeColorMap(c,:),'linewidth',2)
        end
        hold on
        
        %and plot the traces
        subplot(2,2,3)
        hold on
        if uniqueAmps(c)==0
            plot(tbImg,imgDataToPlot(currentAmpIdx,:),'Color','black','Linewidth',2)
            text(max(tbImg),c-1,strcat(num2str(uniqueAmps(c)*100),'%'))
        else
            for cc = 1:numel(currentAmpIdx)
                plot(tbImg,imgDataToPlot(currentAmpIdx(cc),:)+((c-1)*1),'Color',frequencyColorMap(cc+1,:),'Linewidth',2)
            end
            text(max(tbImg),(c-1)*1,strcat(num2str(uniqueAmps(c)*100),'%'))
        end
        hold on
        ylabel('ModulationDepth ->')
        xlabel('Time (s)')
        
    end
    
    %create legend for the figure
    subplot(2,2,1)
    lgdStr=cell(numel(uniqueAmps,1));
    for cc = 1:numel(uniqueAmps)
        
        lgdTitle=strcat(num2str(uniqueAmps(cc)*100),{' '},'%');
        lgdStr{cc}=lgdTitle{1};
        
    end
    legend(lgdStr,'FontSize',8);
    
    %% Generate the right two subplots
    % uniqueFreqs: the [0, 10, 20, 50, 100, 200 Hz] data series
    for d=1:numel(uniqueFreqs)
        title(currentComp)
        %plot peak amplitude as a function fo AM freq, with different AM
        %depths as different colors
        currentFreqIdx = find(uniqueStimuli(:,1)==uniqueFreqs(d));
        thesePeaks = peakSignal(currentFreqIdx);
        theseAmps = uniqueStimuli(currentFreqIdx,2);
        
        
        subplot(2,2,2)
        ylabel('Peak DF/F')
        xlabel('AM Depth (%)')
        if uniqueFreqs(d)==0
            plot(theseAmps,thesePeaks,'x','Color','black','MarkerSize',20)
        else
            plot(theseAmps,thesePeaks,'Color',frequencyColorMap(d,:),'linewidth',2)
        end
        hold on
        
        %and plot the traces
        subplot(2,2,4)
        hold on
        if uniqueFreqs(d)==0
            plot(tbImg,imgDataToPlot(currentFreqIdx,:),'Color','black','Linewidth',2)
            text(max(tbImg),(d-1)*2,strcat(num2str(uniqueFreqs(d)),{' '},'Hz'))
        else
            for dd =1:numel(currentFreqIdx)
                plot(tbImg,imgDataToPlot(currentFreqIdx(dd),:)+((d-1)*1),'Color',amplitudeColorMap(dd+1,:),'Linewidth',2)
            end
            text(max(tbImg),(d-1)*1,strcat(num2str(uniqueFreqs(d)),{' '},'Hz'))
        end
        ylabel('ModulationRate ->')
        xlabel('Time (s)')
    end
    
    %create legend for the figure
    subplot(2,2,2)
    lgdStr=cell(numel(uniqueFreqs,1));
    for cc = 1:numel(uniqueFreqs)
        
        lgdTitle=strcat(num2str(uniqueFreqs(cc)),{' '},'Hz');
        lgdStr{cc}=lgdTitle{1};
        
    end
    legend(lgdStr,'FontSize',8);
    
end


