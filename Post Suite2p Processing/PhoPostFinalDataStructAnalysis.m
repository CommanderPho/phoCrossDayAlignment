% Initially the finalDataStruct
% 

addpath(genpath('..\helpers'));


%% Options:
curr_animal = 'anm265';
%% Filter down to entries for the current animal:
activeAnimalDataStruct = finalDataStruct.(curr_animal); % get the final data struct for the current animal
activeAnimalSessionList = sessionList(strcmpi({sessionList.anmID}, curr_animal));
activeAnimalCompList = compList(strcmpi({compList.anmID}, curr_animal));
%% Processing Options:
dateStrings = {activeAnimalSessionList.date};  % Strings representing each date.


compTable = struct2table(activeAnimalCompList);
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

% Build 2D Mesh for each component
finalOutGrid = zeros(num_comps,6,6);

% Build a 2D Mesh from the uniqueAmps and uniqueFreqs
[xx, yy] = meshgrid(uniqueAmps, uniqueFreqs);
zz = xx.^2 - yy.^2;
figure
surf(xx, yy, zz);
% Set x-labels:
xlabel('uniqueAmps (% Depth)')
uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),'% Depth');
xticklabels(uniqueAmpLabels);
% Set y-labels:
ylabel('uniqueFreqs (Hz)')
uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');
yticklabels(uniqueFreqLabels);

for i = 1:num_comps
   curr_comp = uniqueComps{i};
   curr_indicies = find(strcmp(compTable.compName, curr_comp)); % Should be a list of 3 relevant indicies, one corresponding to each day.
   
   finalOutGrid(i,:,:) 
   
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
        peakSignals = outputs.AMConditions.peakSignal;
        maxPeakSignal = max(peakSignals);
        if j == 1
            compFirstDayTuningMaxPeak(i) = maxPeakSignal;
            if maxPeakSignal > tuning_max_threshold_criteria
               compSatisfiesFirstDayTuning(i) = 1;
               % Build the grid for this session and the two following
               % sessions:
               %outputs.uniqueStimuli
%                tempOut = [outputs.peakSignal outputs.tracesForEachStimulus];
               tempOut = [outputs.AMConditions.peakSignal];
               tempOut = [outputs.TracesForAllStimuli.meanData];
              
               currOutCells{j} = tempOut;
               
            else
                compSatisfiesFirstDayTuning(i) = 0;
                break; % Skip remaining comps for the other days if the first day doesn't meat the criteria
            end
                    
        else
%             tempOut = [outputs.peakSignal outputs.tracesForEachStimulus];
            tempOut = [outputs.AMConditions.peakSignal];
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

% reshape(compTable,[],3)
% reshape(table2cell(compTable),[],3)

% pivotTable = unstack(compTable, 'compName', 'index')

pivotTable = unstack(compTable, 'compName', 'date');

% pivotTable = stack(compTable, 'date') 
pivotTable = stack(compTable, 'compName');





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
    
    % The important red lines:
    outputs.TracesForAllStimuli.meanData = zeros(outputs.numStimuli, numFrames);
    
    outputs.AMConditions.imgDataToPlot = zeros(outputs.numStimuli, numFrames);
    outputs.AMConditions.peakSignal = zeros(outputs.numStimuli,1);
    
    %generate the dimensions of the subplots
    numRows = numel(nonzeros(outputs.uniqueFreqs))+1; %+1 because you have the zero mod condition too
    numCol = numel(nonzeros(outputs.uniqueAmps));
    
    for b = 1:outputs.numStimuli
        tracesToPlot = outputs.tracesForEachStimulus{b};
        %% plotTracesForAllStimuli_FDS Style
         %get the raw data that you're gonna plot
        outputs.TracesForAllStimuli.imgDataToPlot = imgData(tracesToPlot, :);
        %make an average
        outputs.TracesForAllStimuli.meanData(b,:) = mean(outputs.TracesForAllStimuli.imgDataToPlot, 1); % this is that main red line that we care about, it contains 1x150 double
        
        
        %% plotAMConditions_FDS Style
        outputs.AMConditions.imgDataToPlot(b,:) = mean(imgData(tracesToPlot,:));
        [~,maxInd] = max(outputs.AMConditions.imgDataToPlot(b, startSound:endSound)); % get max of current signal only within the startSound:endSound range
        maxInd = maxInd+startSound-1;
        outputs.AMConditions.peakSignal(b) = mean(outputs.AMConditions.imgDataToPlot(b, maxInd-sampPeak:maxInd+sampPeak));
    end

    % 2D projections of the plots:
    outputs.TracesForAllStimuli.finalSeriesAmps = {};
%     finalSeries = {};
 % uniqueAmps: the [0%, 20%, 40%, 60%, 80%, 100%] data series
    for c = 1:numel(outputs.uniqueAmps)
        activeUniqueAmp = outputs.uniqueAmps(c);
        currentAmpIdx = find(outputs.uniqueStimuli(:,2)==activeUniqueAmp); % this varies in size. for the 0 element it's 1x1, but for index 2 for example it's 5x1
        theseFreqs = outputs.uniqueStimuli(currentAmpIdx,1); % AM Depth (%)
        thesePeaks = outputs.AMConditions.peakSignal(currentAmpIdx); % 'Peak DF/F'
        
        
        tempCurrOutput = struct;
        tempCurrOutput.ampIdx = currentAmpIdx;
        tempCurrOutput.ampValue = activeUniqueAmp;
        tempCurrOutput.freqs = theseFreqs;
        tempCurrOutput.peaks = thesePeaks;

        outputs.TracesForAllStimuli.finalSeriesAmps{end+1} = tempCurrOutput;
        
    end
     
    outputs.TracesForAllStimuli.finalSeriesFreqs = {};
    % uniqueFreqs: the [0, 10, 20, 50, 100, 200 Hz] data series
    for d=1:numel(outputs.uniqueFreqs)
        activeUniqueFreq = outputs.uniqueFreqs(d);
        currentFreqIdx = find(outputs.uniqueStimuli(:,1)==activeUniqueFreq);
        theseAmps = outputs.uniqueStimuli(currentFreqIdx,2);
        thesePeaks = outputs.AMConditions.peakSignal(currentFreqIdx); % 'Peak DF/F'
        
        tempCurrOutput = struct;
        tempCurrOutput.freqIdx = currentFreqIdx;
        tempCurrOutput.freqValue = activeUniqueFreq;
        tempCurrOutput.amps = theseAmps;
        tempCurrOutput.peaks = thesePeaks;

        outputs.TracesForAllStimuli.finalSeriesFreqs{end+1} = tempCurrOutput;
        
%         %and plot the traces
%         if uniqueFreqs(d)==0
%             plot(tbImg,imgDataToPlot(currentFreqIdx,:),'Color','black','Linewidth',2)
%             text(max(tbImg),(d-1)*2,strcat(num2str(uniqueFreqs(d)),{' '},'Hz'))
%         else
%             for dd =1:numel(currentFreqIdx)
%                 plot(tbImg,imgDataToPlot(currentFreqIdx(dd),:)+((d-1)*1),'Color',amplitudeColorMap(dd+1,:),'Linewidth',2)
%             end
%         end
    end
    
end