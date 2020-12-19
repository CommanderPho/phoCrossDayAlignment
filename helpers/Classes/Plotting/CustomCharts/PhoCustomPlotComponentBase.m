% PhoCustomPlotComponentBase.m
classdef PhoCustomPlotComponentBase < Chart
    %PhoCustomPlotComponentBase Chart for managing a variable-color curve plotted against
    %a date/time vector.
    %
    % Copyright 2018 The MathWorks, Inc.
    
    properties ( Hidden, Constant )
        % Product dependencies.
        Dependencies = "MATLAB"
    end % properties ( Hidden, Constant )
    
    % Public interface properties.
    properties ( Dependent )
        % Axes x-label.
        XLabel
        % Axes y-label.
        YLabel
        % Axes title.
        Title
        % Grid display.
        Grid
    end % properties ( Dependent )
    
    properties ( Access = private )
        % Chart axes.
        Axes
    end % properties ( Access = private )
    

    methods
        function obj = PhoCustomPlotComponentBase( varargin )
            
            % Create the axes.
            obj.Axes = axes( "Parent", obj.Panel, ...
                "HandleVisibility", "off" );
            % Set the (x, y) view for the axes.
            view( obj.Axes, 2 );
            % Set the chart properties.
            setProperties( obj, varargin{:} )
            
        end % constructor
        
        function xl = get.XLabel( obj )
            xl = obj.Axes.XLabel;
        end % get.XLabel
        
        function set.XLabel( obj, proposedXLabel )
            obj.Axes.XLabel = proposedXLabel;
        end % set.XLabel
        
        function yl = get.YLabel( obj )
            yl = obj.Axes.YLabel;
        end % get.YLabel
        
        function set.YLabel( obj, proposedYLabel )
            obj.Axes.YLabel = proposedYLabel;
        end % set.YLabel
        
        function t = get.Title( obj )
            t = obj.Axes.Title;
        end % get.Title
        
        function set.Title( obj, proposedTitle )
            obj.Axes.Title = proposedTitle;
        end % set.Title
        
        function gridStatus = get.Grid( obj )
            gridStatus = obj.Axes.XGrid;
        end % get.Grid
        
        function set.Grid( obj, proposedGridStatus )
            set( obj.Axes, 'XGrid', proposedGridStatus, ...
                           'YGrid', proposedGridStatus );
        end % set.Grid
        
    end % methods
    
    methods ( Access = private )
        
        function update( obj )
            % Should this be pure virtual?
        end % update
        
    end % methods ( Access = private )
    
end % class definition