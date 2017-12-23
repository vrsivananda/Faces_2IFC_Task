function validIndices = getValidConfidenceJudgmentIndices(dataStructure)

% Get the indices of the trials between -1 and 4s
lessThan4SecondIndices = returnIndicesLessThan4Seconds(dataStructure.rt);

%----Confidence Judgment Indices----

% Get the indices of the confidenceJudgment trials
confidenceJudgmentAndEmotionIndices = sort([returnIndices(dataStructure.confidenceJudgment,'correct');...
    returnIndices(dataStructure.confidenceJudgment,'incorrect')]);

% Get only each third element from the first
indexing = 1:3:length(confidenceJudgmentAndEmotionIndices);

% Get the confidenceJudgmentIndices without the emotion question indices
confidenceJudgmentIndices = confidenceJudgmentAndEmotionIndices(indexing);

% Intersect the confidenceJudgmentIndices with the <4s indices to get the
% valid confidenceJudgment indices
validConfidenceJudgmentIndices = intersect(confidenceJudgmentIndices, lessThan4SecondIndices);

%----First and second presentation indices----

% Get the indices where the face was in the first presentation 
firstPresentationIndices = sort([returnIndices(dataStructure.judgment1,'correct');...
    returnIndices(dataStructure.judgment1,'incorrect')]);

% Get the indices where the face was in the second presentation 
secondPresentationIndices = sort([returnIndices(dataStructure.judgment2,'correct');...
    returnIndices(dataStructure.judgment2,'incorrect')]);

% Intersect the the first and second presentations with the <4s indices to 
% get the valid trials (-1/-2 to normalize to confidenceJudgment trials)
validFirstPresentationIndices = intersect(firstPresentationIndices,lessThan4SecondIndices) - 1;
validSecondPresentationIndices = intersect(secondPresentationIndices,lessThan4SecondIndices) - 2;

validPresentationIndices = sort([validFirstPresentationIndices; validSecondPresentationIndices])

%----Calculate valid indices----

% Intersect validPresentationIndices with validConfidenceJudgmentIndices to
% get all the valid indices
validIndices = intersect(validConfidenceJudgmentIndices,validPresentationIndices);