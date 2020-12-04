function [figH] = fnPlotStimulusTracesForCellROI(dateStrings, uniqueAmps, uniqueFreqs, uniqueStimuli, currAllSessionCompIndicies, cellRoiIndex, traceTimebase_t, tracesForAllStimuli, redTraceLinesForAllStimuli, extantFigH)
%FNPLOTSTIMULUSTRACESFORCELLROI plots the array of traces for each stimulus pair for each session for a single cellRoi
%   Detailed explanation goes here

    % currAllSessionCompIndicies: all sessions for the current ROI
    %% Options:
    temp.numSessions = length(currAllSessionCompIndicies);
    
    plotting_options.should_plot_all_traces = true; % plotting_options.should_plot_all_traces: if true, line traces for all trials are plotted in addition the mean line
    
    plotting_options.should_plot_vertical_sound_start_stop_lines = false; % plotting_options.should_plot_vertical_sound_start_stop_lines: if true, vertical start/stop lines are drawn to show when the sound started and stopped.
    
    if ~exist('processingOptions','var')
        processingOptions.startSound = 31;
        processingOptions.endSound = 90;
        processingOptions.startSoundSeconds = traceTimebase_t(processingOptions.startSound);
        processingOptions.endSoundSeconds = traceTimebase_t(processingOptions.endSound);
        
%         processingOptions.sampPeak = 2;
%         processingOptions.frameRate = 30;
%         processingOptions.smoothValue = 5;
    end
    
    session_colors = {'r','g','b'};
%     session_colors = {[0.6350 0.0780 0.1840, 1.0],[0.4660 0.6740 0.1880, 1.0],[0 0.4470 0.7410, 1.0]};

    if plotting_options.should_plot_all_traces
    %     traces_base_color = [0.2, 0.2, 0.2, 0.4];
        session_traces_opacity = 0.42;
        session_traces_colors = {[0.6350 0.0780 0.1840, session_traces_opacity],[0.4660 0.6740 0.1880, session_traces_opacity],[0 0.4470 0.7410, session_traces_opacity]}; % way too dark
    end
    
    
    if ~exist('extantFigH','var')
        figH = createFigureWithNameIfNeeded(['CellROI StimulusTraces Figure: cellROI ' num2str(cellRoiIndex)]); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end    
    clf(figH);
    
    
    %generate the dimensions of the subplots
    numRows = numel(nonzeros(uniqueFreqs))+1; %+1 because you have the zero mod condition too
    numCol = numel(nonzeros(uniqueAmps));

    % For each session in this cell ROI
    for i = 1:temp.numSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currRedTraceLinesForAllStimuli = squeeze(redTraceLinesForAllStimuli(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x26x150)
        
        if plotting_options.should_plot_all_traces
            temp.currTrialTraceLinesForAllStimuli = squeeze(tracesForAllStimuli.imgDataToPlot(temp.compIndex,:,:,:));
        end
        
        temp.currDateString = dateStrings{i};
        
        numStimuli = size(temp.currRedTraceLinesForAllStimuli,1);
        
        for b = 1:numStimuli
            if plotting_options.should_plot_all_traces
                currAllTraces = squeeze(temp.currTrialTraceLinesForAllStimuli(b,:,:));
            end
            
            meanData = squeeze(temp.currRedTraceLinesForAllStimuli(b,:));
%             axes(ha(numStimuli-b+1));
            
            subplot(numRows, numCol, numStimuli-b+1);
            
            if plotting_options.should_plot_vertical_sound_start_stop_lines
                % Plot the stimulus indicator lines:
                x = [processingOptions.startSoundSeconds processingOptions.startSoundSeconds];
                y = [-0.5 0.5];
                line(x, y,'Color','black','LineStyle','-')
                hold on;

                % end sound line:
                x = [processingOptions.endSoundSeconds processingOptions.endSoundSeconds];
                y = [-0.4 0.4];
                line(x, y,'Color','black','LineStyle','--')
                hold on;

            end
            

            % plot the traces for all trials:
            if plotting_options.should_plot_all_traces
                curr_session_traces_color = session_traces_colors{i};
                h_PlotObj_allTraces = plot(traceTimebase_t, currAllTraces, 'color', curr_session_traces_color);
                hold on;
            end
            
            % plot the average (red) line:
            h_PlotObj = plot(traceTimebase_t, meanData);
            set(h_PlotObj, 'color', session_colors{i}, 'linewidth', 2);
            title(strcat(num2str(uniqueStimuli(b,1)), {' '}, 'Hz', {' '}, 'at', {' '}, num2str(uniqueStimuli(b,2)*100), {' '}, '% Depth'))
            xlim([0, 5]);
            hold on;
            
        end % end for numStimuli
        
    end %% end for session
    
    sgtitle(['cellRoi: ' num2str(cellRoiIndex)]);
end

