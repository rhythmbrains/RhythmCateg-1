function [tapOnsets, responseEvents] = mb_getResponse(cfg, expParam, responseEvents, currSeq, seqi, currSeqStartTime)

% allocate vector of tap times
tapOnsets = [];

% counter to count how many taps were made
cTap = 1; 

% boolean helper variable used to determine if the button was just
% pressed (and not held down from previous loop iteration)
istap = false;

% stay in the loop until the sequence ends
while GetSecs < (currSeqStartTime+cfg.SequenceDur)

        % check if key is pressed
        [~, tapTime, keyCode] = KbCheck(cfg.keyboard);

        % terminate if quit-button pressed
        if find(keyCode)==cfg.keyquit
            error('Experiment terminated by user...');
        end

        % check if tap and save time (it counts as tap if
        % reponse buttons were released initially)
        if ~istap && any(keyCode)
            % tap onset relative to sequence start time
            tapTime = tapTime-currSeqStartTime; 
            
            % append to the vector of tap times
            tapOnsets = [tapOnsets,tapTime];
            
            % set flag
            istap = true;
            
            % ----- log tsv -----
            % now we have some time before the subject taps again so let's
            % write to the log file            
            % each tap on one row (colum names: subjectNum, runNum, seqi, tapOnset)
            fprintf(expParam.fidTap, '%d\t%d\t%d\t%f\n', ...
                                    expParam.subjectNb, ...
                                    expParam.runNb, ...
                                    seqi, ...
                                    tapTime);
            % ------ bids -------
            % Find latest pattern for which current tap time is larger 
            % than it's onset. 
            currPatIdx = max( find(tapTime > currSeq.patternOnset) ); 

            responseEvents(cTap,1).sequenceNum     = seqi;
            responseEvents(cTap,1).onset           = tapTime;
            responseEvents(cTap,1).duration        = 0;
            responseEvents(cTap,1).trial_type      = 'response';
            responseEvents(cTap,1).patternID       = currSeq.patternID{currPatIdx};
            responseEvents(cTap,1).segmCateg       = currSeq.segmCateg{currPatIdx};
            responseEvents(cTap,1).F0              = currSeq.F0(currPatIdx);
            responseEvents(cTap,1).gridIOI         = currSeq.gridIOI(currPatIdx);
            % -----------------
            
            % increase tap counter
            cTap = cTap+1; 
        end
        
        if istap && ~any(keyCode)
            istap = false;
        end

end
