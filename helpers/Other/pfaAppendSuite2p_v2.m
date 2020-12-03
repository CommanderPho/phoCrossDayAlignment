function ephysData=pfaAppendSuite2p_v2(ephysData, F, Fneu, iscell, neuropil_masks, stat, trialLength)

%this script takes the output of your Suite2p registration (and manual
%curation...you gotta manually curate the ROIs before running this) and
%appends it to the wavesurfer behavior data that I like to call the
%"ephysData" structure. Note that you have to import the wavesurfer file
%with pfaFunExtractEphysSingleFileWS0967 instead of pfaImportWS.

%20190816 I haven't tested this extensively. -pfa
%20190904 I am pretty sure this works as advertised. Cross-checked exp
%anm172 20190829 with this vs. extracted with Caiman and it's the same.

imSize=[512,512]; %note you're hardcoding your image size here. I guess this isn't a huge deal because we don't acquire data at any other frame size, but worth nothing

sweepNames=fieldnames(ephysData); %pull out the sweep names

idxOfTrueCells = find(iscell(:,1)==1); %find the index of ROIs are true neurons that you want to analyze and what is garbage.
trueF = F(idxOfTrueCells,:); %discard things that aren't cells
trueNeu = Fneu(idxOfTrueCells,:);
trueNeuropil_masks = neuropil_masks(idxOfTrueCells,:,:);
%initialize this field
ephysData.componentData = [];

%loop through each of the cells (named 'comps'; a holdover from caiman
%pipeline)
for b = 1:length(idxOfTrueCells)
    
    thisComp = strcat('comp',num2str(idxOfTrueCells(b)-1)); %name the comp. LOOOLLL you have to name it idxOfTrueCells(b)-1 <--- because matlab starts indexing at 1 and python at 0.
    disp(strcat('now processing','_',thisComp)); %tell the end user you haven't forgotten about them
    
    %these are the pixel locations for the roi
    xLabels=stat{1,idxOfTrueCells(b)}.xpix+1; %also lmao another python/matlab conversion error need to do +1
    yLabels = stat{1,idxOfTrueCells(b)}.ypix+1;
    
    %initialize these and save some stuff so that you can use the
    %component browsers developed for caiman.
    ephysData.componentData.(thisComp).componentStack = zeros(imSize);
    ephysData.componentData.(thisComp).componentStackBinarized = zeros(imSize);
    ephysData.componentData.(thisComp).segmentLabelMatrix = zeros(imSize);
    
    ephysData.componentData.(thisComp).neuropilMaskLabelMatrix = squeeze(trueNeuropil_masks(b,:,:));
    
    %there has got to be a better way to do this than a for loop. but
    %at the moment I am having trouble with this.
    for c = 1:length(xLabels)
        ephysData.componentData.(thisComp).componentStack(yLabels(c),xLabels(c))=1;
        ephysData.componentData.(thisComp).componentStackBinarized(yLabels(c),xLabels(c))=1;
        ephysData.componentData.(thisComp).segmentLabelMatrix(yLabels(c),xLabels(c))=1;
    end
    
    %save this stuff that the caiman data browsers need to be happy.
    connComp = bwconncomp(ephysData.componentData.(thisComp).componentStack);
    ephysData.componentData.(thisComp).Connectivity = connComp.Connectivity;
    ephysData.componentData.(thisComp).ImageSize = connComp.ImageSize;
    ephysData.componentData.(thisComp).NumObjects = connComp.NumObjects;
    ephysData.componentData.(thisComp).PixelIdxList = connComp.PixelIdxList;
    

    firstFrame = 1; %initialize the first frame of first trial
    lastFrame = trialLength; %initialize the last frame of first trial
    
    %loop through each trial
    for a = 1:numel(sweepNames)
        currentSweep=sweepNames{a}; %pull out the trial name
        ephysData.(currentSweep).imagingData.(thisComp) = trueF(b,firstFrame:lastFrame); %save the fluorescence data for this cell on this trial
        ephysData.(currentSweep).imagingDataNeuropil.(thisComp) = trueNeu(b,firstFrame:lastFrame); %save the neuropil data for this cell on this trial
        
        %now set the frame numbers for the next trial and do it all over
        %again.
        firstFrame = firstFrame + trialLength;
        lastFrame = lastFrame + trialLength;
    end
end


end
