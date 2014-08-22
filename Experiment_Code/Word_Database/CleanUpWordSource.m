%the word source is the normative database described here: 
% Buchanan et al. (2013) Behavior Research Methods 45(3), pp 746-757

%the pronouncable nonwords come from the (excellent) site:
%http://www.cogsci.mq.edu.au/cgi-bin/nwsrch.cgi and should be cited like
%this:
%Rastle et al. (2002) 358,534 nonwords: The ARC Nonword Database. Quarterly
%Journal of Experimental Psychology, 55A, 1339-1362



%ensure that the words in wordSource.mat fit criteria for WP1. Namely:
%at least 4 characters
%only alphabetic characters
%no repeats
%no contractions
%also removed 

load('wordSource.mat');

%remove a few words manually
wordSource(27,:) = []; %can't
wordSource(115,:)=[]; %mouse_computer
wordSource(41,:)=[];%condom
numWords=length(wordSource);

wordsToKeep=[1];  %a vector of elements to retain from wordSource, we know we will keep the first one

%first take out short words and words with numbers
for i=2:numWords %we know we'll keep the first word and this makes life easier
    keep=1;  %default we keep this word
    
    %reasons not to keep a word
    if(length(wordSource{i,1})<4)
        keep=0;
    end
    
    isNonNumeric=isstrprop(wordSource{i,1},'alpha');
    if(~(sum(isNonNumeric)==length(isNonNumeric))) %then at least one character is a number
        keep=0;
    end
    
    if(keep==1) %if it passed, add to the keeper list
        wordsToKeep=[wordsToKeep i];
    end
    
end


wordSource_cleanedOnce=wordSource(wordsToKeep,1);  %take only words we want

%recompute length of list
numWords=length(wordSource_cleanedOnce);
wordsToKeep=[1];  %a vector of elements to retain from wordSource, we know we will keep the first one

%loop again to take out matches
for j=2:numWords %
    keep=1;
    
    if (strcmp(wordSource_cleanedOnce{j,1}(1:4),wordSource_cleanedOnce{j-1,1}(1:4))) %if this word has four chars but matches the first four letters of previous word
        keep=0;
    end
    
   if(keep==1) %if it passed, add to the keeper list
        wordsToKeep=[wordsToKeep j];
    end
end

wordSource_cleaned=wordSource_cleanedOnce(wordsToKeep,1);
save('wordSource_cleaned.mat','wordSource_cleaned');