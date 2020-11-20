
%%% 2D Plotting
function [figH, curr_ax] = fnPlotFlattenedPlotsFromPeaksGrid(dateStrings, uniqueAmps, uniqueFreqs, currAllSessionCompIndicies, cellRoiIndex, finalOutPeaksGrid, extantFigH)
    % currAllSessionCompIndicies: all sessions for the current ROI
    %% Options:
    temp.numSessions = length(currAllSessionCompIndicies);
    uniqueAmpLabels = strcat(num2str(uniqueAmps .* 100),{'% Depth'});
    uniqueFreqLabels = strcat(num2str(uniqueFreqs), {' '},'Hz');

    if ~exist('extantFigH','var')
        figH = figure(1337 + cellRoiIndex); % generate a new figure to plot the sessions.
    else
        figH = extantFigH; % use the existing provided figure    
        figure(figH);
    end
    
    clf(figH);
    
    
    %specify colormaps for your figure. This is important!!
    amplitudeColorMap = winter(numel(uniqueAmps));
    frequencyColorMap = spring(numel(uniqueFreqs));

    curr_linear_subplot_index = 1;
    % For each session in this cell ROI
    for i = 1:temp.numSessions
        % Get the index for this session of this cell ROI
        temp.compIndex = currAllSessionCompIndicies(i); 
        % Gets the grid for this session of this cell ROI
        temp.currPeaksGrid = squeeze(finalOutPeaksGrid(temp.compIndex,:,:)); % "squeeze(...)" removes the singleton dimension (otherwise the output would be 1x6x6)
        temp.currDateString = dateStrings{i};
        
        curr_ax = subplot(2, temp.numSessions, curr_linear_subplot_index);
        colororder(curr_ax, amplitudeColorMap)
        hold on; % required for colororder to take effect
        
        h_x_amp = plot(repmat(uniqueFreqs', [length(uniqueAmps) 1])', temp.currPeaksGrid');
        set(h_x_amp, 'linewidth', 2);
        ylabel('Peak DF/F')
        xlabel('AM Rate (Hz)')
        legend(uniqueAmpLabels);
      
        title(temp.currDateString,'FontSize',14);

        %% AM Depth (%) plot
        curr_ax = subplot(2, temp.numSessions, (curr_linear_subplot_index + temp.numSessions)); % get the subplot for the second row by adding the length of the first row
        colororder(curr_ax, frequencyColorMap)
        hold on; % required for colororder to take effect
        h_x_freq = plot(repmat(uniqueAmps', [length(uniqueFreqs) 1])', temp.currPeaksGrid');
        set(h_x_freq, 'linewidth', 2);
        ylabel('Peak DF/F')
        xlabel('AM Depth (%)')
        legend(uniqueFreqLabels);

        curr_linear_subplot_index = curr_linear_subplot_index + 1;
    end

%     % Set x-labels:
%     xlabel('uniqueAmps (% Depth)');
%     xlim([0 max(uniqueAmps)]);
%     xticks(uniqueAmps);
%     xticklabels(uniqueAmpLabels);
% 
%     % Set y-labels:
%     ylabel('uniqueFreqs (Hz)');
%     ylim([0 max(uniqueFreqs)]);
%     yticks(uniqueFreqs);
%     yticklabels(uniqueFreqLabels);
% 
    sgtitle(['cellRoi: ' num2str(cellRoiIndex)]);
    
end
