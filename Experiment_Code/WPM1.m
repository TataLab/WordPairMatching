%WPM1 is an experiment to test the prediction that slow oscillations correlate
%with memory performance

%*****************************Initialization ******************************
%basic experiment parameters
stimOnTime=5; %seconds, how long to display stimuli
stimOffTime=1;
<<<<<<< HEAD
numPairs=3; %how many word - nonword pairs
numRepeats=1; %during learning phase; how many times to show each word/nonword pair
numTrials=6; %in the test phase; should be twice the number of pairs to even out new and old words
=======
numPairs=20; %how many word - nonword pairs
numBlocks=1; %how many blocks of word - nonword pairs
numRepeats=1; %during learning phase; how many times to show each word/nonword pair
>>>>>>> FETCH_HEAD

numTrials=2*numPairs; %in the test phase; should be twice the number of pairs to even out new and old words
allTrials=cell(numBlocks,1); %a cell for saving all the trials
allWords=cell(numBlocks,1); %a cell for saving all words
allNonwords=cell(numBlocks,1); %a cell for saving all nonwords
allLearnTriggerTime=cell(numBlocks,1); %a cell for saving all events in tne learning phase

eeg=0; %set to 1 to enable eeg triggers sent to Netstation

%Defining counters for counting different responses
hitCounter=0;
missCounter=0;
lureCounter=0;
FACounter=0;%false alarm counter
CRCounter=0;%correct rejection counter
%**************************************************************************
%get the subject ID
blah = inputdlg('Please enter the subjet ID');
subjectID=blah{1,1};  %just the string please
clear blah;
for blockNum=1:numBlocks
    %for this subject build randomized lists of words and nonwords and a pair
    %structure, store them in the subject's data file
    BuildWordListNonwords;
    allWords{blockNum,1}=words; %save the words just in case
    allNonwords{blockNum,1}=nonwords; %save the nonwords just in case
    %%%%%%%%
    %some setup for PTB
    %%%%%%%%%

    %supress warnings - unsupress this if there's a problem
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1 );

    % Find out how many screens and use largest screen number.
    whichScreen = max(Screen('Screens'));

    %make two screens to flip between
    targetWindow = Screen('OpenWindow', whichScreen);

    % Retrieves color codes for black and white and gray.
    black = BlackIndex(targetWindow);  % Retrieves the CLUT color code for black.
    white = WhiteIndex(targetWindow);  % Retrieves the CLUT color code for white.
    gray = (black + white) / 2;  % Computes the CLUT color code for gray.

    r=Screen('rect',targetWindow);  %this rectangle has the dimensions of the screen
    windowW=r(3);
    windowH=r(4);
    screenCentreX =floor(windowW/2);
    screenCentreY=floor(windowH/2);


    %define a destination box to put the fixation point texture
    fixationH=10;
    fixationW=10;
    fixationCentreX=screenCentreX;  %bring them into our coordinate frame
    fixationCentreY=screenCentreY;
    topX = fixationCentreX - fixationW/2; %now compute the top-left corner because this is the "location" to start drawing the target
    topY = fixationCentreY - fixationH/2;
    bottomX = topX + fixationW;  %the bounding rectangle needs top-left and bottom-right coordinates
    bottomY = topY + fixationH;
    fixationDestination=[topX topY bottomX bottomY];

    %define x,y coordinate bounds for the positions of words during learning
    %phase
    learningWordPositionX='center';  %tells PTB to center the string
    learningWordPositionY=screenCentreY-60;
    learningNonwordPositionX='center';
    learningNonwordPositionY=screenCentreY+50;

    %build the target box
    aBox.texture=ones(fixationH,fixationW)*255;  %a white box
    aBox.index=Screen('MakeTexture',targetWindow,aBox.texture);

    % Colors the entire window gray.
    Screen('FillRect', targetWindow, gray);

    %set some text parameters
    % Select specific text font, style and size:
    Screen('TextFont',targetWindow, 'Arial');
    Screen('TextSize',targetWindow, 16);
    Screen('TextStyle', targetWindow, 1+2);

    instructionsForLearning='Try to remember which nonword matches each word.  Keep your eyes on the centre of the screen.';
    instructionsForTest='Press buttons 1 through 4 corresponding to which non-word matches the word above. Select "new" if you have not seen this word before.';
    instructionsForNextBlock='Press "enter" to continue to the next block.';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%%%%
    %%setup and initialize connection with Netstation
    %%%
    
    if(eeg)
    netstationHost='142.66.137.15';
    NetStation('Connect',netstationHost); %initialize a connection to the acquisition software
    Netstation('Synchronize');
    Netstation('StartRecording');
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%run the trials
    %%%%%%%%%%%%%%%%%                                                                    
    RunLearningPhase;
    allLearnTriggerTime{blockNum,1} = learningPhaseEvents; %save the trigger and the time in the learning phase for each block;
    RunTestPhase;
    allTrials{blockNum,1} = trial; %save the trail for each block
    
    %Ask the subject to press 'enter' for going to the next block
    if blockNum < numBlocks %we don't want to show the instructions at the end of the final block
    Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
    DrawFormattedText(targetWindow,instructionsForNextBlock,learningWordPositionX,learningWordPositionY,0,81);
    Screen('Flip', targetWindow);
    

    RestrictKeysForKbCheck(40); %only allow responses to 'enter' key 
    commandwindow;  %direct all the key presses to the command window so they don't cause havoc (alternatively use ListenChar() but this has weird and unpredictable behaviour)
    %wait for subject to press enter and continue to the next block
    while KbCheck; end % Wait until all keys are released.
    [secs, code, delta]=KbWait();
    end
end
PerformanceComp;

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save out the time data for later use with EEGLab and the Avatar toolbox
save('stimOnTime')
save('stimOffTime')
save('allTrials')
save('allWords')
save('allNonwords')
save('allLearnTriggerTime')
save('performanceVector')

%%%%% cleanup
NetStation('StopRecording');
NetStation('Disconnect');

Screen('CloseAll');
