
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

% set and load all the parameters to run the experiment
[subjectName, runNumber] = getSubjectID(cfg);


%%  Experiment

% Safety loop: close the screen if code crashes
try
    %% Init the experiment
    [cfg] = initPTB(device,cfg);
    
    
    
    % Empty vectors and matrices for speed
    % logFile.xx = [];
    % Prepare for the output logfiles
    logFile = saveOutput(subjectName, logFile, ExpParameters, 'open');


    % Show instructions
    if ExpParameters.Task1
        DrawFormattedText(Cfg.win,ExpParameters.TaskInstruction,...
            'center', 'center', Cfg.textColor);
        Screen('Flip', Cfg.win);
    end
    
    %  instructions
    displayInstr(expParameters.taskInstruction,cfg.screen,cfg.keywait);
    
    displayInstr('TAP',cfg.screen);
    
    
    
    
    
    
%% make stimuli

%% fill the buffer

%% start playing

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

%%
cleanUp()

catch
    
    cleanUp()
    psychrethrow(psychlasterror);
    
end