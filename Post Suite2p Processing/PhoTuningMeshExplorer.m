% Pho Tuning Mesh Explorer: Pipeline Stage 6
% Pho Hale, November 18, 2020
% Uses the processed results of the previous pipeline stage to plot tuning curve information for the components.
% Plots 3D Mesh Surface.

fprintf('> Running PhoTuningMeshExplorer...\n');




%% Options:

% Uses:
%   phoPipelineOptions.shouldSaveFiguresToDisk
%   phoPipelineOptions.shouldShowPlots
%   phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path
% %   phoPipelineOptions.PhoTuningMeshExplorer.should_show_neuropil_corrected_version
%   phoPipelineOptions.PhoTuningMeshExplorer.numToCompare

if ~exist('phoPipelineOptions','var')
    warning('phoPipelineOptions is missing! Using defaults specified in PhoTuningMeshExplorer.m')
    phoPipelineOptions.shouldSaveFiguresToDisk = true;
    phoPipelineOptions.shouldShowPlots = true;
    %%% PhoTuningMeshExplorer Options:
    phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path = '';
%     phoPipelineOptions.PhoTuningMeshExplorer.should_show_neuropil_corrected_version = true;
    phoPipelineOptions.PhoTuningMeshExplorer.numToCompare = 1;
%     phoPipelineOptions.PhoTuningMeshExplorer.cellRoisToPlot = [];
end

% If it's needed, make sure the export directory is set up appropriately
if phoPipelineOptions.shouldShowPlots
   if phoPipelineOptions.shouldSaveFiguresToDisk
        if isempty(phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path)
            phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path = uigetdir(pwd, 'Select an export directory');              
        end        
        while (~exist(phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path, 'dir'))
            warning(['WARNING: The specified figure export directory ' phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path ' does not exist!']);
            phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path = uigetdir(pwd, 'Select an export directory');     
        end
   end
end




%% Perform main plot:
[cellRoisToPlot, sortedTuningScores] = fnPlotPhoTuningMeshExplorerFigures(dateStrings, uniqueAmps, uniqueFreqs, multiSessionCellRoi_CompListIndicies, finalOutComponentSegment, componentAggregatePropeties, finalOutPeaksGrid, redTraceLinesForAllStimuli, phoPipelineOptions);
fprintf('\t done.\n');


function [cellRoisToPlot, sortedTuningScores] = fnPlotPhoTuningMeshExplorerFigures(dateStrings, uniqueAmps, uniqueFreqs, multiSessionCellRoi_CompListIndicies, finalOutComponentSegment, componentAggregatePropeties, finalOutPeaksGrid, redTraceLinesForAllStimuli, phoPipelineOptions)

%     %% Sort based on tuning score:
    [sortedTuningScores, cellRoiSortIndex] = sort(componentAggregatePropeties.tuningScore, 'descend');

    numToCompare = phoPipelineOptions.PhoTuningMeshExplorer.numToCompare;
    cellRoisToPlot = cellRoiSortIndex(1:numToCompare);
    % cellRoisToPlot = cellRoiSortIndex(sortedTuningScores == 1);

    for i = 1:length(cellRoisToPlot)
        %% Plot the grid as a test
        temp.cellRoiIndex = cellRoisToPlot(i);
        temp.currAllSessionCompIndicies = multiSessionCellRoi_CompListIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
    %     temp.firstCompSessionIndex = temp.currAllSessionCompIndicies(1);
    %     temp.firstCompSessionMask = squeeze(finalOutComponentSegment.Masks(temp.firstCompSessionIndex,:,:));

        if phoPipelineOptions.shouldShowPlots
            % Mask Plot:
            [figH_Blobs, ~] = fnPlotCellROIBlobs(dateStrings, temp.currAllSessionCompIndicies, temp.cellRoiIndex, finalOutComponentSegment);

            % Make 2D Plots (Exploring):    
            [figH_2d, ~] = fnPlotFlattenedPlotsFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, finalOutPeaksGrid);

            % Make 3D Mesh Plot:
            [figH, ~] = fnPlotMeshFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, temp.currAllSessionCompIndicies, temp.cellRoiIndex, finalOutPeaksGrid);
    %         zlim([-0.2, 1])

            if phoPipelineOptions.shouldSaveFiguresToDisk

                %% Export plots:
                fig_name = sprintf('TuningCurves_cellRoi_%d.fig', temp.cellRoiIndex);
                fig_2d_export_path = fullfile(phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path, fig_name);
                savefig(figH_2d, fig_2d_export_path);
                close(figH_2d);

                fig_name = sprintf('TuningMesh_cellRoi_%d.fig', temp.cellRoiIndex);
                fig_export_path = fullfile(phoPipelineOptions.PhoTuningMeshExplorer.fig_export_parent_path, fig_name);
                savefig(figH, fig_export_path);
                close(figH);
            end

        end
    end %% end for cellRoisToPlot
    
end
