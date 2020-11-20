%% DATA STRUCTURES:
%%%+S- componentAggregatePropeties
    %= maxTuningPeakValueSatisfiedCriteria - 
    %= maxTuningPeakValue - 
    %= maxTuningPeakValueSatisfiedCriteria - 
    %= tuningScore - the number of days the cellRoi meets the criteria
    %= maxTuningPeakValue - the maximum peak value for each signal
    %= sumTuningPeaksValue - the sum of all peaks
%

%%%+S- maximallyPreferredStimulus
    %= LinearIndex - The linear stimulus index corresponding to the maximally preferred (amp, freq) pair for each comp.
    %= AmpFreqIndexTuple - A pair containing the index into the amp array followed by the index into the freq array corresponding to the maximally preferred (amp, freq) pair.
    %= AmpFreqValuesTuple - The unique amp and freq values at the preferred index
    %= Value - The actual Peak DF/F value
%