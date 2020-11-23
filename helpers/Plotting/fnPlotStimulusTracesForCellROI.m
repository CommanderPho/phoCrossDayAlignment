function [figH, curr_ax] = fnPlotStimulusTracesForCellROI(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, redTraceLinesForAllStimuli, extantFigH)
%FNPLOTSTIMULUSTRACESFORCELLROI Summary of this function goes here
%   Detailed explanation goes here

    % currAllSessionCompIndicies: all sessions for the current ROI
    %% Options:
    temp.numSessions = length(currAllSessionCompIndicies);
    
    if ~exist('extantFigH','var')
        figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
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
        temp.currRedTraceLinesForAllStimuli = squeeze(redTraceLinesForAllStimuli(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x6x6)
        temp.currDateString = dateStrings{i};
        
        
    end

end

