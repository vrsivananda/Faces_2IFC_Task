function subjectDataConfidence = analyzeOneSubjectData(dataStructure)

% Parameters
intensityLevels = [5, 10, 15, 20, 25, 75, 100];

%----Preparing variables to store data----
subjectDataConfidence = [];
subjectDataEmotion = [];

%----Filtering out trials with responses < 4s----

% Get the indices of the valid confidenceJudgment trials
validConfidenceJudgmentIndices = getValidConfidenceJudgmentIndices(dataStructure);

%----Correct Betting on Interval----

% For loop that goes through all the intensity levels
for i = 1:length(intensityLevels)
    
    % Get the data for this subject as a data structure
    subjectDataStructure = calculateResultAtIntensity(...
        num2str(intensityLevels(i)), dataStructure);
    
    %--Confidence--
    
    % Slot in the data into our subjectDataConfidence matrix 
    subjectDataConfidence(:,size(subjectDataConfidence,2)+1) = subjectDataStructure.confidence;
    
    %--Emotion--
    
    % Slot in the data into our subjectDataConfidence matrix
    subjectDataEmotion(:,size(subjectDataEmotion,2)+1) = subjectDataStructure.emotion;
    
    
end %End of for loop

% subjectData is in the form:
% [percent5,  percent10,  ...;
%  nCorrect5, nCorrect10, ...;
%  total5,    total10,    ...]