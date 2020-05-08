

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
    logFile.iPatOnset    = zeros(expParam.numSequences, expParam.numPatterns);

    % Prepare for the output logfiles
    logFile = saveOutput(subjectName, runNumber,logFile, cfg,'open');
    
    % not working atm
    % prepare the KbQueue to collect responses
    % getResponse('start', cfg);
    
    
    %  instructions
    displayInstr(expParam.taskInstruction,cfg.screen,cfg.keywait);
    
    % start screen with tap
    displayInstr('TAP',cfg.screen);
    
    
    % get time point at the beginning of the experiment (machine time)
    cfg.experimentStartTime = GetSecs();
    
    % if there's wait time,..wait
    WaitSecs(expParam.onsetDelay);
    
    %% play different sequence
    for iseq = 1:expParam.numSequences
        
        
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
        
        iEvent = 1;
        
        for ipattern = 1:expParam.numPatterns
            
            
            % probably we do not need
            logFile.isegmentCateg = cfg.seq.segmCateg(iseq);
            logFile.iPatOnset(ipattern,iseq) = GetSecs() - cfg.experimentStartTime;
            
            
            % stupid way - it doesnt enter the while loop
            
            
            % currGridIOI = cfg.seq.gridIOI(ipattern)* iEvent -0.01;
            currGridIOI = 0.19;
            
            
            % wait for the every small grip point and register the tapping
            % I think you want to have while loop over gridIOI * gripPoints
            % (e.g. 12 * 0.19) but I'm looking for a way to look every
            % 0.19s and if response, write it down, of not, insert 0
            while GetSecs() < playTime+currGridIOI
                
                status = PsychPortAudio('GetStatus', cfg.pahandle);
                if ~status.Active
                    PsychPortAudio('Stop', cfg.pahandle);
                end
                
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                
                if keyIsDown
                    
                    responseKey = KbName(find(keyCode));
                    responseTime = secs - experimentStartTime;
                    
                    
                    % ecs key press - stop playing the sounds//script
                    if strcmp(responseKey,'ESCAPE')==1
                        
                        % If the script is stopped while a sequence is being
                        % played, it close psychport audio
                        cleanUp();
                        
                        return
                        
                    end
                    
                    % % % inserting all above into function
                    % % % failed attempt
                    %logfile for responses - consider not using while loop above
                    %responseEvents = getResponse('check', cfg);
                    %cfg.responseEvents = responseEvents;
                    
                    %here it logs every 0.18s
                    logFile = saveOutput(subjectName,runNumber,logFile, cfg, input,iseq,ipattern);
                    
                    
                end
            end
            iEvent = iEvent + 1;
            
        
            % Save the events txt logfile
            % here in every pattern
            %
            % logFile = saveOutput(subjectName,runNumber,logFile, cfg, input,iseq,ipattern);
            
            % getResponse('flush', cfg);
            
            
            
        end
        
        logFile.sequenceEnds(iseq,1)= GetSecs - cfg.experimentStartTime;
        logFile.sequenceDurations(iseq,1)= logFile.sequenceEnds(iseq,1) - ...
            logFile.sequenceOnsets(iseq,1);
        
        %add a wait enter for possible breaks - needs instruction
        
        if expParam.sequenceDelay
         %   displayInstr(expParam.delayInstruction,cfg.screen,cfg.keywait);
            WaitSecs(expParam.pauseSeq);
        end  

        
    end %sequence loop
    
    %save everything into .mat file
    logFile = saveOutput(subjectName,runNumber,logFile, cfg, 'savemat');
    
    %%
    cleanUp(cfg)
    
catch
    
    % % % would this work?
    %save everything into .mat file
    logFile = saveOutput(subjectName,runNumber,logFile, cfg, 'savemat');
    % % %
    
    cleanUp(cfg)
    psychrethrow(psychlasterror);
    
end