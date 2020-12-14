function [out_axes, h] = fnPhoMatrixPlotDetailed(data, extantParentH)
    %fnPhoMatrixPlotDetailed currently does nothing more than the regular fnPhoMatrixPlot(...) function.
    %   data should be a 2D matrix.
    
    if (~exist('extantParentH','var') || ~isgraphics(extantParentH))
        figH = gcf; % Get the current figure
        axH = gca; % Get the current axis
    else
            
        if isgraphics(extantParentH,'figure')
            figH = extantParentH; % use the existing provided figure
            figure(figH);
            axH = gca;
        elseif isgraphics(extantParentH,'axes')
            axH = extantParentH;
        else
            error('Unknown graphics type!');
        end
    end
    
    
    

    dim.x = size(data, 1);
    dim.y = size(data, 2);

    [out_axes] = fnPlotHelper_SetupMatrixDisplayAxes(axH, size(data));
    
    xx = [1:dim.x];
    yy = [1:dim.y];
    h = imagesc(out_axes, 'XData', xx, 'YData', yy, 'CData', data, 'AlphaData', .5);
    colorbar(out_axes);
end