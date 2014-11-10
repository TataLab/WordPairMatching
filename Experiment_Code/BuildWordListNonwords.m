


%build word - non-word matches from text files and the appropriate triggers
%assumes there are at least as many non-words as words (there should be
%many more)


subjectPath=['/Users/afrooz/Documents/MATLAB/WordPairMatching/Data/' subjectID '/']; %string together the path
sourcePath='/Users/afrooz/Documents/MATLAB/WordPairMatching/Experiment_Code/Word_Database/';

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
wordArray=nonwordSource_cleaned(1:80);  %a bit of hoop jumping
nonwordArray=nonwordSource_cleaned(81:160); 

numWords=size(wordArray,1);
numNonwords=size(nonwordArray,1);

%randomize the order of words and nonwords
r=randperm(numWords,numWords); %if you pass it the entire length of the array for both arguments it'll return new indices for every element...simple way to shuffle
wordArray(:,1)=wordArray(r,1);
r=randperm(numNonwords,numNonwords); %if you pass it the entire length of the array for both arguments it'll return new indices for every element...simple way to shuffle
nonwordArray(:,1)=nonwordArray(r,1);

r=randperm(numTrials,numTrials); %if you pass it the entire length of the array for both arguments it'll return new indices for every element...simple way to shuffle
rprime=r+(blockNum-1)*numTrials; %avoid word overlap beteen different blocks and trials
splittedWordArray(:,1)=wordArray(rprime,1);
r=randperm(numTrials,numTrials); %if you pass it the entire length of the array for both arguments it'll return new indices for every element...simple way to shuffle
rprime=r+(blockNum-1)*numTrials; %avoid word overlap beteen different blocks and trials
splittedNonwordArray(:,1)=nonwordArray(rprime,1);

for i=1:numPairs
    
    %since the order has been randomized we can just select the first n
    %elements for this subject
    pair(i).word=splittedWordArray{i,1}; %let it grow inside the loop
    pair(i).nonword=splittedNonwordArray{i,1};
    pair(i).trigger=pair(i).word(1:4); %use as a trigger the first four characters of the word (it should be unique unless you uncleverly include words like fireman and firetruck

end

%save out the pair structure into the current subject's data folder
save('pair','pair');

%also save out a vector of all the words and nonwords seen and non-seen by this subject and 
seenWords=splittedWordArray(1:numPairs,1);
nonseenWords=splittedWordArray(numPairs+1:end,1);
seenNonwords=splittedNonwordArray(1:numPairs,1);
nonseenNonwords=splittedNonwordArray(numPairs+1:end,1);
%Save seen and nonseen words and nonwords
words.seenWords= seenWords;
words.nonseenWords=nonseenWords;
nonwords.seenNonwords=seenNonwords;
nonwords.nonseenNonwords=nonseenNonwords;




