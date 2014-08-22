


%build word - non-word matches from text files and the appropriate triggers
%assumes there are at least as many non-words as words (there should be
%many more)


subjectPath=['/Users/Matthew/Documents/MATLAB/WordPairMatching/WPM1/Data/' subjectID '/']; %string together the path
sourcePath='/Users/Matthew/Documents/MATLAB/WordPairMatching/WPM1/Experiment_Code/Word_Database/';

% %pull in the list of possible words
% fid=fopen([sourcePath 'wordSource_cleaned.mat'],'r');
% junk=textscan(fid,'%s','delimiter',','); %why, oh why, does it have to be complicated
% wordArray=junk{1,1};
% fclose(fid);
% 
% %pull in the list of possible non-words
% fid=fopen([sourcePath 'nonwordSource_cleaned.mat'],'r');
% junk=textscan(fid,'%s','delimiter',','); %why, oh why, does it have to be complicated
% nonwordArray=junk{1,1};
% fclose(fid);

load([sourcePath 'wordSource_cleaned.mat']);
load([sourcePath 'nonwordSource_cleaned.mat']);

%now switch to subject's folder to store all the subject specific lists
mkdir(subjectPath);
cd(subjectPath); 

%make a data struct that matches a word to a non-word
wordArray=wordSource_cleaned;  %a bit of hoop jumping
nonwordArray=nonwordSource_cleaned; 

numWords=size(wordArray,1);
numNonwords=size(nonwordArray,1);

%randomize the order of words and nonwords
r=randsample(numWords,numWords); %if you pass it the entire length of the array for both arguments it'll return new indices for every element...simple way to shuffle
wordArray(:,1)=wordArray(r,1);
r=randsample(numNonwords,numNonwords); %if you pass it the entire length of the array for both arguments it'll return new indices for every element...simple way to shuffle
nonwordArray(:,1)=nonwordArray(r,1);

for i=1:numPairs
    
    %since the order has been randomized we can just select the first n
    %elements for this subject
    pair(i).word=wordArray{i,1}; %let it grow inside the loop
    pair(i).nonword=nonwordArray{i,1};
    pair(i).trigger=pair(i).word(1:4); %use as a trigger the first four characters of the word (it should be unique unless you uncleverly include words like fireman and firetruck

end

%save out the pair structure into the current subject's data folder
save('pair','pair');

%also save out a vector of all the words and nonwords seen and non-seen by this subject and 
seenWords=wordArray(1:numPairs,1);
nonseenWords=wordArray(numPairs+1:end,1);
seenNonwords=nonwordArray(1:numPairs,1);
nonseenNonwords=nonwordArray(numPairs+1:end,1);

save('seenWords', 'seenWords');
save('nonseenWords','nonseenWords');
save('seenNonwords','seenNonwords');
save('nonseenNonwords','nonseenNonwords');



