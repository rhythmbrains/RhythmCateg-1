% Clear all the previous stuff
if ~ismac
    close all;
    clear Screen;
else
    clc;
    clear;
end

% make sure we got access to all the required functions and inputs
initEnv()

% Define the task = 'RhythmCategFT', 'PitchFT', 'RhythmCategBlock'
% Get parameters by providing task name, device and debugmode
cfg = getParams('RhythmCategFT', 'mri', 0);

% set and load all the subject input to run the experiment
cfg = userInputs(cfg);
cfg = createFilename(cfg);

% create randomized sequence for 9 runs when run =1
cfg = makefMRISeqDesign(cfg);

% get time point at the beginning of the script (machine time)
cfg.timing.scriptStartTime = GetSecs();

%% Experiment

% Safety loop: close the screen if code crashes
try
    % Init the experiment
    [cfg] = initPTB(cfg);

    % create event file and get file ID - used for event logging - BIDS
    % logFile = getVariable2Save;
    logFile.extraColumns = {'sequenceNum', 'segmentNum', 'segmentOnset', ...
    'stepNum', 'stepOnset', 'patternID', 'segmentCateg', 'F0', 'isTask', ...
    'gridIOI', 'patternAmp', 'minPE4', 'rangePE4', 'minLHL24', ...
    'rangeLHL24', 'LHL24', 'PE4'};
    
    % dummy call to initialize the logFile variable
    [logFile]  = saveEventsFile('open', cfg, logFile);

    % set the real length we really want
    logFile(1).extraColumns.LHL24.length = 12;
    logFile(1).extraColumns.PE4.length = 12;

    % actual inititalization
    logFile = saveEventsFile('open', cfg, logFile);
    
    % define the extra columns: 
    % they will be added to the tsv files in the order the user input them
    responseFile.extraColumns = {'key_name', 'pressed', 'target'};
    
    % open stimulation logfile - used for counting button press
    responseFile  = saveEventsFile('open_stim', cfg, responseFile);

    
    % Show instructions for fMRI task - modify to give duration and volume
    % check
    if cfg.fmriTask
        displayInstr(cfg.fmriTaskInst, cfg);

    end

    % wait for space key to be pressed by the experimenter
    % to make the script more verbose
    %pressSpace4me;
    pressSpaceForMe;

    % prepare the KbQueue to collect responses
    % it's after space keypressed because the key looked for is "space" atm
    getResponse('init', cfg);
    getResponse('start', cfg);

    % wait for trigger from fMRI
    %wait4Trigger(cfg);
    waitForTrigger(cfg);
    
    % show fixation cross
    if cfg.fmriTask
        drawFixationCross(cfg, cfg.fixationCrossColor);
        Screen('Flip', cfg.win);
    end

    % and collect the timestamp
    cfg.experimentStart = GetSecs;

    %   % write down buffered responses
    %   responseEvents = getResponse('check', cfg, expParam,1);

    % wait for dummy fMRI scans
    WaitSecs(cfg.timing.onsetDelay);

    %% play sequences

    % take the runNb corresponding sequence
    seqi = cfg.subject.runNb;

    % prep for BIDS saving structures
    currSeq = struct();
    responseEvents = struct();

    % construct sequence
    currSeq = makeSequence(cfg, seqi);

    % fill the buffer
    PsychPortAudio('FillBuffer', cfg.pahandle, ...
        [currSeq.outAudio;currSeq.outAudio]);

    % start playing
    currSeqStartTime = PsychPortAudio('Start', cfg.pahandle, ...
        cfg.PTBrepet, cfg.PTBstartCue, cfg.PTBwaitForDevice);

    % save params for later call in BIDS saving
    cfg.timing.seqi = seqi;
    cfg.timing.currSeqStartTime = currSeqStartTime;
    cfg.timing.experimentStart = cfg.experimentStart;

    % ===========================================
    % stimulus save for BIDS
    % ===========================================

    % write into logfile
    currSeq(1).fileID = logFile(1).fileID;
    currSeq(1).extraColumns = logFile(1).extraColumns;

    % adding columns in currSeq for BIDS format
    for iPattern = 1:numel(currSeq)

        % correcting onsets for fMRI trigger onset
        currSeq(iPattern, 1).onset  = currSeq(iPattern, 1).onset + ...
            currSeqStartTime - cfg.experimentStart;
        currSeq(iPattern, 1).segmentOnset = currSeq(iPattern, 1).segmentOnset ...
            + currSeqStartTime - cfg.experimentStart;
        currSeq(iPattern, 1).stepOnset = currSeq(iPattern, 1).stepOnset ...
            + currSeqStartTime - cfg.experimentStart;

        % adding compulsory BIDS structures
        currSeq(iPattern, 1).trial_type  = 'dummy';
        currSeq(iPattern, 1).duration    = 0;

        % adding outher interest
        currSeq(iPattern, 1).sequenceNum = seqi;

        % calculate the task/target number
        target(iPattern, 1) = currSeq(iPattern, 1).isTask;

    end
    

    saveEventsFile('save', cfg, currSeq);


    % ===========================================
    % log into matlab structure
    % ===========================================

    % save (machine) onset time for the current sequence
    % might be irrelevant for fMRI
    cfg.data(seqi).currSeqStartTime = currSeqStartTime;

    % save PTB volume
    % might be irrelevant for fMRI
    cfg.data(seqi).ptbVolume = PsychPortAudio('Volume', cfg.pahandle);

    % save current sequence information (without the audio, which can
    % be easily resynthesized)
    currSeq(1).outAudio = [];
    cfg.data(seqi).seq = currSeq;

    %% Wait for audio and delays to catch up
    % wait while fMRI is ongoing
    % stay here till audio stops
    reachHereTime = (GetSecs - cfg.experimentStart);
    audioDuration = (cfg.SequenceDur * cfg.numSeq4Run);

    %     % exp duration + delays - script reaching to till point
    %     WaitSecs(audioDuration + expParam.timing.onsetDelay + ...
    %         expParam.timing.endDelay - reachHereTime);

    % stay in the loop until the sequence ends
    while GetSecs  < (cfg.experimentStart + audioDuration + ...
            cfg.timing.onsetDelay + cfg.timing.endDelay)

        % check if key is pressed
        [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard);

        % terminate if quit-button pressed
        if find(keyCode) == cfg.escapeKey
            error('Experiment terminated by user...');
        end
    end

    %%
    % record exp ending time
    cfg.timing.fMRIendTime = GetSecs - cfg.experimentStart;

    %% Check last button presses & wrap up
    % % %
    % give visual feedback?
    % % %
    displayInstr('Please indicate by pressing button, how many times you detected pitch changes\n\n\n', cfg);

    % wait for participant to press button
    WaitSecs(cfg.timing.endResponseDelay);

    % write down buffered responses after waiting for response
    responseEvents = getResponse('check', cfg, 1);
    % get responses with new CPP_PTB
    %responseEvents = getResponse('check', deviceNumber, cfg);

    % save responses here
    responseEvents(1).fileID = responseFile(1).fileID;
    responseEvents(1).extraColumns = responseFile(1).extraColumns;


    % savethe target number
    responseEvents(1).target = sum(target);

    % checks if something to save exist
    if isfield(responseEvents, 'onset')
        for iResp = 1:size(responseEvents, 1)
            responseEvents(iResp, 1).onset = responseEvents(iResp).onset - ...
                cfg.experimentStart;
        end

        saveEventsFile('save', cfg, responseEvents);
    end

    %% wrapping up
    % last screen
    if cfg.runNb == 666 || cfg.runNb == cfg.numSequences
        displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)\n\n\n Soon we will take you out!', cfg);
    else
        displayInstr('This run is over. We will shortly start the following!', cfg);
    end

    % wait for ending the screen/exp
    WaitSecs(cfg.timing.endScreenDelay);

    % record script ending time
    cfg.timing.scriptEndTime = GetSecs - cfg.experimentStart;

    % clear the buffer
    getResponse('flush', cfg);

    % stop key checks
    getResponse('stop', cfg);

    %% save
    % Close the logfiles (tsv)   - BIDS
    saveEventsFile('close', cfg, logFile);
    saveEventsFile('close', cfg, responseFile);

    % save the whole workspace
    matFile = fullfile(cfg.outputDir, ...
        strrep(cfg.fileName.events, 'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end

    % clean the workspace
    cleanUp;

catch

    % save everything into .mat file
    matFile = fullfile(cfg.outputDir, ...
        strrep(cfg.fileName.events, 'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end

    % Close the logfiles - BIDS
    saveEventsFile('close', cfg, logFile);
    saveEventsFile('close', cfg, responseFile);

    % clean the workspace
    cleanUp;

    psychrethrow(psychlasterror);
end
