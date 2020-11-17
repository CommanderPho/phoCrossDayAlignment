
compTable = struct2table(compList);
indexArray = 1:height(compTable);
indexColumn = table(indexArray','VariableNames',{'index'});
compTable = [compTable indexColumn];

uniqueComps = unique(compTable.compName,'stable');
num_comps = length(uniqueComps);

compOutIndicies = zeros(num_comps, 3);
for i = 1:num_comps
   curr_comp = uniqueComps{i}; 
%    curr_indicies = find(compTable{:,:} == curr_comp);
   curr_indicies = find(strcmp(compTable.compName, curr_comp));
   
   fprintf('uniqueComp[%d]: %s', i, curr_comp);
   disp(curr_indicies');
   compOutIndicies(i,:) = curr_indicies';
end


% [C,ia] = unique(compTable.compName,'stable');
% B = compTable(ia,:);



% % plotTracesForAllStimuli_FDS(finalDataStruct, compList(4))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(162))
% plotTracesForAllStimuli_FDS(finalDataStruct, compList(320))
% plotAMConditions_FDS(finalDataStruct, compList(2:8))