function betTPIntervalData = getBetTPIntervalData(dataStructure)

intensities = [5,10,15,20,25,75,100];

%----Variables to keep track of data----

nBetTPInterval = zeros(1,length(intensities));
nValidTPIntervalTrials = zeros(1,length(intensities));
nInvalidTPIntervalTrials = zeros(1,length(intensities));

% ----Loop through all the trials----
for i = 1:length(dataStructure.trialNumber)
    
    % Load in the variables of this trial for easy handling
    rtInterval = dataStructure.rtInterval{i};
    rtEmotion = dataStructure.rtEmotion{i};
    rtNeutral = dataStructure.rtNeutral{i};
    intensity = str2double(dataStructure.intensity{i});
    intervalJudgment = dataStructure.intervalJudgment{i};
    
    %Check that this trial was correct
    if(strcmp(intervalJudgment,'correct'))
        correct = true;
    else
        correct = false;
    end
    
    % Index according to the intensity
    index = find(intensities == intensity);
    
    % Only count the trials if all 3 are within the reaction time limits
    if( (rtInterval > -1 && rtInterval < 4000) && ...
         (rtEmotion > -1 && rtEmotion < 4000) && ...
         (rtNeutral > -1 && rtNeutral < 4000) )

        % Increment the valid trial counter
        nValidTPIntervalTrials(index) = nValidTPIntervalTrials(index) + 1;
        
        % If the subject got it right, then increment that counter
        if(correct)
            nBetTPInterval(index) = nBetTPInterval(index) + 1;
        end
    
    % Else it is invalid, and we increment the invalid counter
    else
        
        nInvalidTPIntervalTrials(index) = nInvalidTPIntervalTrials(index) + 1;

    end % End if if -1 < rt < 4000
    
end % End of for loop that loops through all the trials

%----Consolidate the data and return----

% Calculate the % Bet Target Present Interval
percentBetTPInterval = nBetTPInterval./nValidTPIntervalTrials;

% Return the data
betTPIntervalData = [percentBetTPInterval;nBetTPInterval;nValidTPIntervalTrials;nInvalidTPIntervalTrials];