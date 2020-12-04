function [figH] = fnPlotStimulusTracesForCellROI(dateStrings, uniqueAmps, uniqueFreqs, uniqueStimuli, currAllSessionCompIndicies, cellRoiIndex, traceTimebase_t, tracesForAllStimuli, redTraceLinesForAllStimuli, extantFigH)
%FNPLOTSTIMULUSTRACESFORCELLROI plots the array of traces for each stimulus pair for each session for a single cellRoi
%   Detailed explanation goes here

    % currAllSessionCompIndicies: all sessions for the current ROI
    %% Options:
    temp.numSessions = length(currAllSessionCompIndicies);
    
    if ~exist('extantFigH','var')
        figH = createFigureWithNameIfNeeded(['CellROI StimulusTraces Figure: cellROI ' num2str(cellRoiIndex)]); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end    
    clf(figH);
    
    
    %generate the dimensions of the subplots
    numRows = numel(nonzeros(uniqueFreqs))+1; %+1 because you have the zero mod condition too
    numCol = numel(nonzeros(uniqueAmps));

%     ha = tight_subplot(numRows, numCol);
    
    curr_linear_subplot_index = 1;
    session_colors = {'r','g','b'};
    
    % For each session in this cell ROI
    for i = 1:temp.numSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currRedTraceLinesForAllStimuli = squeeze(redTraceLinesForAllStimuli(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x26x150)
        
        temp.currTrialTraceLinesForAllStimuli = squeeze(tracesForAllStimuli.imgDataToPlot(temp.compIndex,:,:,:));

        temp.currDateString = dateStrings{i};
        
        numStimuli = size(temp.currRedTraceLinesForAllStimuli,1);
        
%         axH = plot(traceTimebase_t, temp.currRedTraceLinesForAllStimuli);
        
        for b = 1:numStimuli
%             [ampsIndex, freqsIndex] = indexMap_StimulusLinear2AmpsFreqsArray(b,:,:);
            
            %stimulusList = flip(uniqueStimuli);
%             tracesToPlot = squeeze(temp.currRedTraceLinesForAllStimuli(b,:));
%             %get the raw data that you're gonna plot
%             imgDataToPlot = imgData(tracesToPlot,:);
% 
%             %make an average
%             meanData=mean(imgDataToPlot,1);

            currAllTraces = squeeze(temp.currTrialTraceLinesForAllStimuli(b,:,:));
            

            meanData = squeeze(temp.currRedTraceLinesForAllStimuli(b,:));
%             axes(ha(numStimuli-b+1));
            
            subplot(numRows, numCol, numStimuli-b+1);
            h_PlotObj_allTraces = plot(traceTimebase_t, currAllTraces,'color','black');
            hold on;
            h_PlotObj = plot(traceTimebase_t, meanData);
            set(h_PlotObj, 'color', session_colors{i}, 'linewidth', 2);
            title(strcat(num2str(uniqueStimuli(b,1)), {' '}, 'Hz', {' '}, 'at', {' '}, num2str(uniqueStimuli(b,2)*100), {' '}, '% Depth'))
            xlim([0, 5]);
            hold on;
            
        end
        
        
    end %% end for session
    
    sgtitle(['cellRoi: ' num2str(cellRoiIndex)]);
end

