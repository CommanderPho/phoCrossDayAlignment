% Pho Load Final Data Struct: Pipeline Stage 7
% Pho Hale, November 19, 2020
% Builds relations been each cells spatial location and their tuning.

session_mats = {'/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200117/20200117_anm265.mat',...
    '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200120/20200120_anm265.mat',...
    '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/ToLoad/anm265/20200124/20200124_anm265.mat'};


% SessionMat = load(session_mats{1});

%     imshow(activeAnimalDataStruct.session_20200117.imgData.comp1.segmentLabelMatrix)

% componentAggregatePropeties.maxTuningPeakValue

% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);
% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);
% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);
% cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);


amalgamationMask = zeros(512, 512);

for i = 1:length(uniqueComps)
    %% Plot the grid as a test
    temp.cellRoiIndex = cellRoiSortIndex(i);
    temp.currAllSessionCompIndicies = multiSessionCellRoiCompIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    temp.firstCompSessionIndex = temp.currAllSessionCompIndicies(1);
    
    temp.currRoiTuningScore = componentAggregatePropeties.tuningScore(temp.cellRoiIndex);
    temp.firstCompSessionMask = logical(squeeze(finalOutComponentSegmentMasks(temp.firstCompSessionIndex,:,:)));

    % Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
    if temp.currRoiTuningScore > 0
        amalgamationMask(temp.firstCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;
    else
        amalgamationMask(temp.firstCompSessionMask) = -1.0;
    end
    
%     figure;
%     imshow(temp.firstCompSessionMask);
% %     fnPhoMatrixPlot(temp.firstCompSessionMask);
%     title(sprintf('Mask cellRoi[%d]', temp.cellRoiIndex));
%     
    
    
end


fnPhoMatrixPlot(amalgamationMask);
title('number of days meeting tuning criteria for each cellRoi');

