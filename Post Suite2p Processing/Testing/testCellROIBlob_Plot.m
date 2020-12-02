%% testCellROIBlob_Plot.m

% Build Color Matricies
desiredSize = [512 512];
black3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.0], desiredSize);
darkgrey3DArray = fnBuildCDataFromConstantColor([0.3 0.3 0.3], desiredSize);
lightgrey3DArray = fnBuildCDataFromConstantColor([0.6 0.6 0.6], desiredSize);

orange3DArray = fnBuildCDataFromConstantColor([0.9 0.3 0.1], desiredSize);

red3DArray = fnBuildCDataFromConstantColor([1.0 0.0 0.0], desiredSize);
green3DArray = fnBuildCDataFromConstantColor([0.0 1.0 0.0], desiredSize);
blue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 1.0], desiredSize);

darkRed3DArray = fnBuildCDataFromConstantColor([0.6 0.0 0.0], desiredSize);
darkGreen3DArray = fnBuildCDataFromConstantColor([0.0 0.6 0.0], desiredSize);
darkBlue3DArray = fnBuildCDataFromConstantColor([0.0 0.0 0.6], desiredSize);
colorsArray = {lightgrey3DArray, darkBlue3DArray, darkGreen3DArray, darkRed3DArray, black3DArray, red3DArray, green3DArray, blue3DArray};


testCellROIBlob_Plot_figH = createFigureWithNameIfNeeded('CellROI Blobs Testing'); % generate a new figure to plot the sessions.
clf(testCellROIBlob_Plot_figH);

%% Plots CellROI Mask Insets at all depths for debug purposes:
combinedOffsetInsetIndicies = [nan, 0];
% combinedOffsetInsetIndicies = [nan, 3, 2, 1, 0, -1, -2, -3];

imagePlotHandles = gobjects(final_data_explorer_obj.num_cellROIs, length(combinedOffsetInsetIndicies));

for i = 1:final_data_explorer_obj.num_cellROIs
    cellROIIdentifier.uniqueRoiIndex = i;
    cellROIIdentifier.roiName = final_data_explorer_obj.cellROIIndex_mapper.getRoiNameFromUniqueCompIndex(i);
    
    for plotImageIndex = 1:length(combinedOffsetInsetIndicies)
        currEdgePlotImageIdentifier.cellROIIdentifier = cellROIIdentifier;
        currEdgePlotImageIdentifier.edgeOffsetIndex = combinedOffsetInsetIndicies(plotImageIndex);
        
        if isnan(currEdgePlotImageIdentifier.edgeOffsetIndex)
            % For the fill layer, the edgeOffsetIndex is nan
            imagePlotHandles(i, plotImageIndex) = image('CData', colorsArray{plotImageIndex}, 'AlphaData', (0.5 * final_data_explorer_obj.getFillRoiMask(i)));
%             imagePlotHandles(i, plotImageIndex).ButtonDownFcn = {@testCellROIBlob_Plot_OnClicked_Callback, final_data_explorer_obj};
        else
            imagePlotHandles(i, plotImageIndex) = image('CData', colorsArray{plotImageIndex}, 'AlphaData', final_data_explorer_obj.getEdgeOffsetRoiMasks(currEdgePlotImageIdentifier.edgeOffsetIndex, i));
        end
        
%         imagePlotHandles(i, plotImageIndex).ButtonDownFcn = {@testCellROIBlob_Plot_OnClicked_Callback, final_data_explorer_obj};
        imagePlotHandles(i, plotImageIndex).ButtonDownFcn = @(hObject, eventData) (fnTestCellROIBlob_Plot_OnClicked_Callback(hObject, eventData, final_data_explorer_obj));
        
        curr_tag_string = fnBuildCellRoiPlotTagString(combinedOffsetInsetIndicies(plotImageIndex), cellROIIdentifier);
        
        set(imagePlotHandles(i, plotImageIndex), 'UserData', currEdgePlotImageIdentifier);
        set(imagePlotHandles(i, plotImageIndex), 'Tag', curr_tag_string);
        
    end

end
title('Combined Insets and Outsets')
set(gca,'xtick',[],'YTick',[])
set(gca,'xlim',[1 512],'ylim',[1 512])

%% Build Interaction Helper Object:
interaction_helper_obj = InteractionHelper(final_data_explorer_obj, 'Pho');
interaction_helper_obj.setupGraphicalSelectionFigure(testCellROIBlob_Plot_figH, imagePlotHandles);

dcm = datacursormode(testCellROIBlob_Plot_figH);
dcm.Enable = 'on';
dcm.DisplayStyle = 'window';
if exist('slider_controller','var')
    dcm.UpdateFcn = @(figH, info) (testCellROIBlob_Plot_Callback(figH, info, interaction_helper_obj, slider_controller));
else
    dcm.UpdateFcn = @(figH, info) (testCellROIBlob_Plot_Callback(figH, info, interaction_helper_obj));
end
        


%% Update the Plots after creation:

% for i = 1:final_data_explorer_obj.num_cellROIs
%     for j = size(imagePlotHandles, 2)
% %         imagePlotHandles(i, j).ButtonDownFcn = {@testCellROIBlob_Plot_OnClicked_Callback, final_data_explorer_obj};
%         imagePlotHandles(i, j).ButtonDownFcn = @(hObject, eventData) (fnTestCellROIBlob_Plot_OnClicked_Callback(hObject, eventData, final_data_explorer_obj));
%     end
% end


        


%% Custom ToolTip callback function that displays the clicked cell ROI as well as the x,y position.
function txt = testCellROIBlob_Plot_Callback(figH, info, interaction_helper_obj, activeSliderController)
    persistent desiredSize
    persistent orange3DArray
    persistent lightgrey3DArray
    desiredSize = [512 512];
    orange3DArray = fnBuildCDataFromConstantColor([0.9 0.3 0.1], desiredSize);
    lightgrey3DArray = fnBuildCDataFromConstantColor([0.6 0.6 0.6], desiredSize);
    % interaction_helper_obj.final_data_explorer_obj
    x = info.Position(1);
    y = info.Position(2);
    uniqueCompIndex = interaction_helper_obj.final_data_explorer_obj.amalgamationMasks.cellROI_LookupMask(y, x); % Figure out explicitly what index type is assigned here.
    cellROIString = '';
    if uniqueCompIndex > 0
        fprintf('selected cellROI: %d...\n', uniqueCompIndex);
        cellROI_CompName = interaction_helper_obj.final_data_explorer_obj.uniqueComps{uniqueCompIndex};
        cellROIString = ['[' num2str(uniqueCompIndex) ']' cellROI_CompName];
        
        % Ask interaction_helper_obj to toggle the selection status.
        
        [interaction_helper_obj, curr_cellROI_IsSelected] = interaction_helper_obj.toggleCellRoiIsSelected(uniqueCompIndex);
        
        %% Update Selections graphically:
        
        % Get the fill handle
        curr_sel_fill_im_h = interaction_helper_obj.GraphicalSelection.imagePlotHandles(uniqueCompIndex, 1);
%         updated_alpha_data = interaction_helper_obj.final_data_explorer_obj.getFillRoiMask(uniqueCompIndex);
        if curr_cellROI_IsSelected
%             updated_alpha_data = updated_alpha_data .* 0.9;
            
            updated_color_data = orange3DArray;
        else
%             updated_alpha_data = updated_alpha_data .* 0.5;
            
            updated_color_data = lightgrey3DArray;
        end
%         set(curr_sel_fill_im_h,'CData', updated_color_data, 'AlphaData', updated_alpha_data);
        
        set(curr_sel_fill_im_h,'CData', updated_color_data);
        drawnow
%         for i = 1:size(interaction_helper_obj.imagePlotHandles, 1)
%             for j = size(interaction_helper_obj.imagePlotHandles, 2)
%         %         imagePlotHandles(i, j).ButtonDownFcn = {@testCellROIBlob_Plot_OnClicked_Callback, final_data_explorer_obj};
%                 interaction_helper_obj.imagePlotHandles(uniqueCompIndex, j).ButtonDownFcn = @(hObject, eventData) (fnTestCellROIBlob_Plot_OnClicked_Callback(hObject, eventData, final_data_explorer_obj));
%             end
%         end        
        
%         cellROIString = num2str(uniqueCompIndex);  
        
        
        cellROI_PreferredLinearStimulusIndicies = squeeze(interaction_helper_obj.final_data_explorer_obj.preferredStimulusInfo.PreferredStimulus_LinearStimulusIndex(uniqueCompIndex,:)); % These are the linear stimulus indicies for this all sessions of this datapoint.
%         disp(cellROI_PreferredLinearStimulusIndicies);

        cellROI_PreferredAmpsFreqsIndicies = interaction_helper_obj.final_data_explorer_obj.stimuli_mapper.indexMap_StimulusLinear2AmpsFreqsArray(cellROI_PreferredLinearStimulusIndicies',:);
%         disp(cellROI_PreferredAmpsFreqsIndicies);

        cellROI_PreferredAmps = interaction_helper_obj.final_data_explorer_obj.uniqueAmps(cellROI_PreferredAmpsFreqsIndicies(:,1));
        cellROI_PreferredFreqs = interaction_helper_obj.final_data_explorer_obj.uniqueFreqs(cellROI_PreferredAmpsFreqsIndicies(:,2));

%         disp(num2str(cellROI_PreferredAmps'));
        
        cellROI_PreferredAmpsFreqsValues = [cellROI_PreferredAmps, cellROI_PreferredFreqs];
        disp(cellROI_PreferredAmpsFreqsValues);
        txt = {['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString], ['prefAmps: ' num2str(cellROI_PreferredAmps')], ['prefFreqs: ' num2str(cellROI_PreferredFreqs')]};
%         txt = [txt '\n prefAmps: ' num2str(cellROI_PreferredAmps)];
        
    else
        fprintf('selected no cells.\n');
        cellROIString = 'None';
        txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];
    end

    if exist('activeSliderController','var')
        fprintf('updating activeSliderController programmatically to value %d...\n', uniqueCompIndex);
        activeSliderController.controller.Slider.Value = uniqueCompIndex;
    end
end

