function [] = fnTestCellROIBlob_Plot_OnClicked_Callback(hObject, eventData, final_data_explorer_obj)
%FNTESTCELLROIBLOB_PLOT_ONCLICKED_CALLBACK Summary of this function goes here
%   Detailed explanation goes here
% hObject: the actual Image object that was clicked ('matlab.graphics.primitive.Image')
% eventData: matlab.graphics.eventdata.Hit object
    disp('testCellROIBlob_Plot_OnClicked_Callback(...)')

%     disp(hObject);
%     disp(eventData);
%     isLeftClick = (eventData.Button == 1);

    clickedUserData = hObject.UserData;
    disp(clickedUserData)

    clickedCellRoiIdentifier = clickedUserData.cellROIIdentifier;
    uniqueCompIndex = clickedCellRoiIdentifier.uniqueRoiIndex;
    clickedCellRoiIdentifier.roiName;
    
%     x = eventInfo.Position(1);
%     y = eventInfo.Position(2);
%     uniqueCompIndex = final_data_explorer_obj.amalgamationMasks.cellROI_LookupMask(y, x); % Figure out explicitly what index type is assigned here.
    cellROIString = '';
    if uniqueCompIndex > 0
        fprintf('clicked cellROI: %d...\n', uniqueCompIndex);
%         cellROI_CompName = final_data_explorer_obj.uniqueComps{uniqueCompIndex};
        cellROI_CompName = clickedCellRoiIdentifier.roiName;
        cellROIString = ['[' num2str(uniqueCompIndex) '] ' cellROI_CompName];
        
        fprintf(cellROIString);
%         
%         cellROI_PreferredLinearStimulusIndicies = squeeze(final_data_explorer_obj.preferredStimulusInfo.PreferredStimulus_LinearStimulusIndex(uniqueCompIndex,:)); % These are the linear stimulus indicies for this all sessions of this datapoint.
% %         disp(cellROI_PreferredLinearStimulusIndicies);
% 
%         cellROI_PreferredAmpsFreqsIndicies = final_data_explorer_obj.stimuli_mapper.indexMap_StimulusLinear2AmpsFreqsArray(cellROI_PreferredLinearStimulusIndicies',:);
% %         disp(cellROI_PreferredAmpsFreqsIndicies);
% 
%         cellROI_PreferredAmps = final_data_explorer_obj.uniqueAmps(cellROI_PreferredAmpsFreqsIndicies(:,1));
%         cellROI_PreferredFreqs = final_data_explorer_obj.uniqueFreqs(cellROI_PreferredAmpsFreqsIndicies(:,2));
% 
% %         disp(num2str(cellROI_PreferredAmps'));
%         
%         cellROI_PreferredAmpsFreqsValues = [cellROI_PreferredAmps, cellROI_PreferredFreqs];
%         disp(cellROI_PreferredAmpsFreqsValues);
%         txt = {['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString], ['prefAmps: ' num2str(cellROI_PreferredAmps')], ['prefFreqs: ' num2str(cellROI_PreferredFreqs')]};
        
    else
        fprintf('selected no cells.\n');
        cellROIString = 'None';
%         txt = ['(' num2str(x) ', ' num2str(y) '): cellROI: ' cellROIString];
    end

end
