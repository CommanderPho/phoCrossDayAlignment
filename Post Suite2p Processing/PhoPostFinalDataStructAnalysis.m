% Pho Post Final Data Struct Analysis: Pipeline Stage 5
% Pho Hale, November 14, 2020
% Uses the finalDataStruct workspace variable and shows results.

addpath(genpath('..\helpers'));


%% Options:
curr_animal = 'anm265';

% tuning_max_threshold_criteria: the threshold value for peakDFF
tuning_max_threshold_criteria = 0.2;


%% Filter down to entries for the current animal:
activeAnimalDataStruct = finalDataStruct.(curr_animal); % get the final data struct for the current animal
activeAnimalSessionList = sessionList(strcmpi({sessionList.anmID}, curr_animal));
activeAnimalCompList = compList(strcmpi({compList.anmID}, curr_animal));
%% Processing Options:
dateStrings = {activeAnimalSessionList.date};  % Strings representing each date.

compTable = struct2table(activeAnimalCompList);
numCompListEntries = height(compTable); % The number of rows in the compTable. Should be a integer multiple of the number of unique comps (corresponding to multiple sessions/days for each unique comp)
indexArray = 1:height(compTable);
indexColumn = table(indexArray','VariableNames',{'index'});
compTable = [compTable indexColumn];

uniqueComps = unique(compTable.compName,'stable'); % Each unique component corresponds to a cellROI
num_cellROIs = length(uniqueComps); 

multiSessionCellRoiCompIndicies = zeros(num_cellROIs, 3); % a list of comp indicies for each CellRoi
compFirstDayTuningMaxPeak = zeros(num_cellROIs, 1); % Just the first day
compSatisfiesFirstDayTuning = zeros(num_cellROIs, 1); % Just the first day

compFirstDayTuningMaxPeak = zeros(num_cellROIs, 1); % Just the first day
multiSessionCellRoiSeriesOutResults = {};

% Build 2D Mesh for each component
finalOutPeaksGrid = zeros(numCompListEntries,6,6);

% componentAggregatePropeties.maxTuningPeakValue: the maximum peak value for each signal
componentAggregatePropeties.maxTuningPeakValue = zeros(numCompListEntries,1);

% componentAggregatePropeties.sumTuningPeaksValue: the sum of all peaks
componentAggregatePropeties.sumTuningPeaksValue = zeros(numCompListEntries,1);

for i = 1:num_cellROIs
   curr_comp = uniqueComps{i};
   curr_comp_indicies = find(strcmp(compTable.compName, curr_comp)); % Should be a list of 3 relevant indicies, one corresponding to each day.
   
   fprintf('uniqueComp[%d]: %s', i, curr_comp);
   disp(curr_comp_indicies');
   multiSessionCellRoiCompIndicies(i,:) = curr_comp_indicies';

    currOutCells = {};
	for j = 1:length(curr_comp_indicies)
		curr_day_linear_index = curr_comp_indicies(j);
		[currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(activeAnimalCompList, curr_day_linear_index);
        [outputs] = fnProcessCompFromFDS(finalDataStruct, currentAnm, currentSesh, currentComp);
        uniqueAmps = outputs.uniqueAmps;
        uniqueFreqs = outputs.uniqueFreqs;
        peakSignals = outputs.AMConditions.peakSignal;
        maxPeakSignal = max(peakSignals);
        sumPeaksSignal = sum(peakSignals);
        
        % Store the outputs in the grid:
        finalOutPeaksGrid(curr_day_linear_index,:,:) = outputs.finalOutGrid;
        componentAggregatePropeties.maxTuningPeakValue(curr_day_linear_index) = maxPeakSignal; 
        componentAggregatePropeties.sumTuningPeaksValue(curr_day_linear_index) = sumPeaksSignal;
        
        temp.isFirstSessionInCellRoi = (j == 1);
        if temp.isFirstSessionInCellRoi
            compFirstDayTuningMaxPeak(i) = maxPeakSignal;
            if maxPeakSignal > tuning_max_threshold_criteria
               compSatisfiesFirstDayTuning(i) = 1;

            else
                compSatisfiesFirstDayTuning(i) = 0;
%                 break; % Skip remaining comps for the other days if the first day doesn't meat the criteria
            end
                    
        else

        end
        
	end

end

compSatisfiesFirstDayTuning = (compFirstDayTuningMaxPeak > tuning_max_threshold_criteria);
sum(compSatisfiesFirstDayTuning)

% WARNING: This assumes that there are the same number of sessions for each cellROI
componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = (componentAggregatePropeties.maxTuningPeakValue > tuning_max_threshold_criteria);

componentAggregatePropeties.maxTuningPeakValue = reshape(componentAggregatePropeties.maxTuningPeakValue,[],3); % Reshape from linear to cellRoi indexing
componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = reshape(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria,[],3); % Reshape from linear to cellRoi indexing

% componentAggregatePropeties.tuningScore: the number of days the cellRoi meets the criteria
componentAggregatePropeties.tuningScore = sum(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria, 2);




% % plotTracesForAllStimuli_FDS(finalDataStruct, activeAnimalCompList(4))
% plotTracesForAllStimuli_FDS(finalDataStruct, activeAnimalCompList(162))
% plotTracesForAllStimuli_FDS(finalDataStruct, activeAnimalCompList(320))
% plotAMConditions_FDS(finalDataStruct, activeAnimalCompList(2:8))


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
    %TODO: Figure out how the 26 different stimuli (numStimuli) map to the uniqueAmps/uniqueFreqs points.
    % outputs.uniqueStimuli: 26x2 double - contains each unique pair of stimuli, with first column being freq and second column being depth:
    
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
    numUniqueAmps = length(outputs.uniqueAmps);
    numUniqueFreqs = length(outputs.uniqueFreqs);
    
    %% Up to this point, the setup is common for both plotAMConditions_FDS and plotTracesForAllStimuli_FDS
    
    %% Build a map from each unique stimuli to a linear stimulus index:
    outputs.indexMap_AmpsFreqs2StimulusArray = zeros(numUniqueAmps, numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
    for i = 1:numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(i);
        for j = 1:numUniqueFreqs
            activeUniqueFreq = outputs.uniqueFreqs(j);
            if (activeUniqueAmp == 0 || activeUniqueFreq == 0)
                outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = 1;
            else
                currentLinearStimulusIdx = find((outputs.uniqueStimuli(:,1)==activeUniqueFreq) & (outputs.uniqueStimuli(:,2)==activeUniqueAmp));
                outputs.indexMap_AmpsFreqs2StimulusArray(i,j) = currentLinearStimulusIdx;
            end
        end
    end
    
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
    for c = 1:numUniqueAmps
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
    for d=1:numUniqueFreqs
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
        
    end
    
    % Loop through all amplitudes and frequencies:
    % Build 2D Mesh for each component
    outputs.finalOutGrid = zeros(numUniqueAmps, numUniqueFreqs); % each row contains a fixed amplitude, each column a fixed freq
    for i = 1:numUniqueAmps
        activeUniqueAmp = outputs.uniqueAmps(i);
        for j = 1:numUniqueFreqs
            activeUniqueFreq = outputs.uniqueFreqs(j);
            % Get the appropriate linear index from the map
            linearStimulusIndex = outputs.indexMap_AmpsFreqs2StimulusArray(i, j);
            currPeaks = outputs.AMConditions.peakSignal(linearStimulusIndex); % 'Peak DF/F'
            outputs.finalOutGrid(i,j) = currPeaks;
        end
    end

    
    
end