function responses = getResponsesBasedOnStimuli(dataStructure, intensities)
	
	% Prepare the store for the subject
	responses = zeros(4,4,length(intensities)); % This is a (4 x 4 x length(intensities)) dimensional matrix
	
	% For loop for each intensity (each layer of the responses matrix)
	for i = 1:length(intensities)
		
		% Load in current intensity for easy handling
		currentIntensity = num2str(intensities(i));
        
        % For loop that goes through the dataStructure and picks out trials
        % with the current intensity
        for j = 1:length(dataStructure.trialNumber)
            
            % If this trial matches the current intensity, then we use the 
            %  info to fill in our responses matrix
            if(strcmp(dataStructure.intensity{j},currentIntensity))
                
                % --- Col ---

                % Check if the emotion is Happy or Fearful
                if(strcmp(dataStructure.trialEmotion{j},'fearful'))
                    col = 1;
                elseif(strcmp(dataStructure.trialEmotion{j},'happy'))
                    col = 2;
                end
                
                % Check if the emotion was in the first or second interval
                if(strcmp(dataStructure.targetOrder{j},'first'))
                    % Get the relevant response
                    relevantResponse = dataStructure.response1{j};
                elseif(strcmp(dataStructure.targetOrder{j},'second'))
                    % If it was the second interval, then we increase the
                    % column number by 2
                    col = col + 2;
                    % Get the relevant response
                    relevantResponse = dataStructure.response1{j};
                end
                
                % --- Row ---

                % Check if the response is Happy or Fearful
                if(strcmp(relevantResponse,'fearful'))
                    row = 1;
                elseif(strcmp(relevantResponse,'happy'))
                    row = 2;
                end
                
                % If they bet on the second interval, then we increase the
                % column number by 2
                if(strcmp(dataStructure.betInterval{j},'second'))
                    row = row + 2;
                end
                
                % --- Increment the relevant grid ---
                
                responses(row,col,i) = responses(row,col,i) + 1;

            end % End
            
        end % End of for loop that goes through the dataStructure
							  
	end % End of for loop that goes through intensities
	
end % End of function