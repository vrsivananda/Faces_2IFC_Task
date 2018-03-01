function plotSmoothenedMainAnalysisDataDPrime(betTPIntervalDataAll,type1SDTDataAll)

% New figure
figure;

% Smoothing parameters
smoothingParameter = 0.99;

% Parameters
markerSize = 20;
%markerColor = 'b';
markerType = '.';
minX = -1;
maxX = 3;

% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';

% Get the values for the type1SDTData
type1SDTValues = type1SDTDataAll(1,:,:); % This is a 2d plane
% Convert it into a vector to store as the x-axis
x = type1SDTValues(:);

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
xlim([minX maxX]);
ylim([0 1]);


% ---Draw the lines on the graph---

% line for when x = 0
hold on;
plot([0, 0], [0, 1],'LineStyle',lineStyle,'LineWidth',lineWidth);

% line for when y = 0.5
hold on;
plot([minX maxX], [0.5, 0.5],'LineStyle',lineStyle,'LineWidth',lineWidth);
