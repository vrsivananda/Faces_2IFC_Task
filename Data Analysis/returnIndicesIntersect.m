function indices = returnIndicesIntersect(varargin)

% This function returns the intersections of the indices of the array/
% cell array that matches the target values
% Arguments are in the form of (array1, targetValue1, array2, targetValue2, etc.)
% You can use as many argument pairs as possible and it will return the
% intersection of the indices

    % Declare the indices array
    indices = [];

    % For loop that goes through all the arrays/cell arrays
    % Increment by 2 because the argument comes in pairs (cellarray,target)
    for i = 1:2:length(varargin)
        
        %If this is the first round, so not intersect and just return the
        %indices
        if(i == 1)
            
            % Go through the cell array and return the indices where it
            % matches the string
            indices = returnIndices(varargin{i},varargin{i+1});
        
        % Else find the indices and intersect with the old indices
        else
            
            % Find the indices for the new cell array and intersect with
            % the old cell array
            indices = intersect(indices,returnIndices(varargin{i},varargin{i+1}));
            
        end % End of if(i == 1)
        
    end % End of for loop

end % End of function