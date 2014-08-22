%WPM1 is an experiment to test the prediction that slow oscillations correlate
%with memory performance

%basic experiment parameters
numTrials=5;
stimOnTime=.5; %seconds, how long to display stimuli
stimOffTime=.5;
eeg=1; %set to 1 to enable eeg triggers sent to Netstation

% Screen('Preference', 'SkipSyncTests', 1);
%%%%%%%%
%some setup for PTB
%%%%%%%%%

%supress warnings - unsupress this if there's a problem
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1 );

% Find out how many screens and use largest screen number.
% whichScreen = max(Screen('Screens'));
whichScreen = 0; %DH - for single screen setup

%make two screens to flip between
targetWindow = Screen(whichScreen,'OpenWindow');

% Retrieves color codes for black and white and gray.
black = BlackIndex(targetWindow);  % Retrieves the CLUT color code for black.
white = WhiteIndex(targetWindow);  % Retrieves the CLUT color code for white.
gray = (black + white) / 2;  % Computes the CLUT color code for gray.

r=Screen('rect',targetWindow);  %this rectangle has the dimensions of the screen
windowW=r(3);
windowH=r(4);
screenCentreX =floor(windowW/2);
screenCentreY=floor(windowH/2);
targetH=100;
targetW=100;

%define a destination box to put the texture
targetCentreX=screenCentreX;  %bring them into our coordinate frame
targetCentreY=screenCentreY;

topX = targetCentreX - targetW/2; %now compute the top-left corner because this is the "location" to start drawing the target
topY = targetCentreY - targetH/2;
bottomX = topX + targetW;  %the bounding rectangle needs top-left and bottom-right coordinates
bottomY = topY + targetH;

targetDestination=[topX topY bottomX bottomY];


%build the target box
aBox.texture=ones(targetH,targetW)*255;  %a white box
aBox.index=Screen('MakeTexture',targetWindow,aBox.texture);

% Colors the entire window gray.
Screen('FillRect', targetWindow, gray);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%
%%setup and initialize connection with Netstation
%%%
if(eeg)
% netstationHost='142.66.137.15';
netstationHost='169.254.21.186';%DH - had to let the iMac assign its own IP to connect to my laptop
NetStation('Connect',netstationHost); %initialize a connection to the acquisition software
NetStation('Synchronize');%DH - 'S' capitalized
NetStation('StartRecording');%DH - 'S' capitalized
%It's probably a good idea to get the start recording time so that the lag
%between when matlab thinks triggers are and when netstation thinks
%triggers are can be measured
[~,recordingStartTime,~,~]=Screen('Flip',targetWindow);%DH
[~,~,~,~]=Screen('Flip',targetWindow);%DH
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%run the trials
%%%%%%%%%%%%%%%%%

%loop and flip
for trialNum=1:numTrials
    
    Screen('DrawTexture',targetWindow,aBox.index,[], targetDestination );
    [firstVBLtime,stimOnsetTime,~,~]=Screen('Flip', targetWindow);
    NetStation('Event', 'ONxx', stimOnsetTime);
    sOnT(trialNum)=stimOnsetTime;%DH - record onset times to compare with NetStation
    WaitSecs(stimOnTime);

    
    %recall Flip to blank the window
    [secondVBLtime, stimOffsetTime,~,~]=Screen('Flip',targetWindow);
    NetStation('Event', 'OFFx', stimOffsetTime);%DH - stimOnsetTime changed to stimOffsetTime
    sOffT(trialNum)=stimOffsetTime;%DH - record offset times to compare with Netstation
    WaitSecs(stimOffTime);
    
%     display(secondVBLtime-firstVBLtime);
%     display(stimOffsetTime-stimOnsetTime);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% cleanup
NetStation('StopRecording');
NetStation('Disconnect');

Screen('CloseAll');
