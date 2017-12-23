function outputDataStructure = calculateResultAtIntensity(intensity, dataStructure)

% Get the indices of first && intensity (+3 to match with confidenceJudgment)
intensityFirstIndices = intersect(returnIndices(dataStructure.intensity,intensity),...
    returnIndices(dataStructure.targetOrder,'first')) + 3;

% Get the indices of second && intensity (+1 to match with confidenceJudgment)
intensitySecondIndices = intersect(returnIndices(dataStructure.intensity,intensity),...
    returnIndices(dataStructure.targetOrder,'second')) + 1;

% Combine them to get the indices of confidence Judgments at that intensity
intensityIndices = sort([intensityFirstIndices; intensitySecondIndices]);

% Get the valid confidenceJudgment trials
validConfidenceJudgmentIndices = getValidConfidenceJudgmentIndices(dataStructure);

%----Confidence Judgment calculations----

% Get only the valid confidenceJudgments at that intensity
validIntensityIndices = intersect(validConfidenceJudgmentIndices,...
    intensityIndices);

% Intersect the validIntensityIndices with the correct responses to get the
% total correct at that intensity
nCorrectAtIntensity = length(intersect(validIntensityIndices,...
    returnIndices(dataStructure.confidenceJudgment,'correct')));

% The number of valid trials at that intensity
nValidAtIntensity = length(validIntensityIndices);

% The percentage correct at that intensity
percentCorrectAtIntensity = nCorrectAtIntensity/nValidAtIntensity;

%----Emotion Judgment calculations----

% Get the indices of trials where judgment1 is correct, normalize them,
% make sure that they're valid, and intersect with intensity indices
validCorrectJudgment1Indices = intersect(intersect(returnIndices(dataStructure.judgment1,'correct')-1,...
    validConfidenceJudgmentIndices),intensityFirstIndices)

% Get the indices of trials where judgment2 is correct, normalize them,
% make sure that they're valid, and intersect with intensity indices
validCorrectJudgment2Indices = intersect(intersect(returnIndices(dataStructure.judgment2,'correct')-2,...
    validConfidenceJudgmentIndices),intensityFirstIndices)

% Combine the two normalized emotion judgment trials to get the indices that
% have either (first or second presentation) response correct
validCorrectEmotionJudgmentIndices = sort([validCorrectJudgment1Indices;validCorrectJudgment2Indices])

% The number of valid correct emotion judgment trials
nValidCorrectEmotionJudgment = length(validCorrectEmotionJudgmentIndices)

% The number of correct emotion judgments
nCorrectEmotionJudgment = length(validCorrectEmotionJudgmentIndices)

% The percent of correct emotion judgments on valid trials
percentCorrectEmotionJudgment = nCorrectEmotionJudgment/nValidCorrectEmotionJudgment;

%------Output-------

% The out put is in the form:
% [percentCorrectAtIntensity, nCorrectAtIntensity, nValidAtIntensity]
outputDataStructure.confidence = [percentCorrectAtIntensity; nCorrectAtIntensity; nValidAtIntensity];
outputDataStructure.emotion = [percentCorrectEmotionJudgment; nCorrectEmotionJudgment; nValidCorrectEmotionJudgment];
