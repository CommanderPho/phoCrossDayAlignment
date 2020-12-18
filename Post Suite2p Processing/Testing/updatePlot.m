function updatePlot(new_index)
    global plot_manager_cellRoiPlot;
%     plot_manager_cellRoiPlot = evalin('base','plot_manager_cellRoiPlot');
%     plot_manager_cellRoiPlot.pho_plot_2d(new_index);
    plot_manager_cellRoiPlot.pho_plot_stimulus_traces(new_index);
    plot_manager_cellRoiPlot.pho_plot_timing_heatmaps(new_index);
end