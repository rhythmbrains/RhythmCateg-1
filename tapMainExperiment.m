

%%

% set and load all the parameters to run the experiment
[subjectName, runNumber] = getSubjectID(cfg);


%%  Experiment

% Safety loop: close the screen if code crashes
try
    %% Init the experiment
    [cfg] = initPTB(cfg);
    % Prepare for the output logfiles
    logFile = saveOutput(subjectName, logFile, ExpParameters, 'open');

%%

% sound repetition
repetitions = 1;

% Start immediately (0 = immediately)
startCue = 0;

% Should we wait for the device to really start (1 = yes) 
waitForDeviceStart = 1;

%extract pahandle from cfg
pahandle = cfg.pahande;

% start the sound sequence
playTime = PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);


%save the time to cfg
cfg.playTime = playTime;


catch
    
    %cleanUp()
    %psychrethrow(psychlasterror);
    
end