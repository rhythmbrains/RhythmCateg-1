
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
    % logFile.xx = [];
    % Prepare for the output logfiles
    % logFile = saveOutput(subjectName, logFile, ExpParameters, 'open');
    
    
    %  instructions
    displayInstr(expParameters.taskInstruction,cfg.screen,cfg.keywait);
    
    % start screen with tap
    displayInstr('TAP',cfg.screen);
 
    % play different cycle/windows or sequence
    % for iWindow = 1:numWindows 
    
    %% make stimuli
    % add makeStim script or insert into getMainExpParams 
    % pattern info: grid interval
    audio2push = [cfg.seq';cfg.seq'];
    
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
    
    % %extract pahandle from cfg
    % pahandle = cfg.pahande;
    
    % start the sound sequence
    playTime = PsychPortAudio('Start', cfg.pahandle, repetitions, startCue, waitForDeviceStart);
    
    %save the time to cfg
    cfg.currPlayTime = playTime;

    
    %% check & record response/tapping
    
    %load the current pattern period : every 4/2/...
    % maybe a check for every possible period within the window of 4
    % cycles?
    % or record into logfile, the possible period from PE or LHL
    % Which parameters from pat_complex/pat_simple would bee useful for analysis?
    % min.PE3 and min.PE4 maybe?
    %
    
    % the length of each pattern
    cfg.nGripPoints = 12; % length(pat_complex(1).pattern)
    
    %where is the pulse? every xxperiod
    cfg.currPeriod = 4;
    % grid event duration
    cfg.gridInterval = 0.2;
    % window of number of cycles of pattern
    cfg.nCyclesPerWindow = 4;

    %current target inter-tap-interval in seconds
    currTappingInterval = cfg.currPeriod*cfg.gridInterval;
    
    % total duration of the window
    currWindowDur = cfg.nCyclesPerWindow * cfg.nGripPoints * cfg.gridInterval;
    
    % to calculate the max #taps
    % isn't it the last duration/moment to tap?
    currLastTapTime = currWindowDur - cfg.gridInterval;
    
    %to be used later on to calculate the min number that participant
    %has to tap -
    % if subject was tapping regularly with currTappingInterval
    % then below would be possible number of taps
    tapMaxNTaps = floor(currLastTapTime/currTappingInterval);
    % to calculate 70% of this max taps
    tapMinNTaps = floor(tapMaxNTaps * cfg.probMinNTaps);


    %% log file
    
    
    %%
    cleanUp()
    
catch
    
    cleanUp()
    psychrethrow(psychlasterror);
    
end