% Pho Load Final Data Struct: Pipeline Stage 7
% Pho Hale, November 19, 2020
% Builds relations been each cells spatial location and their tuning.

session_mats = {'/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200117/20200117_anm265.mat',...
    '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200120/20200120_anm265.mat',...
    '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200124/20200124_anm265.mat'};

uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');

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
    
%     [temp.rgbFirstCompSessionMask] = gray2rgb(temp.firstCompSessionMask);

    % Get color for each:
%     temp.maxPrefAmpVal

    amalgamationMask_AlphaConjunctionMask(temp.firstCompSessionMask) = 1;
    
%     amalgamationMask_PreferredStimulusAmplitude(temp.rgbFirstCompSessionMask) = [1.0 0.0 1.0]';
    
    amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask) = double(temp.maxPrefAmpIndex);

    amalgamationMask_PreferredStimulusFreq(temp.firstCompSessionMask) = double(temp.maxPrefFreqIndex);
    
%     amalgamationMask_PreferredStimulusAmplitude(temp.rgbFirstCompSessionMask) = amplitudeColorMap(temp.maxPrefAmpIndex,:);
% 
%     % Mask the image using bsxfun() function
%     maskedRgbImage = bsxfun(@times, amalgamationMask_PreferredStimulusAmplitude, cast(mask, 'like', amalgamationMask_PreferredStimulusAmplitude));
% 
%     amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask, 1) = amplitudeColorMap(temp.maxPrefAmpIndex,1);
%     amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask, 2) = amplitudeColorMap(temp.maxPrefAmpIndex,2);
%     amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask, 3) = amplitudeColorMap(temp.maxPrefAmpIndex,3);
%     mask3 = cat(3, mask, mask, mask);
    
%     amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask, 1) = amplitudeColorMap(temp.maxPrefAmpIndex,1);
%     amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask, 2) = amplitudeColorMap(temp.maxPrefAmpIndex,2);
%     amalgamationMask_PreferredStimulusAmplitude(temp.firstCompSessionMask, 3) = amplitudeColorMap(temp.maxPrefAmpIndex,3);
   
%     figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
%     clf(figH);
    
    % Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
    if temp.currRoiTuningScore > 0
        amalgamationMask_NumberOfTunedDays(temp.firstCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;
    else
        amalgamationMask_NumberOfTunedDays(temp.firstCompSessionMask) = -1.0;
    end
    
%     figure;
%     imshow(temp.firstCompSessionMask);
% %     fnPhoMatrixPlot(temp.firstCompSessionMask);
%     title(sprintf('Mask cellRoi[%d]', temp.cellRoiIndex));
%     
    
    
end

% fnPhoMatrixPlot(amalgamationMask_NumberOfTunedDays);
% title('number of days meeting tuning criteria for each cellRoi');

figure(1338)
subplot(1,2,1)
tempImH = imshow(amalgamationMask_PreferredStimulusAmplitude, amplitudeColorMap);
set(tempImH, 'AlphaData', amalgamationMask_AlphaConjunctionMask);
title('Amplitude Tuning')

subplot(1,2,2)
tempImH = imshow(amalgamationMask_PreferredStimulusFreq, frequencyColorMap);
set(tempImH, 'AlphaData', amalgamationMask_AlphaConjunctionMask);
title('Frequency Tuning')





function [rgbImage] = gray2rgb(grayscaleImage)
%GRAY2RGB Inverse of rgb2gray. Takes a grayscale image and returns an RGB representation of that grayscale (obviously not colorizing it or anything).
%   Visually the image is unchanged by this operation
	rgbImage = cat(3, grayscaleImage, grayscaleImage, grayscaleImage);
end

