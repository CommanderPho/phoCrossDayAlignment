classdef CellROIIndexMapper
    %CELLROIINDEXMAPPER Provides mapping between cellROIIDs, compList linear indices, etc.
    %   Detailed explanation goes here
    % a uniqueCompListIndex is the unique linear index of the first session ONLY where a compName occurs.
    
    properties
        dateStrings % a cell array of character strings corresponding to each session date.
        numOfSessions
        
        uniqueComps % The cell array containing the list of unique components
        compIDsArray % The numeric array containing the parsed uniqueComps IDs for each comp in uniqueComps
        
        compTable
        numCompListEntries
        
        num_cellROIs
        multiSessionCellRoi_CompListIndicies % a list of comp indicies for each CellRoi
        
        % Index Maps
        indexMap_uniqueCompName_to_uniqueCompIndex
    end
    
    methods
        function obj = CellROIIndexMapper(activeAnimalSessionList, activeAnimalCompList, phoPipelineOptions)
            %CELLROIINDEXMAPPER Construct an instance of this class
            %   Detailed explanation goes here
            obj.dateStrings = {activeAnimalSessionList.date};  % Strings representing each date.
            obj.numOfSessions = length(obj.dateStrings); % The number of sessions (days) for this animal.

            obj.compTable = struct2table(activeAnimalCompList);
            obj.numCompListEntries = height(obj.compTable); % The number of rows in the compTable. Should be a integer multiple of the number of unique comps (corresponding to multiple sessions/days for each unique comp)

            obj.uniqueComps = unique(obj.compTable.compName, 'stable'); % Each unique component corresponds to a cellROI
            
            obj = obj.parseNames(); % Parse the comp names
%             obj = obj.filterComps(phoPipelineOptions); % Filter out any excluded comp names
            
            obj.num_cellROIs = length(obj.uniqueComps); 
            
            % Build index maps:
            obj.multiSessionCellRoi_CompListIndicies = zeros(obj.num_cellROIs, obj.numOfSessions); % a list of comp indicies for each CellRoi
            
            %% Process Each Cell ROI:
            for i = 1:obj.num_cellROIs
               curr_cellROI_name = obj.uniqueComps{i}; % Get the name of the current cellROI. It has a name like 'comp14'
               curr_cellROI_compListIndicies = find(strcmp(obj.compTable.compName, curr_cellROI_name)); % Should be a list of 3 relevant indicies, one corresponding to each day.

               fprintf('\t \t uniqueComp[%d]: %s', i, curr_cellROI_name);
               disp(curr_cellROI_compListIndicies');
               obj.multiSessionCellRoi_CompListIndicies(i,:) = curr_cellROI_compListIndicies';
            end
            
            % Maps each uniqueComp name to an index
            obj.indexMap_uniqueCompName_to_uniqueCompIndex = containers.Map(obj.uniqueComps, num2cell(1:length(obj.uniqueComps))');
   

            
        end
        
        function obj = parseNames(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            % Parse the compName into a distinct compID (an index).
            regex.compNameParser = 'comp(?<compID>\d+)';

            tokenNames = regexp(obj.compTable.compName, regex.compNameParser, 'names');

            if ~isempty(tokenNames)
                compIDsArray = zeros(length(tokenNames),1);
                for i = 1:length(compIDsArray)
                    compIDsArray(i) = str2num(tokenNames{i}.compID);
                end
            else
                error('cannot parse names');
            end
            
            % Add the compIDs to the table:
            compIDColumn = table(compIDsArray,'VariableNames',{'compID'});
            obj.compTable = [obj.compTable compIDColumn];
        end
        
                
        function obj = filterComps(obj, phoPipelineOptions)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %% Filter Explicitly Excluded ROI components:
            foundNewToBeExcludedComps = {};
            if exist('excludedCompsList','var')
            %     potentiallyNewExcludedCompsList = uniqueComps(phoPipelineOptions.ignoredCellROI_Indicies); % Before removing them, get the list of the component names that are being removed.
                potentiallyNewExcludedCompsList = phoPipelineOptions.ignoredCellROI_CompNames;
            %     lia = ismember(potentiallyNewExcludedCompsList, excludedCompsList);
                for i = 1:length(potentiallyNewExcludedCompsList)
                   if ~ismember(potentiallyNewExcludedCompsList{i}, excludedCompsList)
                       % Found one that hasn't been filtered for
                       foundNewToBeExcludedComps{end+1} = potentiallyNewExcludedCompsList{i};
                   end
                end

            else
                 % Make a backup before removing anything:
                backup.uniqueComps = obj.uniqueComps;
                backup.compList = compList;
                backup.activeAnimalCompList = activeAnimalCompList;
                backup.compTable = obj.compTable;

                excludedCompsList = {};
                foundNewToBeExcludedComps = phoPipelineOptions.ignoredCellROI_CompNames;
            %     excludedCompsList = uniqueComps(phoPipelineOptions.ignoredCellROI_Indicies); % Before removing them, get the list of the component names that are being removed.
            end

            numNew = length(foundNewToBeExcludedComps);
            if numNew > 0

                for i = 1:length(foundNewToBeExcludedComps)
            %        curr_ignoredCellROI_OriginalIndex = phoPipelineOptions.ignoredCellROI_Indicies(i);
                   curr_ignoredCellROI_ComponentName = foundNewToBeExcludedComps{i};

                   obj.uniqueComps(strcmpi(obj.uniqueComps, curr_ignoredCellROI_ComponentName)) = []; % Remove the comps that are excluded

                   rowsToRemove = strcmpi(obj.compTable.compName, curr_ignoredCellROI_ComponentName);
                   obj.compTable(rowsToRemove, :) = []; % Remove these rows
                   compList(rowsToRemove) = [];
                   activeAnimalCompList(rowsToRemove) = [];

                   excludedCompsList{end+1} = curr_ignoredCellROI_ComponentName;
                end

            end

        end
        
        
        %% Accessor functions:
        function compListIndicies = getCompListIndicies(obj, uniqueCompListIndex)
            %getCompListIndicies Gets the indicies into the comp list that correspond to the linearUniqueCellROIIndex passed in.
            %   uniqueCompListIndex: an index like 5.
            compListIndicies = obj.multiSessionCellRoi_CompListIndicies(uniqueCompListIndex,:);
        end
        
        
        function uniqueCompListIndex = getUniqueCompIndexFromName(obj, roiName)
            % returns the single linear uniqueCompListIndex from the roiName provided.
           uniqueCompListIndex = obj.indexMap_uniqueCompName_to_uniqueCompIndex(roiName);
        end
        
        function compListIndicies = getCompListIndiciesFromName(obj, roiName)
            %getCompListIndiciesFromName Gets the indicies into the comp list that correspond to the roiName passed in.
            %   roiName: a name like 'comp678'
            uniqueCompListIndex = obj.getUniqueCompIndexFromName(roiName);
            compListIndicies = getCompListIndicies(obj, uniqueCompListIndex);
        end
        
    end
end
