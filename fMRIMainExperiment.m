% Clear all the previous stuff
if ~ismac
    close all;
    clear Screen;
else
    clc;
    clear;
end

% make sure we got access to all the required functions and inputs
addpath(genpath(fullfile(pwd, 'lib')));

% Define the task = 'RhythmCategFT', 'PitchFT', 'RhythmCategBlock'
% Get parameters by providing task name, device and debugmode
[cfg, expParam] = getParams('RhythmCategFT', 'mri', 0);

% set and load all the subject input to run the experiment
expParam = userInputs(cfg, expParam);
[cfg, expParam] = createFilename(cfg, expParam);

% create randomized sequence for 9 runs
% run ==1 then it'll create 9 seq, otherwise it'll upload whats created
[cfg, expParam] = makefMRISeqDesign(cfg, expParam);

% get time point at the beginning of the script (machine time)
expParam.timing.scriptStartTime = GetSecs();

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
    logFile  = saveEventsFile('open', expParam, logFile);

    % set the real length we really want
    logFile(1).extraColumns.LHL24.length = 12;
    logFile(1).extraColumns.PE4.length = 12;

    % actual inititalization
    logFile = saveEventsFile('open', expParam, logFile);
    
    % define the extra columns: 
    % they will be added to the tsv files in the order the user input them
    responseFile.extraColumns = {'key_name', 'pressed', 'target'};
    
    % open stimulation logfile - used for counting button press
    responseFile  = saveEventsFile('open_stim', expParam, responseFile);

    
    % Show instructions for fMRI task - modify to give duration and volume
    % check
    if expParam.fmriTask
        displayInstr(expParam.fmriTaskInst, cfg);

    end

    % wait for space key to be pressed by the experimenter
    % to make the script more verbose
    pressSpace4me;

    % prepare the KbQueue to collect responses
    % it's after space keypressed because the key looked for is "space" atm
    getResponse('init', cfg, expParam);
    getResponse('start', cfg, expParam);

    % wait for trigger from fMRI
    wait4Trigger(cfg);

    % show fixation cross
    if expParam.fmriTask
        drawFixationCross(cfg, expParam, expParam.fixationCrossColor);
        Screen('Flip', cfg.win);
    end

    % and collect the timestamp
    expParam.experimentStart = GetSecs;

    %   % write down buffered responses
    %   responseEvents = getResponse('check', cfg, expParam,1);

    % wait for dummy fMRI scans
    WaitSecs(expParam.timing.onsetDelay);

    %% play sequences

    % take the runNb corresponding sequence
    seqi = expParam.runNb;

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
    expParam.timing.seqi = seqi;
    expParam.timing.currSeqStartTime = currSeqStartTime;
    expParam.timing.experimentStart = expParam.experimentStart;

    % ===========================================
    % stimulus save for BIDS
    % ===========================================

    % open a file to write sequencefor BIDS
    % currSeq(1).fileID = logFile.fileID;
    % update responseEvents with the relevant info
    currSeq(1).fileID = logFile(1).fileID;
    currSeq(1).extraColumns = logFile(1).extraColumns;

    % adding columns in currSeq for BIDS format
    for iPattern = 1:numel(currSeq)

        % correcting onsets for fMRI trigger onset
        currSeq(iPattern, 1).onset  = currSeq(iPattern, 1).onset + ...
            currSeqStartTime - expParam.experimentStart;
        currSeq(iPattern, 1).segmentOnset = currSeq(iPattern, 1).segmentOnset ...
            + currSeqStartTime - expParam.experimentStart;
        currSeq(iPattern, 1).stepOnset = currSeq(iPattern, 1).stepOnset ...
            + currSeqStartTime - expParam.experimentStart;

        % adding compulsory BIDS structures
        currSeq(iPattern, 1).trial_type  = 'dummy';
        currSeq(iPattern, 1).duration    = 0;

        % adding outher interest
        currSeq(iPattern, 1).sequenceNum = seqi;

        % calculate the task/target number
        target(iPattern, 1) = currSeq(iPattern, 1).isTask;

    end
    

    saveEventsFile('save', expParam, currSeq);
    
    %     saveEventsFile('save', expParam, currSeq, 'sequenceNum', ...
    %         'segmentNum', 'segmentOnset', 'stepNum', 'stepOnset', 'patternID', ...
    %         'segmentCateg', 'F0', 'isTask', 'gridIOI', 'patternAmp', 'PE4', 'minPE4', ...
    %         'rangePE4', 'LHL24', 'minLHL24', 'rangeLHL24');

    % ===========================================
    % log everything into matlab structure
    % ===========================================

    % save (machine) onset time for the current sequence
    % might be irrelevant for fMRI
    expParam.data(seqi).currSeqStartTime = currSeqStartTime;

    % save PTB volume
    % might be irrelevant for fMRI
    expParam.data(seqi).ptbVolume = PsychPortAudio('Volume', cfg.pahandle);

    % save current sequence information (without the audio, which can
    % be easily resynthesized)
    currSeq(1).outAudio = [];
    expParam.data(seqi).seq = currSeq;

    %% Wait for audio and delays to catch up
    % wait while fMRI is ongoing
    % stay here till audio stops
    reachHereTime = (GetSecs - expParam.experimentStart);
    audioDuration = (cfg.SequenceDur * expParam.numSeq4Run);

    %     % exp duration + delays - script reaching to till point
    %     WaitSecs(audioDuration + expParam.timing.onsetDelay + ...
    %         expParam.timing.endDelay - reachHereTime);

    % stay in the loop until the sequence ends
    while GetSecs  < (expParam.experimentStart + audioDuration + ...
            expParam.timing.onsetDelay + expParam.timing.endDelay)

        % check if key is pressed
        [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard);

        % terminate if quit-button pressed
        if find(keyCode) == cfg.escapeKey
            error('Experiment terminated by user...');
        end
    end

    %%
    % record exp ending time
    expParam.timing.fMRIendTime = GetSecs - expParam.experimentStart;

    %% Check last button presses & wrap up
    % % %
    % give visual feedback?
    % % %
    displayInstr('Please indicate by pressing button, how many times you detected pitch changes\n\n\n', cfg);

    % wait for participant to press button
    WaitSecs(expParam.timing.endResponseDelay);

    % write down buffered responses after waiting for response
    responseEvents = getResponse('check', cfg, expParam, 1);
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
                expParam.experimentStart;
          %  responseEvents(iResp, 1).target = sum(target);
        end

        saveEventsFile('save', expParam, responseEvents);
    end

    %% wrapping up
    % last screen
    if expParam.runNb == 666 || expParam.runNb == expParam.numSequences
        displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)\n\n\n Soon we will take you out!', cfg);
    else
        displayInstr('This run is over. We will shortly start the following!', cfg);
    end

    % wait for ending the screen/exp
    WaitSecs(expParam.timing.endScreenDelay);

    % record script ending time
    expParam.timing.scriptEndTime = GetSecs - expParam.experimentStart;

    % clear the buffer
    getResponse('flush', cfg, expParam);

    % stop key checks
    getResponse('stop', cfg, expParam);

    %% save
    % Close the logfiles (tsv)   - BIDS
    saveEventsFile('close', expParam, logFile);
    saveEventsFile('close', expParam, responseFile);

    % save the whole workspace
    matFile = fullfile(expParam.outputDir, ...
        strrep(expParam.fileName.events, 'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end

    % clean the workspace
    cleanUp;

catch

    % save everything into .mat file
    matFile = fullfile(expParam.outputDir, ...
        strrep(expParam.fileName.events, 'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end

    % Close the logfiles - BIDS
    saveEventsFile('close', expParam, logFile);
    saveEventsFile('close', expParam, responseFile);

    % clean the workspace
    cleanUp;

    psychrethrow(psychlasterror);
end
