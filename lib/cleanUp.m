function cleanUp(cfg)

WaitSecs(0.5);

Priority(0);
KbQueueRelease;
ListenChar();
ShowCursor

% Screen Close All
sca
PsychPortAudio('Stop',cfg.pahandle,1);
PsychPortAudio('Close',cfg.pahandle)


if ~ismac
    % remove PsychDebugWindowConfiguration
    clear Screen
end

close all

 
end
