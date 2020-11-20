% Pho Tuning Mesh Explorer: Pipeline Stage 6
% Pho Hale, November 18, 2020
% Uses the processed results of the previous pipeline stage to plot tuning curve information for the components.
% Plots 3D Mesh Surface.

%% Options:
% Uses phoPipelineOptions.shouldSaveFiguresToDisk and phoPipelineOptions.shouldShowPlots



% Find

%% Sort based on tuning score:
[sortedTuningScores, cellRoiSortIndex] = sort(componentAggregatePropeties.tuningScore, 'descend');

fig_export_parent_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ROI Results/Figures';
numToCompare = 1;
cellRoisToPlot = cellRoiSortIndex(1:numToCompare);

% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);

for i = 1:length(cellRoisToPlot)
    %% Plot the grid as a test
    temp.cellRoiIndex = cellRoisToPlot(i);
    temp.currAllSessionCompIndicies = multiSessionCellRoiCompIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    temp.firstCompSessionIndex = temp.currAllSessionCompIndicies(1);
    
    temp.firstCompSessionMask = squeeze(finalOutComponentSegmentMasks(temp.firstCompSessionIndex,:,:));

    if phoPipelineOptions.shouldShowPlots
        figure;
        imshow(temp.firstCompSessionMask);
        title(sprintf('Mask cellRoi[%d]', temp.cellRoiIndex));

        % % plotTracesForAllStimuli_FDS(finalDataStruct, activeAnimalCompList(4))
        % plotTracesForAllStimuli_FDS(finalDataStruct, activeAnimalCompList(162))
        % plotTracesForAllStimuli_FDS(finalDataStruct, activeAnimalCompList(320))
    %     plotAMConditions_FDS(finalDataStruct, activeAnimalCompList(temp.currAllSessionCompIndicies))

        % Make 2D Plots (Exploring):    
        [figH_2d, ~] = fnPlotFlattenedPlotsFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, finalOutPeaksGrid);

        % Make 3D Mesh Plot:
        [figH, axH] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, finalOutPeaksGrid);
        zlim([-0.2, 1])

        if phoPipelineOptions.shouldSaveFiguresToDisk
            %% Export plots:
            fig_name = sprintf('TuningCurves_cellRoi_%d.fig', temp.cellRoiIndex);
            fig_2d_export_path = fullfile(fig_export_parent_path, fig_name);
            savefig(figH_2d, fig_2d_export_path);
            close(figH_2d);

            fig_name = sprintf('TuningMesh_cellRoi_%d.fig', temp.cellRoiIndex);
            fig_export_path = fullfile(fig_export_parent_path, fig_name);
            savefig(figH, fig_export_path);
            close(figH);
        end
    
    end
end

%%% 2D Plotting
function [figH, curr_ax] = fnPlotFlattenedPlotsFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, finalOutPeaksGrid)
    % currAllSessionCompIndicies: all sessions for the current ROI
    %% Options:
    temp.numSessions = length(currAllSessionCompIndicies);
    uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
    uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');

    figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
    clf(figH);
    
    %specify colormaps for your figure. This is important!!
    amplitudeColorMap = winter(numel(uniqueAmps));
    frequencyColorMap = spring(numel(uniqueFreqs));

    curr_linear_subplot_index = 1;
    % For each session in this cell ROI
    for i = 1:temp.numSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currPeaksGrid = squeeze(finalOutPeaksGrid(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x6x6)
        temp.currDateString = dateStrings{i};
        
        curr_ax = subplot(2, temp.numSessions, curr_linear_subplot_index);
        colororder(curr_ax, amplitudeColorMap)
        hold on; % required for colororder to take effect
        
        h_x_amp = plot(repmat(uniqueFreqs', [length(uniqueAmps) 1])', temp.currPeaksGrid');
        set(h_x_amp, 'linewidth', 2);
        ylabel('Peak DF/F')
        xlabel('AM Rate (Hz)')
        legend(uniqueAmpLabels);
      
        title(temp.currDateString,'FontSize',14);

        %% AM Depth (%) plot
        curr_ax = subplot(2, temp.numSessions, (curr_linear_subplot_index + temp.numSessions)); % get the subplot for the second row by adding the length of the first row
        colororder(curr_ax, frequencyColorMap)
        hold on; % required for colororder to take effect
        h_x_freq = plot(repmat(uniqueAmps', [length(uniqueFreqs) 1])', temp.currPeaksGrid');
        set(h_x_freq, 'linewidth', 2);
        ylabel('Peak DF/F')
        xlabel('AM Depth (%)')
        legend(uniqueFreqLabels);

        curr_linear_subplot_index = curr_linear_subplot_index + 1;
    end

%     % Set x-labels:
%     xlabel('uniqueAmps (% Depth)');
%     xlim([0 max(uniqueAmps)]);
%     xticks(uniqueAmps);
%     xticklabels(uniqueAmpLabels);
% 
%     % Set y-labels:
%     ylabel('uniqueFreqs (Hz)');
%     ylim([0 max(uniqueFreqs)]);
%     yticks(uniqueFreqs);
%     yticklabels(uniqueFreqLabels);
% 
    sgtitle(['cellRoi: ' num2str(cellRoiIndex)]);
    
end


%%% 3D Mesh Plotting
function [figH, axH] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, finalOutPeaksGrid)
    % currAllSessionCompIndicies: all sessions for the current ROI

    %% Options:
    dataEdgeColorMap = colormap(gray(6));
    dataEdgeColorMap = dataEdgeColorMap(2:end,:);
    
    meshFaceOpacity = 0.80; % 0.2

    meshPointsMarkerColor = 'cyan';
    meshPointsMarkerSize = 10;

    % meshDifferencesLinesEnabled: if true, draws connecting lines between each point of the surface
    meshDifferencesLinesEnabled = false;
    meshDifferencesLineColor = 'red';
    meshDifferencesLineWidth = 2;

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
        temp.currColor = dataEdgeColorMap(i,:);

        axH = surf(xx, yy, temp.currPeaksGrid);
%         set(axH,'EdgeColor', temp.currColor); % Set edge colors to be able to visually distinguish between the days
        set(axH,'FaceAlpha', meshFaceOpacity);
        set(axH,'FaceColor', temp.currColor);

        set(axH,'Marker','.','MarkerSize', meshPointsMarkerSize); % Dots
        if exist('meshPointsMarkerColor','var')
            set(axH,'MarkerFaceColor', meshPointsMarkerColor, 'MarkerEdgeColor', meshPointsMarkerColor);
        end
        hold on;

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