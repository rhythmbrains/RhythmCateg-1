function [currTapOnsets] = mb_getResponse(cfg, currSeqStartTime)

% allocate vector of tap times
currTapOnsets = [];

% boolean helper variable used to determine if the button was just
% pressed (and not held down from previous loop iteration)
istap = false;

% stay in the loop until the sequence ends
while GetSecs < (currSeqStartTime+cfg.SequenceDur)

        % check if key is pressed
        [~, tapOnset, keyCode] = KbCheck(cfg.keyboard);

        % terminate if quit-button pressed
        if find(keyCode)==cfg.keyquit
            error('Experiment terminated by user...');
        end

        % check if tap and save time (it counts as tap if
        % reponse buttons were released initially)
        if ~istap && any(keyCode)
            % tap onset time is saved wrt sequence start time
            currTapOnsets = [currTapOnsets,tapOnset-currSeqStartTime];
            istap = true;
        end
        if istap && ~any(keyCode)
            istap = false;
        end

end
