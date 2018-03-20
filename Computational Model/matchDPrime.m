function matchingDPrimeIndex = matchDPrime(subject_dPrime_matrix, compModel_dPrime_array)
    
    % ^ 
    % dPrime_array: a length(computational_model_intensities)x1 matrix.
    % dPrime_subject_matrix: a 4xnSubjects matrix
    
    
    % Create a 3D matrix from the 2D subject_dPrime_matrix to match the
    % length of the dPrime_array
    long_subject_dPrime_matrix = repmat(subject_dPrime_matrix,1,1,length(compModel_dPrime_array));
    % ^ In the form:
    % Row = intensities (x4)
    % Col = subjects (xnSubj)
    % Dep = repeats (xlength(comp_model_intensities)
    
    % Permute the dPrime array to match the dimensions of the
    % long_subject_dPrime_matrix
    compModel_dPrime_array = permute(compModel_dPrime_array,[3, 2, 1]);
    % ^ In the form:
    % 1x1xlength(comp_model_intensities)
    
    % Create the dPrime_array to match
    long_compModel_dPrime_matrix = repmat(compModel_dPrime_array,size(long_subject_dPrime_matrix,1),size(long_subject_dPrime_matrix,2),1);
    % ^ In the form:
    % 4 x nSubj x length(comp_model_intensities)
    
    % Get their difference to see how close they are to each other
    difference_matrix = abs(long_compModel_dPrime_matrix - long_subject_dPrime_matrix);
    
    % Get the minimum of the difference in the 3rd dimension (the dimension
    % that matches up with the dPrime_array)
    [min_difference, matchingDPrimeIndex] = min(difference_matrix, [], 3);
    
end % End of function