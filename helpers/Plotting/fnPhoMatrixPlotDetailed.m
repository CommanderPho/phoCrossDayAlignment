function [out_axes, h] = fnPhoMatrixPlotDetailed(data, plottingOptions, extantParentH)
    %fnPhoMatrixPlotDetailed currently does nothing more than the regular fnPhoMatrixPlot(...) function.
    %   data should be a 2D matrix.
    
    if ~exist('plottingOptions','var')
        plottingOptions.should_show_colorbar = true;
    end
    
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
    
    h = imagesc(out_axes, 'XData', yy, 'YData', xx, 'CData', data, 'AlphaData', .5);
    
    if plottingOptions.should_show_colorbar
        colorbar(out_axes);
    end
end