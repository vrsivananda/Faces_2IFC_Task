clear;
close all;

% Create a path to the text file with all the subjects
path='subjects.txt';
% Make an ID for the subject list file
subjectListFileId=fopen(path);
% Read in the number from the subject list
numberOfSubjects = fscanf(subjectListFileId,'%d');

% ---Variables for storage---
allRatingsHappy = []; % Matrix of [subject x person]
allRatingsFearful = [];

% For loop that loops through all the subjects
for i = 1:numberOfSubjects
    
    % Read the subject ID from the file, stop after each line
    subjectId = fscanf(subjectListFileId,'%s',[1 1]);
    % Print out the subject ID
    fprintf('subject: %s\n',subjectId);
    
    % Import the data
    Alldata = load([pwd '/Data/structure_data_' subjectId '.mat']);
    % Data structure that contains all the data for this subject
    dataStructure = Alldata.data;
    
    % Go through the data and fill in the matrix
    for j = 1:length(dataStructure.rt)
        
        % Get the rating
        currentRating = dataStructure.response(j);
        
        % Get the person
        currentPerson = dataStructure.person(j);
        
        % Get the emotion
        currentEmotion = dataStructure.emotion{j};
        
        % Fill in the matrix based on the emotion
        if(strcmp(currentEmotion,'happy'))
            allRatingsHappy(i,currentPerson) = currentRating;
        elseif(strcmp(currentEmotion,'fearful'))
            allRatingsFearful(i,currentPerson) = currentRating;
        end
        
    end
    
    
end % End of for loop that loops through each subject


meanHappy = mean(allRatingsHappy);
meanFearful = mean(allRatingsFearful);

sdHappy = std(allRatingsHappy);
sdFearful = std(allRatingsFearful);

semHappy = sdHappy/sqrt(numberOfSubjects);
semFearful = sdFearful/sqrt(numberOfSubjects);

% Stacked data
stackedRatings = [meanHappy; meanFearful];
bar(stackedRatings','stacked');

% Legend
hold on;
legend({'happy','fearful'})

% y-limits
ylim([0 200]);

% Axis labels
xlabel('face');
ylabel('ratings');

% Errorbar for happy
hold on;
errorbar(1:size(meanHappy,2),meanHappy,semHappy,'g.');

% Errorbar for fearful
hold on;
errorbar(1:size(meanFearful,2),meanHappy+meanFearful,semFearful,'k.');

% ------------------
% Differences between the two emotions
difference = abs(meanHappy - meanFearful)';

% ------------------
% Compare if the 2 faces are from different distributions

% Make a store for the t-test output
ttestOutput = zeros(5,size(allRatingsHappy,2));

% Collect the stats for this face
[h,p,ci,stats] = ttest(allRatingsHappy,allRatingsFearful);

ttestOutput(1,:) = h;
ttestOutput(2,:) = p;
ttestOutput(3:4,:) = ci;
ttestOutput(5,:) = stats.tstat;
ttestOutput(6,:) = stats.df;
ttestOutput(7,:) = stats.sd;

% New figure
figure;

% Plot the p-values
bar(p);

% Plot the p-value == 0.5 line
hold on;
plot([0,size(allRatingsHappy,2)],[0.05,0.05],'--r')

% Axis labels
xlabel('face');
ylabel('p-value');

% y limits
ylim([0, 1]);

% ------------------


% Total up the ratings for each face
totalRatings = meanHappy + meanFearful;

% Rank the faces
sortedRatings = sort(totalRatings,'descend');

% Store for the sorting
sortedFaces = [];

% Loop through all the sortedRatings
for i = 1:length(sortedRatings)
    
    % Get the current rating
    currentRating = sortedRatings(i);
    
    % If the current rating is not zero
    if(currentRating ~= 0)

        % Find the face where the rating is in the current i
        currentFaceNumber = find(totalRatings == currentRating);

        % Find the h and p-value of the current face number;
        currentH = h(currentFaceNumber);
        currentPValue = p(currentFaceNumber);
        
        % Store it in the sorted faces matrix
        sortedFaces(i,1:4) = [currentFaceNumber, currentRating, currentH, currentPValue];

    end % End of if
    
end % End of for loop

