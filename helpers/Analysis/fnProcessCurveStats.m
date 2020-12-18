function [outputs] = fnProcessCurveStats(curve, timingInfo)
%FNPROCESSCURVESTATS Summary of this function goes here
%   Meant to receive a curve from a single trial, which will be divided into the pre/during/post periods.


    %% Subidivide the Curve into the regions based on the timingInfo:

    %outputs.default_DFF_Structure.timingInfo.Index.trialStartRelative.maxPeakIndex
    subCurve_All = curve(1:timingInfo.Index.trialStartRelative.startSound);
    [outputs.All] = fnProcessSubCurveStats(subCurve_All);
    outputs.All.max.Idx = outputs.All.max.subcurveStartRelativeIdx; % same for Pre-stimulus start periods
    
    subCurve_Pre = curve(1:timingInfo.Index.trialStartRelative.startSound);
    [outputs.Pre] = fnProcessSubCurveStats(subCurve_Pre);
    outputs.Pre.max.Idx = outputs.Pre.max.subcurveStartRelativeIdx; % same for Pre-stimulus start periods
    
    subCurve_During =  curve(timingInfo.Index.trialStartRelative.startSound:timingInfo.Index.trialStartRelative.endSound);
    [outputs.During] = fnProcessSubCurveStats(subCurve_During);
    outputs.During.max.Idx = outputs.During.max.subcurveStartRelativeIdx + timingInfo.Index.trialStartRelative.startSound - 1; % convert back to a frame index instead of a stimulus start relative index
    
    subCurve_Post =  curve(timingInfo.Index.trialStartRelative.endSound:end);
    [outputs.Post] = fnProcessSubCurveStats(subCurve_Post);
    outputs.Post.max.Idx = outputs.Post.max.subcurveStartRelativeIdx + timingInfo.Index.trialStartRelative.endSound - 1; % convert back to a frame index instead of a stimulus start relative index
    
    
    
    function [subcurveOutput] = fnProcessSubCurveStats(subcurve)
    %fnProcessSubCurveStats Summary of this function goes here
    %   Meant to receive a subcurve (which is a portion of a curve from a single trial)
        [subcurveOutput.max.value, subcurveOutput.max.subcurveStartRelativeIdx] = max(subcurve); % get max of current signal only within the startSound:endSound range
%         

        [subcurveOutput.min.value, subcurveOutput.min.subcurveStartRelativeIdx] = min(subcurve);

        subcurveOutput.mean = mean(subcurve);
    end


end

