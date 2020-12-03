classdef FigureLayoutManager
    %FIGURELAYOUTMANAGER An overkill class that serves to align the edges of figure windows. Not complete.
    %   Detailed explanation goes here
    
    properties
        managedFigureHandles
    end
    
    methods
        function obj = FigureLayoutManager(managedFigureHandles)
            %FIGURELAYOUTMANAGER Construct an instance of this class
            %   Detailed explanation goes here
            obj.managedFigureHandles = managedFigureHandles;
        end
        
        function figure_info = getInfo(obj, figureHandleRef)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
%             figure_info.handle = obj.managedFigureHandles(figureHandleIndex);
%             figure_info.original_position = get(figure_info.handle, 'Position');
%             figure_info.x = figure_info.original_position(1);
%             figure_info.y = figure_info.original_position(2);
%             figure_info.width = figure_info.original_position(3);
%             figure_info.height = figure_info.original_position(4);

            if isnumeric(figureHandleRef)
                figure_info = FigureLayoutInfo(obj.managedFigureHandles(figureHandleRef));
            elseif ishandle(figureHandleRef)
                figure_info = FigureLayoutInfo(figureHandleRef);
            else
                error('invalid type')
            end
        end
        
        function desired_position = bindSameWidth(obj, relative_figHandleRef, target_figureHandleRef)
            %METHOD1 Summary of this method goes here
            relative_figure_info = obj.getInfo(relative_figHandleRef);
            target_figure_info = obj.getInfo(target_figureHandleRef);
            
            desired_position = target_figure_info.position;
            % Bind Same width:
            desired_position(3) = relative_figure_info.width;
            
            set(target_figure_info.handle, 'Position', desired_position);
        end
        
        function desired_position = bindAlignedEdgeLeft(obj, relative_figHandleRef, target_figureHandleRef)
            %METHOD1 Summary of this method goes here
            relative_figure_info = obj.getInfo(relative_figHandleRef);
            target_figure_info = obj.getInfo(target_figureHandleRef);
            
            desired_position = target_figure_info.position;

            % Bind Same Left Edge alignment:
            desired_position(1) = relative_figure_info.x;
            
            set(target_figure_info.handle, 'Position', desired_position);
        end
        
        function desired_position = bindAlignedTopTargetEdgeToBottomReferenceEdge(obj, relative_figHandleRef, target_figureHandleRef, withOffsetSpacing)
            %METHOD1 Summary of this method goes here
            relative_figure_info = obj.getInfo(relative_figHandleRef);
            target_figure_info = obj.getInfo(target_figureHandleRef);
            
            desired_position = target_figure_info.position;

            % Bind top target edge to bottom reference edge:
            if ~exist('withOffsetSpacing','var')
                withOffsetSpacing = 0;
            end
            desired_position(2) = relative_figure_info.y - (withOffsetSpacing + target_figure_info.height);

            set(target_figure_info.handle, 'Position', desired_position);
        end
        
                
        
    end
end

