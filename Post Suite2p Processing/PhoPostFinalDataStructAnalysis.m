addpath(genpath('..\helpers'));

%% Processing Options:
dateStrings = {'20200117','20200120','20200124'}; % Strings representing each date.
compTable = struct2table(compList);
indexArray = 1:height(compTable);
indexColumn = table(indexArray','VariableNames',{'index'});
compTable = [compTable indexColumn];

uniqueComps = unique(compTable.compName,'stable');
num_comps = length(uniqueComps);

tuning_max_threshold_criteria = 0.2;

compOutIndicies = zeros(num_comps, 3);
compFirstDayTuningMaxPeak = zeros(num_comps, 1); % Just the first day
compSatisfiesFirstDayTuning = zeros(num_comps, 1); % Just the first day

compFirstDayTuningMaxPeak = zeros(num_comps, 1); % Just the first day
compSeriesOutResults = {};

for i = 1:num_comps
   curr_comp = uniqueComps{i};
   curr_indicies = find(strcmp(compTable.compName, curr_comp));
   
   fprintf('uniqueComp[%d]: %s', i, curr_comp);
   disp(curr_indicies');
   compOutIndicies(i,:) = curr_indicies';
%     currOutCells = cell([1, length(curr_indicies)]);
    currOutCells = {};
	for j = 1:length(curr_indicies)
		curr_day_index = curr_indicies(j);
		[currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(compList, curr_day_index);
        [outputs] = fnProcessCompFromFDS(finalDataStruct, currentAnm, currentSesh, currentComp);
        uniqueAmps = outputs.uniqueAmps;
        uniqueFreqs = outputs.uniqueFreqs;
        peakSignals = outputs.peakSignal;
        maxPeakSignal = max(outputs.peakSignal);
        if j == 1
            compFirstDayTuningMaxPeak(i) = maxPeakSignal;
            if maxPeakSignal > tuning_max_threshold_criteria
               compSatisfiesFirstDayTuning(i) = 1;
               % Build the grid for this session and the two following
               % sessions:
               %outputs.uniqueStimuli
%                tempOut = [outputs.peakSignal outputs.tracesForEachStimulus];
               tempOut = [outputs.peakSignal];
              
               currOutCells{j} = tempOut;
               
            else
                compSatisfiesFirstDayTuning(i) = 0;
                break; % Skip remaining comps for the other days if the first day doesn't meat the criteria
            end
                    
        else
%             tempOut = [outputs.peakSignal outputs.tracesForEachStimulus];
            tempOut = [outputs.peakSignal];
            currOutCells{j} = tempOut;
        
            if j == length(curr_indicies)
               % If it's the last index
               compSeriesOutResults = [compSeriesOutResults currOutCells];
            end
        end
        
	end

end

compSatisfiesFirstDayTuning = (compFirstDayTuningMaxPeak > tuning_max_threshold_criteria);
sum(compSatisfiesFirstDayTuning)



% [C,ia] = unique(compTable.compName,'stable');
% B = compTable(ia,:);



% % plotTracesForAllStimuli_FDS(finalDataStruct, compList(4))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(162))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(320))
% plotAMConditions_FDS(finalDataStruct, compList(2:8))

function [currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(compList, index)
	currentAnm = compList(index).anmID;
    currentSesh = compList(index).date;
    currentComp = compList(index).compName;
	%sometimes the current sesh is listed as a num instead of string, so
    %change that if so.
    if ~ischar(currentSesh)
        currentSesh = num2str(currentSesh);
    end
    
    currentSesh=strcat('session_',currentSesh);%make this the same format as in the fds struct
end

function [outputs] = fnProcessCompFromFDS(fStruct, currentAnm, currentSesh, currentComp)
	startSound=31;
	endSound=90;
	sampPeak = 2;
	frameRate=30;
	smoothValue = 5;
        
    imgData = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF; %assumes you have this field
    [numTrials, numFrames] = size(imgData);
    
    if smoothValue>0
        for i = 1:numTrials
            imgData(i,:)=smooth(imgData(i,:),smoothValue);
        end
    end
    
    [~, numFrames] = size(imgData);
    
	outputs.stimList(:,1) = fStruct.(currentAnm).(currentSesh).behData.amFrequency;
    outputs.stimList(:,2) = fStruct.(currentAnm).(currentSesh).behData.amAmplitude;
    
    [outputs.uniqueStimuli, ~, ib] = unique(outputs.stimList, 'rows');
    %correct the 0 depth condition value glitch here
    zeroVal = find(outputs.uniqueStimuli(:,2)==0);
    outputs.uniqueStimuli(zeroVal, 1) = 0;
    
    outputs.tracesForEachStimulus = accumarray(ib, find(ib), [], @(rows){rows});
    
    [outputs.numStimuli,~] = size(outputs.uniqueStimuli);
    outputs.uniqueAmps = unique(outputs.uniqueStimuli(:,2));
    outputs.uniqueFreqs = unique(outputs.uniqueStimuli(:,1));
    
    %% Up to this point, the setup is common for both plotAMConditions_FDS and plotTracesForAllStimuli_FDS

	%pre-allocate
    outputs.imgDataToPlot = zeros(outputs.numStimuli, numFrames);
    outputs.tbImg = linspace(0,numFrames/frameRate,numFrames); % make a timebase to plot as xAxis for traces
    outputs.peakSignal = zeros(outputs.numStimuli,1);
    
    for b = 1:outputs.numStimuli
        tracesToPlot = outputs.tracesForEachStimulus{b};
        
        outputs.imgDataToPlot(b,:) = mean(imgData(tracesToPlot,:));
        [~,maxInd] = max(outputs.imgDataToPlot(b,startSound:endSound));
        maxInd = maxInd+startSound-1;
        outputs.peakSignal(b) = mean(outputs.imgDataToPlot(b,maxInd-sampPeak:maxInd+sampPeak));
    end

% 	for c=1:numel(outputs.uniqueAmps)
%         
%         %plot peak amplitude as a function fo AM freq, with different AM
%         %depths as different colors
%         currentAmpIdx = find(outputs.uniqueStimuli(:,2)==outputs.uniqueAmps(c));
%         thesePeaks = outputs.peakSignal(currentAmpIdx);
%         theseFreqs = outputs.uniqueStimuli(currentAmpIdx,1);
%         
%     end



end