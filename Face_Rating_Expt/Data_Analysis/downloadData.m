
clear;
close all;

% Add the java file that you'll need to use to connect to the database
javaaddpath('mysql-connector-java-5.1.42-bin.jar');

% Create a connection object by connecting to our SQL database.
databaseUsername = '';
databasePassword = '';
databaseName = '';
tableName = '';
serverAddess = '';
conn = database(databaseName,databaseUsername,databasePassword,'Vendor','MySQL',...
    'Server',serverAddess);


% Load a text file that lists all of the subjects.
path='subjects.txt';
% Make an ID for the subject list file
subjectListFileId=fopen(path);
% Read in the number from the subject list
numberOfSubjects = fscanf(subjectListFileId,'%d');
disp('Number of subjects: ');
disp(numberOfSubjects); 

% Loop through all the subjects to get all the data from the database
for i = 1:numberOfSubjects
    
    % Read the subject ID from the file, stop after each line
    subjectId = fscanf(subjectListFileId,'%s',[1 1]);
    % Print out the subject ID
    fprintf('subject: %s\n',subjectId);

    % Make the SQL query to download everything.
    sqlquery = ['SELECT * FROM ' tableName ' WHERE subject = "' subjectId '"'];
    
    % Change the path
    currentFolderPath = pwd;
    desiredFolderPath = [pwd '/Data'];
    
    %------------%
    % CELL ARRAY %
    %------------%
    
    dataFormat = 'cellarray';
    
    % Execute the query
    cursor = exec(conn,sqlquery);
    % Set the format of how you want the data to be stored
    setdbprefs('DataReturnFormat',dataFormat);
    cursor = fetch(cursor);
    % Get the data in the format specified above
    data = cursor.Data;
    %Save the data
    savingFileName = [dataFormat '_data_' subjectId];
    savingFilePath = [desiredFolderPath '/' savingFileName];
    save(savingFilePath, 'data');
    
    %-----------%
    % STRUCTURE %
    %-----------% 
    
    dataFormat = 'structure';
    
    % Execute the query
    cursor = exec(conn,sqlquery);
    % Set the format of how you want the data to be stored
    setdbprefs('DataReturnFormat',dataFormat);
    cursor = fetch(cursor);
    % Get the data in the format specified above
    data = cursor.Data;
    % Save the data
    savingFileName = [dataFormat '_data_' subjectId];
    savingFilePath = [desiredFolderPath '/' savingFileName];
    save(savingFilePath, 'data');
    

end % End of for loop that goes through all the subjects