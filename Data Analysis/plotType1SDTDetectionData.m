function plotType1SDTDetectionData(neutralFacesDataAll, type1SDTDetectionDataAll, intensities)

% Parameters
markerSize = 20;
markerType = '.';
xLimBuffer = 10;
yLimBuffer = 0.1;

% Dashed lines parameters
lineWidth = 1;
lineStyle = '--';

% Get the number of subjects
numberOfSubjects = size(type1SDTDetectionDataAll,3);

% Preallocate legend cell array
legendCellArray = cell(numberOfSubjects,1);

% Prepare the arrays for plotting
intensities = [0 intensities];

%---- d' ----

% Plot on a new figure
figure;

% Calculate the min and max x and y values
minX = min(intensities);
maxX = max(intensities);
minY = min(min(type1SDTDetectionDataAll(1,:,:)));
maxY = max(max(type1SDTDetectionDataAll(1,:,:)));

% Loop through each subject and plot the data
for i = 1:numberOfSubjects

    % Get the data for this subject
    dPrime = [neutralFacesDataAll(5,1,i) type1SDTDetectionDataAll(1,:,i)];
    
    % Plot the data
    plot(intensities,dPrime,'Marker',markerType,...
    'MarkerSize',markerSize);
    
    % Prepare the legend
    legendCellArray{i} = ['Subject: ' num2str(i)];
    
    % Hold on so that next plot goes on the same graph
    hold on;
    
end % End of for loop for each subject

% line for when y = 0
plot([minX-xLimBuffer maxX+xLimBuffer], [0, 0],'LineStyle',lineStyle,'LineWidth',lineWidth, 'Color', 'k');

% Hold off so that we end the plotting on the same graph
hold off;

% Set the axis limits
xlim([minX-xLimBuffer maxX+xLimBuffer]);
ylim([minY-yLimBuffer maxY+yLimBuffer]);

% Set the axis labels
xlabel('intensities');
ylabel('d''');

% Set the x-ticks
xticks(intensities);

% Set the legend
%legend(legendCellArray,'Location','northwest');


%---- c ----

% Plot on a new figure
figure;

% Calculate the min and max x and y values
minX = min(intensities);
maxX = max(intensities);
minY = min(min(-[neutralFacesDataAll(6,:,:), type1SDTDetectionDataAll(2,:,:)]));
maxY = max(max(-[neutralFacesDataAll(6,:,:), type1SDTDetectionDataAll(2,:,:)]));

% Loop through each subject and plot the data
for i = 1:numberOfSubjects

    % Get the data for this subject
    c = -[neutralFacesDataAll(6,1,i), type1SDTDetectionDataAll(2,:,i)];
    
    % Plot the data
    plot(intensities,c,'Marker',markerType,...
    'MarkerSize',markerSize);
    
    % Hold on so that next plot goes on the same graph
    hold on;
    
end % End of for loop for each subject

% line for when y = 0
plot([minX-xLimBuffer maxX+xLimBuffer], [0, 0],'LineStyle',lineStyle,'LineWidth',lineWidth, 'Color', 'k');

% Hold off so that we end the plotting on the same graph
hold off;

% Set the axis limits
xlim([minX-xLimBuffer maxX+xLimBuffer]);
ylim([minY-yLimBuffer maxY+yLimBuffer]);

% Set the axis labels
xlabel('intensities');
ylabel('c');

% Set the x-ticks
xticks(intensities);

% Set the legend
%legend(legendCellArray,'Location','northeast');


end % End of function