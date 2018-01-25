function plotSmoothenedMainAnalysisData(betTPIntervalDataAll,targetDiscriminationDataAll)

% New figure
figure;

% Smoothing parameters
smoothingParameter = 0.99;

% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';

% Get the values for the targetDiscriminationData
targetDiscriminationValues = targetDiscriminationDataAll(1,:,:); % This is a 2d plane
% Convert it into a vector to store as the x-axis
x = targetDiscriminationValues(:);

% Get the values for the betTPIntervalData
betTPIntervalValues = betTPIntervalDataAll(1,:,:); % This is a 2d plane
% Convert it into a vector to store as the x-axis
y = betTPIntervalValues(:);

% Smooth the data
fitObject = fit(x,y,'smoothing','SmoothingParam',smoothingParameter);

% Make the plot
plot(fitObject, x, y);

% Turn off the legend
legendOff = gca; legend(legendOff,'off');

% Set the axis limits
xlim([0 1]);
ylim([0 1]);

% The x and y labels
xlabel('');
ylabel('');

% ---Draw the lines on the graph---

% line for when y = 0.5
hold on;
plot([0, 1], [0.5, 0.5],'LineStyle',lineStyle,'LineWidth',lineWidth);

% line for when x = 0.5
hold on;
plot([0.5, 0.5], [0, 1],'LineStyle',lineStyle,'LineWidth',lineWidth);

% line for when x = y
hold on;
plot([0, 1], [0, 1],'LineStyle',lineStyle,'LineWidth',lineWidth);