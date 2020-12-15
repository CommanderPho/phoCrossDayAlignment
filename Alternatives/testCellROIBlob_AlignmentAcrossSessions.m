%% testCellROIBlob_AlignmentAcrossSessions.m
% Using this, I've confirmed that the cellROIs are identical for all three sessions.

% result = fnTestCellROIBlob_AlignmentAcrossSessions(cellRoiSortIndex, multiSessionCellRoi_CompListIndicies, compMasks);

curr_roiIndex = 5;
result = fnTestCellROIIntensity_AlignmentAcrossSessions(final_data_explorer_obj, curr_roiIndex);

% final_data_explorer_obj.getFillRoiMask(1);
% imshow(final_data_explorer_obj.getEdgeOffsetRoiMasks(0, 1));

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


function result = fnTestCellROIIntensity_AlignmentAcrossSessions(final_data_explorer_obj, curr_roiIndex, plotting_options)
    %% fnTestCellROIIntensity_AlignmentAcrossSessions: loads the exported session max intensity tifs from disk
    
    if ~exist('plotting_options','var')
        plotting_options.not_provided = true;
    end
    
    if ~isfield(plotting_options, 'should_use_custom_subplots')
        plotting_options.should_use_custom_subplots = true;
    end

    % Options for tightening up the subplots:
    if plotting_options.should_use_custom_subplots
        plotting_options.subtightplot.gap = [0.01 0.01]; % [intra_graph_vertical_spacing, intra_graph_horizontal_spacing]
        plotting_options.subtightplot.width_h = [0.01 0.01]; % Looks like [padding_bottom, padding_top]
        plotting_options.subtightplot.width_w = [0.001 0.001];

        plotting_options.opt = {plotting_options.subtightplot.gap, plotting_options.subtightplot.width_h, plotting_options.subtightplot.width_w}; % {gap, width_h, width_w}
        subplot_cmd = @(m,n,p) subtightplot(m, n, p, plotting_options.opt{:});
    else
        subplot_cmd = @(m,n,p) subplot(m, n, p);
    end
    
    exported_sessions_path = '/Users/pho/Dropbox/Classes/Fall 2020/PIBS 600 - Rotations/Rotation_2_Pierre Apostolides Lab/data/reg_tif_aggregates/session_level';
    [result.imds, result.registered_imageInfo] = fnLoadTifFolderToDatastore(exported_sessions_path);
    result.imageFrames = readall(result.imds.registered);
    
    curr_roiFillMask = logical(final_data_explorer_obj.getFillRoiMask(curr_roiIndex));
    curr_roiEdgeMask = logical(final_data_explorer_obj.getEdgeOffsetRoiMasks(0, curr_roiIndex));
    
    if ~isfield(plotting_options, 'background_opacity')
        plotting_options.background_opacity = 0.95;
    end
    
    curr_roiMaxIntensities = ones([length(result.imageFrames), 512, 512]) .* plotting_options.background_opacity;
    
    % Set for the first session
    curr_roiMaxIntensities(1, curr_roiFillMask) = result.imageFrames{1}(curr_roiFillMask);
    
    for sessionIndex = 2:length(result.imageFrames)
       prev_sessionIndex = sessionIndex - 1;
       prev_frame = result.imageFrames{prev_sessionIndex};
       curr_frame = result.imageFrames{sessionIndex};
       
       % Do this for the previous session:
       curr_roiMaxIntensities(sessionIndex, curr_roiFillMask) = curr_frame(curr_roiFillMask);

       %% Draw the highlight on the image for comparison:
%        figure(sessionIndex-1);
%        imshowpair(prev_frame, curr_frame, 'falsecolor')
       
    end
    
    numMasks = size(curr_roiMaxIntensities, 1);
    maskSize = [size(curr_roiMaxIntensities, 2) size(curr_roiMaxIntensities, 3)]; % All masks should be the same size
    
    conjunction_min = squeeze(min(curr_roiMaxIntensities,[],1));

    %% Build Figure
    result.figH = figure(4);
    clf(result.figH);
    
    for sessionIndex = 1:length(result.imageFrames)
        result.axes(sessionIndex) = subplot_cmd(1,3,sessionIndex);
        result.tempImH = imshow(result.imageFrames{sessionIndex}, 'Parent', result.axes(sessionIndex));
        set(result.tempImH, 'AlphaData', squeeze(curr_roiMaxIntensities(sessionIndex,:,:)));
        
%         fnPhoMatrixPlot
%         result.tempImH = imshow(squeeze(curr_roiMaxIntensities(sessionIndex,:,:)), 'Parent', result.axes(sessionIndex));
%         set(result.tempImH, 'AlphaData', curr_roiFillMask);

        hold on;
        
        % Overlay the edge:
%         result.tempEdgeImH = imshow(curr_roiEdgeMask, 'Parent', result.axes(sessionIndex));
%         set(result.tempEdgeImH, 'AlphaData', curr_roiEdgeMask);
        
        % Make a truecolor all-green image. 
        green = cat(3, zeros(size(curr_roiEdgeMask)), ones(size(curr_roiEdgeMask)), zeros(size(curr_roiEdgeMask))); 
        hold on 
        h = imshow(green, 'Parent', result.axes(sessionIndex)); 
        hold off 
        set(h, 'AlphaData', curr_roiEdgeMask)
        
        

        title(result.axes(sessionIndex), sprintf('Session %d', sessionIndex))
    end 
    sgtitle('Sessions')
            
end

function result = fnTestCellROIBlob_AlignmentAcrossSessions(cellRoiSortIndex, multiSessionCellRoi_CompListIndicies, compMasks)
    %% fnTestCellROIBlob_AlignmentAcrossSessions: performs an item-by-item comparison of the roi masks between sessions to determine if there are any changes.
    num_cellROIs = length(cellRoiSortIndex);
    numSessions = size(multiSessionCellRoi_CompListIndicies,2);
    numDifferences = numSessions-1;
    result.diffMasks = zeros([num_cellROIs, numDifferences, 512, 512]);
    result.diffMaskChangeCounts = zeros([num_cellROIs, numDifferences]);
    result.totalDifferences = zeros([num_cellROIs 1]);

    for i = 1:num_cellROIs
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




function [results] = fnAnalyzeOverlapBetweenMasks(masksMatrix)
    % masksMatrix: a i * n * m matrix
    numMasks = size(masksMatrix, 1);
    maskSize = [size(masksMatrix, 2) size(masksMatrix, 3)]; % All masks should be the same size
    
    conjunction_min = min(masksMatrix,[],1);

end