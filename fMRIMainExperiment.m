
%%

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


%% Experiment

% Safety loop: close the screen if code crashes
try
    
    %% Init Experiment
    % get time point at the beginning of the script (machine time)
    cfg.timing.scriptStartTime = GetSecs();

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
    
    % create response file - used for counting button press
    responseFile.extraColumns = cfg.responseExtraColumns;
    responseFile  = saveEventsFile('open_stim', cfg, responseFile);

    %     disp(cfg);
    
    % Show instructions for fMRI task & wait for space press
    standByScreen(cfg);

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);
    getResponse('start', cfg.keyboard.responseBox);

    % wait for trigger from fMRI
    waitForTrigger(cfg);
    
    %% Start Experiment
    % show fixation cross + get timestamp
    cfg = getExperimentStart(cfg);

    % wait for dummy fMRI scans
    WaitSecs(cfg.timing.onsetDelay);

    % take the runNb corresponding sequence
    iSequence = cfg.subject.runNb;

    % prep for BIDS saving structures
    currSeq = struct();
    responseEvents = struct();

    % construct sequence
    currSeq = makeSequence(cfg, iSequence);
    
    %% play sequences
    % fill the buffer % start sound presentation
    PsychPortAudio('FillBuffer', cfg.audio.pahandle, ...
        [currSeq.outAudio;currSeq.outAudio]);
    PsychPortAudio('Start', cfg.audio.pahandle);
    onset = GetSecs;
    %% save timing and sequence info
    % ===========================================
    % log into matlab structure
    % ===========================================
    cfg.timing.seqi = iSequence;
    cfg.timing.currSeqStartTime = onset;
    cfg.timing.experimentStart = cfg.experimentStart;
    % save (machine) onset time for the current sequence info 
    cfg.data(iSequence).currSeqStartTime = onset;
    cfg.data(iSequence).ptbVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
    %    currSeq(1).outAudio = [];
    cfg.data(iSequence).seq = currSeq;
    
    % ===========================================
    % stimulus save for BIDS
    % ===========================================
    target = collectAndSaveEvents(cfg, logFile, currSeq,iSequence, onset);
    
%     % write into logfile
%     currSeq(1).fileID = logFile(1).fileID;
%     currSeq(1).extraColumns = logFile(1).extraColumns;
% 
%     % adding columns in currSeq for BIDS format
%     for iPattern = 1:numel(currSeq)
% 
%         % correcting onsets for fMRI trigger onset
%         currSeq(iPattern, 1).onset  = currSeq(iPattern, 1).onset + ...
%             onset - cfg.experimentStart;
%         currSeq(iPattern, 1).segmentOnset = currSeq(iPattern, 1).segmentOnset ...
%             + onset - cfg.experimentStart;
%         currSeq(iPattern, 1).stepOnset = currSeq(iPattern, 1).stepOnset ...
%             + onset - cfg.experimentStart;
% 
%         % adding compulsory BIDS structures
%         currSeq(iPattern, 1).trial_type  = 'dummy';
%         currSeq(iPattern, 1).duration    = 0;
% 
%         % adding other interest
%         currSeq(iPattern, 1).sequenceNum = iSequence;
%         target(iPattern, 1) = currSeq(iPattern, 1).isTask;
% 
%     end
%     
% 
%     saveEventsFile('save', cfg, currSeq);


    % ===========================================
    % log into matlab structure
    % ===========================================

%     % save (machine) onset time for the current sequence info 
%     cfg.data(iSequence).currSeqStartTime = onset;
%     cfg.data(iSequence).ptbVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
%     %    currSeq(1).outAudio = [];
%     cfg.data(iSequence).seq = currSeq;
%     
    %% Wait for audio and delays to catch up
    % stay here till audio stops & check esc key press
    waitAndCheckEsc(cfg);

    %%
    % record exp ending time
    cfg.timing.fMRIendTime = GetSecs - cfg.experimentStart;

    %% Check button presses
    % instructions to press
    displayInstr(cfg.task.instructionPress, cfg);

    % wait for participant to press button
    WaitSecs(cfg.timing.endResponseDelay);

    % save response & target
    cfg.target = target;
    responseEvents = collectAndSaveResponses(cfg, ...
        responseFile, cfg.experimentStart);
    

    %% wrapping up
    % last screen
    if cfg.debug.do || cfg.subject.runNb == cfg.pattern.numSequences
        displayInstr(cfg.task.instructionEnd, cfg);
    else
        displayInstr(cfg.task.instructionCont, cfg);
    end

    % wait for ending the screen/exp
    WaitSecs(cfg.timing.endScreenDelay);

    % record script ending time
    cfg.timing.scriptEndTime = GetSecs - cfg.experimentStart;

    % clear the buffer & stop key checks
    getResponse('stop', cfg.keyboard.responseBox);
    getResponse('release', cfg.keyboard.responseBox);


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
