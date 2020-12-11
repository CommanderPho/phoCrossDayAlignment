classdef FinalDataExplorer
    %FINALDATAEXPLORER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Used in FinalDataExplorer:
    %%%+S- preferredStimulusInfo
        %- DidPreferredStimulusChange - keeps track of whether the preferredStimulus amplitude or frequency changed for a cellROI between sessions.
        %- PreferredStimulus - 
        %- PreferredStimulus_LinearStimulusIndex - 
        %- PreferredStimulusAmplitude - 
        %- PreferredStimulusFreq - 
		%- ChangeScores: the number of changes in preferred tuning between sessions
		%- InterSessionConsistencyScores: the number of consistently tuned sessions
    %

    %%%+S- roiComputedProperties
        %- areas - 
        %- boundingBoxes - 
        %- centroids - 
    %

    %%%+S- roiMasks
        %- Fill - 
        %- Edge - 
        %- OutsetEdge0 - 
        %- OutsetEdge1 - 
        %- OutsetEdge2 - 
        %- InsetEdge0 - 
        %- InsetEdge1 - 
        %- InsetEdge2 - 
    %

    properties

        cellROIIndex_mapper % a CellROIIndexMapper object
        
        stimuli_mapper
        
        %% Outputs:
        finalOutComponentSegment
        compMasks % struct containing sessionRoiMask fields. sessionRoiMask: *one for each ROI in each session*: matricies the size of the original images (512x512 for example) that specify specific pixels related to the ROIs.
        compNeuropilMasks
        
        active_DFF
        traceTimebase_t
        
        %% Processed Outputs: Computed by running obj.buildSpatialTuningInfo(...)
        amalgamationMasks  % struct containing amalgamationMask fields. amalgamationMask: *only one that includes all ROIs*: matiricies the size of the original images (512x512 for example) that include all pixels related to ANY ROI.
        roiMasks  % struct containing mask fields. masks: *one for each ROI*: matricies the size of the original images (512x512 for example) that specify specific pixels related to the ROIs.
        roiComputedProperties
               
        preferredStimulusInfo
        computedRedTraceLinesAnalyses = struct; % Analysis done for the red mean tracelines
		computedAllTraceLinesAnalyses % Analyses done for all trace lines
		
		

		autoTuningDetection % Used to auto-determine the tuning for a given cellROI
        
    end
    methods
       function obj = set.active_DFF(obj, value)
           obj.active_DFF = value;
       end  
       function obj = set.compMasks(obj, value)
           obj.compMasks = value;
       end  
       
    end
    
    
    %% Computed Properties:
    properties (Dependent)
        dateStrings
        uniqueComps       
        multiSessionCellRoi_CompListIndicies
        
        num_cellROIs
        numOfSessions
        componentAggregatePropeties
        finalOutPeaksGrid
        redTraceLinesForAllStimuli
		tracesForAllStimuli
        uniqueAmps
        uniqueFreqs
        uniqueStimuli

    end
    methods
       function dateStrings = get.dateStrings(obj)
          dateStrings = obj.cellROIIndex_mapper.dateStrings;
       end
       function uniqueComps = get.uniqueComps(obj)
          uniqueComps = obj.cellROIIndex_mapper.uniqueComps;
       end
       function multiSessionCellRoi_CompListIndicies = get.multiSessionCellRoi_CompListIndicies(obj)
          multiSessionCellRoi_CompListIndicies = obj.cellROIIndex_mapper.multiSessionCellRoi_CompListIndicies;
       end
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
       function tracesForAllStimuli = get.tracesForAllStimuli(obj)
          tracesForAllStimuli = obj.active_DFF.TracesForAllStimuli.imgDataToPlot;
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
        function obj = FinalDataExplorer(cellROIIndex_mapper, stimuli_mapper)
            %FINALDATAEXPLORER Construct an instance of this class
            %   Detailed explanation goes here
   
            obj.cellROIIndex_mapper = cellROIIndex_mapper;

            obj.stimuli_mapper = stimuli_mapper;
    
        end
        
        function [mask] = getFillRoiMask(obj, roiIndex)
           %% getFillRoiMask: convenience method for accessing the fill mask for a given roiIndex.
           mask = squeeze(obj.roiMasks.Fill(roiIndex,:,:));
        end
        
		function [mask] = getNeuropilRoiMask(obj, roiIndex)
           %% getNeuropilRoiMask: convenience method for accessing the fill mask of the neuropil mask for a given roiIndex.
           mask = squeeze(obj.roiMasks.NeuropilFill(roiIndex,:,:));
        end

        
        function [mask] = getEdgeOffsetRoiMasks(obj, offsetIndex, roiIndex)
           %% getEdgeOffsetRoiMasks: convenience method for accessing the inset/offset masks by an offset index.
           switch offsetIndex
               case -3
                    mask = obj.roiMasks.InsetEdge2;
               case -2
                    mask = obj.roiMasks.InsetEdge1;
               case -1
                    mask = obj.roiMasks.InsetEdge0;
               case 0
                    mask = obj.roiMasks.Edge;
               case 1
                    mask = obj.roiMasks.OutsetEdge0;
               case 2
                   mask = obj.roiMasks.OutsetEdge1;
               case 3
                   mask = obj.roiMasks.OutsetEdge2;
               otherwise
                    error(['Invalid offset index: ' num2str(offsetIndex) '! Index must correspond to one of the inset [-3, -1] edge [0] or outset [1, 3] masks.']);
           end % end switch
           
           % If we have an roiIndex that we want to access directly, return the squeezed matrix for that component, otherwise, return all masks
           if exist('roiIndex','var')
               mask = squeeze(mask(roiIndex,:,:));             
           end
           
        end

    
              
        function [obj] = buildSpatialTuningInfo(obj, phoPipelineOptions)
            %buildSpatialTuningInfo Builds the spatial tuning objects
            %   Detailed explanation goes here
            % should_enable_edge_layering_mode: if true, uses the borders surrounding each cell to reflect the preferred tuning at a given day.
			should_enable_edge_layering_mode = phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.should_enable_edge_layering_mode;
			edge_layering_is_outset_mode = phoPipelineOptions.PhoBuildSpatialTuning.spatialTuningAnalysisFigure.edge_layering_is_outset_mode; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw; % edge_layering_is_outset_mode: if true, it uses the outer borders to draw
			%     temp.structuring_element = strel('disk', 2);
			%     temp.structuring_element = strel('diamond', 2);
			temp.structuring_element = strel('square', 3);

			%% Sort based on tuning score:
	 		% [sortedTuningScores, cellRoiSortIndex] = sort(obj.componentAggregatePropeties.tuningScore, 'descend');

            % Perform allocations:
            obj = obj.allocateOutputObjects(phoPipelineOptions);

            % Iterate through each cellROI:
			for i = 1:obj.num_cellROIs
				%% Plot the grid as a test
 				%temp.cellRoiIndex = cellRoiSortIndex(i); %% TODO: Should this be uniqueComps(i) instead? RESOLVED: No, this is correct!
                temp.cellRoiIndex = i;
                
                temp.currAllSessionCompIndicies = obj.cellROIIndex_mapper.getCompListIndicies(temp.cellRoiIndex); % Gets all sessions for the current ROI
                
				%% cellROI Specific Score:
				temp.currRoiTuningScore = obj.componentAggregatePropeties.tuningScore(temp.cellRoiIndex); % currently only uses first session? TODO: CHECK
				temp.numSessions = length(temp.currAllSessionCompIndicies);

				% Loop through the sessions once so we can compute obj.preferredStimulusInfo.ChangeScores and other useful properties that might be used in the second loop.
				for j = 1:temp.numSessions
					temp.currCompSessionIndex = temp.currAllSessionCompIndicies(j);
					temp.currCompMaximallyPreferredStimulusInfo = obj.componentAggregatePropeties.maximallyPreferredStimulusInfo(temp.currCompSessionIndex);
					temp.currMaximalIndexTuple = temp.currCompMaximallyPreferredStimulusInfo.AmpFreqIndexTuple; %Check this to make sure it's always (0, 0) when one of the tuple elements are zero.
					temp.maxPrefAmpIndex = temp.currMaximalIndexTuple(1);
					temp.maxPrefFreqIndex = temp.currMaximalIndexTuple(2);
					
					obj.preferredStimulusInfo.PreferredStimulus_LinearStimulusIndex(temp.cellRoiIndex,j) = temp.currCompMaximallyPreferredStimulusInfo.LinearIndex;
					obj.preferredStimulusInfo.PreferredStimulus(temp.cellRoiIndex,j,:) =  temp.currMaximalIndexTuple;

					% If we're not on the first session, see if the preferred values changed between the sessions.
					if j > 1
						didPreferredAmpIndexChange = (temp.prev.maxPrefAmpIndex ~= temp.maxPrefAmpIndex);
						didPreferredFreqIndexChange = (temp.prev.maxPrefFreqIndex ~= temp.maxPrefFreqIndex);
						obj.preferredStimulusInfo.DidPreferredStimulusChange(temp.cellRoiIndex,j-1) = didPreferredAmpIndexChange | didPreferredFreqIndexChange;
					end
					% Update the prev values:
					temp.prev.maxPrefAmpIndex = temp.maxPrefAmpIndex;
					temp.prev.maxPrefFreqIndex = temp.maxPrefFreqIndex;
				end % end for numSessions

				%% TODO: BUG: This currently only compares consecutive sessions for changes in tuning. If a cell has a tuning one day0, then it changes on day1, but returns to the day0 values on day2 it currently has a ChangeScore of 2, meaning a currRoiConsistencyScore of 1.
				%	I would prefer that it would return currRoiConsistencyScore of 2 

				% ChangeScores: the number of changes between sessions
				temp.currRoiChangeScore = sum(obj.preferredStimulusInfo.DidPreferredStimulusChange(temp.cellRoiIndex,:)); % 0..<temp.numSessions
				temp.currRoiConsistencyScore = temp.numSessions - temp.currRoiChangeScore; % Number of sessions the tuning was the same.
				obj.preferredStimulusInfo.ChangeScores(temp.cellRoiIndex) = temp.currRoiChangeScore;
				obj.preferredStimulusInfo.InterSessionConsistencyScores(temp.cellRoiIndex) = temp.currRoiConsistencyScore;
				


				% Loop back through the sessions for a second time to build the masks
				for j = 1:temp.numSessions
					% Returns the linearCompIndex
					temp.currCompSessionIndex = temp.currAllSessionCompIndicies(j);
					
                    isFirstSession = (j == 1);
					%% Results common across all sessions of this cellROI:
					% Check if this is the first session for this cellROI as not to recompute it needlessly when it doesn't change across sessions.
					if isFirstSession
						temp.currCompSessionFill = logical(squeeze(obj.compMasks.Masks(temp.currCompSessionIndex,:,:)));
						temp.currCompSessionEdge = logical(squeeze(obj.compMasks.Edge(temp.currCompSessionIndex,:,:)));
                        temp.currCompSessionNeuropilMaskFill = logical(squeeze(obj.compNeuropilMasks.Masks(temp.currCompSessionIndex,:,:)));
                        
						
						obj.roiMasks.Fill(temp.cellRoiIndex,:,:) = temp.currCompSessionFill;
						obj.roiMasks.Edge(temp.cellRoiIndex,:,:) = temp.currCompSessionEdge;
                        
                        obj.roiMasks.NeuropilFill(temp.cellRoiIndex,:,:) = temp.currCompSessionNeuropilMaskFill;
						
						BW2_Inner = imerode(temp.currCompSessionFill, temp.structuring_element);
						BW3_Inner = imerode(BW2_Inner, temp.structuring_element);
						BW4_Inner = imerode(BW3_Inner, temp.structuring_element);
					
						%% Inset Elements:
						obj.roiMasks.InsetEdge0(temp.cellRoiIndex,:,:) = temp.currCompSessionFill - BW2_Inner;
						obj.roiMasks.InsetEdge1(temp.cellRoiIndex,:,:) = BW2_Inner - BW3_Inner;
						obj.roiMasks.InsetEdge2(temp.cellRoiIndex,:,:) = BW3_Inner - BW4_Inner;
									
						%% Outside Elements:
						BW2_Outer = imdilate(temp.currCompSessionFill, temp.structuring_element);
						BW3_Outer = imdilate(BW2_Outer, temp.structuring_element);
						BW4_Outer = imdilate(BW3_Outer, temp.structuring_element);
                        
						obj.roiMasks.OutsetEdge0(temp.cellRoiIndex,:,:) = BW2_Outer - temp.currCompSessionFill; % OutsetEdge0: accidentally includes inside (fill) as well.
						obj.roiMasks.OutsetEdge1(temp.cellRoiIndex,:,:) = BW3_Outer - BW2_Outer;
						obj.roiMasks.OutsetEdge2(temp.cellRoiIndex,:,:) = BW4_Outer - BW3_Outer;
                        
						%                 temp.currCompSessionMask = temp.currCompSessionEdge; % Use the edges instead of the fills
						temp.currCompSessionMask = temp.currCompSessionFill; % Use the fills
						
						
						temp.s = regionprops(temp.currCompSessionFill,'Centroid','Area','BoundingBox');
						obj.roiComputedProperties.areas(temp.cellRoiIndex) = temp.s.Area;
						obj.roiComputedProperties.boundingBoxes(temp.cellRoiIndex,:) = temp.s.BoundingBox;
						obj.roiComputedProperties.centroids(temp.cellRoiIndex,:) = temp.s.Centroid;
						
						% Save the index of this cell in the reverse lookup table:
						obj.amalgamationMasks.cellROI_LookupMask(temp.currCompSessionFill) = temp.cellRoiIndex;
						obj.amalgamationMasks.cellROI_LookupMask(temp.currCompSessionEdge) = temp.cellRoiIndex;
						if (should_enable_edge_layering_mode && edge_layering_is_outset_mode)
							obj.amalgamationMasks.cellROI_LookupMask(BW2_Outer) = temp.cellRoiIndex;
							obj.amalgamationMasks.cellROI_LookupMask(BW3_Outer) = temp.cellRoiIndex;
							obj.amalgamationMasks.cellROI_LookupMask(BW4_Outer) = temp.cellRoiIndex;
						end
						
						% Set cells in this cellROI region to opaque:
						obj.amalgamationMasks.AlphaConjunctionMask(temp.currCompSessionMask) = 1.0;
						% Set the opacity of cell in this cellROI region based on the number of days that the cell passed the threshold:
						obj.amalgamationMasks.AlphaRoiTuningScoreMask(temp.currCompSessionMask) = (double(temp.currRoiTuningScore) / 3.0);
						
						obj.amalgamationMasks.AlphaRoiConsistencyScoreMask(temp.currRoiConsistencyScore, temp.currCompSessionMask) = 1.0;

						if (should_enable_edge_layering_mode && edge_layering_is_outset_mode)
							obj.amalgamationMasks.AlphaConjunctionMask(BW2_Outer) = 1.0;
							obj.amalgamationMasks.AlphaConjunctionMask(BW3_Outer) = 1.0;
							obj.amalgamationMasks.AlphaConjunctionMask(BW4_Outer) = 1.0;
						end
						
						% Set the greyscale value to the ROIs tuning score, normalized by the maximum possible tuning score (indicating all three days were tuned)
						obj.amalgamationMasks.NumberOfTunedDays(temp.currCompSessionMask) = double(temp.currRoiTuningScore) / 3.0;
						
					end
					
					% TODO: Currently just use the preferred stimulus info from the first of the three sessions:
					temp.currMaximalIndexTuple = obj.preferredStimulusInfo.PreferredStimulus(temp.cellRoiIndex,j,:);
					temp.maxPrefAmpIndex = temp.currMaximalIndexTuple(1);
					temp.maxPrefFreqIndex = temp.currMaximalIndexTuple(2);
					
					if should_enable_edge_layering_mode
						if j <= 1
							if edge_layering_is_outset_mode
								temp.currCompSessionCustomEdgeMask = logical(squeeze(obj.roiMasks.OutsetEdge0(temp.cellRoiIndex,:,:)));
							else
								temp.currCompSessionCustomEdgeMask = logical(squeeze(obj.roiMasks.InsetEdge2(temp.cellRoiIndex,:,:)));
							end
						elseif j == 2
							if edge_layering_is_outset_mode
								temp.currCompSessionCustomEdgeMask = logical(squeeze(obj.roiMasks.OutsetEdge1(temp.cellRoiIndex,:,:)));
							else
								temp.currCompSessionCustomEdgeMask = logical(squeeze(obj.roiMasks.InsetEdge1(temp.cellRoiIndex,:,:)));
							end
						else
							if edge_layering_is_outset_mode
								temp.currCompSessionCustomEdgeMask = logical(squeeze(obj.roiMasks.OutsetEdge2(temp.cellRoiIndex,:,:)));
							else
								temp.currCompSessionCustomEdgeMask = logical(squeeze(obj.roiMasks.InsetEdge0(temp.cellRoiIndex,:,:)));
							end
						end

						obj.amalgamationMasks.PreferredStimulusAmplitudes(j, temp.currCompSessionCustomEdgeMask) = double(temp.maxPrefAmpIndex);
						obj.amalgamationMasks.PreferredStimulusFreqs(j, temp.currCompSessionCustomEdgeMask) = double(temp.maxPrefFreqIndex);
						
						if edge_layering_is_outset_mode
							% Fill in the main fill with nothing
							obj.amalgamationMasks.PreferredStimulusAmplitudes(j, temp.currCompSessionFill) = -1.0; % obj.amalgamationMasks.PreferredStimulusAmplitude: a numSessions x
							obj.amalgamationMasks.PreferredStimulusFreqs(j, temp.currCompSessionFill) = -1.0;
                        end
                        
                    else % else (NOT should_enable_edge_layering_mode)
						obj.amalgamationMasks.PreferredStimulusAmplitudes(j, temp.currCompSessionMask) = double(temp.maxPrefAmpIndex);
						obj.amalgamationMasks.PreferredStimulusFreqs(j, temp.currCompSessionMask) = double(temp.maxPrefFreqIndex);
					end
					
				end % end for numSessions
				
			end % end for each cell ROI

            
        end % end function buildSpatialTuningInfo
        
        
        
        function [obj] = allocateOutputObjects(obj, phoPipelineOptions)
            %% HELPER FUNCTION: allocateOutputObjects
            % Allocates the computed output objects.
            % masks: *one for each ROI*: matricies the size of the original images (512x512 for example) that specify specific pixels related to the ROIs.
            % amalgamationMasks: *only one that includes all ROIs*: matiricies the size of the original images (512x512 for example) that include all pixels related to ANY ROI.

            if exist('phoPipelineOptions','var')
                if isfield(phoPipelineOptions, 'imageDimensions')
                    imageDimensions = phoPipelineOptions.imageDimensions;
                else
                    imageDimensions = [512 512];
                end
            else
                imageDimensions = [512 512];
            end

            % obj.roiMasks: one for each cellROI
            obj.roiMasks.Fill = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));
            obj.roiMasks.Edge = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));
            
            obj.roiMasks.NeuropilFill = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));
            
            obj.roiMasks.OutsetEdge0 = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));
            obj.roiMasks.OutsetEdge1 = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));
            obj.roiMasks.OutsetEdge2 = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));

            obj.roiMasks.InsetEdge0 = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));
            obj.roiMasks.InsetEdge1 = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));
            obj.roiMasks.InsetEdge2 = zeros(obj.num_cellROIs, imageDimensions(1), imageDimensions(2));


            % Amalgamation Masks:
            obj.amalgamationMasks.cellROI_LookupMask = zeros(imageDimensions(1), imageDimensions(2)); % Maps every pixel in the image to the cellROI index of the cell it belongs to, if one exists.

            obj.amalgamationMasks.AlphaConjunctionMask = zeros(imageDimensions(1), imageDimensions(2));
            obj.amalgamationMasks.AlphaRoiTuningScoreMask = zeros(imageDimensions(1), imageDimensions(2));
            obj.amalgamationMasks.NumberOfTunedDays = zeros(imageDimensions(1), imageDimensions(2));

			obj.amalgamationMasks.AlphaRoiConsistencyScoreMask = zeros(obj.numOfSessions, imageDimensions(1), imageDimensions(2));

            % an amalgamationMask that will store the preferred stimuli for all cell ROIs, to be represented as colors
            obj.amalgamationMasks.PreferredStimulusAmplitudes = ones(obj.numOfSessions, imageDimensions(1), imageDimensions(2)) * -1;
            obj.amalgamationMasks.PreferredStimulusFreqs = ones(obj.numOfSessions, imageDimensions(1), imageDimensions(2)) * -1;


            obj.preferredStimulusInfo.PreferredStimulus = zeros(obj.num_cellROIs, obj.numOfSessions, 2);
            obj.preferredStimulusInfo.PreferredStimulus_LinearStimulusIndex = zeros(obj.num_cellROIs, obj.numOfSessions); % Instead of a tuple, it holds a value 1-26 that serves as a unique stimulus identity.

            % outputMaps.DidPreferredStimulusChange: keeps track of whether the preferredStimulus amplitude or frequency changed for a cellROI between sessions.
            obj.preferredStimulusInfo.DidPreferredStimulusChange = zeros(obj.num_cellROIs, (obj.numOfSessions-1));
			obj.preferredStimulusInfo.ChangeScores = zeros(obj.num_cellROIs, 1);
			obj.preferredStimulusInfo.InterSessionConsistencyScores = zeros(obj.num_cellROIs, 1);
			

            obj.roiComputedProperties.areas = zeros(obj.num_cellROIs, 1);
            obj.roiComputedProperties.boundingBoxes = zeros(obj.num_cellROIs, 4);
            obj.roiComputedProperties.centroids = zeros(obj.num_cellROIs, 2);

        end % end function allocateOutputObjects


		function [obj] = computeCurveAnalysis(obj)
			% Computes the derivatives and other meta information from the red line traces objects.
			zeroPaddingColumn = zeros([size(obj.redTraceLinesForAllStimuli, 1), size(obj.redTraceLinesForAllStimuli, 2)]);

			obj.computedRedTraceLinesAnalyses.first_derivative = cat(3, zeroPaddingColumn, diff(obj.redTraceLinesForAllStimuli, 1, 3));
			obj.computedRedTraceLinesAnalyses.second_derivative = cat(3, zeroPaddingColumn, diff(obj.computedRedTraceLinesAnalyses.first_derivative, 1, 3));
			% obj.computedRedTraceLinesAnalyses.second_derivative = diff(obj.redTraceLinesForAllStimuli, 2, 3);

			%% Normalized Curves
			%% Get Information about the ranges and extrema:
			obj.computedRedTraceLinesAnalyses.Extrema.local_max_peaks = max(obj.redTraceLinesForAllStimuli, [], [2 3]); % [159 x 1]
			obj.computedRedTraceLinesAnalyses.Extrema.local_min_extrema = min(obj.redTraceLinesForAllStimuli, [], [2 3]); % [159 x 1]
			obj.computedRedTraceLinesAnalyses.Range = obj.computedRedTraceLinesAnalyses.Extrema.local_max_peaks - obj.computedRedTraceLinesAnalyses.Extrema.local_min_extrema;

			% LargestMagnitudeExtrema: The extrema with the largest abs(magnitude), used to normalize to a range [-1 1]
			obj.computedRedTraceLinesAnalyses.Extrema.LargestMagnitudeExtrema = max([abs(obj.computedRedTraceLinesAnalyses.Extrema.local_max_peaks), abs(obj.computedRedTraceLinesAnalyses.Extrema.local_min_extrema)], [], 2);

			obj.computedRedTraceLinesAnalyses.Normalized = obj.redTraceLinesForAllStimuli ./ obj.computedRedTraceLinesAnalyses.Extrema.LargestMagnitudeExtrema; % Normalize each one by its highest extrema.

			


			obj.computedAllTraceLinesAnalyses.Extrema.local_max_peaks = max(obj.tracesForAllStimuli, [], [2 3 4]); % [159 x 1]
			obj.computedAllTraceLinesAnalyses.Extrema.local_min_extrema = min(obj.tracesForAllStimuli, [], [2 3 4]); % [159 x 1]
			obj.computedAllTraceLinesAnalyses.Range = obj.computedAllTraceLinesAnalyses.Extrema.local_max_peaks - obj.computedAllTraceLinesAnalyses.Extrema.local_min_extrema;
					

			% activePlotExtrema.local_max_peaks = max([obj.computedRedTraceLinesAnalyses.Extrema.local_max_peaks, obj.computedAllTraceLinesAnalyses.Extrema.local_max_peaks], [], 2); % For each cellROI, get the maximum value (whether it is on the average or the traces themsevles).
			% activePlotExtrema.local_min_extrema = min([obj.computedRedTraceLinesAnalyses.Extrema.local_min_extrema, obj.computedAllTraceLinesAnalyses.Extrema.local_min_extrema], [], 2);

		end


		function [obj] = setupAutotuningDetection(obj, autoTuningDetection)
			% setupAutotuningDetection: auto-determine the tuning for a given cellROI
			obj.autoTuningDetection = autoTuningDetection;

			% obj.redTraceLinesForAllStimuli is [159 26 150]

			% D = dot(obj.redTraceLinesForAllStimuli, repmat(obj.autoTuningDetection.detectionCurve, [size(obj.redTraceLinesForAllStimuli, 1) size(obj.redTraceLinesForAllStimuli, 2)]), 3);

			obj.computedRedTraceLinesAnalyses.autotuningValue = zeros([size(obj.redTraceLinesForAllStimuli, 1), size(obj.redTraceLinesForAllStimuli, 2)]);

			for i = 1:size(obj.redTraceLinesForAllStimuli, 1)
				for j = 1:size(obj.redTraceLinesForAllStimuli, 2)
					% obj.computedRedTraceLinesAnalyses.autotuningValue(i, j) = dot(obj.autoTuningDetection.detectionCurve, squeeze(obj.redTraceLinesForAllStimuli(i, j, :)));
					% Need to use the normalized value so the outputs are comparible:
					obj.computedRedTraceLinesAnalyses.autotuningValue(i, j) = dot(obj.autoTuningDetection.detectionCurve, squeeze(obj.computedRedTraceLinesAnalyses.Normalized(i, j, :)));
				end
			end

		end



    end % end methods
end % end class

