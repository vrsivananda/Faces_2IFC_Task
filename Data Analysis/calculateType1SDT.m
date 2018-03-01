function type1SDTData = calculateType1SDT(dataStructure, intensities)

%----Variables to keep track of data----

%Keep track of valid and invalid trials
nValidTargetDiscriminationTrials = zeros(1,length(intensities));
nInvalidTargetDiscriminationTrials = zeros(1,length(intensities));

% Faces and Responses
nHH = zeros(1,length(intensities));
nFH = zeros(1,length(intensities));
nFF = zeros(1,length(intensities));
nHF = zeros(1,length(intensities));


% ----Loop through all the trials----
for i = 1:length(dataStructure.trialNumber)
    
    % Load in the variables of this trial for easy handling
    rtInterval = dataStructure.rtInterval{i};
    rtEmotion = dataStructure.rtEmotion{i};
    intensity = str2double(dataStructure.intensity{i});
    trialEmotion = dataStructure.trialEmotion{i};
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
        
        % If the subject responded Happy and face was Happy, then increment that counter
        if(strcmp(trialEmotion, 'happy') && correct)
            nHH(index) = nHH(index) + 1;
        
        % Else  if the subject responded Fearful and face was Happy, then increment that counter
        elseif(strcmp(trialEmotion, 'happy') && ~correct)
            nFH(index) = nFH(index) + 1;
        
        % Else  if the subject responded Fearful and face was Fearful, then increment that counter
        elseif(strcmp(trialEmotion, 'fearful') && correct)
            nFF(index) = nFF(index) + 1;
        
        % Else  if the subject responded Happy and face was Fearful, then increment that counter
        elseif(strcmp(trialEmotion, 'fearful') && ~correct)
            nHF(index) = nHF(index) + 1;
        
        end % End of if happy && correct
    
    % Else it is invalid, and we increment the invalid counter
    else
        nInvalidTargetDiscriminationTrials(index) = nInvalidTargetDiscriminationTrials(index) + 1;
    end % End if if -1 < rt < 4000
    
end % End of for loop that loops through all the trials

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
type1SDTData = [dPrime;...
                c;...
                nValidTargetDiscriminationTrials];