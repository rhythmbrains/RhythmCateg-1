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
cfg = getParams('RhythmCategFT');

% % set and load all the subject input to run the experiment
% cfg = userInputs(cfg);
% cfg = createFilename(cfg);

% % create randomized sequence for 9 runs when run =1
% cfg = makefMRISeqDesign(cfg);

% get time point at the beginning of the script (machine time)
cfg.timing.scriptStartTime = GetSecs();

%% Experiment

% Safety loop: close the screen if code crashes
try
    % Init the experiment
    [cfg] = initPTB(cfg);

    % create  logfile with extra columns to save - BIDS
    logFile.extraColumns = cfg.extraColumns;
    [logFile]  = saveEventsFile('open', cfg, logFile);

    % set the real length we really want
    logFile(1).extraColumns.LHL24.length = 12;
    logFile(1).extraColumns.PE4.length = 12;

    % actual inititalization
    logFile = saveEventsFile('open', cfg, logFile);
    
    % create response file - used for counting button press
    responseFile.extraColumns = cfg.responseExtraColumns;
    responseFile  = saveEventsFile('open_stim', cfg, responseFile);

    %     disp(cfg);
    % Show instructions for fMRI task
    standByScreen(cfg);

    % wait for space key to be pressed by the experimenter
    pressSpaceForMe;

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);
    getResponse('start', cfg.keyboard.responseBox);

    % wait for trigger from fMRI
    waitForTrigger(cfg);
    
    % show fixation cross + get timestamp
    cfg = getExperimentStart(cfg);

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

    % fill the buffer % start sound presentation
    PsychPortAudio('FillBuffer', cfg.audio.pahandle, ...
        [currSeq.outAudio;currSeq.outAudio]);
    PsychPortAudio('Start', cfg.audio.pahandle);
    onset = GetSecs;

    % save params for later call in BIDS saving
    cfg.timing.seqi = seqi;
    cfg.timing.currSeqStartTime = onset;
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
            onset - cfg.experimentStart;
        currSeq(iPattern, 1).segmentOnset = currSeq(iPattern, 1).segmentOnset ...
            + onset - cfg.experimentStart;
        currSeq(iPattern, 1).stepOnset = currSeq(iPattern, 1).stepOnset ...
            + onset - cfg.experimentStart;

        % adding compulsory BIDS structures
        currSeq(iPattern, 1).trial_type  = 'dummy';
        currSeq(iPattern, 1).duration    = 0;

        % adding outher interest
        currSeq(iPattern, 1).sequenceNum = seqi;
        target(iPattern, 1) = currSeq(iPattern, 1).isTask;

    end
    

    saveEventsFile('save', cfg, currSeq);


    % ===========================================
    % log into matlab structure
    % ===========================================

    % save (machine) onset time for the current sequence info 
    cfg.data(seqi).currSeqStartTime = onset;
    cfg.data(seqi).ptbVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
%    currSeq(1).outAudio = [];
    cfg.data(seqi).seq = currSeq;

    %% Wait for audio and delays to catch up
    % wait while fMRI is ongoing
    % stay here till audio stops
    reachHereTime = (GetSecs - cfg.experimentStart);
    audioDuration = (cfg.pattern.SequenceDur * cfg.pattern.numSeq4Run);

    %     % exp duration + delays - script reaching to till point
    %     WaitSecs(audioDuration + expParam.timing.onsetDelay + ...
    %         expParam.timing.endDelay - reachHereTime);

    %     % Check for experiment abortion from operator
    %     checkAbort(cfg, cfg.keyboard.keyboard);
            
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


    %%
    % record exp ending time
    cfg.timing.fMRIendTime = GetSecs - cfg.experimentStart;

    %% Check last button presses & wrap up
    % % %
    % give visual feedback?
    % % %
    displayInstr('Please indicate by pressing button, how many times you detected piano tones\n\n\n', cfg);

    % wait for participant to press button
    WaitSecs(cfg.timing.endResponseDelay);

    % write down buffered responses after waiting for response
    responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg);

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
    if cfg.subject.runNb == 666 || cfg.subject.runNb == cfg.pattern.numSequences
        displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)\n\n\n Soon we will take you out!', cfg);
    else
        displayInstr('This run is over. We will shortly start the following!', cfg);
    end

    % wait for ending the screen/exp
    WaitSecs(cfg.timing.endScreenDelay);

    % record script ending time
    cfg.timing.scriptEndTime = GetSecs - cfg.experimentStart;

    % clear the buffer & stop key checks
    getResponse('flush', cfg.keyboard.responseBox);
    getResponse('stop', cfg.keyboard.responseBox);

    %% save
    % Close the logfiles (tsv)   - BIDS
    saveEventsFile('close', cfg, logFile);
    saveEventsFile('close', cfg, responseFile);

    % save the whole workspace
    matFile = fullfile(cfg.dir.output, ...
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
    matFile = fullfile(cfg.dir.output, ...
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
