function type1SDTDetectionData = calculateType1SDTDetection(dataStructure, intensities)

%----Variables to keep track of data----

%Keep track of valid and invalid trials
nValidTargetDetectionTrials = zeros(1,length(intensities));
nInvalidTargetDetectionTrials = zeros(1,length(intensities));

% Targets and Responses (F - First Interval, S - Second Interval)
nFF = zeros(1,length(intensities));
nSF = zeros(1,length(intensities));
nSS = zeros(1,length(intensities));
nFS = zeros(1,length(intensities));


% ----Loop through all the trials----
for i = 1:length(dataStructure.trialNumber)
    
    % Load in the variables of this trial for easy handling
    rtInterval = dataStructure.rtInterval{i};
    rtEmotion = dataStructure.rtEmotion{i};
    intensity = str2double(dataStructure.intensity{i});
    targetOrder = dataStructure.targetOrder{i};
    intervalJudgment = dataStructure.intervalJudgment{i};
    
    %Check that this trial was correct
    if(strcmp(intervalJudgment,'correct'))
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
        nValidTargetDetectionTrials(index) = nValidTargetDetectionTrials(index) + 1;
        
        % If the subject responded First and target was in the First interval, then increment that counter
        if(strcmp(targetOrder, 'first') && correct)
            nFF(index) = nFF(index) + 1;
        
        % Else  if the subject responded First and target was in the Second interval, then increment that counter
        elseif(strcmp(targetOrder, 'second') && ~correct)
            nFS(index) = nFS(index) + 1;
        
        % Else  if the subject responded Second and target was in the Second interval, then increment that counter
        elseif(strcmp(targetOrder, 'second') && correct)
            nSS(index) = nSS(index) + 1;
        
        % Else  if the subject responded Second and target was in the First interval, then increment that counter
        elseif(strcmp(targetOrder, 'first') && ~correct)
            nSF(index) = nSF(index) + 1;
        
        end % End of if first && correct
    
    % Else it is invalid, and we increment the invalid counter
    else
        nInvalidTargetDetectionTrials(index) = nInvalidTargetDetectionTrials(index) + 1;
    end % End if if -1 < rt < 4000
    
end % End of for loop that loops through all the trials

%----Calculate SDT parameters----

% --Calculate d'FC--

% Total trials for each position
totalF = nFF + nSF;
totalS = nSS + nFS;

% Probability correct for each first/second order
pF = nFF./(totalF);
pS = nSS./(totalS);

% Adjust if pH or pF == 1 or == 0
pF = probabilityCorrection(pF, totalF);
pS = probabilityCorrection(pS, totalS);

% Calculate the z-score of the probabilities
zF = norminv(pF);
zS = norminv(pS);

% Calculate d'
dPrime = (zF + zS);

% --Calculate c--

% Just for convention
% Hit rate == P(First|First)
% FA rate == P(First|Second)

% Z(H)
zHR = zF;

% P(FA)
pFAR = nFS./(totalS);

% Adjust if pFA == 0
pFAR = probabilityCorrection(pFAR,totalS);

% Z(FA)
zFAR = norminv(pFAR);

% c
c = -(0.5)*(zHR + zFAR);

%----Consolidate the data and return----

% Return the data
type1SDTDetectionData = [dPrime;...
                        c;...
                        nValidTargetDetectionTrials];