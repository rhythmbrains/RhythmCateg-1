

% Clear all the previous stuff
if ~ismac
    close all;
    clear Screen;
else
    clc;
    clear;
end

% make sure we got access to all the required functions and inputs
initEnv();

% Define the task = 'RhythmFT', 'PitchFT', 'RhythmBlock'
% Get parameters by providing task name
cfg = getParams('RhythmFT');


%% Experiment

% Safety loop: close the screen if code crashes
try
    
    % get time point at the beginning of the experiment (machine time)
    cfg.experimentStartTime = GetSecs();

    % Init the experiment
    [cfg] = initPTB(cfg);

    % create  logfile with extra columns to save - BIDS
    logFile.extraColumns = cfg.extraColumns;
    [logFile]  = saveEventsFile('open', cfg, logFile); %dummy initialise
    
    % set the real length of columns
    logFile(1).extraColumns.LHL24.length = 12;
    logFile(1).extraColumns.PE4.length = 12;

    % actual inititalization
    logFile = saveEventsFile('open', cfg, logFile);

    % create response file - used for recording tapping
    responseFile.extraColumns = cfg.extraColumns;
    [responseFile]  = saveEventsFile('open_stim', cfg, responseFile);
    
    % set the real length of columns
    responseFile(1).extraColumns.LHL24.length = 12;
    responseFile(1).extraColumns.PE4.length = 12;
    
    % actual inititalization
    [responseFile]  = saveEventsFile('open_stim', cfg, responseFile);

    
    % show instructions and do initial volume setting
    cfg = setVolume(cfg);

    % more instructions
    displayInstr(cfg.trialDurInstruction,cfg,'setVolume');


    % if there's wait time,..wait
    WaitSecs(2); %expParam.onsetDelay
    
    
    
    %% play sequences
    for iSequence = 1:cfg.pattern.numSequences

        currSeq = struct();
        responseEvents = struct();
        
        % change screen to "TAP" instruction
        displayInstr('TAP',cfg,'instrAndQuitOption');

        % construct sequence
        currSeq = makeSequence(cfg,iSequence);

        
        % ===========================================
        % stimulus save for BIDS
        % ===========================================
        % we save sequence by sequence so we clear this variable every loop
        currSeq(1).fileID = logFile.fileID;
        currSeq(1).extraColumns = logFile(1).extraColumns;
        
        % adding columns in currSeq for BIDS format
        for iPattern=1:length(currSeq)
            currSeq(iPattern,1).trial_type  = 'dummy';
            currSeq(iPattern,1).duration    = 0;
            currSeq(iPattern,1).sequenceNum = iSequence;            
        end
        
        saveEventsFile('save', cfg, currSeq);


        %% present stimulus, record tapping

        % response save for BIDS (set up)
        responseEvents.fileID = logFile.fileID;            

        % fill the buffer
        PsychPortAudio('FillBuffer', cfg.pahandle, ...
                       [currSeq.outAudio;currSeq.outAudio]);

        % start playing
        sequenceOnset = PsychPortAudio('Start', cfg.pahandle, cfg.PTBrepet,...
            cfg.PTBstartCue, cfg.PTBwaitForDevice);

        
        % keep collecting tapping until sound stops (log as you go)
        cfg.iSequence = iSequence;
        cfg.sequenceOnset = sequenceOnset;
        
        [tapOnsets, responseEvents] = mb_getResponse(cfg, ...
            responseEvents, ...
            currSeq);
        
        
        % response save for BIDS (write)
        if isfield(responseEvents,'onset')
            saveEventsFile('save', cfg, responseEvents);
        end
        
        % ===========================================
        % log everything into matlab structure
        % ===========================================
        % save (machine) onset time for the current sequence
        cfg.data(iSequence).currSeqStartTime = sequenceOnset;

        % save PTB volume
        cfg.data(iSequence).ptbVolume = PsychPortAudio('Volume',cfg.pahandle);

        % save current sequence information (without the audio, which can
        % be easily resynthesized)
        currSeq(1).outAudio = [];
        cfg.data(iSequence).seq = currSeq;

        % save all the taps for this sequence
        cfg.data(iSequence).taps = tapOnsets;


        %% Pause
        if iSequence<cfg.pattern.numSequences
            
            % pause (before next sequence starts, wait for key to continue)
            if cfg.sequenceDelay 
                
                % show sequence-specific instruction if there is some
                % defined
                if ~isempty(cfg.seqSpecificDelayInstruction{iSequence})
                    displayInstr(cfg.seqSpecificDelayInstruction{iSequence}, ...
                                 cfg, ...
                                 'setVolumeToggleGeneralInstr', ...
                                 'generalInstrTxt', cfg.generalInstruction);
                end
                
                % show general instruction after each sequence
                fbkToDisp = sprintf(cfg.generalDelayInstruction, ...
                                    iSequence, cfg.pattern.numSequences);
                displayInstr(fbkToDisp, cfg, ...
                             'setVolumeToggleGeneralInstr', ...
                             'generalInstrTxt', cfg.generalInstruction);
                
                % pause for N secs before starting next sequence
                WaitSecs(cfg.pauseSeq);
            end
            
        else
            
            % end of experient
            displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)',cfg);
            
            % wait 3 seconds and end the experiment
            WaitSecs(3);
            
        end

    end % sequence loop



    % Close the logfiles (tsv)   - BIDS
    saveEventsFile('close', cfg, logFile);
    saveEventsFile('close', cfg, responseFile);

    
    % save the whole workspace 
    matFile = fullfile(cfg.dir.output, ...
                       strrep(cfg.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    
    % clean the workspace
    cleanUp();



catch

    % save everything into .mat file
    matFile = fullfile(cfg.dir.output, ...
                       strrep(cfg.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    % Close the logfiles - BIDS
    saveEventsFile('close', cfg, logFile);
    saveEventsFile('close', cfg, responseFile);

    % clean the workspace
    cleanUp();
    psychrethrow(psychlasterror);
end
