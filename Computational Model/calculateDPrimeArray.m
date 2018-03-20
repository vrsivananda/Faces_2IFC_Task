function dPrime_array = calculateDPrimeArray(responsesBasedOnStimuli)
	
	% Declare the dPrime array
	dPrime_array = nan(size(responsesBasedOnStimuli,3),1);
	
	% For loop that goes through all the layers (intensities)
	for i = 1:size(responsesBasedOnStimuli,3)
        
        % Get the current layer
        currentLayer = responsesBasedOnStimuli(:,:,i);
		
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

        % Calculate the z-score of the probabilities
        zH = norminv(pH);
        zF = norminv(pF);

        % Calculate d'
        currentDPrime = (zH + zF);
        
        % Push it into the array
        dPrime_array(i) = currentDPrime;
		
	end % End of for loop
	
	
end % End of function