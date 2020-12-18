function [figH] = fnPlotStimulusTracesForCellROI(final_data_explorer_obj, cellRoiIndex, plotting_options, extantFigH)
%FNPLOTSTIMULUSTRACESFORCELLROI plots the array of traces for each stimulus pair for each session for a single cellRoi
%   Detailed explanation goes here

    % Need: traceTimebase_t, tracesForAllStimuli, redTraceLinesForAllStimuli
    %% final_data_explorer_obj.traceTimebase_t, final_data_explorer_obj.active_DFF.TracesForAllStimuli, final_data_explorer_obj.redTraceLinesForAllStimuli
    
    % Options for tightening up the subplots:
    plotting_options.should_use_custom_subplots = true;
    
    if plotting_options.should_use_custom_subplots
        plotting_options.subtightplot.gap = [0.01 0.01]; % [intra_graph_vertical_spacing, intra_graph_horizontal_spacing]
        plotting_options.subtightplot.width_h = [0.01 0.05]; % Looks like [padding_bottom, padding_top]
        plotting_options.subtightplot.width_w = [0.025 0.01];
        plotting_options.opt = {plotting_options.subtightplot.gap, plotting_options.subtightplot.width_h, plotting_options.subtightplot.width_w}; % {gap, width_h, width_w}
        subplot_cmd = @(m,n,p) subtightplot(m, n, p, plotting_options.opt{:});
    else
        subplot_cmd = @(m,n,p) subplot(m, n, p);
    end
    
    currAllSessionCompIndicies = final_data_explorer_obj.cellROIIndex_mapper.getCompListIndicies(cellRoiIndex); % Gets all sessions for the current ROI
    % currAllSessionCompIndicies: all sessions for the current ROI
    %% Options:
    
    
%     
%     temp.compIndex = currAllSessionCompIndicies(1);
%     fprintf('cellRoiIndex: %d \n compIndex: %d \n', cellRoiIndex, temp.compIndex);
    
    if ~exist('plotting_options','var')
        plotting_options.should_plot_all_traces = false; % plotting_options.should_plot_all_traces: if true, line traces for all trials are plotted in addition the mean line
        plotting_options.should_plot_vertical_sound_start_stop_lines = true; % plotting_options.should_plot_vertical_sound_start_stop_lines: if true, vertical start/stop lines are drawn to show when the sound started and stopped.
        plotting_options.should_normalize_to_local_peak = true; % plotting_options.should_normalize_to_local_peak: if true, the y-values are normalized across all stimuli and sessions for a cellRoi to the maximal peak value.
    end
    
    if ~isfield(plotting_options, 'should_plot_all_traces')
        plotting_options.should_plot_all_traces = false; % plotting_options.should_plot_all_traces: if true, line traces for all trials are plotted in addition the mean line
    end
    if ~isfield(plotting_options, 'should_plot_vertical_sound_start_stop_lines')
        plotting_options.should_plot_vertical_sound_start_stop_lines = true; % plotting_options.should_plot_vertical_sound_start_stop_lines: if true, vertical start/stop lines are drawn to show when the sound started and stopped.
    end
    if ~isfield(plotting_options, 'should_normalize_to_local_peak')
        plotting_options.should_normalize_to_local_peak = false; % plotting_options.should_normalize_to_local_peak: if true, the y-values are normalized across all stimuli and sessions for a cellRoi to the maximal peak value.
    end
    if ~isfield(plotting_options, 'should_plot_titles_for_each_subplot')
        plotting_options.should_plot_titles_for_each_subplot = false; % plotting_options.should_plot_titles_for_each_subplot: if true, a title is added to each subplot (although it's redundent)
    end
    
    
    if ~exist('processingOptions','var')
        processingOptions.startSound = final_data_explorer_obj.active_DFF.timingInfo.Index.trialStartRelative.startSound;
        processingOptions.endSound = final_data_explorer_obj.active_DFF.timingInfo.Index.trialStartRelative.endSound;
        processingOptions.startSoundSeconds = final_data_explorer_obj.traceTimebase_t(processingOptions.startSound);
        processingOptions.endSoundSeconds = final_data_explorer_obj.traceTimebase_t(processingOptions.endSound);      
    end
    
    session_colors = {'r','g','b'};
%     session_colors = {[0.6350 0.0780 0.1840, 1.0],[0.4660 0.6740 0.1880, 1.0],[0 0.4470 0.7410, 1.0]};

    if plotting_options.should_plot_all_traces
    %     traces_base_color = [0.2, 0.2, 0.2, 0.4];
        session_traces_opacity = 0.42;
        session_traces_colors = {[0.6350 0.0780 0.1840, session_traces_opacity],[0.4660 0.6740 0.1880, session_traces_opacity],[0 0.4470 0.7410, session_traces_opacity]}; % way too dark
    end
    
    %% Get Information about the ranges to be plotted:
    % TODO: May want to factor these out for both computational efficiency and to be able to access them elsewhere.
 
    if plotting_options.should_normalize_to_local_peak
       redTraceLinesExtrema.local_max_peaks = max(final_data_explorer_obj.redTraceLinesForAllStimuli, [], [2 3]); % [159 x 1]
       redTraceLinesExtrema.local_min_extrema = min(final_data_explorer_obj.redTraceLinesForAllStimuli, [], [2 3]); % [159 x 1]
     
        if plotting_options.should_plot_all_traces
            tracesForAllStimuliExtrema.local_max_peaks = max(final_data_explorer_obj.tracesForAllStimuli, [], [2 3 4]); % [159 x 1]
            tracesForAllStimuliExtrema.local_min_extrema = min(final_data_explorer_obj.tracesForAllStimuli, [], [2 3 4]); % [159 x 1]
            
            activePlotExtrema.local_max_peaks = max([redTraceLinesExtrema.local_max_peaks, tracesForAllStimuliExtrema.local_max_peaks], [], 2); % For each cellROI, get the maximum value (whether it is on the average or the traces themsevles).
            activePlotExtrema.local_min_extrema = min([redTraceLinesExtrema.local_min_extrema, tracesForAllStimuliExtrema.local_min_extrema], [], 2);
        else
            activePlotExtrema = redTraceLinesExtrema;
        end
    end
    
    if ~exist('extantFigH','var')
        figH = createFigureWithNameIfNeeded(['CellROI StimulusTraces Figure: cellROI ' num2str(cellRoiIndex)]); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end    
    clf(figH);
	
    %generate the dimensions of the subplots
    numRows = numel(nonzeros(final_data_explorer_obj.uniqueFreqs))+1; %+1 because you have the zero mod condition too
    numCol = numel(nonzeros(final_data_explorer_obj.uniqueAmps));

    % For each session in this cell ROI
    for i = 1:final_data_explorer_obj.numOfSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currRedTraceLinesForAllStimuli = squeeze(final_data_explorer_obj.redTraceLinesForAllStimuli(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x26x150)
        
        if plotting_options.should_normalize_to_local_peak
%            temp.local_max_peak = max(temp.currRedTraceLinesForAllStimuli, [], 'all');
%            temp.local_min_extrema = min(temp.currRedTraceLinesForAllStimuli, [], 'all');
           temp.currRedTraceLinesForAllStimuli = temp.currRedTraceLinesForAllStimuli ./ activePlotExtrema.local_max_peaks(temp.compIndex); %% TODO: Make sure using the temp.compIndex is correct
        end
        
        
        if plotting_options.should_plot_all_traces
            temp.currTrialTraceLinesForAllStimuli = squeeze(final_data_explorer_obj.tracesForAllStimuli(temp.compIndex,:,:,:));
            if plotting_options.should_normalize_to_local_peak
%                temp.local_max_peak_trial_traces = max(temp.currTrialTraceLinesForAllStimuli, [], 'all');
%                temp.local_min_extrema_trial_traces = min(temp.currTrialTraceLinesForAllStimuli, [], 'all');
               temp.currTrialTraceLinesForAllStimuli = temp.currTrialTraceLinesForAllStimuli ./ activePlotExtrema.local_max_peaks(temp.compIndex);
            end
        end
        
        numStimuli = size(temp.currRedTraceLinesForAllStimuli,1);
        is_first_session_for_stimuli = (i == 1); % used to perform first-plot-only setup

        %% Loop throught the linear stimuli indicies
        for b = 1:numStimuli
            
            if plotting_options.should_plot_all_traces
                currAllTraces = squeeze(temp.currTrialTraceLinesForAllStimuli(b,:,:));
            end
            
            meanData = squeeze(temp.currRedTraceLinesForAllStimuli(b,:));
            
            curr_linear_subplot_index = numStimuli-b+1;
            curr_ax = subplot_cmd(numRows, numCol, curr_linear_subplot_index);
            
			fnPlotHelper_SetupStimulusSubplot(final_data_explorer_obj, numRows, numCol, b, curr_ax, plotting_options);
			
			if is_first_session_for_stimuli
				if plotting_options.should_plot_vertical_sound_start_stop_lines
					%% Plot the stimulus indicator lines:
					if plotting_options.should_normalize_to_local_peak
						y = [-0.5 1.0];
					else
						y = [-0.1 0.1]; % the same y-values are used for both lines (as they are the same height)
					end
				
					x = [processingOptions.startSoundSeconds processingOptions.startSoundSeconds];
					line(x, y,'Color','black','LineStyle','-')
					hold on;

					% end sound line:
					x = [processingOptions.endSoundSeconds processingOptions.endSoundSeconds];
					line(x, y,'Color','black','LineStyle','-')
					hold on;

				end
			end
            

            % plot the traces for all trials:
            if plotting_options.should_plot_all_traces
                curr_session_traces_color = session_traces_colors{i};
                h_PlotObj_allTraces = plot(final_data_explorer_obj.traceTimebase_t, currAllTraces, 'color', curr_session_traces_color);
                hold on;
            end
            
            % plot the average (red) line:
            h_PlotObj = plot(final_data_explorer_obj.traceTimebase_t, meanData);
            set(h_PlotObj, 'color', session_colors{i}, 'linewidth', 2);

			if is_first_session_for_stimuli
                fnPlotHelper_StimulusGridLabels(final_data_explorer_obj, numRows, numCol, b, plotting_options)

				xlim([0, 5]);
				xticks([]);
% 				yticks([]);

                if plotting_options.should_normalize_to_local_peak
                    ylim([-0.5, 1]);
                end
                
			end

            hold on;
            

        end % end for numStimuli
        
    end %% end for session
    
    sgtitle(['cellRoi: ' num2str(cellRoiIndex)]);
 

end % End outer function





