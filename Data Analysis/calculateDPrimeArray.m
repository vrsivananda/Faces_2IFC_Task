function dPrime_matrix = calculateDPrimeArray(responsesBasedOnStimuli)
	
	% Declare the dPrime array
	dPrime_matrix = nan(size(responsesBasedOnStimuli,3),size(responsesBasedOnStimuli,4));
    
    %For loop that goes through all the subjects
    for h = 1:size(responsesBasedOnStimuli,4)
	
        % For loop that goes through all the layers (intensities)
        for i = 1:size(responsesBasedOnStimuli,3)

            % Get the current layer
            currentLayer = responsesBasedOnStimuli(:,:,i,h);

            % ------ Calculate d' for this intensity ------

            % Get the number of each response and stimuli
            nHH = currentLayer(2,2) + currentLayer(2,4) + currentLayer(4,2) + currentLayer(4,4);
            nFH = currentLayer(1,2) + currentLayer(1,4) + currentLayer(3,2) + currentLayer(3,4);
            nHF = currentLayer(2,1) + currentLayer(2,3) + currentLayer(4,1) + currentLayer(4,3);
            nFF = currentLayer(1,1) + currentLayer(1,3) + currentLayer(3,1) + currentLayer(3,3);

            % Total trials for each stimulus
            totalH = nHH + nFH;
            totalF = nFF + nHF;

            % Probability correct for each happy/fearful stimulus
            pH = nHH./(totalH);
            pF = nFF./(totalF);
            
            % Adjust if pH or pF == 1 or == 0
            pH = probabilityCorrection(pH, totalH);
            pF = probabilityCorrection(pF, totalF);

            % Calculate the z-score of the probabilities
            zH = norminv(pH);
            zF = norminv(pF);

            % Calculate d'
            currentDPrime = (zH + zF);

            % Push it into the array
            dPrime_matrix(i,h) = currentDPrime;

        end % End of for loop (intensities)
        
    end % End of for loop (subjects)
	
end % End of function