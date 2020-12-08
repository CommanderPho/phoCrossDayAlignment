%% testCellROIBlob_AlignmentAcrossSessions.m
% Using this, I've confirmed that the cellROIs are identical for all three sessions.

result = fnTestCellROIBlob_AlignmentAcrossSessions(cellRoiSortIndex, multiSessionCellRoi_CompListIndicies, compMasks);


% test.numDiffs = result.totalDifferences;
% test.totalDiffCounts = sum(result.totalDifferences,'all')

% test.cellRoiIndex = 1;
% test.currDiffMasks = squeeze(result.diffMasks(test.cellRoiIndex,:,:,:));
% sum(test.currDiffMasks(1,:,:),'all')
% sum(test.currDiffMasks(2,:,:),'all')
% 
% figure(1);
% imshow(squeeze(test.currDiffMasks(1,:,:)));
% 
% 
% h = imshowpair(A,B);


function result = fnTestCellROIBlob_AlignmentAcrossSessions(cellRoiSortIndex, multiSessionCellRoi_CompListIndicies, compMasks)
    num_cellROIs = length(cellRoiSortIndex);
    numSessions = size(multiSessionCellRoi_CompListIndicies,2);
    numDifferences = numSessions-1;
    result.diffMasks = zeros([num_cellROIs, numDifferences, 512, 512]);
    result.diffMaskChangeCounts = zeros([num_cellROIs, numDifferences]);
    result.totalDifferences = zeros([num_cellROIs 1]);

    for i = 1:num_cellROIs
        %% Plot the grid as a test
        temp.cellRoiIndex = cellRoiSortIndex(i);
        temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
        temp.cellROI_allSessionMasks = compMasks.Masks(temp.currAllSessionCompIndicies,:,:);
        temp.numSessions = length(temp.currAllSessionCompIndicies);
        temp.numDifferences = temp.numSessions-1;
%         temp.diffMasks = zeros([temp.numDifferences, size(temp.cellROI_allSessionMasks,2), size(temp.cellROI_allSessionMasks, 3)]);
        % Figure out the difference between the three masks for this session:
        for j = 1:temp.numDifferences
            maskA = squeeze(temp.cellROI_allSessionMasks(j,:,:));
            maskB = squeeze(temp.cellROI_allSessionMasks((j+1),:,:));
%             [temp.diffMasks(j,:,:)] = fnTestCellROIBlob_ComputeDifferenceBetweenTwoMasks(maskA, maskB);
            [result.diffMasks(i,j,:,:)] = fnTestCellROIBlob_ComputeDifferenceBetweenTwoMasks(maskA, maskB);
            result.diffMaskChangeCounts(i,j) = sum(result.diffMasks(i,j,:,:),'all');
        end
        result.totalDifferences(i) = sum(result.diffMaskChangeCounts(i,:),'all');
    end 
end


function [diffMask] = fnTestCellROIBlob_ComputeDifferenceBetweenTwoMasks(maskA, maskB)
    diffMask = imabsdiff(maskA, maskB);
end