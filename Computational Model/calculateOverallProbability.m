function overallProbability = calculateOverallProbability(compModel_responsesBasedOnStimuli, subject_responsesBasedOnStimuli, matchingDPrimeIndex)
    
    % Array to store the products from each intensity of each subject
    products_All = nan(size(matchingDPrimeIndex,1),size(matchingDPrimeIndex,2));
    
    % --- Convert the compModel_responsesBasedOnStimuli to probabilities ---
    
    % Get the total responses per intensity (this is used to convert below
    % into percentages)
    totalResponsesPerIntensity = sum(sum(compModel_responsesBasedOnStimuli(:,:,1)));
    
    % Convert all in the responses to probabilities
    compModel_probabilityBasedOnStimuli = compModel_responsesBasedOnStimuli./totalResponsesPerIntensity;
    
    % --- Get the number we want from each intensity ---
    
    % For loop that goes through each row (intensity)
    for currentIntensity = 1:size(matchingDPrimeIndex,1)
        
        % For loop that goes through each column (subject)
        for currentSubject = 1:size(matchingDPrimeIndex,2)
            
            % Get the matching compModel Layer
            matchingCompModelLayer = compModel_probabilityBasedOnStimuli(:,:,matchingDPrimeIndex(currentIntensity,currentSubject));
            
            % Raise that to the human responses
            raisedToHumanResponses = matchingCompModelLayer.^subject_responsesBasedOnStimuli(:,:,currentIntensity,currentSubject);
            
            % Get the product by multiplying all the elements in the matrix together
            currentProduct = prod(prod(raisedToHumanResponses));
            
            % Store it into our products store
            products_All(currentIntensity,currentSubject) = currentProduct;
            
        end % End of for col
        
    end % End of for row
    
    % Get overall p(model|data) by multiplying all d' together per subject
    overallProbability = log(prod(products_All))';
    
end % End of function