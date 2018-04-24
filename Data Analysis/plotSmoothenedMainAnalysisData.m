function plotSmoothenedMainAnalysisData(betTPIntervalDataAll,targetDiscriminationDataAll)

% Add the path to the boundedLine function
addpath('/boundedLinePackage/boundedline');

% New figure
figure;

% Smoothing parameters
smoothingParameter = 0.99;

% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';

% Shade of gray
grayIndex = 0.5;

% Get the values for the targetDiscriminationData
targetDiscriminationValues = targetDiscriminationDataAll(1,:,:); % This is a 2d plane
% Convert it into a vector to store as the x-axis
x = targetDiscriminationValues(:);

% Get the values for the betTPIntervalData
betTPIntervalValues = betTPIntervalDataAll(1,:,:); % This is a 2d plane
% Convert it into a vector to store as the x-axis
y = betTPIntervalValues(:);

% Smooth the data
%fitObject = fit(x,y,'smoothing','SmoothingParam',smoothingParameter);
fitObject = fit(x,y,'smoothingspline','SmoothingParam',smoothingParameter);


% Make the plot
h1 = plot(fitObject, x, y);
set(h1,'color','k');
set(h1,'lineWidth',4);
set(h1,'markerSize',25);
set(h1,'markerEdgeColor',[grayIndex, grayIndex, grayIndex]);
set(h1,'markerFaceColor',[grayIndex, grayIndex, grayIndex]);

% Turn off the legend
legendOff = gca; legend(legendOff,'off');

% Set the axis limits
xlim([0.25 1]);
ylim([0.25 1]);

% The x and y labels
xlabel('');
ylabel('');

% ---Draw the lines on the graph---

% line for when y = 0.5
hold on;
plot([0, 1], [0.5, 0.5],'LineStyle',lineStyle,'LineWidth',lineWidth,'Color','k');

% line for when x = 0.5
hold on;
plot([0.5, 0.5], [0, 1],'LineStyle',lineStyle,'LineWidth',lineWidth,'Color','k');

% line for when x = y
hold on;
plot([0, 1], [0, 1],'LineStyle',lineStyle,'LineWidth',lineWidth,'Color','k');