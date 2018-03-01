clear;
close all;

%----Analysis variables----

% The suffix of the file
fileSuffix = 'Round4&5&6';

% The levels of intensities for the analysis
intensities = [5, 15, 25, 75];

% Threshold for valid trials
validTrialsThreshold = 0.8; % Subjects with proportion below this is discarded


%----Reading the text file----

% Add the path to the data folder so that MATLAB can access it
addpath([pwd '/Data']);

% Create a path to the text file with all the subjects
path = ['Faces_2IFC_Task_Subjects_' fileSuffix '.txt'];
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

% This is a 3D matrix that stores all subject's data on betTPInterval,
% targetDiscrimination, and Type1SDT
% Each 2D sheet is a subject, depth is multiple subjects
betTPIntervalDataAll = [];
targetDiscriminationDataAll = [];
type1SDTDataAll = [];
neutralFacesDataAll = []; % This is (4 x 1 x nSubjects) dimensional (only 1 column)
responsesBasedOnStimuliAll = []; 
% ^ This is a (4 x 4 x length(intensities) x nSubjects) dimensional matrix


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
        disp(['-Subject ' subjectId ' has no simplified data.'])
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
    type1SDTData = calculateType1SDT(dataStructure, intensities);
    % ^ In the form:
    % 1st row: d'
    % 2nd row: c
    % 3rd row: nValidDiscriminationTrials
    
    % Neutral faces
    neutralFacesData = analyzeNeutralFaces(dataStructure);
    % ^ In the form:
    % 1st row: proportion Happy response
    % 2nd row: proportion Fearful response
    % 3rd row: nValidNeutralTrials
    % 4th row: nInvalidNeutralTrials
    
    % Responses based on stimuli
    responsesBasedOnStimuli = getResponsesBasedOnStimuli(dataStructure,intensities);
	% ^ In the form:
	% [TP1_Fear_Resp1_Fear,  TP1_Happy_Resp1_Fear,  TP2_Fear_Resp1_Fear,  TP2_Happy_Resp1_Fear;
	%  TP1_Fear_Resp1_Happy, TP1_Happy_Resp1_Happy, TP2_Fear_Resp1_Happy, TP2_Happy_Resp1_Happy;
	%  TP1_Fear_Resp2_Fear,  TP1_Happy_Resp2_Fear,  TP2_Fear_Resp2_Fear,  TP2_Happy_Resp2_Fear;
	%  TP1_Fear_Resp2_Happy, TP1_Happy_Resp2_Happy, TP2_Fear_Resp2_Happy, TP2_Happy_Resp2_Happy];
    % ^ For EACH 2D layer (corresponding to an intensity)
	% ^ It is a 3D matrix, one 2D layer per intensity
    
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
        type1SDTDataAll(:,:,nValidSubjects) = type1SDTData;
        neutralFacesDataAll(:,:,nValidSubjects) = neutralFacesData;
		responsesBasedOnStimuliAll(:,:,:,nValidSubjects) = responsesBasedOnStimuli;
		% ^ 4D matrix
    
    end
    
end % End of loop for each subject

%------------PLOT DATA----------------

% Plot the data for all the subjects
plotMainAnalysisData(betTPIntervalDataAll,targetDiscriminationDataAll);

% Plot the smoothened data for all the subjects
plotSmoothenedMainAnalysisData(betTPIntervalDataAll,targetDiscriminationDataAll);

% Plot the data for all the subjects using d' as x-axis
plotMainAnalysisDataDPrime(betTPIntervalDataAll,type1SDTDataAll);

% Plot the data for all the subjects using d' as x-axis
plotSmoothenedMainAnalysisDataDPrime(betTPIntervalDataAll,type1SDTDataAll);

% Plot the Type1 SDT data
plotType1SDTData(type1SDTDataAll, intensities);

% Plot the neutral Faces Data
plotNeutralFacesData(neutralFacesData);
