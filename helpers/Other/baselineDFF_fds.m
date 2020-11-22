function fStruct = baselineDFF_fds(fStruct, sessionList, baselineFrames, processingOptions)
%make DFF traces based on the baseline period for sessions in
%finalDataStruct format.

if ~exist('processingOptions','var')
   processingOptions.use_neuropil = false;
   
end

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
        if processingOptions.use_neuropil
            imgDataNeuropil = fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataNeuropil; % 520x150 double
            neuropilSubtractedImgData = imgData - imgDataNeuropil; % subtract off the neuropil from the original data for this component 
            fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataMinusNeuropilDFF = zeros(numTrials, numFrames);
        end
        
        for b=1:numTrials
            if processingOptions.use_neuropil
                bsln_neuropil_subtracted = mean(neuropilSubtractedImgData(b,baselineFrames(1):baselineFrames(2)));
                fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataMinusNeuropilDFF(b,:) = (neuropilSubtractedImgData(b,:) - bsln_neuropil_subtracted)./bsln_neuropil_subtracted;
            end
            bsln = mean(imgData(b,baselineFrames(1):baselineFrames(2)));
            fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingDataDFF(b,:) = (fStruct.(currentAnm).(currentSesh).imgData.(currentComp).imagingData(b,:) - bsln)./bsln;
        end
        
        
    end
end
end