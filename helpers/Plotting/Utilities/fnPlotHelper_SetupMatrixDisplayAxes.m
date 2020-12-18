function [ax] = fnPlotHelper_SetupMatrixDisplayAxes(ax, matrixSize)
        % fnPlotHelper_SetupMatrixDisplayAxes: Plots a grid to display a matrix in
        % matrixSize: [numRows numColumns]
        % Starts the plot at the top left (like a matrix)
        numRows = matrixSize(1);
        numColumns = matrixSize(2);
        
        numXTicks = numColumns - 1;
        numYTicks = numRows - 1;
        
        cellSize.width = (1.0 / numColumns);
        cellSize.height = (1.0 / numRows);
        
        cellSize.halfWidth = (cellSize.width / 2.0);
        cellSize.halfHeight = (cellSize.height / 2.0);
        
        ax.Toolbar.Visible = 'off'; % we know this can be slow, check the actual performance.
        disableDefaultInteractivity(ax);
        
        ax.Layer = 'top'; % Place the ticks and grid lines on top of the plot
        ax.GridAlpha = 0.9;
        ax.Box = 'on';
        ax.BoxStyle = 'full'; % Only affects 3D views
        ax.YDir = 'reverse'; % Reverse the y-axis direction, so the origin is at the top left corner.
        
        ax.XTick = (1:numXTicks) + 0.5;
        ax.XTickLabel = {};
        ax.YTick = (1:numYTicks) + 0.5;
        ax.YTickLabel = {};
        
        
        ax.YLim = [0.5 (numRows+0.5)];
        
        is_column_vector = false;
        is_row_vector = false;
        
        if numRows > 1
            ax.YGrid = 'on';
        else
            ax.YGrid = 'off';
            is_row_vector = true;
        end
        
        ax.XLim = [0.5 (numColumns+0.5)];
        if numColumns > 1
            ax.XGrid = 'on';
        else
            ax.XGrid = 'off';
            is_column_vector = true;
        end
        
        is_vector = (is_column_vector || is_row_vector);
        
        %% Add Cell Text Labels:
        for i = 1:numRows
%             curr_cell_offset_start_x = ((i-1) * cellSize.height);
%             curr_cell_offset_center_x = curr_cell_offset_start_x + cellSize.halfWidth;
            
            for j = 1:numColumns
%                 curr_cell_offset_start_y = ((j-1) * cellSize.width);
%                 curr_cell_offset_center_y = curr_cell_offset_start_y + cellSize.halfHeight;
                if is_column_vector
                    curr_cell_label = sprintf('%d',i);
                elseif is_row_vector
                    curr_cell_label = sprintf('%d',j);
                else
                    curr_cell_label = sprintf('(%d, %d)',i, j);
                end                
%                 h = text(ax, curr_cell_offset_center_x, curr_cell_offset_center_y, curr_cell_label, 'HorizontalAlignment','center','VerticalAlignment','middle');
                h = text(ax, j, i, curr_cell_label, 'HorizontalAlignment','center','VerticalAlignment','middle');

            end 
        end

       
    end