function [h] = fnPhoMatrixPlot(data)
%FNPHOMATRIXPLOT Plots a 2D matrix of unnormalized data.
%   data should be a 2D matrix.
dim.x = size(data, 1);
dim.y = size(data, 2);

% [xx, yy] = meshgrid(1:dim.x, 1:dim.y);
% h = plot3(xx, yy, data);

xx = [1:dim.x];
yy = [1:dim.y];
h = imagesc(xx, yy, data);
colorbar

end

