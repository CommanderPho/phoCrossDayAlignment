function [fdStruct, sessionList, compList] = makeFiltered_FDS(fdStruct, phoPipelineOptions)
% based off of makeSessionList_FDS.m, but in addition it can make use of exclusion/inclusion cellROI info to build filtered objects.
% requires a valid phoPipelineOptions with a valid loadedFilteringData struct

% phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults

% phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.included_comp_names;

% phoPipelineOptions.loadedFilteringData.curr_animal


%if you don't have a list of components and sessions, this script will make
%one 20200602

anmIDs = fieldnames(fdStruct);
compList = struct;
sessionList = struct;

currentID = 0;
for a = 1:numel(anmIDs)
    currentAnmID = anmIDs{a};
    if (~strcmpi(phoPipelineOptions.loadedFilteringData.curr_animal, currentAnmID))
        fprintf('\t skipping animal ID: %s in finalDataStruct, as it is not specified in phoPipelineOptions.loadedFilteringData.curr_animal!\n', currentAnmID);
        continue;
        
    else
        % Otherwise we found the active animal in the finalDataStruct
        sessionIDs = fieldnames(fdStruct.(currentAnmID));
        % Loop through each session (day)
        for b = 1:numel(sessionIDs)
            currentID = currentID + 1;

            tempCompList = struct;
            currentSeshName = sessionIDs{b};
            compNames = fieldnames(fdStruct.(currentAnmID).(currentSeshName).imgData);

            splitName = strsplit(currentSeshName, '_');
            sessionList(currentID).anmID = currentAnmID;
            sessionList(currentID).date = splitName{2};

%             for c = 1:numel(compNames)
%                 % filter the compNames using phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.included_comp_names
%                 currentComp = compNames{c};
%                 if ismember(phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.included_comp_names, currentComp)
%                     tempCompList(c).anmID = currentAnmID;
%                     tempCompList(c).date = splitName{2};
%                     tempCompList(c).compName = currentComp;
%         %            tempCompList(c).sigSampleAnswer=fdStruct.(currentAnm).(currentSesh).imgData.(currentComp).sigSampleAnswer;
%                 end
%             end % end for numel(compNames)

           % Determine which character vectors of compNames are also in the included_comp_names from the manualRoiFilteringResults.
            [comp_inclusion_mask, ~] = ismember(compNames, phoPipelineOptions.loadedFilteringData.manualRoiFilteringResults.included_comp_names);
            included_compNames = compNames(comp_inclusion_mask);
            % loop through and add only the included comps:
            for c = 1:numel(included_compNames)
                currentComp = included_compNames{c};
                tempCompList(c).anmID = currentAnmID;
                tempCompList(c).date = splitName{2};
                tempCompList(c).compName = currentComp;
            end % end for numel(compNames)
            
            % check if this is the first iteration, in which case we will make a new compList to contain the tempCompList
            if numel(fieldnames(compList)) == 0
                compList = tempCompList;
            else
                % otherwise on the 2nd iteration and onward we accumulate the compList using the different animals
                compList = [compList, tempCompList];
            end
        end % end for numel(sessionIDs)        
        
        
    end % end if
    

    
end
