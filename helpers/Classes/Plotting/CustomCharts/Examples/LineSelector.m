classdef LineSelector < Chart
    %LINESELECTOR Chart displaying a collection of line plots, possibly on
    %different scales.
    %
    % Copyright 2018 The MathWorks, Inc.
    
    properties ( Hidden, Constant )
        % Product dependencies.
        Dependencies = "MATLAB"
    end % properties ( Hidden, Constant )
    
    % Public interface properties.
    properties ( Dependent )
        % Chart x-data.
        XData
        % Chart y-data.
        YData
        % Axes x-label.
        XLabel
        % Axes y-label.
        YLabel
        % Axes title.
        Title
        % Legend text.
        LegendText
        % Legend font size.
        LegendFontSize
        % Legend location.
        LegendLocation
        % Legend orientation.
        LegendOrientation
        % Legend visibility.
        LegendVisible
        % Grid display.
        Grid
        % Color of the selected line.
        SelectedColor
        % Color of the unselected line or lines.
        TraceColor
        % Limits for the x-axis.
        XLim
        % Limits for the y-axis.
        YLim
        % Index of the selected line.
        SelectedLineIndex
    end % properties ( Dependent )
    
    properties ( Access = private )
        % Chart axes.
        Axes
        % Backing property for the x-data.
        XData_ = NaN;
        % Backing property for the y-data.
        YData_ = NaN;
        % Line objects.
        Lines
        % Legend.
        Legend
        % Backing property for the highlight color.
        SelectedColor_ = [0, 0.447, 0.741];
        % Backing property for the color of the unselected line(s).
        TraceColor_ = 0.85 * ones( 1, 3 );
        % Backing property for the index of the selected line.
        SelectedLineIndex_ = [];
    end % properties ( Access = private )
    
    properties ( Dependent, Access = private )
        % Columnwise rescaled data, in the range [0, 1].
        YData01
        % Columnwise ranges.
        YDataRange
        % Columnwise minima.
        YDataMin
    end % properties ( Dependent, Access = private )
    
    methods
        
        function obj = LineSelector( varargin )
            %LINESELECTOR Constructor for the LineSelector chart. All
            %inputs are specified using name-value pairs.
            
            % Create a temporary figure to act as the chart's Parent.
            f = figure( 'Visible', 'off' );
            oc = onCleanup( @() delete( f ) );
            obj.Parent = f;
            
            % Create the axes.
            obj.Axes = axes( "Parent", obj.Panel, ...
                "HandleVisibility", "off" );
            
            % Create the legend.
            obj.Legend = legend( obj.Axes, 'String', {}, ...
                'ItemHitFcn', @obj.onLegendClicked );
            
            % Remove the chart axes' temporary Parent.
            obj.Parent = [];
            
            % Set the chart properties.
            obj.setProperties( varargin{:} )
            
        end % constructor
        
        % Get/set methods.
        function value = get.XData( obj )
            
            value = obj.XData_;
            
        end % get.XData
        
        function set.XData( obj, value )
            
            % Perform basic validation.
            validateattributes( value, {'double'}, ...
                {'real', 'vector'}, 'LineSelector/set.XData', ...
                'the x-data' )
            
            % Decide how to modify the chart data.
            nX = numel( value );
            nY = size( obj.YData_, 1 );
            
            % Truncate the y-data if the new x-data is shorter.
            if nX < nY
                obj.YData_(nX+1:end, :) = [];
                % Otherwise, pad the y-data with NaNs.
            else
                obj.YData_(end+1:nX, :) = NaN;
            end % if
            
            % Set the internal x-data.
            obj.XData_ = value(:);
            
            % Update the chart graphics.
            update( obj );
            
        end % set.XData
        
        function value = get.YData( obj )
            
            value = obj.YData_;
            
        end % get.YData
        
        function set.YData( obj, value )
            
            % Perform basic validation.
            validateattributes( value, {'double'}, {'real', '2d'}, ...
                'LineSelector/set.YData', 'the y-data' )
            
            % Decide how to modify the chart data.
            nX = numel( obj.XData_ );
            nY = size( value, 1 );
            
            % Truncate the x-data if the new y-data is shorter.
            if nY < nX
                obj.XData_(nY+1:end) = [];
                % Otherwise, pad the x-data with NaNs.
            else
                obj.XData_(end+1:nY) = NaN;
            end % if
            
            % Set the internal y-data.
            if isvector(value)
                obj.YData_ = value(:);
            else
                obj.YData_ = value;
            end % if
            
            % Update the chart graphics.
            update( obj );
            
        end % set.YData
        
        function value = get.XLabel( obj )
            value = obj.Axes.XLabel;
        end % get.XLabel
        
        function set.XLabel( obj, value )
            obj.Axes.XLabel = value;
        end % set.XLabel
        
        function value = get.YLabel( obj )
            value = obj.Axes.YLabel;
        end % get.YLabel
        
        function set.YLabel( obj, value )
            obj.Axes.YLabel = value;
        end % set.YLabel
        
        function value = get.Title( obj )
            value = obj.Axes.Title;
        end % get.Title
        
        function set.Title( obj, value )
            obj.Axes.Title = value;
        end % set.Title
        
        function value = get.LegendText( obj )
            value = obj.Legend.String;
        end % get.LegendText
        
        function set.LegendText( obj, value )
            % Check the proposed legend text.
            assert( iscellstr( value ) && ...
                numel( value ) == length( obj.Lines ), ...
                ['Legend text must be a cell array of character ', ...
                'vectors with length ', ...
                'equal to the number of lines.'] ) %#ok<*ISCLSTR>
            obj.Legend.String = value;
        end % set.LegendText
        
        function value = get.LegendFontSize( obj )
            value = obj.Legend.FontSize;
        end % get.LegendFontSize
        
        function set.LegendFontSize( obj, value )
            obj.Legend.FontSize = value;
        end % set.LegendFontSize
        
        function value = get.LegendLocation( obj )
            value = obj.Legend.Location;
        end % get.LegendLocation
        
        function set.LegendLocation( obj, value )
            obj.Legend.Location = value;
        end % set.LegendLocation
        
        function value = get.LegendOrientation( obj )
            value = obj.Legend.Orientation;
        end % get.LegendOrientation
        
        function set.LegendOrientation( obj, value )
            obj.Legend.Orientation = value;
        end % set.LegendOrientation
        
        function value = get.LegendVisible( obj )
            value = obj.Legend.Visible;
        end % get.LegendVisible
        
        function set.LegendVisible( obj, value )
            obj.Legend.Visible = value;
        end % set.LegendVisible
        
        function value = get.Grid( obj )
            value = obj.Axes.XGrid;
        end % get.Grid
        
        function set.Grid( obj, value )
            set( obj.Axes, 'XGrid', value, ...
                'YGrid', value );
        end % set.Grid
        
        function value = get.YData01( obj )
            value = (obj.YData_ - obj.YDataMin) ./ obj.YDataRange;
        end % get.YData01
        
        function value = get.YDataRange( obj )
            value = max( obj.YData_, [], 1 ) - obj.YDataMin;
        end % get.YDataRange
        
        function value = get.YDataMin( obj )
            value = min( obj.YData_, [], 1 );
        end % get.YDataMin
        
        function value = get.SelectedColor( obj )
            value = obj.SelectedColor_;
        end % get.SelectedColor
        
        function set.SelectedColor( obj, value )
            
            % Validate the user-specified color.
            validatecolor( value )
            % Set the property value.
            obj.SelectedColor_ = value;
            % Update the selected line if necessary.
            selectedLineIdx = obj.SelectedLineIndex_;
            if any( selectedLineIdx )
                obj.Lines(selectedLineIdx).Color = value;
                obj.Axes.YColor = value;
            end % if
            
        end % set.SelectedColor
        
        function value = get.TraceColor( obj )
            
            value = obj.TraceColor_;
            
        end % get.TraceColor
        
        function set.TraceColor( obj, value )
            
            % Validate the user-specified color.
            validatecolor( value )
            % Set the property value.
            obj.TraceColor_ = value;
            % Update the unselected line(s) if necessary.
            unselectedLineIdx = setdiff( 1:numel( obj.Lines ), ...
                obj.SelectedLineIndex_ );
            set( obj.Lines(unselectedLineIdx), 'Color', value )
            
        end % set.TraceColor
        
        function value = get.XLim( obj )
            value = obj.Axes.XLim;
        end % get.XLim
        
        function set.XLim( obj, value )
            obj.Axes.XLim = value;
        end % set.XLim
        
        function value = get.YLim( obj )
            value = obj.Axes.YLim;
        end % get.YLim
        
        function set.YLim( obj, value )
            obj.Axes.YLim = value;
        end % set.YLim
        
        function value = get.SelectedLineIndex( obj )
            value = obj.SelectedLineIndex_;
        end % get.SelectedLineIndex
        
        function set.SelectedLineIndex( obj, value )
            
            % Reset the chart if the user specifies an empty value.
            if isempty( value )
                obj.SelectedLineIndex_ = [];
                reset( obj );
            else
                % Otherwise, selected the specified line.
                validateattributes( value, {'double'}, ...
                    {'scalar', 'integer', ...
                    '>=', 1, '<=', numel( obj.Lines )}, mfilename(), ...
                    'the index of the selected line' )
                % Set the internal value.
                obj.SelectedLineIndex_ = value;
                % Trigger the line selected callback.
                onLineClicked( obj, obj.Lines(value) );
            end % if
            
        end % set.SelectedLineIndex
        
    end % methods
    
    methods ( Access = private )
        
        function update( obj )
            
            % Count the number of lines required.
            nNew = size( obj.YData_, 2 );
            
            % Count the number of existing lines.
            nOld = numel( obj.Lines );
            
            if nNew > nOld
                % Create new lines.
                nToCreate = nNew - nOld;
                obj.Lines = [obj.Lines; gobjects( nToCreate, 1 )];
                for k = 1:nToCreate
                    obj.Lines(nOld+k) = line( ...
                        obj.Axes, NaN, NaN, ...
                        'Color', obj.TraceColor );
                end % for
            elseif nNew < nOld
                % Remove the unnecessary lines.
                delete( obj.Lines(nNew+1:nOld) );
                obj.Lines(nNew+1:nOld) = [];
            end % if
            
            % Update the data for all lines.
            for k = 1:nNew
                set( obj.Lines(k), 'XData', obj.XData_, ...
                    'YData', obj.YData01(:, k) )
            end % for
            
            % Enable interactivity and gray out all lines.
            reset( obj );
            
        end % update
        
        function onLineClicked( obj, s, ~ )
            
            % Determine the index of the selected line.
            selectedIdx = find( obj.Lines == s );
            % Record this value in the object.
            obj.SelectedLineIndex_ = selectedIdx;
            % Gray out all lines.
            set( obj.Lines, 'LineWidth', 0.5, ...
                'Color', obj.TraceColor )
            % Highlight the selected line.
            set( obj.Lines(selectedIdx), 'LineWidth', 3, ...
                'Color', obj.SelectedColor, ...
                'YData', obj.YData_(:, selectedIdx) )
            set( obj.Axes, 'YColor', obj.SelectedColor )
            % Adjust the y-data for all other lines.
            notSelectedIdx = setdiff( 1:numel( obj.Lines ), selectedIdx );
            for k = notSelectedIdx
                adjustedYData = obj.YData01(:, k) * ...
                    obj.YDataRange(selectedIdx) + ...
                    obj.YDataMin(selectedIdx);
                set( obj.Lines(k), 'YData', adjustedYData )
            end % for
            
        end % onLineClicked
        
        function onLegendClicked( obj, ~, e )
            
            onLineClicked( obj, e.Peer );
            
        end % onLegendClicked
        
        function reset( obj )
            
            % Enable interactivity and gray out all lines.
            set( obj.Lines, 'ButtonDownFcn', @obj.onLineClicked, ...
                'LineWidth', 0.5, ...
                'Color', obj.TraceColor )
            % Restore the original y-axis color.
            obj.Axes.YColor = 'k';
            % Record an empty selection.
            obj.SelectedLineIndex_ = [];
            
        end % reset
        
    end % methods ( Access = private )
    
end % class definition

function validatecolor( color )

% Verify that the input is a valid color.
narginchk( 1, 1 )
validateattributes( color, {'char', 'double'}, {}, ...
    mfilename(), 'the color' )

if ischar( color )
    validatestring( color, {'r', 'g', 'b', 'k', 'y', 'c', 'w', 'm', ...
        'red', 'green', 'blue', 'black', 'yellow', 'cyan', 'white', ...
        'magenta'}, mfilename(), 'the color' );
else
    validateattributes( color, {'double'}, {'real', 'size', [1, 3], ...
        '>=', 0, '<=', 1 }, mfilename(), 'the color' )
end % if

end % validatecolor