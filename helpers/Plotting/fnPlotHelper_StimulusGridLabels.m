function fnPlotHelper_StimulusGridLabels(final_data_explorer_obj, numRows, numCol, curr_linear_stimulus_index, plotting_options)
    %% fnPlotHelper_StimulusGridLabels(...): Adds the 100% Depth, 80% Depth, etc.. labels to the top of the Stimuli Traces Figure
        % Adds the 200Hz, 100Hz, 50Hz, etc labels down the left side of the same figure.
        % Used by fnPlotStimulusTracesForCellROI(...)
    curr_linear_subplot_index = final_data_explorer_obj.stimuli_mapper.numStimuli-curr_linear_stimulus_index+1;
    [~, ~, depthValue, freqValue] = final_data_explorer_obj.stimuli_mapper.getDepthFreqIndicies(curr_linear_stimulus_index);
    
    if plotting_options.should_plot_titles_for_each_subplot
        title(strcat(num2str(uniqueStimuli(curr_linear_stimulus_index,1)), {' '}, 'Hz', {' '}, 'at', {' '}, num2str(uniqueStimuli(curr_linear_stimulus_index,2)*100), {' '}, '% Depth'))
    else
        [curr_row, curr_col] = ind2subplot(numRows, numCol, curr_linear_subplot_index);
%                     curr_title_string = sprintf('[row: %d, col: %d]: linear - %d', curr_row, curr_col, curr_linear_subplot_index); % Debugging
        curr_title_string = '';
        % Include the frequency only along the left hand edge
        if (curr_col == 1) 
            curr_freq_string = final_data_explorer_obj.stimuli_mapper.getFormattedString_Freq(freqValue);
            curr_title_string = strcat(curr_title_string, curr_freq_string);
            ylabel(curr_title_string,'FontWeight','bold','FontSize',14,'Interpreter','none');
        else
            ylabel('')
            curr_freq_string = '';
        end
        % Include the depth only along the top edge:
        curr_title_string = '';
        if (curr_row == 1)
            curr_depth_string = final_data_explorer_obj.stimuli_mapper.getFormattedString_Depth(depthValue, true);                        
            curr_title_string = strcat(curr_title_string, curr_depth_string);
            title(curr_title_string,'FontSize',14,'Interpreter','none');
        end            
    end
    
    
end % end fnPlotHelper_StimulusGridLabels