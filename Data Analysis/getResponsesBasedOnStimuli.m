function output = getResponsesBasedOnStimuli(dataStructure, intensities)
	
	% Prepare the store for the subject
	responses = []; % This is a (4 x 4 x length(intensities)) dimensional matrix

	
	% For loop for each intensity
	for i = 1:length(intensities)
		
		% Load in current intensity for easy handling
		currentIntensity = num2str(intensities(i));

		% ------ Stimuli ------

		% Get the indices where TP=1 && face was fearful
		TP1_Fear = returnIndicesIntersect(dataStructure.targetOrder,'first',...
										  dataStructure.trialEmotion,'fearful',...
										  dataStructure.intensity,currentIntensity);

		% Get the indices where TP=1 && face was happy
		TP1_Happy = returnIndicesIntersect(dataStructure.targetOrder,'first',...
										   dataStructure.trialEmotion,'happy',...
										   dataStructure.intensity,currentIntensity);

		% Get the indices where TP=2 && face was fearful
		TP2_Fear = returnIndicesIntersect(dataStructure.targetOrder,'second',...
										  dataStructure.trialEmotion,'fearful',...
										  dataStructure.intensity,currentIntensity);

		% Get the indices where TP=2 && face was happy
		TP2_Happy = returnIndicesIntersect(dataStructure.targetOrder,'second',...
										   dataStructure.trialEmotion,'happy',...
										   dataStructure.intensity,currentIntensity);

		% ------ Responses ------

		% Get the indices where subjects responded 'fearful' on first interval
		% and bet on it
		resp1_Fear = returnIndicesIntersect(dataStructure.response1,'fearful',...
											dataStructure.betInterval,'first',...
										    dataStructure.intensity,currentIntensity);

		% Get the indices where subjects responded 'fearful' on first interval
		% and bet on it
		resp1_Happy = returnIndicesIntersect(dataStructure.response1,'happy',...
											 dataStructure.betInterval,'first',...
										     dataStructure.intensity,currentIntensity);

		% Get the indices where subjects responded 'fearful' on second interval
		% and bet on it
		resp2_Fear = returnIndicesIntersect(dataStructure.response1,'fearful',...
											dataStructure.betInterval,'second',...
										    dataStructure.intensity,currentIntensity);

		% Get the indices where subjects responded 'fearful' on second interval
		% and bet on it
		resp2_Happy = returnIndicesIntersect(dataStructure.response1,'happy',...
											 dataStructure.betInterval,'second',...
										     dataStructure.intensity,currentIntensity);


		% ----------- Intersect them to pair up stimuli and response -----------

		% Fearful stimuli in first interval (TP = 1, Fear)
		TP1_Fear_Resp1_Fear	 = length(intersect(TP1_Fear,resp1_Fear));
		TP1_Fear_Resp1_Happy = length(intersect(TP1_Fear,resp1_Happy));
		TP1_Fear_Resp2_Fear	 = length(intersect(TP1_Fear,resp2_Fear));
		TP1_Fear_Resp2_Happy = length(intersect(TP1_Fear,resp2_Happy));

		% Happy stimuli in first interval (TP = 1, Happy)
		TP1_Happy_Resp1_Fear  = length(intersect(TP1_Happy,resp1_Fear));
		TP1_Happy_Resp1_Happy = length(intersect(TP1_Happy,resp1_Happy));
		TP1_Happy_Resp2_Fear  = length(intersect(TP1_Happy,resp2_Fear));
		TP1_Happy_Resp2_Happy = length(intersect(TP1_Happy,resp2_Happy));

		% Fearful stimuli in second interval (TP = 2, Fear)
		TP2_Fear_Resp1_Fear	 = length(intersect(TP2_Fear,resp1_Fear));
		TP2_Fear_Resp1_Happy = length(intersect(TP2_Fear,resp1_Happy));
		TP2_Fear_Resp2_Fear	 = length(intersect(TP2_Fear,resp2_Fear));
		TP2_Fear_Resp2_Happy = length(intersect(TP2_Fear,resp2_Happy));

		% Happy stimuli in second interval (TP = 2, Happy)
		TP2_Happy_Resp1_Fear  = length(intersect(TP2_Happy,resp1_Fear));
		TP2_Happy_Resp1_Happy = length(intersect(TP2_Happy,resp1_Happy));
		TP2_Happy_Resp2_Fear  = length(intersect(TP2_Happy,resp2_Fear));
		TP2_Happy_Resp2_Happy = length(intersect(TP2_Happy,resp2_Happy));

		% ----------- Put it in a matrix and add it into the larger matrix -----------

		currentIntensityOutput = [TP1_Fear_Resp1_Fear,	TP1_Happy_Resp1_Fear,  TP2_Fear_Resp1_Fear,	 TP2_Happy_Resp1_Fear;...
								  TP1_Fear_Resp1_Happy, TP1_Happy_Resp1_Happy, TP2_Fear_Resp1_Happy, TP2_Happy_Resp1_Happy;...
								  TP1_Fear_Resp2_Fear,	TP1_Happy_Resp2_Fear,  TP2_Fear_Resp2_Fear,	 TP2_Happy_Resp2_Fear;...
								  TP1_Fear_Resp2_Happy, TP1_Happy_Resp2_Happy, TP2_Fear_Resp2_Happy, TP2_Happy_Resp2_Happy];
		
		% Add it to the larger matrix for the subject
		responses(:,:,i) = currentIntensityOutput;
							  
	end % End of for loop that goes through intensities
	
	% --- Return ---
	output = responses;
	
end % End of function