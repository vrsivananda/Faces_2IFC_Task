% This script goes through the the raw data and condenses it such that
% every experimental trial is in one line.

close all;

% Create a path to the text file with all the subjects
path='Faces_2IFC_Task_Subjects_Round2.txt';
% Make an ID for the subject list file
subjectListFileId=fopen(path);
% Read in the number from the subject list
numberOfSubjects = fscanf(subjectListFileId,'%d');

%----Variable to keep track of incomplete data----
nIncompleteData = 0;
incompleteDataSubjectId = {};

%----Variables to store each subject's data---
subject = {};
trialNumber = {};
rtInterval = {};
rtEmotion = {};
rtNeutral = {};
discardInterval = {};
discardEmotion = {};
discardNeutral = {};
trialEmotion = {};
targetOrder = {};
intensity = {};
intervalJudgment = {};
emotionJudgment = {};
neutralJudgment = {};


%----Start looping and get the values----

for i = 1:numberOfSubjects
    
    % Read the subject ID from the file, stop after each line
    subjectId = fscanf(subjectListFileId,'%s',[1 1]);
    % Print out the subject ID
    fprintf('subject: %s\n',subjectId);
    
    % Import the data
    Alldata = load(['structure_data_' subjectId '.mat']);
    dataStructure = Alldata.data;
    
    % Counter to tell which part of the trial the trialIndex is in
    counter = 0;
    
    % Only do subjects that have complete data
    if (length(returnIndices(dataStructure.trialType,'real')) < 500)
        
        %Save the data and move to the next subject
        nIncompleteData = nIncompleteData + 1;
        incompleteDataSubjectId{size(incompleteDataSubjectId,1)+1,1} = subjectId;
        
    else
    
        % For loop that goes through each trial_index
        for trialIndex = 1:length(dataStructure.trial_index)

            % Only record the real trials
            if(strcmp(dataStructure.trialType{trialIndex},'real'))

                %Increment the counter
                counter = counter + 1;

                %--- 1 ---  
                % If this is the first presentation
                if(counter == 1)
                    % Get the variables
                    currentTrialNumber = str2double(dataStructure.trialNumber{trialIndex});
                    currentTrialEmotion = dataStructure.trialEmotion{trialIndex};
                    currentTargetOrder = dataStructure.targetOrder{trialIndex};
                    % If the emotion was presented first, then save the intensity
                    if(strcmp(currentTargetOrder,'first'))
                       currentIntensity = dataStructure.intensity(trialIndex);
                    end

                %--- 2 ---    
                % Else if this was the second presentation
                elseif(counter == 2)
                    % If the emotion was presented second, then save the intensity
                    if(strcmp(currentTargetOrder,'second'))
                       currentIntensity = dataStructure.intensity(trialIndex);
                    end

                %--- 3 ---  
                % Else if this was the interval judgment
                elseif(counter == 3)
                    % Get the rt to make an interval judgment
                    currentRtInterval = dataStructure.rt(trialIndex);
                    currentIntervalJudgment = dataStructure.confidenceJudgment(trialIndex);

                %--- 4 ---  
                % Else if this was the first emotion judgment
                elseif(counter == 4)

                    % If the emotion was presented first, then we see if it was
                    % correct
                    if(strcmp(currentTargetOrder,'first'))
                        currentEmotionJudgment = dataStructure.judgment1(trialIndex);
                        % Get the rt to make an emotion judgment
                        currentRtEmotion = dataStructure.rt(trialIndex);

                    % Else see what they chose when the face was neutral
                    else
                        % Get the rt to make a neutral judgment
                        currentRtNeutral = dataStructure.rt(trialIndex);

                        % Get the keyPress
                        currentKeyPress = dataStructure.key_press(trialIndex);
                        if(currentKeyPress == 70)
                            currentNeutralJudgment = 'fearful';
                        elseif(currentKeyPress == 72)
                            currentNeutralJudgment = 'happy';
                        end % End of if keyPress

                    end % End of if targetOrder

                %--- 5 ---  
                % Else if this was the second emotion judgment
                elseif(counter == 5)

                    % If the emotion was presented second, then we see if it was
                    % correct
                    if(strcmp(currentTargetOrder,'second'))
                        currentEmotionJudgment = dataStructure.judgment2(trialIndex);
                        % Get the rt to make an emotion judgment
                        currentRtEmotion = dataStructure.rt(trialIndex);

                    % Else see what they chose when the face was neutral
                    else
                        % Get the rt to make a neutral judgment
                        currentRtNeutral = dataStructure.rt(trialIndex);

                        % Get the keyPress
                        currentKeyPress = dataStructure.key_press(trialIndex);
                        if(currentKeyPress == 70)
                            currentNeutralJudgment = 'fearful';
                        elseif(currentKeyPress == 72)
                            currentNeutralJudgment = 'happy';
                        end % End of if keyPress
                    end % End of if targetOrder

                    % Save all the variables (+1 because currentTrialNumber
                    % starts at 0)

                    subject{currentTrialNumber+1,1} = subjectId;
                    trialNumber{currentTrialNumber+1,1} = currentTrialNumber;
                    rtInterval{currentTrialNumber+1,1} = currentRtInterval;
                    rtEmotion{currentTrialNumber+1,1} = currentRtEmotion;
                    rtNeutral{currentTrialNumber+1,1} = currentRtNeutral;
                    discardInterval{currentTrialNumber+1,1} = {};
                    discardEmotion{currentTrialNumber+1,1} = {};
                    discardNeutral{currentTrialNumber+1,1} = {};
                    trialEmotion{currentTrialNumber+1,1} = currentTrialEmotion;
                    targetOrder{currentTrialNumber+1,1} = currentTargetOrder;
                    intensity{currentTrialNumber+1,1} = currentIntensity;
                    intervalJudgment{currentTrialNumber+1,1} = currentIntervalJudgment;
                    emotionJudgment{currentTrialNumber+1,1} = currentEmotionJudgment;
                    neutralJudgment{currentTrialNumber+1,1} = currentNeutralJudgment;

                    % Reset the counter
                    counter = 0;

                end % End of if counter

            end % End of if trialType == 'real'

        end % End of for loop that loops through each trial_index
    
        %------Organize and save data-------

        % Make the data structure to be saved
        newDataStructure.subject = subject;
        newDataStructure.trialNumber = trialNumber;
        newDataStructure.rtInterval = rtInterval;
        newDataStructure.rtEmotion = rtEmotion;
        newDataStructure.rtNeutral = rtNeutral;
        newDataStructure.discardInterval = discardInterval;
        newDataStructure.discardEmotion = discardEmotion;
        newDataStructure.discardNeutral = discardNeutral;
        newDataStructure.trialEmotion = trialEmotion;
        newDataStructure.targetOrder = targetOrder;
        newDataStructure.intensity = intensity;
        newDataStructure.intervalJudgment = intervalJudgment;
        newDataStructure.emotionJudgment = emotionJudgment;
        newDataStructure.neutralJudgment = neutralJudgment;
        
        % Save the data structure
        savingFileName = ['simplifiedDataStructure_data_' subjectId];
        save(savingFileName, 'newDataStructure');
    
    end % End of if length < 500 
    
end % End of for loop that loops through each subject