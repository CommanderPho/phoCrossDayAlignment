function [figH, curr_ax] = fnPlotCellROIBlobs(dateStrings, currAllSessionCompIndicies, cellRoiIndex, compMasks, extantFigH)
% fnPlotCellROIBlobs: Plots the blob mask and outlines for the given cell ROIs
    % currAllSessionCompIndicies: all sessions for the current ROI
    %% Options:
    temp.numSessions = length(currAllSessionCompIndicies);
    if ~exist('extantFigH','var')
%         figH = figure(1337 + cellRoiIndex); 
        figH = createFigureWithNameIfNeeded(['CellROI Blobs Figure: cellROI ' num2str(cellRoiIndex)]); % generate a new figure to plot the sessions.
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
        temp.currMask = squeeze(compMasks.Masks(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension
        temp.currEdge = squeeze(compMasks.Edge(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension
        temp.currDateString = dateStrings{i};
        
        %% Plot Blobs (areas)
        curr_ax = subplot(2, temp.numSessions, curr_linear_subplot_index);
        imshow(temp.currMask);
        title(sprintf('%s - Mask', temp.currDateString),'FontSize',14);
    
        %% Plot Edges
        curr_ax = subplot(2, temp.numSessions, (curr_linear_subplot_index + temp.numSessions)); % get the subplot for the second row by adding the length of the first row
        imshow(temp.currEdge);
        title(sprintf('%s - Edge', temp.currDateString),'FontSize',14);
        
        curr_linear_subplot_index = curr_linear_subplot_index + 1;
    end

    sgtitle(['cellRoi: ' num2str(cellRoiIndex)]);
    
end
