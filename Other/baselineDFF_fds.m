function fStruct=baselineDFF_fds(fStruct,sessionList,baselineFrames)
%make DFF traces based on the baseline period for sessions in
%finalDataStruct format.

for a = 1:numel(sessionList)
    currentAnm=sessionList(a).anmID;
    currentSesh = sessionList(a).date;
    
    %sometimes the current sesh is listed as a num instead of string, so
    %change that if so.
    if ~ischar(currentSesh)
        currentSesh = num2str(currentSesh);
    end
    
    currentSesh=strcat('session_',currentSesh);%make this the same format as in the fds struct
    
    compNames = fieldnames(fStruct.(currentAnm).(currentSesh).imgData);
    for aa = 1:numel(compNames)
        currentComp=compNames{aa};
        
        imgData=fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingData;
        [numTrials,numFrames]=size(imgData);
        
        %pre-allocate
        fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF = zeros(numTrials,numFrames);
        
        for b=1:numTrials
            bsln = mean(imgData(b,baselineFrames(1):baselineFrames(2)));
            fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF(b,:) = (fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingData(b,:) - bsln)./bsln;
        end
    end
end
end