function [componentAggregatePropeties] = updateComponentAggregateProperties(componentAggregatePropeties, tuning_max_threshold_criteria)
	% updateComponentAggregateProperties(...): small helper function that adds some reshaped properties
	% WARNING: This assumes that there are the same number of sessions for each cellROI
	componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = (componentAggregatePropeties.maxTuningPeakValue > tuning_max_threshold_criteria);

	componentAggregatePropeties.maxTuningPeakValue = reshape(componentAggregatePropeties.maxTuningPeakValue,[],3); % Reshape from linear to cellRoi indexing
	componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria = reshape(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria,[],3); % Reshape from linear to cellRoi indexing

	% componentAggregatePropeties.tuningScore: the number of days the cellRoi meets the criteria
	componentAggregatePropeties.tuningScore = sum(componentAggregatePropeties.maxTuningPeakValueSatisfiedCriteria, 2);

end