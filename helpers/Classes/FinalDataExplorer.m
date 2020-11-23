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
        
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end


    end
end

