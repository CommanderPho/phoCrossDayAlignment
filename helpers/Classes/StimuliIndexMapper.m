classdef StimuliIndexMapper
    %STIMULIINDEXMAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        uniqueAmps
        uniqueFreqs
        
        uniqueStimuli
        numStimuli
        indexMap_AmpsFreqs2StimulusArray
        indexMap_StimulusLinear2AmpsFreqsArray

    end
    
    methods
        function obj = StimuliIndexMapper(uniqueStimuli,uniqueAmps,uniqueFreqs,indexMap_AmpsFreqs2StimulusArray,indexMap_StimulusLinear2AmpsFreqsArray)
            %STIMULIINDEXMAPPER Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.uniqueAmps = uniqueAmps;
            obj.uniqueFreqs = uniqueFreqs;
            
            obj.uniqueStimuli = uniqueStimuli;
            obj.numStimuli = size(uniqueStimuli,1);
            
            obj.indexMap_AmpsFreqs2StimulusArray = indexMap_AmpsFreqs2StimulusArray;
            obj.indexMap_StimulusLinear2AmpsFreqsArray = indexMap_StimulusLinear2AmpsFreqsArray;
            
%             obj.uniqueFreqs = uniqueFreqs;
            
        end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end

    end
end

