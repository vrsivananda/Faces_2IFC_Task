close all;

% Add the path to the data folder so that MATLAB can access it
addpath([pwd '/Data']);

% Create a path to the text file with all the subjects
path='Faces_2IFC_Task_Subjects_All.txt';
% Make an ID for the subject list file
subjectListFileId=fopen(path);
% Read in the number from the subject list
numberOfSubjects = fscanf(subjectListFileId,'%d');

%----Prepare Arrays to store the data----

% Variable to keep track of how many valid subjects there are
nValidSubjects = 0;

% Matrix to store all the percent correct interval bets from all subjects
percentCorrectConfidenceJudgmentAllSubjects = [];

% Array to store all the judgment correct from all the subjects
percentCorrectEmotionJudgmentAllSubjects = [];


%----Prepare Arrays to store discarded subjects data----

% Total number of subjects discarded
nDiscarded = 0;

% Number discarded due to incomplete data
nDiscardedIncompleteData = 0;
% Subject ID of those discarded due to incomplete data
discardedIncompleteDataSubjectId = {};


%----Start looping and get the values----

for i = 1:numberOfSubjects
    
    % Read the subject ID from the file, stop after each line
    subjectId = fscanf(subjectListFileId,'%s',[1 1]);
    % Print out the subject ID
    fprintf('subject: %s\n',subjectId);
    
    % Import the data
    Alldata = load(['structure_data_' subjectId '.mat']);
    dataStructure = Alldata.data;
    
    % Get the indices of all the real trials
    realTrialIndices = returnIndices(dataStructure.trialType,'real');
    
    %----Gatekeeper #1----
    
    % If the number of real trials are less than 500 (100 trials x 5 times
    % logged per trial) then discard it and log down the info
    if(length(realTrialIndices) < 500)
        
        % Increment the general discarded counter
        nDiscarded = nDiscarded + 1;
        
        % Increment this incomplete data discarded counter
        nDiscardedIncompleteData = nDiscardedIncompleteData + 1;
        % Log in the subject ID
        discardedIncompleteDataSubjectId{nDiscardedIncompleteData} = subjectId;
        
    % Else continue with the data analysis  
    else
        
        % Analyze the data from this subject
        subjectData = analyzeOneSubjectData(dataStructure);
        
        
%         %----Correct Judgment of Faces (regardless of betting)----
%         
%         % Get the indices of correct responses for judgment1 (first interval judgment)
%         correctJudgment1Indices = returnIndices(dataStructure.judgment1, 'correct');
%         
%         % Get the indices of correct responses for judgment2 (second interval judgment)
%         correctJudgment2Indices = returnIndices(dataStructure.judgment2, 'correct');
%         
%         % Get the indices of correct responses for judgment1 on real trials
%         correctJudgment1RealIndices = intersect(realTrialIndices,correctJudgment1Indices);
%         
%         % Get the indices of correct responses for judgment2 on real trials
%         correctJudgment2RealIndices = intersect(realTrialIndices,correctJudgment2Indices);
%         
%         % Get the total number of correct responses for emotion judgments
%         nJudgmentCorrect = length(correctJudgment1RealIndices) + length(correctJudgment2RealIndices);
%         
%         % Get the percentage correct by dividing by total number of trials
%         percentJudgmentCorrect = nJudgmentCorrect/100;
        
%         %--------STORE DATA---------
%         
%         % Increment the number of valid subjects [Make sure to move this to
%         % the last gatekeeper]
%         nValidSubjects = nValidSubjects + 1;
%         
%         % Store the percentBetCorrect
%         percentBetCorrectAllSubjects(nValidSubjects,1) = percentBetCorrect;
%         
%         % Store the percentJudgmentCorrect
%         percentJudgmentCorrectAllSubjects(nValidSubjects,1) = percentJudgmentCorrect;
%         
    end % End of Gatekeeper #1
    
end % End of for loop for subjects

%----PLOT DATA----

% Plot the data for % Bet on target correct against time
% plotData(percentJudgmentCorrectAllSubjects,percentBetCorrectAllSubjects);
