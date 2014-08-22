
% 
% %a tool for building word and non-word list text files
% subPath='/Users/Matthew/Documents/MATLAB/WordPairMatching/WPM1/Experiment_Code/';
% 
% fid=fopen([subPath 'words.m'],'r');
% junk=textscan(fid,'%s','delimiter',','); %why, oh why, does it have to be complicated
% wordArray=junk{1,1};
% fclose(fid);


%double-checking how KbWait and KbCheck work
% 
% ListenChar(2);
% RestrictKeysForKbCheck([30 31 32 33]);
% 
% sum=0;
% % 
% for i=1:10
%     while KbCheck; end % Wait until all keys are released.
%     display('press a key');
%     [secs, code, delta]=KbWait();
%    % display(['you pressed key ' KbName(code) ' which is code ' num2str(code)]);
%     display(num2str(find(code)));
% end
% 
% ListenChar(0);

RestrictKeysForKbCheck([]);
%check timing of Screen('flip') vs KbWait
ListenChar(2);
%supress warnings - unsupress this if there's a problem
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1 );
% Find out how many screens and use largest screen number.
whichScreen = max(Screen('Screens'));
%make two screens to flip between
targetWindow = Screen('OpenWindow', whichScreen);

done=0;
while(~done)

    DrawFormattedText(targetWindow,'press a key',100,100);
    [firstVBLtime,firstStimOnsetTime,~,~]=Screen('Flip', targetWindow);


    %wait for subject to respond
    while KbCheck; end % Wait until all keys are released.
    [secs, code, delta]=KbWait();
    DrawFormattedText(targetWindow,'thanks',100,100);
    [secondVBLtime,secondStimOnsetTime,~,~]=Screen('Flip', targetWindow);
    
    display(['time difference = ' num2str(secondStimOnsetTime-secs)]);
    

end


Screen('CloseAll');
ListenChar(0);
