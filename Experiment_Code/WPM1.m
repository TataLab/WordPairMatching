%WPM1 is an experiment to test the prediction that slow oscillations correlate
%with memory performance

%basic experiment parameters
stimOnTime=5; %seconds, how long to display stimuli
stimOffTime=1;
numPairs=3; %how many word - nonword pairs
numRepeats=3; %during learning phase; how many times to show each word/nonword pair
numTrials=6; %in the test phase; should be twice the number of pairs to even out new and old words

eeg=0; %set to 1 to enable eeg triggers sent to Netstation


%get the subject ID
blah = inputdlg('Please enter the subjet ID');
subjectID=blah{1,1};  %just the string please
clear blah;

%for this subject build randomized lists of words and nonwords and a pair
%structure, store them in the subject's data file
BuildWordLists;

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
Screen('TextSize',targetWindow, 20);
Screen('TextStyle', targetWindow, 1+2);

instructionsForLearning='Try to remember which nonword matches each word.  Keep your eyes on the centre of the screen.';
instructionsForTest='Press buttons 1 through 4 corresponding to which non-word matches the word above.  Select "new" if you have not seen this word before.';
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
RunTestPhase;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save out the time data for later use with EEGLab and the Avatar toolbox
save('learningPhaseEvents.mat','learningPhaseEvents');
save('testPhasePresentationEvents.mat','testPhasePresentationEvents');
save('testPhaseOutcomeEvents.mat','testPhaseOutcomeEvents');


%%%%% cleanup
NetStation('StopRecording');
NetStation('Disconnect');

Screen('CloseAll');
