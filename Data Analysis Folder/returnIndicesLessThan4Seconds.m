function indices = returnIndicesLessThan4Seconds(array)

% Initialize the indices array
indices = [];

% Make a loop that goes through the array to return the indices that
% contain a value between -1 and 4000 ms
for i = 1:length(array)
    
    % Push the index in if it is between -1 and 4000
    if(array(i) > -1 && array(i) < 4000)
        indices(length(indices)+1) = i;
    end
    
end % End of for loop