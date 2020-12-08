plotting_options.subtightplot.gap = [0.01/26 0.1]; % [intra_graph_vertical_spacing, intra_graph_horizontal_spacing]
plotting_options.subtightplot.width_h = [0.01 0.05]; % Looks like [padding_bottom, padding_top]
plotting_options.subtightplot.width_w = [0.12 0.01];
plotting_options.opt = {plotting_options.subtightplot.gap, plotting_options.subtightplot.width_h, plotting_options.subtightplot.width_w}; % {gap, width_h, width_w}
subplot = @(m,n,p) subtightplot(m, n, p, plotting_options.opt{:}); 