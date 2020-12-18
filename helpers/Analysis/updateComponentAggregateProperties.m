function [componentAggregatePropeties] = updateComponentAggregateProperties(componentAggregatePropeties, tuning_max_threshold_criteria)
	% updateComponentAggregateProperties(...): small helper function that adds some reshaped properties
	% WARNING: This assumes that there are the same number of sessions for each cellROI
	componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = (componentAggregatePropeties.maxTuningPeakValue > tuning_max_threshold_criteria);

	componentAggregatePropeties.maxTuningPeakValue = reshape(componentAggregatePropeties.maxTuningPeakValue,[],3); % Reshape from linear to cellRoi indexing
	componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = reshape(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria,[],3); % Reshape from linear to cellRoi indexing

	% componentAggregatePropeties.tuningScore: the number of days the cellRoi meets the criteria
	componentAggregatePropeties.tuningScore = sum(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria, 2);

end

function [loaded_DFF] = processOutputsDFF(outputs, output_DFF_Name, curr_day_linear_comp_index, phoPipelineOptions)
	% processOutputsDFF(...): process the outputs from processOutputsDFF(...) for a specific comp index and frame type
		loaded_DFF.finalOutPeaksGrid(curr_day_linear_comp_index,:,:) = outputs.(output_DFF_Name).finalOutGrid;
		loaded_DFF.componentAggregatePropeties.maximallyPreferredStimulusInfo(curr_day_linear_comp_index) = outputs.(output_DFF_Name).maximallyPreferredStimulus; 
		loaded_DFF.peakSignals = outputs.(output_DFF_Name).AMConditions.peakSignal; % used
		loaded_DFF.maxPeakSignal = max(loaded_DFF.peakSignals); % used
		loaded_DFF.componentAggregatePropeties.maxTuningPeakValue(curr_day_linear_comp_index) = loaded_DFF.maxPeakSignal; 
		loaded_DFF.componentAggregatePropeties.sumTuningPeaksValue(curr_day_linear_comp_index) = sum(loaded_DFF.peakSignals);   
		loaded_DFF.TracesForAllStimuli.imgDataToPlot(curr_day_linear_comp_index, :, :, :) = outputs.TracesForAllStimuli.imgDataToPlot;
		loaded_DFF.redTraceLinesForAllStimuli(curr_day_linear_comp_index, :, :) = outputs.(output_DFF_Name).AMConditions.imgDataToPlot; % [26   150]
		% Get timing info for the mean (red) curves for all stimuli.
		loaded_DFF.timingInfo.Index.startSoundRelative.maxPeakIndex(curr_day_linear_comp_index,:) = outputs.(output_DFF_Name).timingInfo.Index.startSoundRelative.maxPeakIndex;
		loaded_DFF.timingInfo.Index.trialStartRelative.maxPeakIndex(curr_day_linear_comp_index,:) = outputs.(output_DFF_Name).timingInfo.Index.trialStartRelative.maxPeakIndex;
		
		% These are the same each time.
		loaded_DFF.timingInfo.Index.trialStartRelative.startSound = outputs.(output_DFF_Name).timingInfo.Index.trialStartRelative.startSound;
		loaded_DFF.timingInfo.Index.trialStartRelative.endSound = outputs.(output_DFF_Name).timingInfo.Index.trialStartRelative.endSound;
		loaded_DFF.timingInfo.Index.sampPeak = outputs.(output_DFF_Name).timingInfo.Index.sampPeak;
		
		% outputs.(output_DFF_Name).StimulusCurveSummaryStats: 1x26 struct. Has 4 fields (All, Pre, During, Post), each with 26 entries (one for each stimulus).
		loaded_DFF.StimulusCurveSummaryStats(curr_day_linear_comp_index,:) = outputs.(output_DFF_Name).StimulusCurveSummaryStats;

		% temp.isFirstSessionInCellRoi = (j == 1);
		% if temp.isFirstSessionInCellRoi
		% 	loaded_DFF.cellROI_FirstDayTuningMaxPeak(i) = loaded_DFF.maxPeakSignal;
		% 	if loaded_DFF.maxPeakSignal > phoPipelineOptions.PhoPostFinalDataStructAnalysis.tuning_max_threshold_criteria
		% 	   loaded_DFF.cellROI_SatisfiesFirstDayTuning(i) = 1;
		% 	else
		% 	   loaded_DFF.cellROI_SatisfiesFirstDayTuning(i) = 0;
		% 		%                 break; % Skip remaining comps for the other days if the first day doesn't meet the criteria
		% 	end
		% end %% endif is first session

end
