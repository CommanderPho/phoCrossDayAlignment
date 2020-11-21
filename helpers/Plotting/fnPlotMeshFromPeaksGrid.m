
%%% 3D Mesh Plotting
function [figH, axH] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, finalOutPeaksGrid, extantFigH)
    % currAllSessionCompIndicies: all sessions for the current ROI

    %% Options:
    dataEdgeColorMap = colormap(gray(6));
    dataEdgeColorMap = dataEdgeColorMap(2:end,:);
    
    meshFaceOpacity = 0.80; % 0.2
    meshEdgeColor = {'red','green','cyan'};
    
    meshPointsMarkerSymbol = '.';
    meshPointsMarkerColor = {'red','green','cyan'};
    meshPointsMarkerSize = 20; % 10 is default
    
    % meshDifferencesLinesEnabled: if true, draws connecting lines between each point of the surface
    meshDifferencesLinesEnabled = false;
    meshDifferencesLineColor = 'red';
    meshDifferencesLineWidth = 2;
    
    meshMaximumPointsEnabled = true; % if true, the maximum point is plotted
    maxPointMarkerColor = 'yellow';
    
%     meshPlotSinglePointZeroMode = false; % If true, only the non-zero points are drawn.
    
    
    % uniqueAmps, uniqueFreqs, multiSessionCellRoiCompIndicies, cellRoiIndex

    temp.numSessions = length(currAllSessionCompIndicies);
    % meshgrid is common to all sessions within the ROI:
    [xx, yy] = meshgrid(uniqueAmps, uniqueFreqs);
    uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
    uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');

%     fprintf('debug: \n')
%     fprintf('\t uniqueAmps: ')
%     disp(uniqueAmps)
%     fprintf('\t uniqueFreqs: ')
%     disp(uniqueFreqs)
    
    
    if ~exist('extantFigH','var')
        figH = figure(cellRoiIndex); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end
    
    clf(figH);
    hold off;

    % For each session in this cell ROI
    for i = 1:temp.numSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currPeaksGrid = squeeze(finalOutPeaksGrid(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x6x6)
        temp.currColor = dataEdgeColorMap(i,:);

        axH = surf(xx, yy, temp.currPeaksGrid);
%         set(axH,'EdgeColor', temp.currColor); % Set edge colors to be able to visually distinguish between the days
        set(axH,'FaceAlpha', meshFaceOpacity);
        set(axH,'FaceColor', temp.currColor);
        
        if exist('meshEdgeColor','var')
            set(axH,'EdgeColor',meshEdgeColor{i});
            set(axH,'LineStyle','-.');
            set(axH,'EdgeAlpha', 0.3);
            set(axH,'LineWidth', 1.0);
        end
        
        set(axH,'Marker',meshPointsMarkerSymbol,'MarkerSize', meshPointsMarkerSize); % Dots
        if exist('meshPointsMarkerColor','var')
            set(axH,'MarkerFaceColor', meshPointsMarkerColor{i}, 'MarkerEdgeColor', meshPointsMarkerColor{i});
            set(axH,'Marker');
        end
        hold on;

        %% tODO: Zero stuff
%         peak_zero = temp.currPeaksGrid(1,1);
%         scatter3(xx(1), yy(1), peak_zero,'x','Color','black','MarkerSize',20) % Draws a single point
%         hold on;
            
        
        if meshMaximumPointsEnabled
            [maxValue, linearIndexesOfMaxes] = max(temp.currPeaksGrid(:));
            [rowsOfMaxes, colsOfMaxes] = find(temp.currPeaksGrid == maxValue);
                           
            if length(colsOfMaxes) > 1
%                 error('More than one maximum!');
%                 axH = scatter3(xx(rowsOfMaxes, colsOfMaxes), yy(rowsOfMaxes, colsOfMaxes), maxValue, 60); % Draws a single point
%                 set(axH,'MarkerEdgeColor',maxPointMarkerColor,'MarkerFaceColor',maxPointMarkerColor);
                warning('More than one maximum!');

            else
%                 fprintf('maxPoints: %s [%s, %s], %s\n', num2str(linearIndexesOfMaxes), num2str(rowsOfMaxes), num2str(colsOfMaxes), num2str(maxValue))
%                 fprintf('\t xx,yy: [%s, %s]\n', num2str(xx(rowsOfMaxes)), num2str(yy(colsOfMaxes)))
%                 fprintf('\t values: [%s, %s]\n', num2str(uniqueAmps(rowsOfMaxes)), num2str(uniqueFreqs(colsOfMaxes)))
                axH = scatter3(xx(rowsOfMaxes, colsOfMaxes), yy(rowsOfMaxes, colsOfMaxes), maxValue, 60); % Draws a single point
                set(axH,'MarkerEdgeColor',maxPointMarkerColor,'MarkerFaceColor',maxPointMarkerColor);
                hold on;
            end
            
      
%             
%             
%             hold on;
        end
        
        %% TODO: Draw the difference between each point in the grid as a thick line, shaded white for positive changes or black for negative ones.
        if i == 2
            if meshDifferencesLinesEnabled
                for ii = 1:length(xx)
                    for jj = 1:length(yy)
                        line_i = ii;
                        line_j = jj;
                        lineObj = line([xx(line_i,line_j) xx(line_i,line_j)], [yy(line_i,line_j) yy(line_i,line_j)], [temp.prevPeaksGrid(line_i,line_j) temp.currPeaksGrid(line_i,line_j)]);
                        set(lineObj, 'Color',meshDifferencesLineColor,'LineWidth', meshDifferencesLineWidth);
                    end
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