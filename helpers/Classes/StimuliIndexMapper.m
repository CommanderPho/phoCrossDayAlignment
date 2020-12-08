classdef StimuliIndexMapper
    %STIMULIINDEXMAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        uniqueAmps
        uniqueFreqs
        
        uniqueStimuli
        numStimuli
        indexMap_AmpsFreqs2StimulusArray
        indexMap_StimulusLinear2AmpsFreqsArray % This is a 26 x 2 array, where the two columns are the [ampIndex, frequencyIndex] corresponding to the linear stimulus index for that row.

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




        function [depthIndex, freqIndex, depthValues, freqValues] = getDepthFreqIndicies(obj, linearStimulusIndex)
            %getDepthFreqIndicies Converts a linear stimulus index into a 1-6 depth or freq index
            %   Detailed explanation goes here
			depthFreqIndexTuple = obj.indexMap_StimulusLinear2AmpsFreqsArray(linearStimulusIndex,:);
			depthIndex = depthFreqIndexTuple(:,1);
			freqIndex = depthFreqIndexTuple(:,2);

			depthValues = obj.uniqueAmps(depthIndex);
			freqValues = obj.uniqueFreqs(freqIndex);

			% depthFreqsValues = [depthValues, freqValues];
        end
		

    end
end

