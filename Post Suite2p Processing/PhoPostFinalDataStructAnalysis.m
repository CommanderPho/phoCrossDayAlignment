addpath(genpath('..\helpers'));

%% Processing Options:
dateStrings = {'20200117','20200120','20200124'}; % Strings representing each date.
compTable = struct2table(compList);
indexArray = 1:height(compTable);
indexColumn = table(indexArray','VariableNames',{'index'});
compTable = [compTable indexColumn];

uniqueComps = unique(compTable.compName,'stable');
num_comps = length(uniqueComps);

compOutIndicies = zeros(num_comps, 3);
for i = 1:num_comps
   curr_comp = uniqueComps{i}; 
%    curr_indicies = find(compTable{:,:} == curr_comp);
   curr_indicies = find(strcmp(compTable.compName, curr_comp));
   
   fprintf('uniqueComp[%d]: %s', i, curr_comp);
   disp(curr_indicies');
   compOutIndicies(i,:) = curr_indicies';

	for j = 1:length(curr_indicies)
		curr_day_index = curr_indicies(j);
		[currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(compList, curr_day_index)
	end

end


% [C,ia] = unique(compTable.compName,'stable');
% B = compTable(ia,:);



% % plotTracesForAllStimuli_FDS(finalDataStruct, compList(4))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(162))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(320))
% plotAMConditions_FDS(finalDataStruct, compList(2:8))

function [currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(compList, index)
	currentAnm = compList(a).anmID;
    currentSesh = compList(a).date;
    currentComp = compList(a).compName;
	%sometimes the current sesh is listed as a num instead of string, so
    %change that if so.
    if ~ischar(currentSesh)
        currentSesh = num2str(currentSesh);
    end
    
    currentSesh=strcat('session_',currentSesh);%make this the same format as in the fds struct
end

function [uniqueAmps, uniqueFreqs] = fnProcessCompFromFDS(fStruct, currentAnm, currentSesh, currentComp)
	startSound=31;
	endSound=90;
	sampPeak = 2;
	frameRate=30;
	smoothValue = 5;
        
    imgData = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF; %assumes you have this field
    [numTrials, numFrames] = size(imgData);

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
    imgDataToPlot = zeros(numStimuli, numFrames);
    tbImg = linspace(0,numFrames/frameRate,numFrames); % make a timebase to plot as xAxis for traces
    peakSignal = zeros(numStimuli,1);
    
    for b = 1:numStimuli
        tracesToPlot = tracesForEachStimulus{b};
        
        imgDataToPlot(b,:) = mean(imgData(tracesToPlot,:));
        [~,maxInd] = max(imgDataToPlot(b,startSound:endSound));
        maxInd = maxInd+startSound-1;
        peakSignal(b) = mean(imgDataToPlot(b,maxInd-sampPeak:maxInd+sampPeak));
    end

	for c=1:numel(uniqueAmps)
        
        %plot peak amplitude as a function fo AM freq, with different AM
        %depths as different colors
        currentAmpIdx = find(uniqueStimuli(:,2)==uniqueAmps(c));
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




end