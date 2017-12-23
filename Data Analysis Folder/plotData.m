function plotData(judgmentArray, betArray)

% Parameters
markerSize = 20;
markerColor = 'b';
markerType = '.';
lineColor = 'white'; % Invisible

% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';

% Plot
plot(judgmentArray,betArray,'Marker',markerType,'MarkerEdgeColor',markerColor,...
    'MarkerFaceColor',markerColor,'MarkerSize',markerSize,'Color',lineColor);

% Set the axis limits
xlim([0 1]);
ylim([0 1]);

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