function neutralFacesData = analyzeNeutralFaces(dataStructure)

%----Variables to keep track of data----

% Keep track of valid and invalid trials
nValidNeutralTrials = 0;
nInvalidNeutralTrials = 0;

% Counters for happy and fearful responses
happyCounter = 0;
fearfulCounter = 0;

% Counters for calculation of c
nHH = 0;
nFH = 0;
nFF = 0;
nHF = 0;

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
        
        % --- Counters for responses ---
        
        % If the emotion was happy, increment the happy counter
        if (strcmp(neutralJudgment, 'happy'))
            happyCounter = happyCounter + 1;
        % If the emotion was fearful, increment the fearful counter    
        elseif (strcmp(neutralJudgment, 'fearful'))
            fearfulCounter = fearfulCounter + 1;
        end
        
        % --- Hits and FAs ---
        
        % Randomly assign the emotion for this trial
        if(rand < 0.5)
            pseudoTrialEmotion = 'happy';
        else
            pseudoTrialEmotion = 'fearful';
        end
        
        % If emotion was happy and response was happy
        if(strcmp(pseudoTrialEmotion, 'happy') && strcmp(neutralJudgment, 'happy'))
            nHH = nHH + 1;
        % Else if emotion was fearful and response was happy
        elseif(strcmp(pseudoTrialEmotion, 'happy') && strcmp(neutralJudgment, 'fearful'))
            nFH = nFH + 1;
        % Else if emotion was fearful and response was fearful
        elseif(strcmp(pseudoTrialEmotion, 'fearful') && strcmp(neutralJudgment, 'fearful'))
            nFF = nFF + 1;
        % Else if emotion was fearful and response was happy
        elseif(strcmp(pseudoTrialEmotion, 'fearful') && strcmp(neutralJudgment, 'happy'))
            nHF = nHF + 1;
        end % End of if
    
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

%----Calculate SDT parameters----

% --Calculate d'FC--

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
dPrime = (zH + zF);

% --Calculate c--

% Just for convention
% Hit rate == P(Happy|Happy)
% FA rate == P(Happy|Fearful)

% Z(H)
zHR = zH;

% P(FA)
pFAR = nHF./(totalF);

% Adjust if pFA == 0
pFAR = probabilityCorrection(pFAR,totalH);

% Z(FA)
zFAR = norminv(pFAR);

% c
c = -(0.5)*(zHR + zFAR);

%----Consolidate the data and return----

% Return the data
neutralFacesData = [pHappy;...
                    pFearful;...
                    nValidNeutralTrials;...
                    nInvalidNeutralTrials;...
                    dPrime;...
                    c];