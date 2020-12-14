function [figH] = fnPlotStimulusTraceSummaryStatsForCellROI(final_data_explorer_obj, cellRoiIndex, plotting_options, extantFigH)
%fnPlotStimulusTraceSummaryStatsForCellROI plots the array of traces for each stimulus pair for each session for a single cellRoi
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
    
    if ~exist('plotting_options','var')
        plotting_options.should_plot_vertical_sound_start_stop_lines = true; % plotting_options.should_plot_vertical_sound_start_stop_lines: if true, vertical start/stop lines are drawn to show when the sound started and stopped.
        plotting_options.should_normalize_to_local_peak = true; % plotting_options.should_normalize_to_local_peak: if true, the y-values are normalized across all stimuli and sessions for a cellRoi to the maximal peak value.
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
    
    trialLengthNumSamples = length(final_data_explorer_obj.traceTimebase_t);
    
    %% Get Information about the ranges to be plotted:
    % TODO: May want to factor these out for both computational efficiency and to be able to access them elsewhere.
 
%     if plotting_options.should_normalize_to_local_peak
%        redTraceLinesExtrema.local_max_peaks = max(final_data_explorer_obj.redTraceLinesForAllStimuli, [], [2 3]); % [159 x 1]
%        redTraceLinesExtrema.local_min_extrema = min(final_data_explorer_obj.redTraceLinesForAllStimuli, [], [2 3]); % [159 x 1]
%      
%         if plotting_options.should_plot_all_traces
%             tracesForAllStimuliExtrema.local_max_peaks = max(final_data_explorer_obj.tracesForAllStimuli, [], [2 3 4]); % [159 x 1]
%             tracesForAllStimuliExtrema.local_min_extrema = min(final_data_explorer_obj.tracesForAllStimuli, [], [2 3 4]); % [159 x 1]
%             
%             activePlotExtrema.local_max_peaks = max([redTraceLinesExtrema.local_max_peaks, tracesForAllStimuliExtrema.local_max_peaks], [], 2); % For each cellROI, get the maximum value (whether it is on the average or the traces themsevles).
%             activePlotExtrema.local_min_extrema = min([redTraceLinesExtrema.local_min_extrema, tracesForAllStimuliExtrema.local_min_extrema], [], 2);
%         else
%             activePlotExtrema = redTraceLinesExtrema;
%         end
%     end
    
    if ~exist('extantFigH','var')
        figH = createFigureWithNameIfNeeded(['CellROI StimulusTracesSummaryStats Figure: cellROI ' num2str(cellRoiIndex)]); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end    
    clf(figH);
    
    %generate the dimensions of the subplots
    numRows = numel(nonzeros(final_data_explorer_obj.uniqueFreqs))+1; %+1 because you have the zero mod condition too
    numCol = numel(nonzeros(final_data_explorer_obj.uniqueAmps));

    % Split the trial x-values into the correct sections
    curr_x_all = final_data_explorer_obj.traceTimebase_t;
    curr_x_pre = final_data_explorer_obj.traceTimebase_t(1:final_data_explorer_obj.active_DFF.timingInfo.Index.trialStartRelative.startSound);
    curr_x_during = final_data_explorer_obj.traceTimebase_t(final_data_explorer_obj.active_DFF.timingInfo.Index.trialStartRelative.startSound:final_data_explorer_obj.active_DFF.timingInfo.Index.trialStartRelative.endSound);
    curr_x_post = final_data_explorer_obj.traceTimebase_t(final_data_explorer_obj.active_DFF.timingInfo.Index.trialStartRelative.endSound:end);
    
    % For each session in this cell ROI
    for i = 1:final_data_explorer_obj.numOfSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
    
        % outputs.default_DFF.StimulusCurveSummaryStats: 1x26 struct. Has 4 fields (All, Pre, During, Post), each with 26 entries (one for each stimulus).
        temp.curr_summary_stats = squeeze(final_data_explorer_obj.active_DFF.StimulusCurveSummaryStats(temp.compIndex,:))';
        
        numStimuli = length(temp.curr_summary_stats);
        is_first_session_for_stimuli = (i == 1); % used to perform first-plot-only setup

        %% Loop throught the linear stimuli indicies
        for b = 1:numStimuli
          
            temp.curr_stim_all = temp.curr_summary_stats(b).All;
            temp.curr_stim_pre = temp.curr_summary_stats(b).Pre;
            temp.curr_stim_during = temp.curr_summary_stats(b).During;
            temp.curr_stim_post = temp.curr_summary_stats(b).Post;
            
            curr_linear_subplot_index = numStimuli-b+1;
            subplot_cmd(numRows, numCol, curr_linear_subplot_index);
            
			if is_first_session_for_stimuli
				if plotting_options.should_plot_vertical_sound_start_stop_lines
					%% Plot the stimulus indicator lines:
					if plotting_options.should_normalize_to_local_peak
						y = [-0.5 1.0];
					else
						y = [-0.1 0.1]; % the same y-values are used for both lines (as they are the same height)
                    end
                    plottingOptions.black_lines_only = true;
                    [~] = fnAddStimulusStartStopIndicatorLines(trialLengthNumSamples, processingOptions.startSoundSeconds, processingOptions.endSoundSeconds, y, plottingOptions);
			
				end
			end
            

            % plot the average (red) line:
%             temp.curr_stim_all_value = repmat(temp.curr_stim_all.mean, [1 length(curr_x_all)]);
%             h_PlotObj = plot(curr_x_pre, temp.curr_stim_all.mean);
%             set(h_PlotObj, 'color', session_colors{i}, 'linewidth', 2);
            
            temp.curr_stim_pre_value = repmat(temp.curr_stim_pre.mean, [1 length(curr_x_pre)]);
            temp.curr_stim_during_value = repmat(temp.curr_stim_during.mean, [1 length(curr_x_during)]);
            temp.curr_stim_post_value = repmat(temp.curr_stim_post.mean, [1 length(curr_x_post)]);
            
            h_PlotObj = plot(curr_x_pre, temp.curr_stim_pre_value);
            set(h_PlotObj, 'color', session_colors{i}, 'linewidth', 2);
            hold on;
            h_PlotObj = plot(curr_x_during, temp.curr_stim_during_value);
            set(h_PlotObj, 'color', session_colors{i}, 'linewidth', 2);
            hold on;
            h_PlotObj = plot(curr_x_post, temp.curr_stim_post_value);
            set(h_PlotObj, 'color', session_colors{i}, 'linewidth', 2);
            hold on;
            
			if is_first_session_for_stimuli
                fnPlotHelper_StimulusGridLabels(final_data_explorer_obj, numRows, numCol, b, plotting_options)

				xlim([0, 5]);
				xticks([]);
% 				yticks([]);

%                 if plotting_options.should_normalize_to_local_peak
%                     ylim([-0.5, 1]);
%                 end
                
			end

            hold on;
            

        end % end for numStimuli
    
        %% Once the plot is finished, get the ylim values
        curr_y_lim = ylim;
        
        
        
    end %% end for session
    
    
    
    
    
    sgtitle(['cellRoi: ' num2str(cellRoiIndex)]);
 

end % End outer function





