

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
    logFile.sequenceOnsets    = zeros(expParam.numSequences, 1);
    logFile.sequenceEnds      = zeros(expParam.numSequences, 1);
    logFile.sequenceDurations = zeros(expParam.numSequences, 1);
    
    % %expParameters.numSegments
    
    logFile.patternOnsets    = zeros(expParam.numSequences, expParam.numPatterns);
    logFile.patternEnds      = zeros(expParam.numSequences, expParam.numPatterns);
    logFile.patternDurations = zeros(expParam.numSequences, expParam.numPatterns);
    
    % Prepare for the output logfiles
    logFile = saveOutput(subjectName, runNumber,logFile, cfg,'open');
    
    
    %  instructions
    displayInstr(expParam.taskInstruction,cfg.screen,cfg.keywait);
    
    % start screen with tap
    displayInstr('TAP',cfg.screen);
    
    
    % get time point at the beginning of the experiment (machine time)
    cfg.experimentStartTime = GetSecs();
    
    % if there's wait time,..wait
    WaitSecs(expParam.onsetDelay);
    
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
        
        %logFile.sequenceOnsets(iseq,1)= GetSecs-cfg.experimentStartTime;
        logFile.sequenceOnsets(iseq,1)= cfg.currSeqPlayTime - cfg.experimentStartTime;
        
        %% check & record response/tapping
        
        
        for ipattern = 1:expParameters.numPatterns
            
            iEvent = 1;
            currGridIOI = seq.gridIOI(ipattern)* iEvent;
            
            logFile.iPatOnset(ipattern,iseq) = GetSecs() - cfg.experimentStartTime;
            
            
            % wait for the every small grip point and register the tapping
         %   while GetSecs() < logFile.sequenceOnsets(iseq,1)+currGridIOI
                
                
                % Check for experiment abortion from operator
                [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard);
                if (keyIsDown==1 && keyCode(cfg.keyquit))
                    break;
                end
                
                %logfile for responses - consider not using while loop above
                responseEvents = getResponse('check', cfg);

                
                
         %   end
            
            iEvent = iEvent + 1;
            
            logFile.isegmentCateg = seq.segmCateg(iseq);

            
            
            %duration of 1 pattern
             
            logFile.iPatDuration(ipattern,iseq) = cfg.interPatternInterval; 
            logFile.iPatEnd(ipattern,iseq) = logFile.iPatOnset(ipattern,iseq) + ...

            

            

            
            
            %% logfile for responses
            
            responseEvents = getResponse('check', cfg);

            
            
            % Save the events txt logfile
            logFile = saveOutput(subjectName,runNumber,logFile, cfg, input,iseq,ipattern);
            

            
          
            getResponse('flush', cfg, expParameters);
            
            
            
        end
        
        logFile.sequenceEnds(iseq,1)= GetSecs - cfg.experimentStartTime;
        logFile.sequenceDurations(iseq,1)= logFile.sequenceEnds(iseq,1) - ...
            logFile.sequenceOnsets(iseq,1);
        
        %add a wait enter for possible breaks
        if expParam.sequenceDelay
            displayInstr(expParam.delayInstruction,cfg.screen,cfg.keywait);
            WaitSecs(expParam.pauseSeq);
        end  

        
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