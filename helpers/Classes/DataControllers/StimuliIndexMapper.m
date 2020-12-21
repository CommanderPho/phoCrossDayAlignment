classdef StimuliIndexMapper
    %STIMULIINDEXMAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        uniqueAmps
        uniqueFreqs
        
        uniqueStimuli
        
        indexMap_AmpsFreqs2StimulusArray
        indexMap_StimulusLinear2AmpsFreqsArray % This is a 26 x 2 array, where the two columns are the [ampIndex, frequencyIndex] corresponding to the linear stimulus index for that row.

    end

	    % Computed Properties:
    properties (Dependent)
        numStimuli
    end
    
    methods
       function numStimuli = get.numStimuli(obj)
          numStimuli = size(obj.uniqueStimuli,1);
       end
    end


    
    methods
        function obj = StimuliIndexMapper(uniqueStimuli,uniqueAmps,uniqueFreqs,indexMap_AmpsFreqs2StimulusArray,indexMap_StimulusLinear2AmpsFreqsArray)
            %STIMULIINDEXMAPPER Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.uniqueAmps = uniqueAmps;
            obj.uniqueFreqs = uniqueFreqs;
            
            obj.uniqueStimuli = uniqueStimuli;
            
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


    end % ends methods block


	methods %% formatting methods block
		% function [formattedString] = getFormattedString_Depth(obj, linearStimulusIndex)
        %     %getFormattedString_Depth Returns the correct Depth string with units corresponding to the linearStimulusIndex
		% 	[depthIndex, freqIndex, depthValues, freqValues] = getDepthFreqIndicies(obj, linearStimulusIndex)
		% 	formattedString = sprintf('%d % Depth', depthValues);
        % end

		% function [formattedString] = getFormattedString_Freq(obj, linearStimulusIndex)
        %     %getFormattedString_Freq Converts a linear stimulus index into a 1-6 depth or freq index
        %     %   Detailed explanation goes here
		% 	[depthIndex, freqIndex, depthValues, freqValues] = getDepthFreqIndicies(obj, linearStimulusIndex)
		% 	formattedString = sprintf('%d % Depth', depthValues);
        % end


		function [formattedString] = getFormattedString_Depth(obj, depthValue, shouldPrintLiteralDepthSuffix)
            %getFormattedString_Depth Returns the correct depth string with units (like '80% Depth') for the provided depthValue
			if ~exist('shouldPrintLiteralDepthSuffix','var')
				shouldPrintLiteralDepthSuffix = false;
			end

			formattedString = sprintf('%d%%', (depthValue * 100)); % Note the double percent (%%) in the string is required to escape the % command of sprintf
			if shouldPrintLiteralDepthSuffix
				formattedString = [formattedString ' Depth'];
			end
        end

		function [formattedString] = getFormattedString_Freq(obj, freqValue)
            %getFormattedString_Freq Converts a linear stimulus index into a 1-6 depth or freq index
			formattedString = sprintf('%dHz', freqValue);
        end


	end % end formatting methods block

end

