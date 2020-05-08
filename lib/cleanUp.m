function cleanUp(cfg)

WaitSecs(0.5);

Priority(0);
KbQueueRelease;
ListenChar();
ShowCursor

% Screen Close All
sca

% if audioport was opened, close it
if isstruct(cfg)
    if isfield(cfg,'pahandle')
        PsychPortAudio('Stop', cfg.pahandle,1);
        PsychPortAudio('Close',cfg.pahandle)
    end
end

if ~ismac
    % remove PsychDebugWindowConfiguration
    clear Screen
end

close all

 
end
