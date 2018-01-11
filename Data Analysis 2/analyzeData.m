clear all;
close all;

%----Analysis variables----

% The levels of intensities for the analysis
intensities = [5, 25, 75, 100];

% Threshold for valid trials
validTrialsThreshold = 0.8; % Subjects with proportion below this is discarded


%----Reading the text file----

% Add the path to the data folder so that MATLAB can access it
addpath([pwd '/Data']);

% Create a path to the text file with all the subjects
path='Faces_2IFC_Task_Subjects_Round2.txt';
% Make an ID for the subject list file
subjectListFileId=fopen(path);
% Read in the number from the subject list
numberOfSubjects = fscanf(subjectListFileId,'%d');

%----Variables to keep track of subjects----

% Incomplete Data
nIncompleteData = 0;
incompleteDataSubjectIds = {};

% Too many invalid trials
nTooManyInvalidTrials = 0;
tooManyInvalidTrialsSubjectIds = {};

% Valid Subjects
nValidSubjects = 0;
validSubjectIds = {};

%----Variables to keep track of Data----

% This is a 3D matrix that stores all subject's data on betTPInterval
% and targetDiscrimination
% Each 2D sheet is a subject, depth is multiple subjects
betTPIntervalDataAll = [];
targetDiscriminationDataAll = [];


%----Start looping and get the values----

for i = 1:numberOfSubjects
    
    % Read the subject ID from the file, stop after each line
    subjectId = fscanf(subjectListFileId,'%s',[1 1]);
    % Print out the subject ID
    fprintf('subject: %s\n',subjectId);
    
    % Import the data
    try
        % Load the data if it exists
        Alldata = load(['simplifiedDataStructure_data_' subjectId '.mat']);
    catch
        % If not, then show that it has no simplified data
        disp(['Subject ' subjectId ' has no simplified data.'])
        % Keep track of incomplete data
        nIncompleteData = nIncompleteData + 1;
        incompleteDataSubjectIds{size(incompleteDataSubjectIds,1)+1,1} = subjectId;
        % Continue to next iteration of the for loop
        continue;
    end
    
    
    % Load the data structure into a new variable for easy handling
    dataStructure = Alldata.newDataStructure;
    
    %---------------ANALYZE DATA----------------
    
    % Target Present Interval
    betTPIntervalData = getBetTPIntervalData(dataStructure, intensities);
    % ^ In the form:
    % 1st row: percent TP Correct
    % 2nd row: nBetTPInterval
    % 3rd row: nValidTPIntervalTrials
    % 4th row: nInvalidTPIntervalTrials
    
    % Target Discrimination 
    targetDiscriminationData = getTargetDiscriminationData(dataStructure, intensities);
    % ^ Same form as above
    
    % SDT
    
    
    %---------------STORE DATA--------------
    
    % Calculate the number of valid trials
    percentValidTrialsBetTPInterval = calculateValidTrials(betTPIntervalData);
    percentValidTrialsTargetDiscrimination = calculateValidTrials(targetDiscriminationData);
    
    % If their valid trials are less than 80%, then we discard them
    if(percentValidTrialsBetTPInterval < validTrialsThreshold || percentValidTrialsTargetDiscrimination < validTrialsThreshold)
        
        % Increment the discard counter
        nTooManyInvalidTrials = nTooManyInvalidTrials + 1;
        tooManyInvalidTrialsSubjectIds{size(tooManyInvalidTrialsSubjectIds,1)+1,1} = subjectId;
    
    % Else increment the counter and add it into our data store
    else
    
        % Keep track of valid data
        nValidSubjects = nValidSubjects + 1;
        validSubjectIds{size(validSubjectIds,1)+1,1} = subjectId;

        % Add another sheet (3rd dimension) for each subject
        betTPIntervalDataAll(:,:,nValidSubjects) = betTPIntervalData;
        targetDiscriminationDataAll(:,:,nValidSubjects) = targetDiscriminationData;
    
    end
    
end % End of loop for each subject

%------------PLOT DATA----------------

% Plot the data for all the subjects
plotMainAnalysisData(betTPIntervalDataAll,targetDiscriminationDataAll);