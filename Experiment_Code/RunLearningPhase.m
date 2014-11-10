%this script runs through the learning phase of the experiment

learningPhaseEvents=cell(numPairs*numRepeats,2);% for use with Avatar MATLAB Toolbox and EEGLab one column for the event code and one for the UINT64 time stamp returned by tic()

%first draw the instructions and flip them up
Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
DrawFormattedText(targetWindow,instructionsForLearning,learningWordPositionX,learningWordPositionY);
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
for repeat=1:numRepeats
    
    %shuffle the sequence of pairs
    randSequence=randperm(length(pair),length(pair));
    pair=pair(randSequence);
    
    %loop and flip
    for pairNum=1:numPairs
        
        %draw the fixation point into the window
        Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
        %draw the word and nonword for this trial
        DrawFormattedText(targetWindow,pair(pairNum).word,learningWordPositionX,learningWordPositionY);
        DrawFormattedText(targetWindow,pair(pairNum).nonword,learningNonwordPositionX,learningNonwordPositionY);
        
        
        %now flip this window onto the display
        [firstVBLtime,stimOnsetTime,~,~]=Screen('Flip', targetWindow);
        t=tic;  %possibly redundant with onset time but it's easier to just deal in mach time
        
        NetStation('Event', pair(pairNum).trigger, stimOnsetTime); %send the trigger for Netstation
        
        learningPhaseEvents{(repeat-1)*3+pairNum,1}=pair(pairNum).trigger; %record events for use with EEGLab and Avatar toolbox
        learningPhaseEvents{(repeat-1)*3+pairNum,2}=t; %record the time for later epoching
        display(['sending event code ' pair(pairNum).trigger ' to Netstation at time ' num2str(stimOnsetTime)]); 

        
        %handle stuff inbetween display events and keep track of elapsed time
        %so we can, in principle, do slightly time-consuming stuff here
        t=tic;
        Screen('DrawTexture',targetWindow,aBox.index,[], fixationDestination );
        while(toc(t)<stimOnTime) %spin to elapse time
        end;
        
        %re-call Flip to blank the window
        [secondVBLtime, stimOffsetTime,~,~]=Screen('Flip',targetWindow);
        NetStation('Event', 'OFFx', stimOffsetTime);
        WaitSecs(stimOffTime); %basic timing here
        
        
        
    end

end
