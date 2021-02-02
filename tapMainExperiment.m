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

  % show instructions and do initial volume setting
  cfg = setVolume(cfg);

  % more instructions
  displayInstr(cfg.trialDurInstruction, cfg, 'setVolume');

  % change screen to "GET READY" instruction
  displayInstr('GET READY', cfg);
  
  % if there's wait time,..wait
  WaitSecs(cfg.timing.startDelay);

  %% play sequences in a loop
  for iSequence = 1:cfg.pattern.numSequences
    
    % set run to the current iSequence
    cfg.subject.runNb = iSequence; 
    cfg.iSequence = iSequence; 

    cfg = createFilename(cfg);

    logFile = struct();

    % create events with extra columns to save - BIDS
    logFile(1).extraColumns = cfg.extraColumns;
    
    % dummy initialise
    logFile = saveEventsFile('init', cfg, logFile); 
    
    % set the real length of columns
    logFile(1).extraColumns.LHL24.length = 12;
    logFile(1).extraColumns.PE4.length = 12;
    
    % actual inititalization
    logFile = saveEventsFile('open', cfg, logFile);    
    
    % construct sequence
    currSeq = makeSequence(cfg, iSequence);

    % change screen to "TAP" instruction
    displayInstr('TAP', cfg, 'instrAndQuitOption');


    %% present stimulus, record tapping
                               
    % play sound
    [tapData, sequenceOnset, trialTerminated] = playSound(currSeq(1).outAudio, ...
                                                        cfg.audio.fs, ...
                                                        cfg.audio.pahandle, ...
                                                        cfg.audio.channels(1), ...
                                                        cfg.audio.channels(2), ...
                                                        cfg.audio.trigChanMapping(1), ...
                                                        cfg.audio.initPushDur, ...
                                                        cfg.audio.pushDur, ...
                                                        cfg.keyboard.quit); 
       
    % wait for playback end                                                
    PsychPortAudio('Stop', cfg.audio.pahandle, 1);  
    
    % show quick message to the participant 
    displayInstr('... saving data, please wait ...', cfg)
    
    %% log data 
                                                                        
    % ===========================================
    % BIDS
    % ===========================================            
    collectAndSaveEvents(cfg, logFile, currSeq, iSequence, sequenceOnset);
    
    % ---- SAVE tapping as stim file ---- 
    
    % downsample tapping
    [P,Q] = rat(cfg.audio.fsDs/cfg.audio.fs); 
    tapDataDs = num2cell(resample(tapData(1,:), P, Q)); 
    
    % get stimulus envelope and downsample 
    env = abs(hilbert(tapData(2,:))); 
    soundDataDs = num2cell(resample(env, P, Q)); 
            
    stimFile = []; 
    
    % set columns for data
    stimFile(1).extraColumns = {'tapForce', 'sound'};

    stimFile(1).StartTime = 0; 
    stimFile(1).SamplingFrequency = cfg.audio.fsDs; 

    % init stim file
    stimFile = saveEventsFile('init_stim', cfg, stimFile); 

    % output directory (created automatically)
    stimFile = saveEventsFile('open', cfg, stimFile); 
    
    % prepre data
    [stimFile(1:length(tapDataDs),1).tapForce] = tapDataDs{:}; 
    [stimFile(1:length(tapDataDs),1).sound] = soundDataDs{:}; 

    % write
    stimFile = saveEventsFile('save', cfg, stimFile);
    
    % Close the logfiles (tsv)   - BIDS
    saveEventsFile('close', cfg, logFile);
    saveEventsFile('close', cfg, stimFile);
  
    % ===========================================
    % audiofile
    % ===========================================
    fileNameTap = [cfg.fileName.base, ...
                   cfg.fileName.suffix.run, ...
                   '_recording-tapping_physio', ...
                   '_date-',  cfg.fileName.date, ...
                   '.wav']; 

    % save tapping with original sampling rate          
    audiowrite(fullfile(cfg.dir.outputSubject, fileNameTap),...
               tapData', ...
               cfg.audio.fs); % 'BitsPerSample' -> only 8 bit resolution to save faster...

    %% 
    % show pause screen in between sequences
    showPauseScreen(cfg);

  end


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

  % clean the workspace
  cleanUp();
  psychrethrow(psychlasterror);
end
