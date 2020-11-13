function [sessionList,compList]=makeSessionList_FDS(fdStruct)

%if you don't have a list of components and sessions, this script will make
%one 20200602

anmIDs=fieldnames(fdStruct);
compList=struct;
sessionList = struct;

currentID = 0;
for a=1:numel(anmIDs)
    currentAnm = anmIDs{a};
    sessionIDs=fieldnames(fdStruct.(currentAnm));
    
    for b = 1:numel(sessionIDs)
        
        currentID = currentID + 1;
        
        tempCompList=struct;
        currentSesh=sessionIDs{b};
        compNames=fieldnames(fdStruct.(currentAnm).(currentSesh).imgData);
        
        splitName=strsplit(currentSesh,'_');
        sessionList(currentID).anmID=currentAnm;
        sessionList(currentID).date = splitName{2};
        
        for c=1:numel(compNames)
            currentComp=compNames{c};
            tempCompList(c).anmID=currentAnm;
            tempCompList(c).date=splitName{2};
            tempCompList(c).compName=currentComp;
%            tempCompList(c).sigSampleAnswer=fdStruct.(currentAnm).(currentSesh).imgData.(currentComp).sigSampleAnswer;
        end
        if numel(fieldnames(compList))==0
            compList=tempCompList;
        else
            
            compList=[compList,tempCompList];
        end
    end
end
