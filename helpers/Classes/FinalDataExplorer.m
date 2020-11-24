classdef FinalDataExplorer
    %FINALDATAEXPLORER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        uniqueComps
        
        multiSessionCellRoi_CompListIndicies
%         finalOutComponentSegment

        dateStrings
 
        stimuli_mapper
        
        %% Outputs:
        finalOutComponentSegment
        active_DFF
        
    end
    methods
       function obj = set.active_DFF(obj, value)
           obj.active_DFF = value;
       end  
       function obj = set.finalOutComponentSegment(obj, value)
           obj.finalOutComponentSegment = value;
       end  
       
    end
    
    
    %% Computed Properties:
    properties (Dependent)
        num_cellROIs
        numOfSessions
        componentAggregatePropeties
        finalOutPeaksGrid
        redTraceLinesForAllStimuli
        uniqueAmps
        uniqueFreqs
        uniqueStimuli
    end
    methods
       function num_cellROIs = get.num_cellROIs(obj)
          num_cellROIs = length(obj.uniqueComps);
       end
       function numOfSessions = get.numOfSessions(obj)
          numOfSessions = length(obj.dateStrings);
       end
       function componentAggregatePropeties = get.componentAggregatePropeties(obj)
          componentAggregatePropeties = obj.active_DFF.componentAggregatePropeties;
       end
       function finalOutPeaksGrid = get.finalOutPeaksGrid(obj)
          finalOutPeaksGrid = obj.active_DFF.finalOutPeaksGrid;
       end
       function redTraceLinesForAllStimuli = get.redTraceLinesForAllStimuli(obj)
          redTraceLinesForAllStimuli = obj.active_DFF.redTraceLinesForAllStimuli;
       end
       function uniqueAmps = get.uniqueAmps(obj)
          uniqueAmps = obj.stimuli_mapper.uniqueAmps;
       end
       function uniqueFreqs = get.uniqueFreqs(obj)
          uniqueFreqs = obj.stimuli_mapper.uniqueFreqs;
       end
       function uniqueStimuli = get.uniqueStimuli(obj)
          uniqueStimuli = obj.stimuli_mapper.uniqueStimuli;
       end
    end
    
    methods
        function obj = FinalDataExplorer(uniqueComps, multiSessionCellRoi_CompListIndicies, dateStrings, stimuli_mapper)
            %FINALDATAEXPLORER Construct an instance of this class
            %   Detailed explanation goes here
            obj.uniqueComps = uniqueComps;
%             obj.num_cellROIs = length(uniqueComps);
            
            obj.dateStrings = dateStrings;
%             obj.numOfSessions = length(dateStrings);
            
            obj.multiSessionCellRoi_CompListIndicies = multiSessionCellRoi_CompListIndicies;
            obj.stimuli_mapper = stimuli_mapper;

        end

%         function obj = setActiveDFF(obj, active_DFF)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             obj.active_DFF = active_DFF;
%         end
        
        
        function [amalgamationMasks, outputMaps, cellRoiSortIndex] = buildSpatialTuningInfo(obj, phoPipelineOptions)
            %buildSpatialTuningInfo Builds the spatial tuning objects
            %   Detailed explanation goes here
            % should_enable_edge_layering_mode: if true, uses the borders surrounding each cell to reflect the preferred tuning at a given day.
			should_enable_edge_layering_mode = phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode;
			edge_layering_is_outset_mode = phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.edge_layering_is_outset_mode; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw
			%     temp.structuring_element = strel('disk', 2);
			%     temp.structuring_element = strel('diamond', 2);
			temp.structuring_element = strel('square', 3);

			num_cellROIs = obj.num_cellROIs;
			numOfSessions = obj.numOfSessions;


			%% Sort based on tuning score:
			[sortedTuningScores, cellRoiSortIndex] = sort(obj.componentAggregatePropeties.tuningScore, 'descend');

			amalgamationMasks.cellROI_LookupMask = zeros(512, 512); % Maps every pixel in the image to the cellROI index of the cell it belongs to, if one exists.

			amalgamationMasks.AlphaConjunctionMask = zeros(512, 512);
			amalgamationMasks.AlphaRoiTuningScoreMask = zeros(512, 512);
			amalgamationMasks.NumberOfTunedDays = zeros(512, 512);

			% outputMaps.masks: one for each cellROI
			outputMaps.masks.Fill = zeros(num_cellROIs,512,512);
			outputMaps.masks.Edge = zeros(num_cellROIs,512,512);

			outputMaps.masks.OutsetEdge0 = zeros(num_cellROIs,512,512);
			outputMaps.masks.OutsetEdge1 = zeros(num_cellROIs,512,512);
			outputMaps.masks.OutsetEdge2 = zeros(num_cellROIs,512,512);

			outputMaps.masks.InsetEdge0 = zeros(num_cellROIs,512,512);
			outputMaps.masks.InsetEdge1 = zeros(num_cellROIs,512,512);
			outputMaps.masks.InsetEdge2 = zeros(num_cellROIs,512,512);

			% amalgamationMasks.PreferredStimulusAmplitude = zeros(512, 512, 3);
			% init_matrix = zeros(512, 512);
			init_matrix = ones(numOfSessions, 512, 512) * -1;

			amalgamationMasks.PreferredStimulusAmplitude = init_matrix;
			amalgamationMasks.PreferredStimulusFreq = init_matrix;


			outputMaps.PreferredStimulus = zeros(num_cellROIs, numOfSessions, 2);
			outputMaps.PreferredStimulus_LinearStimulusIndex = zeros(num_cellROIs, numOfSessions); % Instead of a tuple, it holds a value 1-26 that serves as a unique stimulus identity.

			% amalgamationMasks.DidPreferredStimulusChange: keeps track of whether the preferredStimulus amplitude or frequency changed for a cellROI between sessions.
			outputMaps.DidPreferredStimulusChange = zeros(num_cellROIs, (numOfSessions-1));

			outputMaps.computedProperties.areas = zeros(num_cellROIs, 1);
			outputMaps.computedProperties.boundingBoxes = zeros(num_cellROIs, 4);
			outputMaps.computedProperties.centroids = zeros(num_cellROIs, 2);

			for i = 1:num_cellROIs
				%% Plot the grid as a test
				temp.cellRoiIndex = cellRoiSortIndex(i); %% TODO: Should this be uniqueComps(i) instead? RESOLVED: No, this is correct!
				temp.currAllSessionCompIndicies = obj.multiSessionCellRoi_CompListIndicies(temp.cellRoiIndex,:); % Gets all sessions for the current ROI
				%% cellROI Specific Score:
				temp.currRoiTuningScore = obj.componentAggregatePropeties.tuningScore(temp.cellRoiIndex); % currently only uses first session?
				temp.numSessions = length(temp.currAllSessionCompIndicies);
				
				for j = 1:temp.numSessions
					
					temp.currCompSessionIndex = temp.currAllSessionCompIndicies(j);
					
					%% Results common across all sessions of this cellROI:
					% Check if this is the first session for this cellROI as not to recompute it needlessly when it doesn't change across sessions.
					if j == 1
						temp.currCompSessionFill = logical(squeeze(obj.finalOutComponentSegment.Masks(temp.currCompSessionIndex,:,:)));
						temp.currCompSessionEdge = logical(squeeze(obj.finalOutComponentSegment.Edge(temp.currCompSessionIndex,:,:)));
						
						outputMaps.masks.Fill(temp.cellRoiIndex,:,:) = temp.currCompSessionFill;
						outputMaps.masks.Edge(temp.cellRoiIndex,:,:) = temp.currCompSessionEdge;
						
						BW2_Inner = imerode(temp.currCompSessionFill, temp.structuring_element);
						BW3_Inner = imerode(BW2_Inner, temp.structuring_element);
						BW4_Inner = imerode(BW3_Inner, temp.structuring_element);
					
						%% Inset Elements:
						outputMaps.masks.InsetEdge0(temp.cellRoiIndex,:,:) = BW2_Inner;
						outputMaps.masks.InsetEdge1(temp.cellRoiIndex,:,:) = BW3_Inner;
						outputMaps.masks.InsetEdge2(temp.cellRoiIndex,:,:) = BW4_Inner;
									
						%% Outside Elements:
						BW2_Outer = imdilate(temp.currCompSessionFill, temp.structuring_element);
						BW3_Outer = imdilate(BW2_Outer, temp.structuring_element);
						BW4_Outer = imdilate(BW3_Outer, temp.structuring_element);
						outputMaps.masks.OutsetEdge0(temp.cellRoiIndex,:,:) = BW2_Outer;
						outputMaps.masks.OutsetEdge1(temp.cellRoiIndex,:,:) = BW3_Outer;
						outputMaps.masks.OutsetEdge2(temp.cellRoiIndex,:,:) = BW4_Outer;
						%                 temp.currCompSessionMask = temp.currCompSessionEdge; % Use the edges instead of the fills
						temp.currCompSessionMask = temp.currCompSessionFill; % Use the fills
						
						
						s = regionprops(temp.currCompSessionFill,'Centroid','Area','BoundingBox');
						outputMaps.computedProperties.areas(temp.cellRoiIndex) = s.Area;
						outputMaps.computedProperties.boundingBoxes(temp.cellRoiIndex,:) = s.BoundingBox;
						outputMaps.computedProperties.centroids(temp.cellRoiIndex,:) = s.Centroid;
						
						% Save the index of this cell in the reverse lookup table:
						amalgamationMasks.cellROI_LookupMask(temp.currCompSessionFill) = temp.cellRoiIndex;
						amalgamationMasks.cellROI_LookupMask(temp.currCompSessionEdge) = temp.cellRoiIndex;
						if (should_enable_edge_layering_mode && edge_layering_is_outset_mode)
							amalgamationMasks.cellROI_LookupMask(BW2_Outer) = temp.cellRoiIndex;
							amalgamationMasks.cellROI_LookupMask(BW3_Outer) = temp.cellRoiIndex;
							amalgamationMasks.cellROI_LookupMask(BW4_Outer) = temp.cellRoiIndex;
						end
						
						% Set cells in this cellROI region to opaque:
						amalgamationMasks.AlphaConjunctionMask(temp.currCompSessionMask) = 1.0;
						% Set the opacity of cell in this cellROI region based on the number of days that the cell passed the threshold:
						amalgamationMasks.AlphaRoiTuningScoreMask(temp.currCompSessionMask) = (double(temp.currRoiTuningScore) / 3.0);
						
						if (should_enable_edge_layering_mode && edge_layering_is_outset_mode)
							amalgamationMasks.AlphaConjunctionMask(BW2_Outer) = 1.0;
							amalgamationMasks.AlphaConjunctionMask(BW3_Outer) = 1.0;
							amalgamationMasks.AlphaConjunctionMask(BW4_Outer) = 1.0;
						end
						
						% Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
						amalgamationMasks.NumberOfTunedDays(temp.currCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;
						
					end
					
					% Currently just use the preferred stimulus info from the first of the three sessions:
					temp.currCompMaximallyPreferredStimulusInfo = obj.componentAggregatePropeties.maximallyPreferredStimulusInfo(temp.currCompSessionIndex);
					temp.currMaximalIndexTuple = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqIndexTuple; %Check this to make sure it's always (0, 0) when one of the tuple elements are zero.
					temp.maxPrefAmpIndex = temp.currMaximalIndexTuple(1);
					temp.maxPrefFreqIndex = temp.currMaximalIndexTuple(2);
					
					outputMaps.PreferredStimulus_LinearStimulusIndex(temp.cellRoiIndex,j) = temp.currCompMaximallyPreferredStimulusInfo.LinearIndex;
					outputMaps.PreferredStimulus(temp.cellRoiIndex,j,:) =  temp.currMaximalIndexTuple;
					
					if should_enable_edge_layering_mode
						if j <= 1
							if edge_layering_is_outset_mode
								temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.OutsetEdge0(temp.cellRoiIndex,:,:)));
							else
								temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.InsetEdge2(temp.cellRoiIndex,:,:)));
							end
						elseif j == 2
							if edge_layering_is_outset_mode
								temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.OutsetEdge1(temp.cellRoiIndex,:,:)));
							else
								temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.InsetEdge1(temp.cellRoiIndex,:,:)));
							end
						else
							if edge_layering_is_outset_mode
								temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.OutsetEdge2(temp.cellRoiIndex,:,:)));
							else
								temp.currCompSessionCustomEdgeMask = logical(squeeze(outputMaps.masks.InsetEdge0(temp.cellRoiIndex,:,:)));
							end
						end
						amalgamationMasks.PreferredStimulusAmplitude(j, temp.currCompSessionCustomEdgeMask) = double(temp.maxPrefAmpIndex);
						amalgamationMasks.PreferredStimulusFreq(j, temp.currCompSessionCustomEdgeMask) = double(temp.maxPrefFreqIndex);
						if edge_layering_is_outset_mode
							% Fill in the main fill with nothing
							amalgamationMasks.PreferredStimulusAmplitude(j, temp.currCompSessionFill) = -1.0;
							amalgamationMasks.PreferredStimulusFreq(j, temp.currCompSessionFill) = -1.0;
						end
					else
						amalgamationMasks.PreferredStimulusAmplitude(j, temp.currCompSessionMask) = double(temp.maxPrefAmpIndex);
						amalgamationMasks.PreferredStimulusFreq(j, temp.currCompSessionMask) = double(temp.maxPrefFreqIndex);
					end
					
					% If we're not on the first session, see if the preferred values changed between the sessions.
					if j > 1
						didPreferredAmpIndexChange = (temp.prev.maxPrefAmpIndex ~= temp.maxPrefAmpIndex);
						didPreferredFreqIndexChange = (temp.prev.maxPrefFreqIndex ~= temp.maxPrefFreqIndex);
						outputMaps.DidPreferredStimulusChange(temp.cellRoiIndex,j-1) = didPreferredAmpIndexChange | didPreferredFreqIndexChange;
					end
					% Update the prev values:
					temp.prev.maxPrefAmpIndex = temp.maxPrefAmpIndex;
					temp.prev.maxPrefFreqIndex = temp.maxPrefFreqIndex;
					
				end % end for numSessions
				
			end % end for each cell ROI

        end


    end
end

