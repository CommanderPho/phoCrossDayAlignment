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
        active_DFF
    end
    methods
       function obj = set.active_DFF(obj, value)
           obj.active_DFF = value;
       end  
    end
    
    
    %% Computed Properties:
    properties (Dependent)
        num_cellROIs
        numOfSessions
    end
    methods
       function num_cellROIs = get.num_cellROIs(obj)
          num_cellROIs = length(obj.uniqueComps);
       end
       function numOfSessions = get.numOfSessions(obj)
          numOfSessions = length(obj.dateStrings);
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

