function [h] = fnAddStimulusStartStopIndicatorLines(xLength, startStimulusFrame, endStimulusFrame, vLineRange, plottingOptions)
    %fnAddStimulusStartStopIndicatorLines Adds the stimulus start, stop and origin indicator to the current plot
    % vLineRange: the vertical (y-axis) height of the plotted vertical lines.
	% Note the start and end MUST BE IN SECONDS

	
    if ~exist('vLineRange','var')
        vLineRange = [-1 1];
    end
    
    if ~exist('plottingOptions','var')
        plottingOptions.black_lines_only = false;
		plottingOptions.plot_origin_h_line = true;
    end
    
    if ~isfield(plottingOptions, 'plot_origin_h_line')
        plottingOptions.plot_origin_h_line = true;
    end

    
    % horizontal origin line:
	if plottingOptions.plot_origin_h_line
		x = [0 xLength];
		y = [0 0];
		h = line(x, y,'Color','black','LineStyle','-','Tag','originXAxisHLine');
		hold on;
	end

    y = vLineRange; % the same y-values are used for both lines (as they are the same height)
    % sound start/on line:
    x = [startStimulusFrame startStimulusFrame];
    h = line(x, y,'LineStyle','-','Tag','stimulusStartVLine');
    if plottingOptions.black_lines_only
        set(h, 'Color', 'black');
    else
        set(h, 'Color', 'green');
    end
    hold on;
    
    % sound end/off line:
    x = [endStimulusFrame endStimulusFrame];
    h = line(x, y,'LineStyle','-','Tag','stimulusEndVLine');
    if plottingOptions.black_lines_only
        set(h, 'Color', 'black');
    else
        set(h, 'Color', 'red');
    end
    hold on;

end