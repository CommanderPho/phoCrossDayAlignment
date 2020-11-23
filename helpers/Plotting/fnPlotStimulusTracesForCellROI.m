function [figH] = fnPlotStimulusTracesForCellROI(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, tbImg, redTraceLinesForAllStimuli, extantFigH)
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
    
    curr_linear_subplot_index = 1;
    % For each session in this cell ROI
    for i = 1:temp.numSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currRedTraceLinesForAllStimuli = squeeze(redTraceLinesForAllStimuli(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x26x150)
        temp.currDateString = dateStrings{i};
        
        axH = plot(tbImg, temp.currRedTraceLinesForAllStimuli);
        
        
        
    end

end

