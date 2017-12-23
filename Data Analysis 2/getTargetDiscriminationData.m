function targetDiscriminationData = getTargetDiscriminationData(dataStructure)

intensities = [5,10,15,20,25,75,100];

%----Variables to keep track of data----

nTargetDiscrimination = zeros(1,length(intensities));
nValidTargetDiscriminationTrials = zeros(1,length(intensities));
nInvalidTargetDiscriminationTrials = zeros(1,length(intensities));

% ----Loop through all the trials----
for i = 1:length(dataStructure.trialNumber)
    
    % Load in the variables of this trial for easy handling
    rtInterval = dataStructure.rtInterval{i};
    rtEmotion = dataStructure.rtEmotion{i};
    intensity = str2double(dataStructure.intensity{i});
    emotionJudgment = dataStructure.emotionJudgment{i};
    
    %Check that this trial was correct
    if(strcmp(emotionJudgment,'correct'))
        correct = true;
    else
        correct = false;
    end
    
    % Index according to the intensity
    index = find(intensities == intensity);
    
    % Only count the trials if Interval Question and Emotion Question are 
    % within the reaction time limits
    if( (rtInterval > -1 && rtInterval < 4000) && ...
         (rtEmotion > -1 && rtEmotion < 4000) )

        % Increment the valid trial counter
        nValidTargetDiscriminationTrials(index) = nValidTargetDiscriminationTrials(index) + 1;
        
        % If the subject got it right, then increment that counter
        if(correct)
            nTargetDiscrimination(index) = nTargetDiscrimination(index) + 1;
        end
    
    % Else it is invalid, and we increment the invalid counter
    else
        nInvalidTargetDiscriminationTrials(index) = nInvalidTargetDiscriminationTrials(index) + 1;
    end % End if if -1 < rt < 4000
    
end % End of for loop that loops through all the trials

%----Consolidate the data and return----

% Calculate the % Bet Target Present Interval
percentTargetDiscrimination = nTargetDiscrimination./nValidTargetDiscriminationTrials;

% Return the data
targetDiscriminationData = [percentTargetDiscrimination;...
                            nTargetDiscrimination;...
                            nValidTargetDiscriminationTrials;...
                            nInvalidTargetDiscriminationTrials];