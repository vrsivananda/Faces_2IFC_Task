clear all;
close all;

% Add the path to the data folder so that MATLAB can access it
addpath([pwd '/Data']);

% Create a path to the text file with all the subjects
path='Faces_2IFC_Task_Subjects_All.txt';
% Make an ID for the subject list file
subjectListFileId=fopen(path);
% Read in the number from the subject list
numberOfSubjects = fscanf(subjectListFileId,'%d');

%----Variables to keep track of subjects----

% Incomplete Data
nIncompleteData = 0;
incompleteDataSubjectIds = {};

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
    
    % Keep track of valid data
    nValidSubjects = nValidSubjects + 1;
    validSubjectIds{size(validSubjectIds,1)+1,1} = subjectId;
    
    % Load the data structure into a new variable for easy handling
    dataStructure = Alldata.newDataStructure;
    
    %---------------ANALYZE DATA----------------
    
    % Target Present Interval
    betTPIntervalData = getBetTPIntervalData(dataStructure);
    % ^ In the form:
    % 1st row: percent TP Correct
    % 2nd row: nBetTPInterval
    % 3rd row: nValidTPIntervalTrials
    % 4th row: nInvalidTPIntervalTrials
    
    % Count the total number of trials analyzed for the subject (for
    % debugging)
    totalTrialsAnalyzed = sum(sum(betTPIntervalData(3:4,:)));
    disp(totalTrialsAnalyzed);
    
    % Target Discrimination 
    targetDiscriminationData = getTargetDiscriminationData(dataStructure);
    
    %---------------STORE DATA--------------
    
    % Add another sheet (3rd dimension) for each subject
    betTPIntervalDataAll(:,:,nValidSubjects) = betTPIntervalData;
    targetDiscriminationDataAll(:,:,nValidSubjects) = targetDiscriminationData;
    
    
end % End of loop for each subject

%------------PLOT DATA----------------

% Plot the data for all the subjects
plotMainAnalysisData(betTPIntervalDataAll,targetDiscriminationDataAll);