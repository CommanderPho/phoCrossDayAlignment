function [finalDataStruct]=phoProgrammaticCombineAllAMSessionsForSummary(varargin)
%combines all datasets in a folder into finalDataStruct. This is useful if
%you want to do transformations and analysis on datasets across multiple
%sessions. Currently saving only the event detection and DF/F data, but in
%principle you can save anything you want. If you don't pass any arguments
%it returns finalDataStruct. If you pass it an existing finalDataStruct the
%script will append the new data to the existing structure.

%pfa 20200425

%to do list
%double check to make sure there's no comps with multiple segments
%double check to make sure that events rasters aren't synchronous across
%comps (you checked this with fluo data but do again with event rasters)

%downsampling lick trace because it's way too long
dsRate = 50; %by what factor do you want to downsample?

if isempty(varargin)
    finalDataStruct =struct;
else
    finalDataStruct=varargin{1};
end

%initialized arrays
allSoundExcited=[];
allSoundInhibited=[];
allAnsExcited=[];
allAnsInhibited=[];

%point to the path to the master folder
pathName = uigetdir('please point me to the directory containing your curated sessions');
cd(pathName);
fileDir = dir(fullfile(pwd, '**\*.*')); %list everything and everything
fileDir = fileDir(~[fileDir.isdir]); %remove folders
%now you got a list of all files in all subdirectories

for a =1:numel(fileDir)
    fullFilePath = strcat(fileDir(a).folder,'\',fileDir(a).name);
    
    %get date and animal name
    fileNameParts = strsplit(fileDir(a).name,'_');
    dateString = fileNameParts{1};
    anmID = fileNameParts{2};
    
    if contains(anmID,'.mat')
        splitAnmID = strsplit(anmID,'.');
        anmID = splitAnmID{1};
    end
    
    disp(strcat('now loading','_',anmID,'_session_',dateString))
    
    load(fullFilePath,'ephysData'); %load the files
    disp(strcat('loaded_',anmID,'session_',dateString))
    
    [finalDataStruct] = fnPhoBuildUpdatedFinalDataStruct(anmID, dateString, ephysData, finalDataStruct)
end

end



