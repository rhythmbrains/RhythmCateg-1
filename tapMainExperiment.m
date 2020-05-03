
% Clear all the previous stuff
% clc; clear;
if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
addpath(genpath(fullfile(pwd, 'lib')))

% Get parameters
[cfg,expParameters] = getParams();

% set and load all the subject input to run the experiment
[subjectName, runNumber] = getSubjectID(cfg);


%%  Experiment

% Safety loop: close the screen if code crashes
try
    % Init the experiment
    [cfg] = initPTB(cfg);
    
    % Empty vectors and matrices for speed
    logFile.patternOnsets    = zeros(expParameters.numPatterns, 1);
    logFile.patternEnds      = zeros(expParameters.numPatterns, 1);
    logFile.patternDurations = zeros(expParameters.numPatterns, 1);
    
    %not sure every event/beep should be recorded
    % %expParameters.numSounds
    
    logFile.sequenceOnsets    = zeros(expParameters.numPatterns, expParameters.numSequences);
    logFile.sequenceEnds      = zeros(expParameters.numPatterns, expParameters.numSequences);
    logFile.sequenceDurations = zeros(expParameters.numPatterns, expParameters.numSequences);
    
    % Prepare for the output logfiles
    logFile = saveOutput(subjectName, runNumber,logFile, cfg,'open');
    
    
    %  instructions
    displayInstr(expParameters.taskInstruction,cfg.screen,cfg.keywait);
    
    % start screen with tap
    displayInstr('TAP',cfg.screen);
 
    % if there's wait time,..wait
    WaitSecs(expParameters.onsetDelay);
    
    
    % get time point at the beginning of the experiment (machine time)
    cfg.experimentStartTime = GetSecs();
    
    % play different sequence 
    %% for iseq = 1:expParameters.numSequences
    
    % below for loop is only for recording time
    % or it could be converted into looping through each gridpoint
    % so all the 1s and 0s can be recorded as 1-line for each event (silent
    % or sound)
    % for ipattern = 1:expParameters.numPatterns
    
    
    
    % stimuli made in getMainExpParams.m 
    % call it now
    audio2push = [cfg.seq;cfg.seq];
    
    %% fill the buffer
    PsychPortAudio('FillBuffer', cfg.pahandle, audio2push);
    % % %
    % do we need cfg.reqsampleoffset here?
    % % %
    
    %% start playing
    % sound repetition
    repetitions = 1;
    
    % Start immediately (0 = immediately)
    startCue = 0;
    
    % Should we wait for the device to really start (1 = yes)
    waitForDeviceStart = 1;
    
    % start the sound sequence
    playTime = PsychPortAudio('Start', cfg.pahandle, repetitions, startCue, waitForDeviceStart);
    
    %save the time to cfg
    cfg.currPlayTime = playTime;

    
    %% check & record response/tapping
    
    
    
    % stimulus envelope for each trial 
    % (it can be extracted by taking abs(hilbert(s)) 
    % and downsampling to e.g. 256 Hz to save space
    
    
    
    
    %% log file
    % make a saveOutput script
    logFile = saveOutput(subjectName,runNumber,logFile, cfg,'save');
    
% end
    

    
    %save everything into .mat file 
    logFile = saveOutput(subjectName,runNumber,logFile, cfg, 'savemat');
    
    %%
    cleanUp()
    
catch
    
    % % % would this work? 
    %save everything into .mat file 
    logFile = saveOutput(subjectName,runNumber,logFile, cfg, 'savemat');
    % % % 
    
    cleanUp()
    psychrethrow(psychlasterror);
    
end