% TapMainExperiment script which runs the exp and present auditory sequence
% and records the tapping

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

% Define the task = 'RhythmFT', 'RhythmBlock'
% Get task specific parameters by providing task name
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
  [logFile]  = saveEventsFile('open', cfg, logFile); % dummy initialise

  % set the real length of columns
  logFile(1).extraColumns.LHL24.length = 12;
  logFile(1).extraColumns.PE4.length = 12;

  % actual inititalization
  logFile = saveEventsFile('open', cfg, logFile);

  % show instructions and do initial volume setting
  cfg = setVolume(cfg);

  % more instructions
  displayInstr(cfg.trialDurInstruction, cfg, 'setVolume');

  % if there's wait time,..wait
  WaitSecs(cfg.timing.startDelay);

  %% play sequences in a loop
  for iSequence = 1:cfg.pattern.numSequences

    currSeq = struct();
    responseEvents = struct();

    % change screen to "TAP" instruction
    displayInstr('TAP', cfg, 'instrAndQuitOption');

    % construct sequence
    currSeq = makeSequence(cfg, iSequence);

    % ===========================================
    % stimulus save for BIDS
    % ===========================================
    % we save sequence by sequence so we clear this variable every loop
    currSeq(1).fileID = logFile.fileID;
    currSeq(1).extraColumns = logFile(1).extraColumns;

    % adding columns in currSeq for BIDS format
    for iPattern = 1:length(currSeq)
      currSeq(iPattern, 1).trial_type  = 'dummy';
      currSeq(iPattern, 1).duration    = 0;
      currSeq(iPattern, 1).sequenceNum = iSequence;
    end

    saveEventsFile('save', cfg, currSeq);

    %% present stimulus, record tapping

    % response save in the same logfile we keep the trial/sequence info
    responseEvents.fileID = logFile.fileID;

    % fill the buffer
    PsychPortAudio('FillBuffer', cfg.audio.pahandle, ...
                   [currSeq.outAudio; currSeq.outAudio]);

    % start playing
    sequenceOnset = PsychPortAudio('Start', cfg.audio.pahandle, ...
                                   cfg.audio.repeat, ...
                                   cfg.audio.startCue, ...
                                   cfg.audio.waitForDevice);

    % keep collecting tapping until sound stops (log as you go)
    cfg.iSequence = iSequence;
    cfg.sequenceOnset = sequenceOnset;

    [tapOnsets, responseEvents] = mb_getResponse(cfg, ...
                                                 responseEvents, ...
                                                 currSeq);

    % response save for BIDS (write)
    if isfield(responseEvents, 'onset')
      saveEventsFile('save', cfg, responseEvents);
    end

    % ===========================================
    % log everything into matlab structure
    % ===========================================
    % save (machine) onset time for the current sequence
    cfg.data(iSequence).currSeqStartTime = sequenceOnset;

    % save PTB volume
    cfg.data(iSequence).ptbVolume = PsychPortAudio('Volume', ...
                                                   cfg.audio.pahandle);

    % save current sequence information (without the audio, which can
    % be easily resynthesized)
    currSeq(1).outAudio = [];
    cfg.data(iSequence).seq = currSeq;

    % save all the taps for this sequence
    cfg.data(iSequence).taps = tapOnsets;

    % show pause screen in between sequences
    showPauseScreen(cfg);

  end

  % Close the logfiles (tsv)   - BIDS
  saveEventsFile('close', cfg, logFile);

  % save the whole workspace
  matFile = fullfile(cfg.dir.output, ...
                     strrep(cfg.fileName.events, 'tsv', 'mat'));
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
                     strrep(cfg.fileName.events, 'tsv', 'mat'));
  if IsOctave
    save(matFile, '-mat7-binary');
  else
    save(matFile, '-v7.3');
  end

  % Close the logfiles - BIDS
  saveEventsFile('close', cfg, logFile);

  % clean the workspace
  cleanUp();
  psychrethrow(psychlasterror);
end
