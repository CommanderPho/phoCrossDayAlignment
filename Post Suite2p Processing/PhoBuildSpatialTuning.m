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

% [amalgamationMasks, outputMaps, cellRoiSortIndex] = fnBuildSpatialTuningInfo(num_cellROIs, numOfSessions, multiSessionCellRoi_CompListIndicies, finalOutComponentSegment, componentAggregatePropeties, phoPipelineOptions);
[amalgamationMasks, outputMaps] = final_data_explorer_obj.buildSpatialTuningInfo(phoPipelineOptions);


if phoPipelineOptions.shouldShowPlots
    [figH_numDaysCriteria, figH_roiTuningPreferredStimulus, final_data_explorer_obj] = fnPlotPhoBuildSpatialTuningFigures(uniqueAmps, uniqueFreqs, final_data_explorer_obj, final_data_explorer_obj.componentAggregatePropeties, amalgamationMasks, outputMaps, phoPipelineOptions);
    
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



%% Master Plotting Function
function [figH_numDaysCriteria, figH_roiTuningPreferredStimulus, final_data_explorer_obj] = fnPlotPhoBuildSpatialTuningFigures(uniqueAmps, uniqueFreqs, final_data_explorer_obj, componentAggregatePropeties, amalgamationMasks, outputMaps, phoPipelineOptions)
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
        temp.currPreferredStimulusAmplitude = squeeze(sum(amalgamationMasks.PreferredStimulusAmplitude, 1));
        temp.currPreferredStimulusFrequency = squeeze(sum(amalgamationMasks.PreferredStimulusFreq, 1));

        %Preferred Stimulus Figure:
        [figH_roiTuningPreferredStimulus, amplitudeHandles, freqHandles] = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks, outputMaps, temp.currPreferredStimulusAmplitude, temp.currPreferredStimulusFrequency);
    else
        % Can only plot a single session, such as j=1:
%         j = 1;
        j = 1:3;
        temp.currPreferredStimulusAmplitude = squeeze(amalgamationMasks.PreferredStimulusAmplitude(j,:,:));
        temp.currPreferredStimulusFrequency = squeeze(amalgamationMasks.PreferredStimulusFreq(j,:,:));

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
            dcm.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks, outputMaps, final_data_explorer_obj, slider_controller));
        else
            dcm.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks, outputMaps, final_data_explorer_obj));
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
function txt = displayCoordinates(figH, info, amalgamationMasks, outputMaps, final_data_explorer_obj, activeSliderController)
    x = info.Position(1);
    y = info.Position(2);
    cellROI = amalgamationMasks.cellROI_LookupMask(y, x); % Figure out explicitly what index type is assigned here.
    
    cellROIString = '';
    if cellROI > 0
        fprintf('selected cellROI: %d...\n', cellROI);
        cellROIString = num2str(cellROI);
        cellROI_PreferredLinearStimulusIndicies = squeeze(outputMaps.PreferredStimulus_LinearStimulusIndex(cellROI,:)); % These are the linear stimulus indicies for this all sessions of this datapoint.
%         disp(cellROI_PreferredLinearStimulusIndicies);

        cellROI_PreferredAmpsFreqsIndicies = final_data_explorer_obj.stimuli_mapper.indexMap_StimulusLinear2AmpsFreqsArray(cellROI_PreferredLinearStimulusIndicies',:);
%         disp(cellROI_PreferredAmpsFreqsIndicies);

        cellROI_PreferredAmps = final_data_explorer_obj.uniqueAmps(cellROI_PreferredAmpsFreqsIndicies(:,1));
        cellROI_PreferredFreqs = final_data_explorer_obj.uniqueFreqs(cellROI_PreferredAmpsFreqsIndicies(:,2));

%         disp(num2str(cellROI_PreferredAmps'));
        
        cellROI_PreferredAmpsFreqsValues = [cellROI_PreferredAmps, cellROI_PreferredFreqs];
        disp(cellROI_PreferredAmpsFreqsValues);

    %     cellROI_PreferredStimulusMatrix = squeeze(outputMaps.PreferredStimulus(cellROI,:,:));
    %     disp(cellROI_PreferredStimulusMatrix);
        % 3 sessions x [preferredAmp, preferredFreq]
    %     numSessions = size(cellROI_PreferredStimulusMatrix, 1);
    %     
    %     for i = 1:numSessions
    %         preferredAmpFreq = cellROI_PreferredStimulusMatrix(i,:);
    %         
    %         
    %     end

        txt = {['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString], ['prefAmps: ' num2str(cellROI_PreferredAmps')], ['prefFreqs: ' num2str(cellROI_PreferredFreqs')]};
%         txt = [txt '\n prefAmps: ' num2str(cellROI_PreferredAmps)];
        
    else
        fprintf('selected no cells.\n');
        cellROIString = 'None';
        txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];
    end

    
    
    if exist('activeSliderController','var')
        fprintf('updating activeSliderController programmatically to value %d...\n', cellROI);
        activeSliderController.controller.Slider.Value = cellROI;
    end
end
    

