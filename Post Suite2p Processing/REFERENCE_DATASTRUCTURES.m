%% README:
% The incoming findalDataStruct contains animal.recordingDay.componentIndex

% These are linearized into a struct array named 'compList'.
% If there are 'd' recording days, each recording from 'n' components, the compList will contain 'd * n' entries.
% For example:
% size(fieldnames(finalDataStruct.anm265.session_20200117.imgData)) = [158 1]
%   % => n = 158
% size(fieldnames(finalDataStruct.anm265)) = [3 1]
%   % => d = 3
% => size(compList) = 1   474


%% DATA STRUCTURES:


%% SPEC: finalDataStruct
% finalDataStruct: 1x1 struct - 1 field: has one field for each animal
%   anm265: 1x1 struct: has one field for each session ("day")
%       - session_20200117: 1x1 struct
%           - behData:  1x1 struct
%               - amAmplitude: 520x1 double
%               - amFrequency: 520x1 double
%           - imgData:  1x1 struct - has one field for each ROI (referred to as a "component" or "comp") named "comp%d" in printf format
%               - comp1:    1x1 struct
%                   - imagingData: 520x150 double
%                   - imagingDataNeuropil: 520x150 double
%                   - segmentLabelMatrix: 512x512 double
%                   - neuropilMaskLabelMatrix: 512x512 double
%                   - imagingDataDFF: 520x150 double

%% SPEC: sessionList
% sessionList: 1x3 struct - 2 fields:
%   anmID: 'anm265'
%   date:  '20200117'

%% SPEC: compList
% compList: 1x474 struct - 3 fields:
%   anmID: 'anm265'
%   date:  '20200117'
%   compName: 'comp1'


 %%%+S- fnProcessCompFromFDS outputs
    %= referenceMask - the reference mask for this component
    %= referenceMaskNeuropil - the reference mask for the neuropil mask for this component
    %= stimList - 
    %= uniqueStimuli - 
    %= tracesForEachStimulus - 
    %= numStimuli - 
    %= uniqueFreqs - 
    %= uniqueAmps - 
    %= indexMap_AmpsFreqs2StimulusArray - a map from each unique stimuli to a linear stimulus index. Each row contains a fixed amplitude, each column a fixed freq
    %= indexMap_StimulusLinear2AmpsFreqsArray - each row contains a fixed linear stimulus, and the two entries in the adjacent columns contain the uniqueAmps index and the uniqueFreqs index.
    %= imgDataToPlot - 
    %= traceTimebase_t - make a timebase to plot as xAxis for traces
    %= TracesForAllStimuli.meanData - The important red lines
    %= TracesForAllStimuli.imgDataToPlot - 
    %= TracesForAllStimuli.finalSeriesAmps - 2D projections of the plots
    %= TracesForAllStimuli.finalSeriesFreqs - 2D projections of the plots
    %= AMConditions.imgDataToPlot - 
    %= AMConditions.peakSignal - get max of current signal only within the startSound:endSound range
    %= finalOutGrid - 
    %= maximallyPreferredStimulus - See reference structure
    %

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

%%%+S- compMasks
    %= Masks - the binary mask for each component. zeros(numCompListEntries, 512, 512)
    %= Edge - the binary edge corresponding to each component in Masks
%


    %% Used in FinalDataExplorer:
    %%%+S- preferredStimulusInfo
        %- DidPreferredStimulusChange - keeps track of whether the preferredStimulus amplitude or frequency changed for a cellROI between sessions.
        %- PreferredStimulus - 
        %- PreferredStimulus_LinearStimulusIndex - 
        %- PreferredStimulusAmplitude - 
        %- PreferredStimulusFreq - 
		%- ChangeScores: the number of changes in preferred tuning between sessions
		%- InterSessionConsistencyScores: the number of consistently tuned sessions
    %

    %%%+S- roiComputedProperties
        %- areas - 
        %- boundingBoxes - 
        %- centroids - 
    %

    %%%+S- roiMasks
        %- Fill - 
        %- Edge - 
        %- OutsetEdge0 - 
        %- OutsetEdge1 - 
        %- OutsetEdge2 - 
        %- InsetEdge0 - 
        %- InsetEdge1 - 
        %- InsetEdge2 - 
    %
    
    