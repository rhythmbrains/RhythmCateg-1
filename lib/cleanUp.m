function cleanUp(cfg)

WaitSecs(0.5);

Priority(0);
KbQueueRelease;
ListenChar();
ShowCursor

% Screen Close All
sca

% if audioport was opened, close it
if isfield(cfg,'pahandle')
    PsychPortAudio('Stop', cfg.pahandle,0);% don't wait for playback end!
    PsychPortAudio('Close',cfg.pahandle)
end
        

if ~ismac
    % remove PsychDebugWindowConfiguration
    clear Screen
end

close all

 
end
