function plotNeutralFacesData(neutralFacesDataAll)

% Parameters
barColor = [0.7, 0.7, 0.7];
minX = 0;
maxX = 3;

% Load in variables for easy handling
pHappy = neutralFacesDataAll(1,1,:).*100;
pFearful = neutralFacesDataAll(2,1,:).*100;
n = length(pHappy);

% Calculate the means
pHappyMean = mean(pHappy);
pFearfulMean = mean(pFearful);

% Calculate the standard deviations
pHappySD = std(pHappy);
pFearfulSD = std(pFearful);

% Calculate the standard error of the mean
pHappySEM = pHappySD/sqrt(n);
pFearfulSEM = pFearfulSD/sqrt(n);

% Load in the plotting variables for easy handling
y = [pHappyMean, pFearfulMean];

% Plot the bar graph
figure;
bar(y,'FaceColor',barColor);
hold on;
errorbar([1,2],y,[pHappySEM, pFearfulSEM],'.'); % This works when we run only this file

% Format the graph
set(gca, 'XTickLabel', {'Happy' 'Fearful'});
xlim([minX maxX]);
ylim([0 100]);

% line for when y = 0.5
hold on;
plot([minX maxX], [50, 50],'LineStyle','--','LineWidth',0.5,'Color',[0.5, 0.5, 0.5]);


end