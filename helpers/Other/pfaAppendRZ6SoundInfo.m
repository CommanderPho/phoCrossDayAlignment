function [ephysData,pathName] = pfaAppendRZ6SoundInfo(experimentType, ephysData, audioParametersPath)

%this function appends metadata regarding the stimuli you fed the RZ6
%during your experiments. This code is currently a work in progress and
%only works for amplitude-modulation experiments, but I'll add the other
%types as needed. pfa 20190626
%20191013 added ability to search for external trigger list.

%experimentType is a string, which designates what type of exp this was.
%AM = AM modulation, import information regarding the frequency and
%amplitude (depth) of AM.

%code for AM stimulus import. Note that your amplitude and frequency lists
%need to be named EXACTLY as myParameters_amplitudes.txt and
%myParameters_frequencies.txt


if strcmp(experimentType,'AM')
    
    % allow the user to pass-in a path programmatically instead of
    % requiring GUI selection of one.
    if ~exist('audioParametersPath','var')
        pathName = uigetdir ;
    else
        pathName = audioParametersPath;
    end


    cd(pathName);
    dirContents = dir('*.txt') ;
    fileNameList = {dirContents(:).name} ;
    
    %triggerList initialize, so that ~isempty statements down there don't
    %crash
    triggerList = [];
    
%     for aa = 1:numel(fileNameList)
%         if strcmp(fileNameList{aa},'myParameters_amplitudes.txt')
%             amplitudeList = importdata(strcat(pathName,'/',dirContents(aa).name));
%         elseif strcmp(fileNameList{aa},'myParameters_frequencies.txt')
%             frequencyList = importdata(strcat(pathName,'/',dirContents(aa).name));
%         elseif strcmp(fileNameList{aa},'myParameters_triggers.txt')
%             triggerList = importdata(strcat(pathName,'/',dirContents(aa).name));
%         end
%         
%     end
    
    %changed this 20200818 because people name their files differently
    for aa = 1:numel(fileNameList)
        if contains(fileNameList{aa},'amplitudes')
            amplitudeList = importdata(strcat(pathName,'/',dirContents(aa).name));
        elseif contains(fileNameList{aa},'frequencies')
            frequencyList = importdata(strcat(pathName,'/',dirContents(aa).name));
        elseif contains(fileNameList{aa},'triggers')
            triggerList = importdata(strcat(pathName,'/',dirContents(aa).name));
        end
        
    end
end

%sanity check here to make sure the amplitude and frequency lists are the
%same length
if length(amplitudeList) == length(frequencyList)
    
    %sanity check to test if this is an imaging experiment or an ephys
    %experiment.
    if isfield(ephysData,'componentData') %this might not the best way to differentiate
        expType = 'imagingExp';
    elseif isfield(ephysData,'ephysTimeBase')
        expType = 'electrophysiology';
    end
    
    
    %for imaging data
    if strcmp(expType,'imagingExp')
        
        numberOfSweeps = numel(fieldnames(ephysData))-1;
        sweepNames = fieldnames(ephysData);
        %sanity check to make sure there wasn't any desynchronization
        %between RZ6 triggering and data acquisition.
        if mod(numberOfSweeps,length(amplitudeList)) ~= 0
            disp('WARNING: NUMBER OF TRIALS IS NOT EQUALLY DIVISIBLE BY THE NUMBER OF STIMULI, PLEASE INVESTIGATE ACCORDINGLY')
        end
        
        eventIndex = 0;
        
        %loop through the sweeps
        for a = 1:numberOfSweeps
            currentSweep = sweepNames{a};
            
            %find the event index, which is the event number in the run
            if eventIndex >= length(amplitudeList)
                eventIndex = 1;
            else
                eventIndex = eventIndex + 1;
            end
            
            %save the data
            ephysData.(currentSweep).amAmpAndFreq(1) = amplitudeList(eventIndex);
            ephysData.(currentSweep).amAmpAndFreq(2) = frequencyList(eventIndex);
            if ~isempty(triggerList)
                ephysData.(currentSweep).extTrigger = triggerList(eventIndex);
            end
        end
        
        %same, but for actual electrophysiology exps
    elseif strcmp(expType,'electrophysiology')
        numberOfSweeps = numel(ephysData);
        
        
        %sanity check to make sure there wasn't any desynchronization
        %between RZ6 triggering and data acquisition.
        if mod(numberOfSweeps,length(amplitudeList)) ~= 0
            disp('WARNING: NUMBER OF TRIALS IS NOT EQUALLY DIVISIBLE BY THE NUMBER OF STIMULI, PLEASE INVESTIGATE ACCORDINGLY')
        end
        
        eventIndex = 0;
        
        %loop through the sweeps
        for a = 1:numberOfSweeps
            
            %find the event index, which is the event number in the run
            if eventIndex >= length(amplitudeList)
                eventIndex = 1;
            else
                eventIndex = eventIndex + 1;
            end
            
            %save the data
            ephysData(a).amAmpAndFreq(1) = amplitudeList(eventIndex);
            ephysData(a).amAmpAndFreq(2) = frequencyList(eventIndex);
            
            if ~isempty(triggerList)
                ephysData(a).extTrigger = triggerList(eventIndex);
            end
        end
        
    end
else
    disp('your list of amplitudes and frequencies arent the same length! What the hell???')
    return
end

%now run this
%averageArray = pfaAverageSimilarStimuli(ephysData,experimentType,pathName);
