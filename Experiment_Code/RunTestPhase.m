%run subject through set of trials in which a word must be matched to its
%non-word pair, or identified as new
%two classes of trials:
%
%       old word trials: -choose a word from pairs
%                                -use its nonword as one of the targets
%
%       new word trials: -choose a word from the nonseenWords list
%                                -use random words from the seenNonwords list
%
%Trials need to be saved in a blocked trial. Hence, we define trial as the
%output of the function
%send triggers to netstation like this:
%-on presentation of the word, send the first three chars of the word plus
%'  T' for Test
%-on response, send the first three chars of 'hit', 'miss', 'correct
%rejection', 'lure' or 'false alarm', along with an 'R' for response.
%build trial vector

%split trials according to old or new word target
for i=1:floor(numTrials/2) %first half
    trial(i).old=1;
end

for i=floor(numTrials/2)+1:numTrials %second half
    trial(i).old=0;
end

%set the words,  we'll use the strategy of assigning the first pair,
%choosing randomly from additional pairs, then circshifting so there's a
%new pair at the front and the old pair goes to the back to be selected
%from

%RESPONSES:
%1=hit
%2=lure
%3=miss
%4=correct rejection
%5=false alarm
outcomeTriggers={'hit_';'lure';'miss';'crej';'falm'};

%for the bottom row we'll keep track of which is the correct response with
%a vector on the second row indicating 1s and 0s
for i=1:numTrials  %there should be 2x as many trials as there are word-nonword pairs in the training phase
    
    if(trial(i).old==1) %this is a seen word trial, take it and its pair
        trial(i).topRow=pair(1).word;
        trial(i).bottomRow{1,1}=pair(1).nonword;
        trial(i).bottomRow{1,2}=pair(randi(length(pair)-1)+1).nonword;  %select anything but the first word
        trial(i).bottomRow{1,3}=nonseenNonwords{1};
        trial(i).bottomRow{1,4}='new';
        trial(i).presentationTrigger=[trial(i).topRow(1:3) 'T']; %send this trigger to Netstation; T is for Test to differentiate from Learning.  As long as there are no words in the list that match in the first three characters then you can use this to align EEG epochs
        
        %the response mappings
        trial(i).bottomRow{2,1}='hit'; %the first word is the correct response
        trial(i).bottomRow{2,2}='lure'; % all the rest are incorrect
        trial(i).bottomRow{2,3}='false_alarm'; % all the rest are incorrect
        trial(i).bottomRow{2,4}='miss'; % all the rest are incorrect
        
        pair=circshift(pair,[0 -1]);%shift all the elements forward and wrap the first one to the back
        nonseenNonwords=circshift(nonseenNonwords,[ -1 0 ]);
    end

    if(trial(i).old==0) %this is an unseen word trial
        trial(i).topRow=nonseenWords{1};
        tempRandomSample=randperm(length(nonseenNonwords),3); %choose 3 without replacement
        trial(i).bottomRow{1,1}=nonseenNonwords{tempRandomSample(1)};
        trial(i).bottomRow{1,2}=nonseenNonwords{tempRandomSample(2)};
        trial(i).bottomRow{1,3}=nonseenNonwords{tempRandomSample(3)}; 
        trial(i).bottomRow{1,4}='new';
        trial(i).presentationTrigger='newT'; %send this trigger to netstation to indicate this is a new word
        
        %the response mappings
        trial(i).bottomRow{2,1}='false_alarm'; %the first three are incorrect
        trial(i).bottomRow{2,2}='false_alarm'; 
        trial(i).bottomRow{2,3}='false_alarm'; 
        trial(i).bottomRow{2,4}='correct_rejection'; %the last one is correct
        
        nonseenWords=circshift(nonseenWords,[ -1 0 ]);
    end
    
    %label this trial so it can be matched with the eeg recorded during
    %learning
    trial(i).trigger=trial(i).topRow(1:4); %this corresponds to the trigger that was sent to netstation when this word was presented during learning

    %now shuffle the columns of bottomRow while keeping the rows intact to
    %preserve relationship between items and correct/incorrect flag
    r=randperm(length(trial(i).bottomRow),length(trial(i).bottomRow));
    trial(i).bottomRow=trial(i).bottomRow(:,r');
    
    
end

%for recording latencies of events for use with the Avatar MATLAB toolbox
%and EEGLab
testPhasePresentationEvents=cell(1,2); 
testPhaseOutcomeEvents=cell(1,2); 


%shuffle the trials
trial=trial(randperm(length(trial),length(trial)));

targetPositionX=0;  %technically these are translations of the drawing position
targetPositionY=-100;
nonwordPositions=[-225 -75 75 225]; %x positions of centers of nonword boxes

%display instructions
%first draw the instructions and flip them up
Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
DrawFormattedText(targetWindow,instructionsForTest,learningWordPositionX,learningWordPositionY,0,81);
Screen('Flip', targetWindow);
WaitSecs(5);

Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
DrawFormattedText(targetWindow,'ready',learningWordPositionX,learningWordPositionY);
Screen('Flip', targetWindow);
WaitSecs(2);

Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
DrawFormattedText(targetWindow,'go',learningWordPositionX,learningWordPositionY);
Screen('Flip', targetWindow);
WaitSecs(2);


%loop the trials
RestrictKeysForKbCheck([30 31 32 33]); %only allow responses on keys '1' '2' '3' and '4' (positions 30 - 33 in the vector return by KbWait)
commandwindow;  %direct all the key presses to the command window so they don't cause havoc (alternatively use ListenChar() but this has weird and unpredictable behaviour)

for trialNum=1:numTrials
    
    %draw the target
    Screen('glPushMatrix', targetWindow);
    Screen('glTranslate', targetWindow, targetPositionX,targetPositionY, 0);
    DrawFormattedText(targetWindow,trial(trialNum).topRow,'center','center');
    Screen('glPopMatrix', targetWindow);
    
    for position=1:4
        %push, traslate, draw, pop to draw each word box in a different place
        Screen('glPushMatrix', targetWindow);
        Screen('glTranslate', targetWindow, nonwordPositions(position), 100, 0);
        DrawFormattedText(targetWindow,[num2str(position) ') ' trial(trialNum).bottomRow{1,position}],'center','center');
        Screen('glPopMatrix', targetWindow);
    end
    Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );

    %flip it
    [~,stimOnsetTime,~,~]=Screen('Flip', targetWindow);
    t=tic;  %redundant but convenient (and very very fast)
    NetStation('Event', trial(trialNum).presentationTrigger, stimOnsetTime); %send a trigger
    display(['sending event code ' trial(trialNum).presentationTrigger ' to Netstation at time ' num2str(stimOnsetTime)]); 
    
    %for use with Avatar toolbox and EEGLab
    testPhasePresentationEvents{1}=trial(trialNum).presentationTrigger;
    testPhasePresentationEvents{2}=t;
    trial(trialNum).TPPE = testPhasePresentationEvents; %record presentation events in the test phase (TPPE is the abbreviation for tesPhasePresentationEvents)

    %wait for subject to respond
    while KbCheck; end % Wait until all keys are released.
    [secs, code, delta]=KbWait();

    t=tic;
    trial(trialNum).response=find(code)-29; %record what the subject responded - since '1' is element 30, '2' is element 31 etc. we need only to subtract 29 to map onto the .bottomRow vector
    trial(trialNum).outcome=trial(trialNum).bottomRow{2,trial(trialNum).response};  %correct/incorrect code for this trial
    
    NetStation('Event', [trial(trialNum).outcome(1:3) 'R'], secs);  %does that work!!?? Yes! Secs is in the same time base as the return values of Screen('flip');
        %for use with Avatar toolbox and EEGLab
    testPhaseOutcomeEvents{1}=[trial(trialNum).outcome(1:3) 'R'];
    testPhaseOutcomeEvents{2}=t;
    trial(trialNum).TPOE = testPhaseOutcomeEvents; %save outcome events in the test phase (TPPE is the abbreviation for tesPhaseOutcomeEvents)

    
    display(['sending event code ' [trial(trialNum).outcome(1:3) 'R'] ' to Netstation at time ' num2str(secs)]); 

    %draw the fixation point into the window
    Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
%     DrawFormattedText(targetWindow,'not blah','center','center',0,[],[],[],[],wordbox);

    %flip it
     [~,~,~,~]=Screen('Flip', targetWindow);
   
end

%save out the trial vector
cd(subjectPath);  %in case it's changed
save('trialVector','trial');
RestrictKeysForKbCheck([]);
