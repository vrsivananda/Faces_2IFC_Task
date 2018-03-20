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

% 		% ------ Stimuli ------
% 
% 		% Get the indices where TP=1 && face was fearful
% 		TP1_Fear = returnIndicesIntersect(dataStructure.targetOrder,'first',...
% 										  dataStructure.trialEmotion,'fearful',...
% 										  dataStructure.intensity,currentIntensity);
% 
% 		% Get the indices where TP=1 && face was happy
% 		TP1_Happy = returnIndicesIntersect(dataStructure.targetOrder,'first',...
% 										   dataStructure.trialEmotion,'happy',...
% 										   dataStructure.intensity,currentIntensity);
% 
% 		% Get the indices where TP=2 && face was fearful
% 		TP2_Fear = returnIndicesIntersect(dataStructure.targetOrder,'second',...
% 										  dataStructure.trialEmotion,'fearful',...
% 										  dataStructure.intensity,currentIntensity);
% 
% 		% Get the indices where TP=2 && face was happy
% 		TP2_Happy = returnIndicesIntersect(dataStructure.targetOrder,'second',...
% 										   dataStructure.trialEmotion,'happy',...
% 										   dataStructure.intensity,currentIntensity);
% 
% 		% ------ Responses ------
% 
% 		% Get the indices where subjects responded 'fearful' on first interval
% 		% and bet on it
% 		resp1_Fear = returnIndicesIntersect(dataStructure.response1,'fearful',...
% 											dataStructure.betInterval,'first',...
% 										    dataStructure.intensity,currentIntensity);
% 
% 		% Get the indices where subjects responded 'fearful' on first interval
% 		% and bet on it
% 		resp1_Happy = returnIndicesIntersect(dataStructure.response1,'happy',...
% 											 dataStructure.betInterval,'first',...
% 										     dataStructure.intensity,currentIntensity);
% 
% 		% Get the indices where subjects responded 'fearful' on second interval
% 		% and bet on it
% 		resp2_Fear = returnIndicesIntersect(dataStructure.response1,'fearful',...
% 											dataStructure.betInterval,'second',...
% 										    dataStructure.intensity,currentIntensity);
% 
% 		% Get the indices where subjects responded 'fearful' on second interval
% 		% and bet on it
% 		resp2_Happy = returnIndicesIntersect(dataStructure.response1,'happy',...
% 											 dataStructure.betInterval,'second',...
% 										     dataStructure.intensity,currentIntensity);
% 
% 
% 		% ----------- Intersect them to pair up stimuli and response -----------
% 
% 		% Fearful stimuli in first interval (TP = 1, Fear)
% 		TP1_Fear_Resp1_Fear	 = length(intersect(TP1_Fear,resp1_Fear));
% 		TP1_Fear_Resp1_Happy = length(intersect(TP1_Fear,resp1_Happy));
% 		TP1_Fear_Resp2_Fear	 = length(intersect(TP1_Fear,resp2_Fear));
% 		TP1_Fear_Resp2_Happy = length(intersect(TP1_Fear,resp2_Happy));
% 
% 		% Happy stimuli in first interval (TP = 1, Happy)
% 		TP1_Happy_Resp1_Fear  = length(intersect(TP1_Happy,resp1_Fear));
% 		TP1_Happy_Resp1_Happy = length(intersect(TP1_Happy,resp1_Happy));
% 		TP1_Happy_Resp2_Fear  = length(intersect(TP1_Happy,resp2_Fear));
% 		TP1_Happy_Resp2_Happy = length(intersect(TP1_Happy,resp2_Happy));
% 
% 		% Fearful stimuli in second interval (TP = 2, Fear)
% 		TP2_Fear_Resp1_Fear	 = length(intersect(TP2_Fear,resp1_Fear));
% 		TP2_Fear_Resp1_Happy = length(intersect(TP2_Fear,resp1_Happy));
% 		TP2_Fear_Resp2_Fear	 = length(intersect(TP2_Fear,resp2_Fear));
% 		TP2_Fear_Resp2_Happy = length(intersect(TP2_Fear,resp2_Happy));
% 
% 		% Happy stimuli in second interval (TP = 2, Happy)
% 		TP2_Happy_Resp1_Fear  = length(intersect(TP2_Happy,resp1_Fear));
% 		TP2_Happy_Resp1_Happy = length(intersect(TP2_Happy,resp1_Happy));
% 		TP2_Happy_Resp2_Fear  = length(intersect(TP2_Happy,resp2_Fear));
% 		TP2_Happy_Resp2_Happy = length(intersect(TP2_Happy,resp2_Happy));
% 
% 		% ----------- Put it in a matrix and add it into the larger matrix -----------
% 
% 		currentIntensityOutput = [TP1_Fear_Resp1_Fear,	TP1_Happy_Resp1_Fear,  TP2_Fear_Resp1_Fear,	 TP2_Happy_Resp1_Fear;...
% 								  TP1_Fear_Resp1_Happy, TP1_Happy_Resp1_Happy, TP2_Fear_Resp1_Happy, TP2_Happy_Resp1_Happy;...
% 								  TP1_Fear_Resp2_Fear,	TP1_Happy_Resp2_Fear,  TP2_Fear_Resp2_Fear,	 TP2_Happy_Resp2_Fear;...
% 								  TP1_Fear_Resp2_Happy, TP1_Happy_Resp2_Happy, TP2_Fear_Resp2_Happy, TP2_Happy_Resp2_Happy];
% 		
% 		% Add it to the larger matrix for the subject
% 		responses(:,:,i) = currentIntensityOutput;
							  
	end % End of for loop that goes through intensities
	
end % End of function