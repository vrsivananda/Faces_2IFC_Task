function plotMainAnalysisData(betTPIntervalDataAll,targetDiscriminationDataAll)

% New figure
figure;

% Parameters
markerSize = 20;
%markerColor = 'b';
markerType = '.';
%lineColor = 'white'; % Invisible

% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';

% Get the number of subjects
numberOfSubjects = size(betTPIntervalDataAll,3);

% Preallocate legend cell array
legendCellArray = cell(numberOfSubjects,1);

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

% ---Draw the individual subjects' data---

% Loop through each subject and plot the data
for i = 1:numberOfSubjects

    % Get the data for this subject
    betTPIntervalData = betTPIntervalDataAll(1,:,i);
    targetDiscriminationData = targetDiscriminationDataAll(1,:,i);
    
    % Plot the data
    plot(targetDiscriminationData,betTPIntervalData,'Marker',markerType,...
    'MarkerSize',markerSize);
    
    % Prepare the legend
    legendCellArray{i} = ['Subject: ' num2str(i)];
    
    % Hold on so that next plot goes on the same graph
    hold on;
    
end % End of for loop for each subject

% Hold off so that we end the plotting on the same graph
hold off;

% Set the axis limits
xlim([0.25 1]);
ylim([0.25 1]);

% Set the ticklabels
xticks([0.25,0.5,0.75,1]);
xticklabels({'0.25','0.5','0.75','1'});
yticks([0.25,0.5,0.75,1]);
yticklabels({'0.25','0.5','0.75','1'});

% Set the legend
%legend(legendCellArray,'Location','northwest');

