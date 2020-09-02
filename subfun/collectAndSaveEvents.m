function target = collectAndSaveEvents(cfg, logFile, currentSequence,SeqNum, audioOnset)

experimentStart = cfg.experimentStart;

% write into logfile
currentSequence(1).fileID = logFile(1).fileID;
currentSequence(1).extraColumns = logFile(1).extraColumns;

% adding columns in currSeq for BIDS format
for iPattern = 1:numel(currentSequence)
    
    % correcting onsets for fMRI trigger onset
    currentSequence(iPattern, 1).onset  = ...
        currentSequence(iPattern, 1).onset + audioOnset - experimentStart;
    currentSequence(iPattern, 1).segmentOnset = ...
        currentSequence(iPattern, 1).segmentOnset + audioOnset - experimentStart;
    currentSequence(iPattern, 1).stepOnset = ...
        currentSequence(iPattern, 1).stepOnset + audioOnset - experimentStart;
    
    % adding compulsory BIDS structures
    currentSequence(iPattern, 1).trial_type  = 'dummy';
    currentSequence(iPattern, 1).duration    = 0;
    
    % adding other interest
    currentSequence(iPattern, 1).sequenceNum = SeqNum;
    target(iPattern, 1) = currentSequence(iPattern, 1).isTask;
    
end


saveEventsFile('save', cfg, currentSequence);


end