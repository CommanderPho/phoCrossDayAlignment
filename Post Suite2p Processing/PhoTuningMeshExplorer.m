% Plots 3D Mesh Surface.
% To be called after '

dateEdgeColors = {'r', 'g', 'b'};
% dateEdgeColorMap = colormap(greyscale(3));

%% Plot the grid as a test
temp.cellRoiIndex = 5;
temp.currAllSessionCompIndicies = multiSessionCellRoiCompIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI

temp.numSessions = length(temp.currAllSessionCompIndicies);
% meshgrid is common to all sessions within the ROI:
[xx, yy] = meshgrid(uniqueAmps, uniqueFreqs);
uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');

figH = figure(1); % generate a new figure to plot the sessions.
clf(figH);
hold off;

% For each session in this cell ROI
for i = 1:temp.numSessions
    % Get the index for this session of this cell ROI
    temp.compIndex = temp.currAllSessionCompIndicies(i); 
    % Gets the grid for this session of this cell ROI
    temp.currPeaksGrid = squeeze(finalOutPeaksGrid(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x6x6)
    axH = surf(xx, yy, temp.currPeaksGrid);
    set(axH,'EdgeColor', dateEdgeColors{i}); % Set edge colors to be able to visually distinguish between the days
    set(axH,'FaceAlpha', 0.2);
    set(axH,'FaceColor',dateEdgeColors{i});
    set(axH,'Marker','.','MarkerSize',20); % Dots
    hold on;
    
    %% TODO: Draw the difference between each point in the grid as a thick line, shaded white for positive changes or black for negative ones.
    if i == 2        
        for ii = 1:length(xx)
            for jj = 1:length(yy)
                line_i = ii;
                line_j = jj;
                lineObj = line([xx(line_i,line_j) xx(line_i,line_j)], [yy(line_i,line_j) yy(line_i,line_j)], [temp.prevPeaksGrid(line_i,line_j) temp.currPeaksGrid(line_i,line_j)]);
                set(lineObj, 'Color','black','LineWidth',10);
            end
        end
    end
%     
%     temp.prevCompIndex = temp.compIndex;
%     temp.prevPeaksGrid = temp.currPeaksGrid;
% WORKS: line(xx(2,2), yy(2,2), temp.currPeaksGrid(2,2), 'Color','black');

%     line([xx(2,2) xx(2,2)], [yy(2,2) yy(2,2)], [temp.prevPeaksGrid(2,2) temp.currPeaksGrid(2,2)], 'Color','black');

end

% Set x-labels:
xlabel('uniqueAmps (% Depth)')
xlim([0 max(uniqueAmps)])
xticks(uniqueAmps)
xticklabels(uniqueAmpLabels);

% Set y-labels:
ylabel('uniqueFreqs (Hz)')
ylim([0 max(uniqueFreqs)])
yticks(uniqueFreqs)
yticklabels(uniqueFreqLabels);

legend(dateStrings)