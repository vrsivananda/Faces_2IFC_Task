%SHINE toolbox on the faces

%Get the list of files
filepath = [pwd '/img'];
d = uigetdir(filepath, 'Select a folder');
files = dir(fullfile(d, '*.png'));

%Load in the first image to extract the rows and columns to be used as a
%template
templateImage = imread(files(1).name);
rows = 422; %205; %Dimensions from the smallest image
cols = 348; %178;

%Specify the save location
saveLocation = [pwd '/img_resized'];

%Iterate through the list of files and make the image the same size
for i = 1:512
    
    %Load in the current name for easy handling
    currentFileName = files(i).name;
    
    %Load in the current image
    currentImg = imread(currentFileName);
    
    %Resize the image
    resizedImg = imresize(currentImg, [rows cols]);
    
    %Change the present working directory to Img_resized folder
    cd(saveLocation);
    
    %Save the image in img_resized folder
    imwrite(resizedImg, currentFileName);
    
end %End of for loop