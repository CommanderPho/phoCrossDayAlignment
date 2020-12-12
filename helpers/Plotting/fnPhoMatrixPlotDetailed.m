function [h] = fnPhoMatrixPlotDetailed(data)
    %fnPhoMatrixPlotDetailed currently does nothing more than the regular fnPhoMatrixPlot(...) function.
    %   data should be a 2D matrix.

    
    dim.x = size(data, 1);
    dim.y = size(data, 2);

    % [xx, yy] = meshgrid(1:dim.x, 1:dim.y);
    % h = plot3(xx, yy, data);

    xx = [1:dim.x];
    yy = [1:dim.y];
    h = imagesc(xx, yy, data);

%     currAxesPosition = get(gca, 'Position');
% %     cell_height = 1;
% %     cell_width = 1;
%     
%     % "height" and "width" here refer to the plotting conventions, not the abnormal imagesc conventions
%     cell_height = currAxesPosition(4)/dim.x;
%     cell_width = currAxesPosition(3)/dim.y;
%     
%     % strangely this stupid thing is sideways:
% %     x_cell_centers = h.XData - 0.5;
% %     y_cell_centers = h.YData - 0.5;
%     
%     
%     for i = 1:dim.x
%         for j = 1:dim.y
% %             curr_cell_x_center = currAxesPosition(1) + (i * (cell_width/2.0));
% %             curr_cell_y_center = currAxesPosition(2) + (j * (cell_height/2.0));
% 
% %             curr_cell_x_center = currAxesPosition(1) + (i * (cell_width/2.0));
% %             curr_cell_y_center = currAxesPosition(2) + (j * (cell_height/2.0));
% 
%             curr_cell_x_center = currAxesPosition(1) + (i * (cell_height/2.0));
%             curr_cell_y_center = currAxesPosition(2) + (j * (cell_width/2.0));
%             
%             
%             curr_cell_string = sprintf('%d, %d', i, j);
%             annotation(gcf,'textbox',...
%             [curr_cell_y_center curr_cell_x_center cell_width cell_height],...
%             'Color',[1 0.0745098039215686 0.650980392156863],...
%             'VerticalAlignment','middle',...
%             'String',curr_cell_string,...
%             'Margin',0,...
%             'Interpreter','none',...
%             'HorizontalAlignment','center',...
%             'FontSize',12,...
%             'FitBoxToText','off',...
%             'EdgeColor','none');
%         end
%     end
    
    colorbar
end