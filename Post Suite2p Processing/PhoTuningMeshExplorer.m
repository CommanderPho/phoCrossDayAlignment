% Pho Tuning Mesh Explorer: Pipeline Stage 6
% Pho Hale, November 18, 2020
% Uses the processed results of the previous pipeline stage to plot tuning curve information for the components.
% Plots 3D Mesh Surface.


componentAggregatePropeties.maxTuningPeakValue
% Find


cellRoisToPlot = 1:10;

for i = 1:length(cellRoisToPlot)
    %% Plot the grid as a test
    temp.cellRoiIndex = cellRoisToPlot(i);
    temp.currAllSessionCompIndicies = multiSessionCellRoiCompIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI

    [figH, axH] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, finalOutPeaksGrid);
    zlim([-1, 1])
end


function [figH, axH] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, finalOutPeaksGrid)
    % currAllSessionCompIndicies: all sessions for the current ROI

    %% Options:
    dateEdgeColorMap = colormap(gray(6));
    meshFaceOpacity = 0.95; % 0.2

    meshPointsMarkerSize = 20;

    meshDifferencesLineWidth = 5;

    % uniqueAmps, uniqueFreqs, multiSessionCellRoiCompIndicies, cellRoiIndex

    temp.numSessions = length(currAllSessionCompIndicies);
    % meshgrid is common to all sessions within the ROI:
    [xx, yy] = meshgrid(uniqueAmps, uniqueFreqs);
    uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
    uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');

    figH = figure(cellRoiIndex); % generate a new figure to plot the sessions.
    clf(figH);
    hold off;

    % For each session in this cell ROI
    for i = 1:temp.numSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currPeaksGrid = squeeze(finalOutPeaksGrid(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x6x6)
        temp.currColor = dateEdgeColorMap(i,:);

        axH = surf(xx, yy, temp.currPeaksGrid);
        set(axH,'EdgeColor', temp.currColor); % Set edge colors to be able to visually distinguish between the days
        set(axH,'FaceAlpha', meshFaceOpacity);
        set(axH,'FaceColor',temp.currColor);

        set(axH,'Marker','.','MarkerSize', meshPointsMarkerSize); % Dots
        hold on;

        %% TODO: Draw the difference between each point in the grid as a thick line, shaded white for positive changes or black for negative ones.
        if i == 2        
            for ii = 1:length(xx)
                for jj = 1:length(yy)
                    line_i = ii;
                    line_j = jj;
                    lineObj = line([xx(line_i,line_j) xx(line_i,line_j)], [yy(line_i,line_j) yy(line_i,line_j)], [temp.prevPeaksGrid(line_i,line_j) temp.currPeaksGrid(line_i,line_j)]);
                    set(lineObj, 'Color','black','LineWidth', meshDifferencesLineWidth);
                end
            end
        end
    %     
        temp.prevCompIndex = temp.compIndex;
        temp.prevPeaksGrid = temp.currPeaksGrid;

    end

    % Set x-labels:
    xlabel('uniqueAmps (% Depth)');
    xlim([0 max(uniqueAmps)]);
    xticks(uniqueAmps);
    xticklabels(uniqueAmpLabels);

    % Set y-labels:
    ylabel('uniqueFreqs (Hz)');
    ylim([0 max(uniqueFreqs)]);
    yticks(uniqueFreqs);
    yticklabels(uniqueFreqLabels);

    legend(dateStrings);
    title(['cellRoi: ' num2str(cellRoiIndex)]);

end