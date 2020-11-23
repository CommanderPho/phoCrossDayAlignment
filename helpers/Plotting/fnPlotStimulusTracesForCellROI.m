function [figH] = fnPlotStimulusTracesForCellROI(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, tbImg, uniqueStimuli, indexMap_StimulusLinear2AmpsFreqsArray, redTraceLinesForAllStimuli, extantFigH)
%FNPLOTSTIMULUSTRACESFORCELLROI Summary of this function goes here
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

    curr_linear_subplot_index = 1;
    % For each session in this cell ROI
%     for i = 1:temp.numSessions
        i = 1;
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currRedTraceLinesForAllStimuli = squeeze(redTraceLinesForAllStimuli(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x26x150)
        temp.currDateString = dateStrings{i};
        
        numStimuli = size(temp.currRedTraceLinesForAllStimuli,1);
        
        
%         axH = plot(tbImg, temp.currRedTraceLinesForAllStimuli);
        
        for b = 1:numStimuli
            %stimulusList = flip(uniqueStimuli);
%             tracesToPlot = squeeze(temp.currRedTraceLinesForAllStimuli(b,:));
%             %get the raw data that you're gonna plot
%             imgDataToPlot = imgData(tracesToPlot,:);
% 
%             %make an average
%             meanData=mean(imgDataToPlot,1);

            meanData = squeeze(temp.currRedTraceLinesForAllStimuli(b,:));
            subplot(numRows, numCol, numStimuli-b+1);
%             plot(tbImg, imgDataToPlot,'color','black')
%             hold on
            plot(tbImg, meanData, 'color', 'red', 'linewidth', 2);
            title(strcat(num2str(uniqueStimuli(b,1)), {' '}, 'Hz', {' '}, 'at', {' '}, num2str(uniqueStimuli(b,2)*100), {' '}, '% Depth'))
            xlim([0, 5]);
        end
        
        
    % end %% end for session

end

