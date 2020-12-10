function [cum_first_index_array, cum_last_index_array] = fnGetBlockIndexArrays(items_per_block, num_blocks)
%FNGETBLOCKINDEXARRAYS Returns the start and stop index arrays for a 
%   items_per_block: if a vector is provided, the entries are assumed to be
%       the number of items in each block and need not be the same size:
%           [10 19 5] (3 blocks, the first of size 10, the second of size 19, etc..)
%       if a single number is provided, the num_blocks argument must also be
%           specified and will be used to create a vector repeating the
%           items_per_block ([items_per_block items_per_block items_per_block]) 
% Returns the starting and ending indexes

if length(items_per_block) == 1
   if ~exist('num_blocks','var')
      error('num_blocks not specified! If you pass in a non-array of items_per_block, it can be built for you, but you must pass a second argument specifiying the number of items you want in each block') 
   end
   items_per_block = repmat(items_per_block, [1 num_blocks]);
end

cum_last_index_array = cumsum(items_per_block);
cum_first_index_array = (cum_last_index_array - items_per_block) + 1;

end

