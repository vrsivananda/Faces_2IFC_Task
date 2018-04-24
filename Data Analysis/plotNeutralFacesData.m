function plotNeutralFacesData(neutralFacesDataAll)

% ========== Plot percentages ==========

% Parameters
barColor = [0.7, 0.7, 0.7];
minX = 0;
maxX = 3;

% Load in variables for easy handling
pHappy = neutralFacesDataAll(1,1,:);
pFearful = neutralFacesDataAll(2,1,:);
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
ylim([0 1]);

% line for when y = 0.5
hold on;
plot([minX maxX], [0.5, 0.5],'LineStyle','--','LineWidth',0.5,'Color',[0.5, 0.5, 0.5]);


% ========== Calculate c against zero ==========

% Load in c
c_All = neutralFacesDataAll(6,1,:)

% Calculate the stats
cMean = mean(c_All);
cSD = std(c_All);
cSEM = cSD/sqrt(n);


% t-test against 0
disp('c for neutral faces against 0 (one-sample t-test):');
[h, p, ci, stats] = ttest(c_All,0)

% Plot the bar graph
figure;
bar(cMean,'FaceColor',barColor);
hold on;
errorbar(1, cMean, cSEM, '.'); % This works when we run only this file

% Format the graph
set(gca, 'XTickLabel', 'Neutral');
xlim([0 2]);
ylim([0 1]);

end