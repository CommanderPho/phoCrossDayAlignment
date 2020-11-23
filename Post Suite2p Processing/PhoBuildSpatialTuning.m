% Pho Load Final Data Struct: Pipeline Stage 7
% Pho Hale, November 19, 2020
% Builds relations been each cells spatial location and their tuning.

fprintf('> Running PhoBuildSpatialTuning...\n');

%% Options:
% Uses:
%   phoPipelineOptions.shouldSaveFiguresToDisk
%   phoPipelineOptions.shouldShowPlots
%   phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path

if ~exist('phoPipelineOptions','var')
    warning('phoPipelineOptions is missing! Using defaults specified in PhoBuildSpatialTuning.m')
    phoPipelineOptions.shouldSaveFiguresToDisk = true;
    phoPipelineOptions.shouldShowPlots = true;
    %%% PhoBuildSpatialTuning Options:
    phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = '';
    phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria = false; % If true, the cell region will be rendered with an opacity proporitional to the number of days it met the threshold critiera
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





% componentAggregatePropeties.maxTuningPeakValue

amalgamationMasks.cellROI_LookupMask = zeros(512, 512); % Maps every pixel in the image to the cellROI index of the cell it belongs to, if one exists.

amalgamationMasks.AlphaConjunctionMask = zeros(512, 512);
amalgamationMasks.AlphaRoiTuningScoreMask = zeros(512, 512);
amalgamationMasks.NumberOfTunedDays = zeros(512, 512);

% amalgamationMasks.PreferredStimulusAmplitude = zeros(512, 512, 3);
% init_matrix = zeros(512, 512);
init_matrix = ones(numOfSessions, 512, 512) * -1;

amalgamationMasks.PreferredStimulusAmplitude = init_matrix;
amalgamationMasks.PreferredStimulusFreq = init_matrix;

% amalgamationMasks.DidPreferredStimulusChange: keeps track of whether the preferredStimulus amplitude or frequency changed for a cellROI between sessions.
amalgamationMasks.DidPreferredStimulusChange = zeros(num_cellROIs, (numOfSessions-1));

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
            temp.currCompSessionMask = logical(squeeze(finalOutComponentSegment.Masks(temp.currCompSessionIndex,:,:)));
            % Save the index of this cell in the reverse lookup table:
            amalgamationMasks.cellROI_LookupMask(temp.currCompSessionMask) = temp.cellRoiIndex;

            % Set cells in this cellROI region to opaque:
            amalgamationMasks.AlphaConjunctionMask(temp.currCompSessionMask) = 1.0;
            % Set the opacity of cell in this cellROI region based on the number of days that the cell passed the threshold:
            amalgamationMasks.AlphaRoiTuningScoreMask(temp.currCompSessionMask) = (double(temp.currRoiTuningScore) / 3.0);

            % Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
            amalgamationMasks.NumberOfTunedDays(temp.currCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;

        end
        
        % Currently just use the preferred stimulus info from the first of the three sessions:
        temp.currCompMaximallyPreferredStimulusInfo = componentAggregatePropeties.maximallyPreferredStimulusInfo(temp.currCompSessionIndex);
        temp.currMaximalIndexTuple = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqIndexTuple; %Check this to make sure it's always (0, 0) when one of the tuple elements are zero.
        temp.maxPrefAmpIndex = temp.currMaximalIndexTuple(1);
        temp.maxPrefFreqIndex = temp.currMaximalIndexTuple(2);

        amalgamationMasks.PreferredStimulusAmplitude(j, temp.currCompSessionMask) = double(temp.maxPrefAmpIndex);
        amalgamationMasks.PreferredStimulusFreq(j, temp.currCompSessionMask) = double(temp.maxPrefFreqIndex);
            
        % If we're not on the first session, see if the preferred values changed between the sessions.
        if j > 1
            didPreferAmpIndexChange = (temp.prev.maxPrefAmpIndex ~= temp.maxPrefAmpIndex);
            didPreferFreqIndexChange = (temp.prev.maxPrefFreqIndex ~= temp.maxPrefFreqIndex);
            amalgamationMasks.DidPreferredStimulusChange(i,j-1) = didPreferAmpIndexChange | didPreferFreqIndexChange;
        end
        % Update the prev values:
        temp.prev.maxPrefAmpIndex = temp.maxPrefAmpIndex;
        temp.prev.maxPrefFreqIndex = temp.maxPrefFreqIndex;

    end
    
end

if phoPipelineOptions.shouldShowPlots
    [figH_numDaysCriteria, figH_roiTuningPreferredStimulus] = fnPlotPhoBuildSpatialTuningFigures(uniqueAmps, uniqueFreqs, componentAggregatePropeties, amalgamationMasks, phoPipelineOptions);
    
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
function [figH_numDaysCriteria, figH_roiTuningPreferredStimulus] = fnPlotPhoBuildSpatialTuningFigures(uniqueAmps, uniqueFreqs, componentAggregatePropeties, amalgamationMasks, phoPipelineOptions)
    uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
    uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');
    %specify colormaps for your figure. This is important!!
    amplitudeColorMap = winter(numel(uniqueAmps));
    frequencyColorMap = spring(numel(uniqueFreqs));
    % Override with solid black for the (0,0) elements.
    amplitudeColorMap(1,:) = [0, 0, 0];
    frequencyColorMap(1,:) = [0, 0, 0];
    

    % Number of Days Meeting Criteria Figure:
    figH_numDaysCriteria = fnPlotNumberOfDaysCriteriaFigure(amalgamationMasks);

    %% Custom Tooltips:
    dcm_numDaysCriteria = datacursormode(figH_numDaysCriteria);
    dcm_numDaysCriteria.Enable = 'on';
    dcm_numDaysCriteria.DisplayStyle = 'window';
    if exist('slider_controller','var')
        dcm_numDaysCriteria.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks, slider_controller));
    else
        dcm_numDaysCriteria.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks));
    end
    
    
    
    j = 1;
    %Preferred Stimulus Figure:
    figH_roiTuningPreferredStimulus = createFigureWithNameIfNeeded('CellROI Aggregate: Preferred Stimulus Tuning');
    subplot(1,2,1)
    tempImH = imshow(squeeze(amalgamationMasks.PreferredStimulusAmplitude(j,:,:)), amplitudeColorMap);
    if phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria
        set(tempImH, 'AlphaData', amalgamationMasks.AlphaRoiTuningScoreMask);
    else
        set(tempImH, 'AlphaData', amalgamationMasks.AlphaConjunctionMask);
    end
    title('Amplitude Tuning')
    fnAddSimpleLegend(uniqueAmpLabels, amplitudeColorMap)

    subplot(1,2,2)
    tempImH = imshow(squeeze(amalgamationMasks.PreferredStimulusFreq(j,:,:)), frequencyColorMap);
    if phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria
        set(tempImH, 'AlphaData', amalgamationMasks.AlphaRoiTuningScoreMask);
    else
        set(tempImH, 'AlphaData', amalgamationMasks.AlphaConjunctionMask);
    end
    title('Frequency Tuning')
    fnAddSimpleLegend(uniqueFreqLabels, frequencyColorMap)

    sgtitle('Spatial Tuning Analysis')
    
    %% Custom Tooltips:
    dcm_roiTuningPreferredStimulus = datacursormode(figH_roiTuningPreferredStimulus);
    dcm_roiTuningPreferredStimulus.Enable = 'on';
    dcm_roiTuningPreferredStimulus.DisplayStyle = 'window';
    if exist('slider_controller','var')
        dcm_roiTuningPreferredStimulus.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks, slider_controller));
    else
        dcm_roiTuningPreferredStimulus.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMasks));
    end
    
    
    
    
    function figH_roiTuningPreferredStimulus = fnPlotROITuningPreferredStimulusFigure(amalgamationMasks)
        figH_numDaysCriteria = createFigureWithNameIfNeeded('CellROI Aggregate: Number of Days Meeting Criteria');
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


    
    
    function figH_numDaysCriteria = fnPlotNumberOfDaysCriteriaFigure(amalgamationMasks)
        figH_numDaysCriteria = createFigureWithNameIfNeeded('CellROI Aggregate: Number of Days Meeting Criteria');
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
    function txt = displayCoordinates(~, info, amalgamationMasks, activeSliderController)
        x = info.Position(1);
        y = info.Position(2);
        cellROI = amalgamationMasks.cellROI_LookupMask(y, x);
        cellROIString = '';
        if cellROI > 0
            cellROIString = num2str(cellROI);
        else
            cellROIString = 'None';
        end
        txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];

        if exist('activeSliderController','var')
           fprintf('updating activeSliderController programmatically to value %d...\n', cellROI);
           activeSliderController.controller.Slider.Value = cellROI;
        end 
    end

end
