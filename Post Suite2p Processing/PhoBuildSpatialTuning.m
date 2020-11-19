% Pho Load Final Data Struct: Pipeline Stage 7
% Pho Hale, November 19, 2020
% Builds relations been each cells spatial location and their tuning.

session_mats = {'/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200117/20200117_anm265.mat',...
    '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200120/20200120_anm265.mat',...
    '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200124/20200124_anm265.mat'};

uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');
uniqueNumberOfTunedDaysLabels = strcat(num2str(unique(componentAggregatePropeties.tuningScore)),{' days'});

%specify colormaps for your figure. This is important!!
amplitudeColorMap = winter(numel(uniqueAmps));
frequencyColorMap = spring(numel(uniqueFreqs));

% SessionMat = load(session_mats{1});

%     imshow(activeAnimalDataStruct.session_20200117.imgData.comp1.segmentLabelMatrix)

% componentAggregatePropeties.maxTuningPeakValue

% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);
% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);
% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);
% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);
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
    temp.currMaximalIndexTuple = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqIndexTuple;
    temp.maxPrefAmpIndex = temp.currMaximalIndexTuple(1);
    temp.maxPrefFreqIndex = temp.currMaximalIndexTuple(2);
    
%     temp.maxPrefAmpVal, temp.maxPrefFreqVal = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqValuesTuple;
    
    temp.currRoiTuningScore = componentAggregatePropeties.tuningScore(temp.cellRoiIndex);
    temp.firstCompSessionMask = logical(squeeze(finalOutComponentSegmentMasks(temp.firstCompSessionIndex,:,:)));

    % Set cells in this cellROI region to opaque:
    amalgamationMask_AlphaConjunctionMask(temp.firstCompSessionMask) = 1.0;
    % Set the opacity of cell in this cellROI region based on the number of days that the cell passed the threshold:
    amalgamationMask_AlphaRoiTuningScoreMask(temp.firstCompSessionMask) = (double(temp.currRoiTuningScore) / 3.0);

    amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask) = double(temp.maxPrefAmpIndex);

    amalgamationMask_PreferredStimulusFreq(temp.firstCompSessionMask) = double(temp.maxPrefFreqIndex);
    
%     figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
%     clf(figH);
    
    % Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
%     if temp.currRoiTuningScore > 0
        amalgamationMask_NumberOfTunedDays(temp.firstCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;
%     else
%         amalgamationMask_NumberOfTunedDays(temp.firstCompSessionMask) = -1.0;
%     end
    
%     figure;
%     imshow(temp.firstCompSessionMask);
% %     fnPhoMatrixPlot(temp.firstCompSessionMask);
%     title(sprintf('Mask cellRoi[%d]', temp.cellRoiIndex));
%     
    
    
end

figure(1337)
tempImH = fnPhoMatrixPlot(amalgamationMask_NumberOfTunedDays);
xticks([])
yticks([])
set(tempImH, 'AlphaData', amalgamationMask_AlphaConjunctionMask);
title('number of days meeting tuning criteria for each cellRoi');
% c = colormap('jet');
curr_color_map = colormap(jet(length(uniqueNumberOfTunedDaysLabels)));
colorbar('off')
% curr_color_map = colormap(tempImH,default);
simpleLegend(uniqueNumberOfTunedDaysLabels, curr_color_map);


figure(1338)
subplot(1,2,1)
tempImH = imshow(amalgamationMask_PreferredStimulusAmplitude, amplitudeColorMap);
set(tempImH, 'AlphaData', amalgamationMask_AlphaRoiTuningScoreMask);
title('Amplitude Tuning')
simpleLegend(uniqueAmpLabels, amplitudeColorMap)

subplot(1,2,2)
tempImH = imshow(amalgamationMask_PreferredStimulusFreq, frequencyColorMap);
set(tempImH, 'AlphaData', amalgamationMask_AlphaRoiTuningScoreMask);
title('Frequency Tuning')
simpleLegend(uniqueFreqLabels, frequencyColorMap)

sgtitle('Spatial Tuning Analysis')



function simpleLegend(legendStrings, legendColorMap)
    hold on;

    h = zeros(length(legendStrings), 1);
    for i = 1:length(legendStrings)
        h(i) = plot(NaN,NaN,'Color', legendColorMap(i,:));
    end
    
%     h(1) = plot(NaN,NaN,'or');
%     h(2) = plot(NaN,NaN,'ob');
%     h(3) = plot(NaN,NaN,'ok');
%     legend(h, 'red','blue','black');
    legend(h, legendStrings);

end

function [rgbImage] = gray2rgb(grayscaleImage)
%GRAY2RGB Inverse of rgb2gray. Takes a grayscale image and returns an RGB representation of that grayscale (obviously not colorizing it or anything).
%   Visually the image is unchanged by this operation
	rgbImage = cat(3, grayscaleImage, grayscaleImage, grayscaleImage);
end

