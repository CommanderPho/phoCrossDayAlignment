classdef FigureLayoutInfo
    %FIGURELAYOUTINFO A wrapper around a handle object with a 'Position' property, like a figure
    %   TODO: this should really be refactored into a pure object, not one based on the handle.
    
    properties
        handle
    end
    
    %% Computed Properties:
    properties (Dependent)
        position
        x
        y
        width
        height
    end
    
    methods
       function position = get.position(obj)
          position = get(obj.handle, 'Position');
       end
       function x = get.x(obj)
          x = obj.position(1);
       end
       function y = get.y(obj)
          y = obj.position(2);
       end
       function width = get.width(obj)
          width = obj.position(3);
       end
       function height = get.height(obj)
          height = obj.position(4);
       end
    end
    
    % Main methods block:
    methods
        function obj = FigureLayoutInfo(figureH)
            %FIGURELAYOUTINFO Construct an instance of this class
            %   Detailed explanation goes here
            obj.handle = figureH;
        end
        
    end
end

