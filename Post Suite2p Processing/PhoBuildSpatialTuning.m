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

%         if ~exist(phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path, 'dir')
%             error(['ERROR: The specified figure export directory ' phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path ' does not exist!']);
%         end
        
        while (~exist(phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path, 'dir'))
            warning(['WARNING: The specified figure export directory ' phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path ' does not exist!']);
            phoPipelineOptions.PhoBuildSpatialTuning.fig_export_parent_path = uigetdir(pwd, 'Select an export directory');     
        end
   end
end


% session_mats = {'/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200117/20200117_anm265.mat',...
%     '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200120/20200120_anm265.mat',...
%     '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200124/20200124_anm265.mat'};
% SessionMat = load(session_mats{1});


uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');
uniqueNumberOfTunedDaysLabels = strcat(num2str(unique(componentAggregatePropeties.tuningScore)),{' days'});

%specify colormaps for your figure. This is important!!
amplitudeColorMap = winter(numel(uniqueAmps));
frequencyColorMap = spring(numel(uniqueFreqs));

% Override with solid black for the (0,0) elements.
amplitudeColorMap(1,:) = [0, 0, 0];
frequencyColorMap(1,:) = [0, 0, 0];

% componentAggregatePropeties.maxTuningPeakValue

amalgamationMask_cellROI_LookupMask = zeros(512, 512); % Maps every pixel in the image to the cellROI index of the cell it belongs to, if one exists.

amalgamationMask_AlphaConjunctionMask = zeros(512, 512);
amalgamationMask_AlphaRoiTuningScoreMask = zeros(512, 512);
amalgamationMask_NumberOfTunedDays = zeros(512, 512);

% amalgamationMask_PreferredStimulusAmplitude = zeros(512, 512, 3);
% init_matrix = zeros(512, 512);
init_matrix = ones(512, 512) * -1;

amalgamationMask_PreferredStimulusAmplitude = init_matrix;
amalgamationMask_PreferredStimulusFreq = init_matrix;

for i = 1:length(uniqueComps)
    %% Plot the grid as a test
    temp.cellRoiIndex = cellRoiSortIndex(i);
    temp.currAllSessionCompIndicies = multiSessionCellRoiCompIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    temp.firstCompSessionIndex = temp.currAllSessionCompIndicies(1);
    
    % Currently just use the preferred stimulus info from the first of the three sessions:
    temp.currCompMaximallyPreferredStimulusInfo = componentAggregatePropeties.maximallyPreferredStimulusInfo(temp.firstCompSessionIndex);
    temp.currMaximalIndexTuple = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqIndexTuple; %Check this to make sure it's always (0, 0) when one of the tuple elements are zero.
    temp.maxPrefAmpIndex = temp.currMaximalIndexTuple(1);
    temp.maxPrefFreqIndex = temp.currMaximalIndexTuple(2);
    
%     temp.maxPrefAmpVal, temp.maxPrefFreqVal = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqValuesTuple;
    
    temp.currRoiTuningScore = componentAggregatePropeties.tuningScore(temp.cellRoiIndex);
    temp.firstCompSessionMask = logical(squeeze(finalOutComponentSegmentMasks(temp.firstCompSessionIndex,:,:)));

    % Save the index of this cell in the reverse lookup table:
    amalgamationMask_cellROI_LookupMask(temp.firstCompSessionMask) = temp.cellRoiIndex;
    
    
    % Set cells in this cellROI region to opaque:
    amalgamationMask_AlphaConjunctionMask(temp.firstCompSessionMask) = 1.0;
    % Set the opacity of cell in this cellROI region based on the number of days that the cell passed the threshold:
    amalgamationMask_AlphaRoiTuningScoreMask(temp.firstCompSessionMask) = (double(temp.currRoiTuningScore) / 3.0);

    amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask) = double(temp.maxPrefAmpIndex);

    amalgamationMask_PreferredStimulusFreq(temp.firstCompSessionMask) = double(temp.maxPrefFreqIndex);
    
    % Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
%     if temp.currRoiTuningScore > 0
        amalgamationMask_NumberOfTunedDays(temp.firstCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;
%     else
%         amalgamationMask_NumberOfTunedDays(temp.firstCompSessionMask) = -1.0;
%     end
    
    
    
end

if phoPipelineOptions.shouldShowPlots
%     figH_numDaysCriteria = figure(1337);
%     figH_numDaysCriteria = figure('Name','CellROI Aggregate: Number of Days Meeting Criteria','NumberTitle','off');
    figH_numDaysCriteria = createFigureWithNameIfNeeded('CellROI Aggregate: Number of Days Meeting Criteria');
    
    
    tempImH = fnPhoMatrixPlot(amalgamationMask_NumberOfTunedDays);
    xticks([])
    yticks([])
    set(tempImH, 'AlphaData', amalgamationMask_AlphaConjunctionMask);
    title('number of days meeting tuning criteria for each cellRoi');
    % c = colormap('jet');
    curr_color_map = colormap(jet(length(uniqueNumberOfTunedDaysLabels)));
    colorbar('off')
    % curr_color_map = colormap(tempImH,default);
    fnAddSimpleLegend(uniqueNumberOfTunedDaysLabels, curr_color_map);


%     figH_roiTuningPreferredStimulus = figure(1338);
%     figH_roiTuningPreferredStimulus = figure('Name','CellROI Aggregate: Preferred Stimulus Tuning','NumberTitle','off');
    figH_roiTuningPreferredStimulus = createFigureWithNameIfNeeded('CellROI Aggregate: Preferred Stimulus Tuning');
    
    
    subplot(1,2,1)
    tempImH = imshow(amalgamationMask_PreferredStimulusAmplitude, amplitudeColorMap);
    if phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria
        set(tempImH, 'AlphaData', amalgamationMask_AlphaRoiTuningScoreMask);
    else
        set(tempImH, 'AlphaData', amalgamationMask_AlphaConjunctionMask);
    end
    title('Amplitude Tuning')
    fnAddSimpleLegend(uniqueAmpLabels, amplitudeColorMap)

    subplot(1,2,2)
    tempImH = imshow(amalgamationMask_PreferredStimulusFreq, frequencyColorMap);
    if phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.opacityWeightedByDaysMeetingCriteria
        set(tempImH, 'AlphaData', amalgamationMask_AlphaRoiTuningScoreMask);
    else
        set(tempImH, 'AlphaData', amalgamationMask_AlphaConjunctionMask);
    end
    title('Frequency Tuning')
    fnAddSimpleLegend(uniqueFreqLabels, frequencyColorMap)

    sgtitle('Spatial Tuning Analysis')
    
    %% Custom Tooltips:
    dcm = datacursormode;
    dcm.Enable = 'on';
    dcm.DisplayStyle = 'window';
    dcm.UpdateFcn = @(figH, info) (displayCoordinates(figH, info, amalgamationMask_cellROI_LookupMask));



    
    
    
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


function figH = createFigureWithNameIfNeeded(name)
    figHPotential = findobj( 'Type', 'Figure', 'Name', name);
    if isempty(figHPotential)
       figH = figure('Name',name,'NumberTitle','off'); % Make a new figure
    else
        % Use existing figure
        figH = figHPotential;
        figure(figH); % Make it active.
    end

end

%% Custom ToolTip callback function that displays the clicked cell ROI as well as the x,y position.
function txt = displayCoordinates(~, info, amalgamationMask_cellROI_LookupMask)
    x = info.Position(1);
    y = info.Position(2);
    cellROI = amalgamationMask_cellROI_LookupMask(y, x);
    cellROIString = '';
    if cellROI > 0
        cellROIString = num2str(cellROI);
    else
        cellROIString = 'None';
    end
    txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];
end


