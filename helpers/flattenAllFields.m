function [fieldSizes, fieldDims, outputValues] = flattenAllFields(S, alongDimension)
% Gets the value of a field named 'fieldName' in the struct 'S', or if it doesn't exist optionally returns a providedDefaultValue.
% IF the field doesn't exist no providedDefaultValue is offered, an error is thrown
    preallocate = false;
    
    names = fieldnames(S);
%     sizes = zeros(
    num_fields = length(names);
    
    if ~exist('alongDimension','var')
       needs_dimension_determination = true;
    else
       needs_dimension_determination = false;
    end
     
%     is_dim_size_constant = [];    
%     candidate_concatenation_dimensions = [];
%     can_cat_on_dim = [];
    
    num_active_cat_dims = 0;
%     fieldSizes = [];
    fieldDims = zeros([num_fields 1]); % Holds the dimensions of each field
    
    for aFieldIndex = 1:num_fields
       currName = names{aFieldIndex}; 
       currVal = S.(currName);
       currValSize = size(currVal);
       num_curr_dims = length(size(currValSize));

       if preallocate
            fieldSizes(aFieldIndex) = currValSize;
       else
           if ~exist('fieldSizes','var')
              fieldSizes = currValSize;
           else
               fieldSizes(end+1) = currValSize;
           end        
       end
    
       
       fieldDims(aFieldIndex) = num_curr_dims;
       if exist('active_field_size','var')
          
          if num_curr_dims ~= num_active_cat_dims
            error('The fields of the structure must be of the same dimensionality, even if they are not of the same size');
          end
          % Figure out which dimensions have changing sizes, if any
          curr_is_cat_dim_size_equal = (active_field_size == currValSize);
          is_dim_size_constant(~curr_is_cat_dim_size_equal) = false; % Find the dims that are not equal and set them to false.
       else
           active_field_size = currValSize;
           num_active_cat_dims = length(size(active_field_size));
%            candidate_concatenation_dimensions = 1:num_active_cat_dims; % The dimensions that concatenation can happen on
%            can_cat_on_dim = ones([num_active_cat_dims 1], 'logical');
           is_dim_size_constant = ones([num_active_cat_dims 1], 'logical');
       end
    end % end for
    
    if needs_dimension_determination
        % Figure out which dimension to concatenate on
        candidate_concatenation_dimensions = 1:num_active_cat_dims; % The dimensions that concatenation can happen on
        candidate_concatenation_dimensions(is_dim_size_constant) = []; % If one of the sizes changes, we must concatenate along that dimension

        if length(candidate_concatenation_dimensions) > 0
            alongDimension = candidate_concatenation_dimensions;
        else
            error('Failure to determine concatenation dimension!')
        end
    
    end
    

    if preallocate
        outputSize = sum(fieldSizes, alongDimension);
        outputValues = zeros(outputSize);
    else
        outputValues = [];
    end
    
    for aFieldIndex = 1:num_fields
       currName = names{aFieldIndex}; 
       currVal = S.(currName);
       currValSize = size(currVal);
       
        if preallocate
            error('TODO')
        else
            outputValues = cat(alongDimension, outputValues, currVal);
        end
    
    end % end for
    
    
end