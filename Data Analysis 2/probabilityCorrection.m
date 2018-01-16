% This function corrects probabilities if 
% hit rate or false alarm rate == 0 or == 1

function probabilities = probabilityCorrection(probabilities, nTotal)

% Get the indices of probabilities which are zero and one
indices0 = find(probabilities == 0);
indices1 = find(probabilities == 1);

% If there are probabilites which are zero, then go through each element and correct
% them
if(~isempty(indices0))
    
    % For loop that goes through all the indices to correct the value
    for i = 1:length(indices0)
        
        % Load the index for easy handling
        index = indices0(i);
        
        % Replace the index with the corrected value
        probabilities(index) = 1/(nTotal(index)+1);
        
    end % End of for loop

end % End of if indices0 is not empty

% If there are probabilites which are one, then go through each element and correct
% them
if(~isempty(indices1))
    
    % For loop that goes through all the indices to correct the value
    for i = 1:length(indices1)
        
        % Load the index for easy handling
        index = indices1(i);
        
        % Replace the index with the corrected value
        probabilities(index) = 1 - (1/(nTotal(index)+1));
        
    end % End of for loop

end % End of if indices1 is not empty

end % End of function
