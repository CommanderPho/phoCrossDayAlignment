% Pho Load Final Data Struct: Pipeline Stage 7
% Pho Hale, November 19, 2020
% Builds relations been each cells spatial location and their tuning.

fprintf('> Running PhoBuildSpatialTuning...\n');

%% Options:
% Uses:
%   phoPipelineOptions.shouldSaveFiguresToDisk
%   phoPipelineOptions.shouldShowPlots
%   phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path
%   phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria
%   phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode
%   phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.edge_layering_is_outset_mode
%   phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCentroidPoints
%   phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCellROILabels
if ~exist('phoPipelineOptions','var')
    warning('phoPipelineOptions is missing! Using defaults specified in PhoBuildSpatialTuning.m')
    phoPipelineOptions.shouldSaveFiguresToDisk = true;
    phoPipelineOptions.shouldShowPlots = true;
    %%% PhoBuildSpatialTuning Options:
    phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = '';
    phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria = false; % If true, the cell region will be rendered with an opacity proporitional to the number of days it met the threshold critiera
    phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode = false; % If true, colorful borders are drawn around each cellROI to represent its preferred stimuli for each day.
    phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.edge_layering_is_outset_mode = false; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw
    
    phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCentroidPoints = true;
    phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCellROILabels = true;
    
    
end

% If it's needed, make sure the export directory is set up appropriately
if phoPipelineOptions.shouldShowPlots
    if phoPipelineOptions.shouldSaveFiguresToDisk
        if isempty(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path)
            phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = uigetdir(pwd, 'Select an export directory');
        end
        while (~exist(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, 'dir'))
            warning(['WARNING: The specified figure export directory ' phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path ' does not exist!']);
            phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = uigetdir(pwd, 'Select an export directory');
        end
    end
end

[amalgamationMasks, outputMaps, cellRoiSortIndex] = fnBuildSpatialTuningInfo(num_cellROIs, numOfSessions, multiSessionCellRoi_CompListIndicies, finalOutComponentSegment, componentAggregatePropeties, phoPipelineOptions);

if phoPipelineOptions.shouldShowPlots
    [figH_numDaysCriteria, figH_roiTuningPreferredStimulus] = fnPlotPhoBuildSpatialTuningFigures(uniqueAmps, uniqueFreqs, cellRoiSortIndex, componentAggregatePropeties, amalgamationMasks, outputMaps, phoPipelineOptions);
    
    %% Optional Export to disk:
    if phoPipelineOptions.shouldSaveFiguresToDisk
        %% Export plots:
        fig_name = sprintf('cellROI_shaded_by_number_of_days.fig');
        fig_numDaysCriteria_export_path = fullfile(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, fig_name);
        savefig(figH_numDaysCriteria, fig_numDaysCriteria_export_path);
        close(figH_numDaysCriteria);
        
        fig_name = sprintf('cellROI_TuningPreferredStimulus.fig');
        fig_export_path = fullfile(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, fig_name);
        savefig(figH_roiTuningPreferredStimulus, fig_export_path);
        close(figH_roiTuningPreferredStimulus);
    end
    
end

fprintf('\t done.\n')


%% Build Spatial Info:
function [amalgamationMasks, outputMaps, cellRoiSortIndex] = fnBuildSpatialTuningInfo(num_cellROIs, numOfSessions, multiSessionCellRoi_CompListIndicies, finalOutComponentSegment, componentAggregatePropeties, phoPipelineOptions)
% should_enable_edge_layering_mode: if true, uses the borders surrounding each cell to reflect the preferred tuning at a given day.
should_enable_edge_layering_mode = phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode;
edge_layering_is_outset_mode = phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.edge_layering_is_outset_mode; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw
%     temp.structuring_element = strel('disk', 2);
%     temp.structuring_element = strel('diamond', 2);
temp.structuring_element = strel('square', 3);

%% Sort based on tuning score:
[sortedTuningScores, cellRoiSortIndex] = sort(componentAggregatePropeties.tuningScore, 'descend');

amalgamationMasks.cellROI_LookupMask = zeros(512, 512); % Maps every pixel in the image to the cellROI index of the cell it belongs to, if one exists.

amalgamationMasks.AlphaConjunctionMask = zeros(512, 512);
amalgamationMasks.AlphaRoiTuningScoreMask = zeros(512, 512);
amalgamationMasks.NumberOfTunedDays = zeros(512, 512);

% outputMaps.masks: one for each cellROI
outputMaps.masks.Fill = zeros(num_cellROIs,512,512);
outputMaps.masks.Edge = zeros(num_cellROIs,512,512);

outputMaps.masks.OutsetEdge0 = zeros(num_cellROIs,512,512);
outputMaps.masks.OutsetEdge1 = zeros(num_cellROIs,512,512);
outputMaps.masks.OutsetEdge2 = zeros(num_cellROIs,512,512);

outputMaps.masks.InsetEdge0 = zeros(num_cellROIs,512,512);
outputMaps.masks.InsetEdge1 = zeros(num_cellROIs,512,512);
outputMaps.masks.InsetEdge2 = zeros(num_cellROIs,512,512);

% amalgamationMasks.PreferredStimulusAmplitude = zeros(512, 512, 3);
% init_matrix = zeros(512, 512);
init_matrix = ones(numOfSessions, 512, 512) * -1;

outputMaps.PreferredStimulusAmplitude = init_matrix;
outputMaps.PreferredStimulusFreq = init_matrix;


outputMaps.PreferredStimulus = zeros(num_cellROIs, numOfSessions, 2);


% amalgamationMasks.DidPreferredStimulusChange: keeps track of whether the preferredStimulus amplitude or frequency changed for a cellROI between sessions.
outputMaps.DidPreferredStimulusChange = zeros(num_cellROIs, (numOfSessions-1));

outputMaps.computedProperties.areas = zeros(num_cellROIs, 1);
outputMaps.computedProperties.boundingBoxes = zeros(num_cellROIs, 4);
outputMaps.computedProperties.centroids = zeros(num_cellROIs, 2);

for i = 1:num_cellROIs
    %% Plot the grid as a test
    temp.cellRoiIndex = cellRoiSortIndex(i); %% TODO: Should this be uniqueComps(i) instead? RESOLVED: No, this is correct!
    temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    %% cellROI Specific Score:
    temp.currRoiTuningScore = componentAggregatePropeties.tuningScore(temp.cellRoiIndex); % currently only uses first session?
    temp.numSessions = length(temp.currAllSessionCompIndicies);
    
    for j = 1:temp.numSessions
        
        temp.currCompSessionIndex = temp.currAllSessionCompIndicies(j);
        
        %% Results common across all sessions of this cellROI:
        % Check if this is the first session for this cellROI as not to recompute it needlessly when it doesn't change across sessions.
        if j == 1
            temp.currCompSessionFill = logical(squeeze(finalOutComponentSegment.Masks(temp.currCompSessionIndex,:,:)));
            temp.currCompSessionEdge = logical(squeeze(finalOutComponentSegment.Edge(temp.currCompSessionIndex,:,:)));
            
            outputMaps.masks.Fill(i,:,:) = temp.currCompSessionFill;
            outputMaps.masks.Edge(i,:,:) = temp.currCompSessionEdge;
            
            BW2_Inner = imerode(temp.currCompSessionFill, temp.structuring_element);
            BW3_Inner = imerode(BW2_Inner, temp.structuring_element);
            BW4_Inner = imerode(BW3_Inner, temp.structuring_element);
         
            %% Inset Elements:
            outputMaps.masks.InsetEdge0(i,:,:) = BW2_Inner;
            outputMaps.masks.InsetEdge1(i,:,:) = BW3_Inner;
            outputMaps.masks.InsetEdge2(i,:,:) = BW4_Inner;
                        
            %% Outside Elements:
            BW2_Outer = imdilate(temp.currCompSessionFill, temp.structuring_element);
            BW3_Outer = imdilate(BW2_Outer, temp.structuring_element);
            BW4_Outer = imdilate(BW3_Outer, temp.structuring_element);
            outputMaps.masks.OutsetEdge0(i,:,:) = BW2_Outer;
            outputMaps.masks.OutsetEdge1(i,:,:) = BW3_Outer;
            outputMaps.masks.OutsetEdge2(i,:,:) = BW4_Outer;
            %                 temp.currCompSessionMask = temp.currCompSessionEdge; % Use the edges instead of the fills
            temp.currCompSessionMask = temp.currCompSessionFill; % Use the fills
            
            
            s = regionprops(temp.currCompSessionFill,'Centroid','Area','BoundingBox');
            outputMaps.computedProperties.areas(i) = s.Area;
            outputMaps.computedProperties.boundingBoxes(i,:) = s.BoundingBox;
            outputMaps.computedProperties.centroids(i,:) = s.Centroid;
            
            % Save the index of this cell in the reverse lookup table:
            amalgamationMasks.cellROI_LookupMask(temp.currCompSessionFill) = temp.cellRoiIndex;
            amalgamationMasks.cellROI_LookupMask(temp.currCompSessionEdge) = temp.cellRoiIndex;
            if (should_enable_edge_layering_mode && edge_layering_is_outset_mode)
                amalgamationMasks.cellROI_LookupMask(BW2_Outer) = temp.cellRoiIndex;
                amalgamationMasks.cellROI_LookupMask(BW3_Outer) = temp.cellRoiIndex;
                amalgamationMasks.cellROI_LookupMask(BW4_Outer) = temp.cellRoiIndex;
            end
            
            % Set cells in this cellROI region to opaque:
            amalgamationMasks.AlphaConjunctionMask(temp.currCompSessionMask) = 1.0;
            % Set the opacity of cell in this cellROI region based on the number of days that the cell passed the threshold:
            amalgamationMasks.AlphaRoiTuningScoreMask(temp.currCompSessionMask) = (double(temp.currRoiTuningScore) / 3.0);
            
            if (should_enable_edge_layering_mode && edge_layering_is_outset_mode)
                amalgamationMasks.AlphaConjunctionMask(BW2_Outer) = 1.0;
                amalgamationMasks.AlphaConjunctionMask(BW3_Outer) = 1.0;
                amalgamationMasks.AlphaConjunctionMask(BW4_Outer) = 1.0;
            end
            
            % Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
            amalgamationMasks.NumberOfTunedDays(temp.currCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;
            
        end
        
        % Currently just use the preferred stimulus info from the first of the three sessions:
        temp.currCompMaximallyPreferredStimulusInfo = componentAggregatePropeties.maximallyPreferredStimulusInfo(temp.currCompSessionIndex);
        temp.currMaximalIndexTuple = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqIndexTuple; %Check this to make sure it's always (0, 0) when one of the tuple elements are zero.
        temp.maxPrefAmpIndex = temp.currMaximalIndexTuple(1);
        temp.maxPrefFreqIndex = temp.currMaximalIndexTuple(2);
        
        outputMaps.PreferredStimulus(i,j,:) =  temp.currMaximalIndexTuple;
        
        if should_enable_edge_layering_mode
            if j <= 1
                if edge_layering_is_outset_mode
                    temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.OutsetEdge0(i,:,:)));
                else
                    temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.InsetEdge2(i,:,:)));
                end
            elseif j == 2
                if edge_layering_is_outset_mode
                    temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.OutsetEdge1(i,:,:)));
                else
                    temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.InsetEdge1(i,:,:)));
                end
            else
                if edge_layering_is_outset_mode
                    temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.OutsetEdge2(i,:,:)));
                else
                    temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.InsetEdge0(i,:,:)));
                end
            end
            outputMaps.PreferredStimulusAmplitude(j, temp.currCompSessionCustomEdgeMask) = double(temp.maxPrefAmpIndex);
            outputMaps.PreferredStimulusFreq(j, temp.currCompSessionCustomEdgeMask) = double(temp.maxPrefFreqIndex);
            if edge_layering_is_outset_mode
                % Fill in the main fill with nothing
                outputMaps.PreferredStimulusAmplitude(j, temp.currCompSessionFill) = -1.0;
                outputMaps.PreferredStimulusFreq(j, temp.currCompSessionFill) = -1.0;
            end
        else
            outputMaps.PreferredStimulusAmplitude(j, temp.currCompSessionMask) = double(temp.maxPrefAmpIndex);
            outputMaps.PreferredStimulusFreq(j, temp.currCompSessionMask) = double(temp.maxPrefFreqIndex);
        end
        
        % If we're not on the first session, see if the preferred values changed between the sessions.
        if j > 1
            didPreferredAmpIndexChange = (temp.prev.maxPrefAmpIndex ~= temp.maxPrefAmpIndex);
            didPreferredFreqIndexChange = (temp.prev.maxPrefFreqIndex ~= temp.maxPrefFreqIndex);
            outputMaps.DidPreferredStimulusChange(i,j-1) = didPreferredAmpIndexChange | didPreferredFreqIndexChange;
        end
        % Update the prev values:
        temp.prev.maxPrefAmpIndex = temp.maxPrefAmpIndex;
        temp.prev.maxPrefFreqIndex = temp.maxPrefFreqIndex;
        
    end % end for numSessions
    
end % end for each cell ROI
end

%% Master Plotting Function
function [figH_numDaysCriteria, figH_roiTuningPreferredStimulus] = fnPlotPhoBuildSpatialTuningFigures(uniqueAmps, uniqueFreqs, cellRoiSortIndex, componentAggregatePropeties, amalgamationMasks, outputMaps, phoPipelineOptions)
    uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
    uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');
    %specify colormaps for your figure. This is important!!
    amplitudeColorMap = winter(numel(uniqueAmps));
    frequencyColorMap = spring(numel(uniqueFreqs));
    % Override with solid black for the (0,0) elements.
    amplitudeColorMap(1,:) = [0, 0, 0];
    frequencyColorMap(1,:) = [0, 0, 0];


    % Number of Days Meeting Criteria Figure:
    figH_numDaysCriteria = fnPlotNumberOfDaysCriteriaFigure(amalgamationMasks, componentAggregatePropeties);
    % Custom Tooltips:
    [dcm_numDaysCriteria] = fnAddCustomDataCursor(figH_numDaysCriteria);

    if phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode
        temp.currPreferredStimulusAmplitude = squeeze(sum(outputMaps.PreferredStimulusAmplitude, 1));
        temp.currPreferredStimulusFrequency = squeeze(sum(outputMaps.PreferredStimulusFreq, 1));

        %Preferred Stimulus Figure:
        [figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, temp.currPreferredStimulusAmplitude, temp.currPreferredStimulusFrequency);
    else
        % Can only plot a single session, such as j=1:
%         j = 1;
        j = 1:3;
        temp.currPreferredStimulusAmplitude = squeeze(outputMaps.PreferredStimulusAmplitude(j,:,:));
        temp.currPreferredStimulusFrequency = squeeze(outputMaps.PreferredStimulusFreq(j,:,:));

        %Preferred Stimulus Figure:
        [figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, temp.currPreferredStimulusAmplitude, temp.currPreferredStimulusFrequency);

    end

    %% Custom Tooltips:
    [dcm_roiTuningPreferredStimulus] = fnAddCustomDataCursor(figH_roiTuningPreferredStimulus);


    % fnPlotROITuningPreferredStimulusFigure
    function [figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, currPreferredStimulusAmplitude, currPreferredStimulusFrequency)
        
        figH_roiTuningPreferredStimulus = createFigureWithNameIfNeeded('CellROI Aggregate: Preferred Stimulus Tuning');
        clf(figH_roiTuningPreferredStimulus);
        
        input_size = size(currPreferredStimulusAmplitude); % [512, 512]; [3 512 512]
        input_size_num_dims = length(input_size); % 1x2 double, 1x3 double
        
        if input_size_num_dims == 2
            num_sessions = 1;
        elseif input_size_num_dims == 3
            num_sessions = size(currPreferredStimulusAmplitude,1);
        else
            error('Unexpected input dimensions!')
        end
        
        ha = tight_subplot(num_sessions,2);

        amplitudeHandles.axes = ha(1:2:length(ha)); % odd indicies [1 3 5]
        freqHandles.axes = ha(2:2:length(ha)); % even indicies, [2 4 6]
        
        for i = 1:num_sessions
            % Get the current amplitude and frequencies to plot
            if (input_size_num_dims == 3)
                temp.currPreferredStimulusAmplitude = squeeze(currPreferredStimulusAmplitude(i,:,:));
                temp.currPreferredStimulusFrequency = squeeze(currPreferredStimulusFrequency(i,:,:));
            else
                temp.currPreferredStimulusAmplitude = currPreferredStimulusAmplitude;
                temp.currPreferredStimulusFrequency = currPreferredStimulusFrequency;
            end
            
            axes(amplitudeHandles.axes(i));
            amplitudeHandles.tempImH = imshow(temp.currPreferredStimulusAmplitude, amplitudeColorMap, 'Parent', amplitudeHandles.axes(i));
            if phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria
                set(amplitudeHandles.tempImH, 'AlphaData', amalgamationMasks.AlphaRoiTuningScoreMask);
            else
                set(amplitudeHandles.tempImH, 'AlphaData', amalgamationMasks.AlphaConjunctionMask);
            end
            title(amplitudeHandles.axes(i), 'Amplitude Tuning')
            fnAddSimpleLegend(uniqueAmpLabels, amplitudeColorMap);
            [amplitudeHandles.axH_centroidPoints, amplitudeHandles.axH_centroidTextObjects] = fnPlotAddCentroids(outputMaps, phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCentroidPoints, phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCellROILabels);
            
            axes(freqHandles.axes(i));
            freqHandles.tempImH = imshow(temp.currPreferredStimulusFrequency, frequencyColorMap, 'Parent', freqHandles.axes(i));
            if phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria
                set(freqHandles.tempImH, 'AlphaData', amalgamationMasks.AlphaRoiTuningScoreMask);
            else
                set(freqHandles.tempImH, 'AlphaData', amalgamationMasks.AlphaConjunctionMask);
            end
            title(freqHandles.axes(i), 'Frequency Tuning')
            fnAddSimpleLegend(uniqueFreqLabels, frequencyColorMap);
            [freqHandles.axH_centroidPoints, freqHandles.axH_centroidTextObjects] = fnPlotAddCentroids(outputMaps, phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCentroidPoints, phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.shouldDrawCellROILabels);
            
            ylabel(amplitudeHandles.axes(i), sprintf('Session[%d]', i),...
                'FontSize', 18,...
                'FontWeight','bold',...
                'Interpreter','none');
        end
        
        sgtitle('Spatial Tuning Analysis')
    end

    % fnAddCustomDataCursor: adds a custom datacursor to the figure
    function [dcm] = fnAddCustomDataCursor(figH, slider_controller)
        dcm = datacursormode(figH);
        dcm.Enable = 'on';
        dcm.DisplayStyle = 'window';
        if exist('slider_controller','var')
            dcm.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks, outputMaps, slider_controller));
        else
            dcm.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks, outputMaps));
        end

    end


    %% Draws the centroid (center) points and text label
    function [axH_centroidPoints, axH_centroidTextObjects] = fnPlotAddCentroids(outputMaps, shouldDrawCentroidPoints, shouldDrawCellROILabels)
        % Requirements: amalgamationMasks
        if shouldDrawCentroidPoints
            hold on
            axH_centroidPoints = plot(outputMaps.computedProperties.centroids(:,1), outputMaps.computedProperties.centroids(:,2),'.r',...
                'PickableParts','none',...
                'Tag','centroidPoints'); % Hides from the legend
            axH_centroidPoints.Annotation.LegendInformation.IconDisplayStyle = 'off';
            
            if shouldDrawCellROILabels
                numCentroids = size(outputMaps.computedProperties.centroids,1);
                %                axH_centroidTextObjects = zeros([numCentroids, 1],typename
                for i = 1:numCentroids
                    x = outputMaps.computedProperties.centroids(i,1);
                    y = outputMaps.computedProperties.centroids(i,2);
                    cellROI = amalgamationMasks.cellROI_LookupMask(round(y), round(x));
                    textLabel = sprintf('%d', cellROI);
                    axH_centroidTextObjects(i) = text(x, y, textLabel, 'Color', 'r',...
                        'FontSize', 10,...
                        'FontSmoothing', 'on',...
                        'HorizontalAlignment','center',...
                        'PickableParts','none',...
                        'Interpreter','none',...
                        'Tag','centroidTexts');
                    % When you click on a line, set the marker of just the line you clicked on.
%                     set(axH_centroidTextObjects(i), 'ButtonDownFcn', @(src, evt) set(src, 'Color', 'g' ) );
                end % end for numCentroids
            else
                axH_centroidTextObjects = []; % empty array
            end
            hold off
        else
            axH_centroidPoints = []; % empty array
            axH_centroidTextObjects = []; % empty array
        end
    end





end



function figH_numDaysCriteria = fnPlotNumberOfDaysCriteriaFigure(amalgamationMasks, componentAggregatePropeties)
    figH_numDaysCriteria = createFigureWithNameIfNeeded('CellROI Aggregate: Number of Days Meeting Criteria');
    clf(figH_numDaysCriteria);
    tempImH = fnPhoMatrixPlot(amalgamationMasks.NumberOfTunedDays);
    xticks([])
    yticks([])
    set(tempImH, 'AlphaData', amalgamationMasks.AlphaConjunctionMask);
    title('number of days meeting tuning criteria for each cellRoi');
    uniqueNumberOfTunedDaysLabels = strcat(num2str(unique(componentAggregatePropeties.tuningScore)),{' days'});
    curr_color_map = colormap(jet(length(uniqueNumberOfTunedDaysLabels)));
    colorbar('off')
    fnAddSimpleLegend(uniqueNumberOfTunedDaysLabels, curr_color_map);
end

%% Custom ToolTip callback function that displays the clicked cell ROI as well as the x,y position.
function txt = displayCoordinates(figH, info, amalgamationMasks, outputMaps, activeSliderController)
    x = info.Position(1);
    y = info.Position(2);
    cellROI = amalgamationMasks.cellROI_LookupMask(y, x);
    cellROIString = '';
    if cellROI > 0
        cellROIString = num2str(cellROI);
    else
        cellROIString = 'None';
    end
    
    cellROI_PreferredStimulusMatrix = squeeze(outputMaps.PreferredStimulus(cellROI,:,:));
    disp(cellROI_PreferredStimulusMatrix);
    % 3 sessions x [preferredAmp, preferredFreq]
%     numSessions = size(cellROI_PreferredStimulusMatrix, 1);
%     
%     for i = 1:numSessions
%         preferredAmpFreq = cellROI_PreferredStimulusMatrix(i,:);
%         
%         
%     end
        
    
    txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];

    txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];
    
    
    fprintf('selected cellROI: %d...\n', cellROI);

    if exist('activeSliderController','var')
        fprintf('updating activeSliderController programmatically to value %d...\n', cellROI);
        activeSliderController.controller.Slider.Value = cellROI;
    end
end
    

