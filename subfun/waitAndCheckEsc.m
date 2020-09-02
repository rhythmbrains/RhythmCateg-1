function waitAndCheckEsc(cfg)

% reachHereTime = (GetSecs - cfg.experimentStart);
audioDuration = (cfg.pattern.SequenceDur * cfg.pattern.numSeq4Run);
    
%     % exp duration + delays - script reaching to till point
%     WaitSecs(audioDuration + cfg.timing.onsetDelay + ...
%         cfg.timing.endDelay - reachHereTime);

% stay in the loop until the sequence ends
while GetSecs  < (cfg.experimentStart + audioDuration + ...
        cfg.timing.onsetDelay + cfg.timing.endDelay)
    
    % check if key is pressed
    [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard.keyboard);
    
    % terminate if quit-button pressed
    if keyIsDown && keyCode(KbName(cfg.keyboard.escapeKey))
        error('Experiment terminated by user...');
    end
end

%     % stay in the loop until the sequence ends
%     while GetSecs  < (cfg.experimentStart + audioDuration + ...
%             cfg.timing.onsetDelay + cfg.timing.endDelay)
%
%         % Check for experiment abortion from operator
%         checkAbort(cfg, cfg.keyboard.keyboard);
%
%     end
%
end