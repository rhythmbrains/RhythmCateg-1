
% Clear all the previous stuff
% clc; clear;
if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
addpath(genpath(fullfile(pwd, 'lib')))

% Get parameters
[cfg,expParam] = getParams();

% set and load all the subject input to run the experiment
[subjectName, runNumber] = getSubjectID(cfg);


%%  Experiment

% Safety loop: close the screen if code crashes
try
    % Init the experiment
    [cfg] = initPTB(cfg);
    
    % Empty vectors and matrices for speed
    logFile.patternOnsets    = zeros(expParam.numPatterns, 1);
    logFile.patternEnds      = zeros(expParam.numPatterns, 1);
    logFile.patternDurations = zeros(expParam.numPatterns, 1);
    
    %not sure every event/beep should be recorded
    % %expParameters.numSegments
    
    logFile.sequenceOnsets    = zeros(expParam.numPatterns, expParam.numSequences);
    logFile.sequenceEnds      = zeros(expParam.numPatterns, expParam.numSequences);
    logFile.sequenceDurations = zeros(expParam.numPatterns, expParam.numSequences);
    
    % Prepare for the output logfiles
    logFile = saveOutput(subjectName, runNumber,logFile, cfg,'open');
    
    
    %  instructions
    displayInstr(expParam.taskInstruction,cfg.screen,cfg.keywait);
    
    % start screen with tap
    displayInstr('TAP',cfg.screen);
 
    % if there's wait time,..wait
    WaitSecs(expParam.onsetDelay);
    
    
    % get time point at the beginning of the experiment (machine time)
    cfg.experimentStartTime = GetSecs();
    
    %% play different sequence 
    for iseq = 1:expParameters.numSequences
        
        
        % all stimuli made in getMainExpParams script, here we call it now
        audio2push = [cfg.seq.outAudio;cfg.seq.outAudio];
        % we actually have mono sound, should work: audio2push = [cfg.seq];
        
        %% fill the buffer
        PsychPortAudio('FillBuffer', cfg.pahandle, audio2push);
        
        
        %% start playing
        % start the sound sequence
        playTime = PsychPortAudio('Start', cfg.pahandle, cfg.PTBrepet,...
                                   cfg.PTBstartCue, cfg.PTBwaitForDevice);
        %save the time to cfg
        cfg.currSeqPlayTime = playTime;
        
        
        %% check & record response/tapping
        
        
        for ipattern = 1:expParameters.numPatterns
            
            
            
            
            % Check for experiment abortion from operator
            [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard);
            if (keyIsDown==1 && keyCode(cfg.keyquit))
                break;
            end
            
            
            % cfg.keywait
            % cfg.keyquit
            % cfg.keytap
            %    seq.F0
            % seq.gridIOI
            % seq.segmCateg
            % seq.patternID
            % seq.outPatterns
            % seq.outAudio
            
            % Direction of that event
            logFile.iEventDirection = ExpParameters.designDirections(iBlock,iEventsPerBlock);
            % Speed of that event
            logFile.iEventSpeed = ExpParameters.designSpeeds(iBlock,iEventsPerBlock);
            
            
            % % % initially an input for DoDotMo func, now from
            % ExpParameters.eventDuration, to be tested
            % DODOTMO
            iEventDuration = ExpParameters.eventDuration ;                        % Duration of normal events
            % % %
            logFile.iEventIsFixationTarget = ExpParameters.designFixationTargets(iBlock,iEventsPerBlock);
            
            % Event Onset
            logFile.eventOnsets(iBlock,iEventsPerBlock) = GetSecs-Cfg.experimentStart;
            
            
            % % % REFACTORE
            % play the dots
            doDotMo(Cfg, ExpParameters, logFile);
            
            
            %% logfile for responses
            
            responseEvents = getResponse('check', Cfg, ExpParameters);
            
            % concatenate the new event responses with the old responses vector
            %             logFile.allResponses = [logFile.allResponses responseTimeWithinEvent];
            
            
            
            %% Event End and Duration
            logFile.eventEnds(iBlock,iEventsPerBlock) = GetSecs-Cfg.experimentStart;
            logFile.eventDurations(iBlock,iEventsPerBlock) = logFile.eventEnds(iBlock,iEventsPerBlock) - logFile.eventOnsets(iBlock,iEventsPerBlock);
            
            
            
            
            % Save the events txt logfile
            logFile = saveOutput(subjectName, logFile, ExpParameters, 'save Events', iBlock, iEventsPerBlock);
            
            
            % wait for the inter-stimulus interval
            WaitSecs(ExpParameters.ISI);
            
            
            getResponse('flush', Cfg, ExpParameters);
            
            
            %% log file
            % make a saveOutput script
            logFile = saveOutput(subjectName,runNumber,logFile, cfg,'save');
            
        end
        
        %add a wait enter for possible breaks
        
    end %sequence loop
    
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