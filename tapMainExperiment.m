

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

    
    % Prepare for the output logfiles - BIDS
    logFile  = saveEventsFile('open', cfg,[],'sequenceNum',...
        'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
        'category','F0','gridIOI','patternAmp','PE4','minPE4',...
        'rangePE4','LHL24','minLHL24','rangeLHL24');


    % show instructions and do initial volume setting
    currInstrPage = 1; 
    nInstrPages = length(cfg.introInstruction); 
    while 1
        % display instructions and wait for action
        subAction = displayInstr(cfg.introInstruction{currInstrPage}, cfg, 'setVolumePrevNext', ...
                                 'currInstrPage', currInstrPage, ...
                                 'nInstrPages', nInstrPages); 
        % go one instruction page forward or backward (depending on subject's action)                      
        if strcmp(subAction,'oneInstrPageForward')
            currInstrPage = min(currInstrPage+1, length(cfg.introInstruction)); 
        elseif strcmp(subAction,'oneInstrPageBack')
            currInstrPage = max(currInstrPage-1, 1); 
        elseif strcmp(subAction,'done')
            break
        end
    end
        
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
        
        % adding columns in currSeq for BIDS format
        for iPattern=1:length(currSeq)
            currSeq(iPattern,1).trial_type  = 'dummy';
            currSeq(iPattern,1).duration    = 0;
            currSeq(iPattern,1).sequenceNum = iSequence;            
        end
        
        saveEventsFile('save', cfg, currSeq,'sequenceNum',...
        'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
        'segmCateg','F0','gridIOI','patternAmp','PE4','minPE4',...
        'rangePE4','LHL24','minLHL24','rangeLHL24');


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
            
            
            saveEventsFile('save', cfg, responseEvents,'sequenceNum',...
                'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
                'segmCateg','F0','gridIOI','patternAmp','PE4','minPE4',...
                'rangePE4','LHL24','minLHL24','rangeLHL24');

    
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
    
    
    % save the whole workspace 
    matFile = fullfile(cfg.outputDir, strrep(cfg.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    
    % clean the workspace
    cleanUp(cfg);



catch

    % save everything into .mat file
    matFile = fullfile(cfg.outputDir, strrep(cfg.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    % Close the logfiles - BIDS
    saveEventsFile('close', cfg, logFile);

    % clean the workspace
    cleanUp(cfg);

    psychrethrow(psychlasterror);
end
