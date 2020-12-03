classdef PlotManager < handle & matlab.mixin.CustomDisplay
    %PLOTMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        activeFigures
    end
    
    methods
        function obj = PlotManager(activeFigures)
            %PLOTMANAGER Construct an instance of this class
            %   Detailed explanation goes here
            if exist('activeFigures','var')
                obj.activeFigures = activeFigures;
            else
                obj.activeFigures = []; % empty array
            end
            
        end
        

        
    end
end

