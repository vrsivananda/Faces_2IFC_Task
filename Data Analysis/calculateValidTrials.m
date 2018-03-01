function output = calculateValidTrials(dataBlock)

% ^ dataBlock in the form:
% 1st row: percent Correct
% 2nd row: nBet
% 3rd row: nValidTrials
% 4th row: nInvalidTrials

% Total number of trials
totalTrials = sum(sum(dataBlock(3:4,:)));

% Number of valid trials
totalValidTrials = sum(dataBlock(3,:));

% The percent of valid trials
output = totalValidTrials/totalTrials;


end