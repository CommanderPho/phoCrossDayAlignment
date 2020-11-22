function [currentAnm, currentSesh, currentComp] = fnBuildCurrIdentifier(compList, index)
	currentAnm = compList(index).anmID;
    currentSesh = compList(index).date;
    currentComp = compList(index).compName;
	%sometimes the current sesh is listed as a num instead of string, so
    %change that if so.
    if ~ischar(currentSesh)
        currentSesh = num2str(currentSesh);
    end
    
    currentSesh=strcat('session_',currentSesh);%make this the same format as in the fds struct
end