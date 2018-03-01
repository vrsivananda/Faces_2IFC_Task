function neutralFacesData = analyzeNeutralFaces(dataStructure)

%----Variables to keep track of data----

% Keep track of valid and invalid trials
nValidNeutralTrials = 0;
nInvalidNeutralTrials = 0;

% Counters for happy and fearful responses
happyCounter = 0;
fearfulCounter = 0;

% ----Loop through all the trials----
for i = 1:length(dataStructure.trialNumber)
    
    % Load in the variables of this trial for easy handling
    rtNeutral = dataStructure.rtNeutral{i};
    neutralJudgment = dataStructure.neutralJudgment{i};
    
    % Only count the trials if Interval Question and Emotion Question are 
    % within the reaction time limits
    if( (rtNeutral > -1 && rtNeutral < 4000) )

        % Increment the valid trial counter
        nValidNeutralTrials = nValidNeutralTrials + 1;
        
        % If the emotion was happy, increment the happy counter
        if (strcmp(neutralJudgment, 'happy'))
            
            happyCounter = happyCounter + 1;
            
        % If the emotion was fearful, increment the fearful counter    
        elseif (strcmp(neutralJudgment, 'fearful'))
            
            fearfulCounter = fearfulCounter + 1;
            
        end
    
    % Else it is invalid, and we increment the invalid counter
    else
        nInvalidNeutralTrials = nInvalidNeutralTrials + 1;
    end % End if if -1 < rt < 4000
    
end % End of for loop that loops through all the trials

%----Calculate the percentage responses----

% Total up number of responses
total = happyCounter + fearfulCounter;

% Get the precentage of happy responses
pHappy = happyCounter / total;

% Get the percentage of fearful responses
pFearful = fearfulCounter / total;

%----Consolidate the data and return----

% Return the data
neutralFacesData = [pHappy;...
                    pFearful;...
                    nValidNeutralTrials;...
                    nInvalidNeutralTrials;];