

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

% datalogging structure
datalog = []; 

% get time point at the beginning of the experiment (machine time)
datalog.experimentStartTime = GetSecs();

% set and load all the subject input to run the experiment
[datalog.subjectName, datalog.runNumber] = getSubjectID(cfg);


%%  Experiment

% Safety loop: close the screen if code crashes
try
    % Init the experiment
    [cfg] = initPTB(cfg);
        
    % Prepare for the output logfiles
    datalog = saveOutput(datalog, cfg, expParam, 'open'); 
    
    %  instructions
    displayInstr(expParam.taskInstruction,cfg.screen,cfg.keywait);
    
    % start screen with tap
    displayInstr('TAP',cfg.screen);
    
    
    % if there's wait time,..wait
    WaitSecs(expParam.onsetDelay);
    
    
    
    
    %% play sequences
    for seqi = 1:expParam.numSequences
        
        % construct sequence 
        currSeq = makeSequence(cfg,seqi); 

        
        % fill the buffer
        PsychPortAudio('FillBuffer', cfg.pahandle, [currSeq.outAudio;currSeq.outAudio]);
                
        % start playing
        currSeqStartTime = PsychPortAudio('Start', cfg.pahandle, cfg.PTBrepet,...
            cfg.PTBstartCue, cfg.PTBwaitForDevice);
        
        
        
        %% record tapping (fast looop)
        
        % allocate vector of tap times
        currTapOnsets = []; 
        
        % boolean helper variable used to determine if the button was just
        % pressed (and not held down from previous loop iteration)
        istap = false;

        % stay in the loop until the sequence ends
        while GetSecs < (currSeqStartTime+cfg.SequenceDur)

                % check if key is pressed
                [~, tapOnset, keyCode] = KbCheck(cfg.keyboard);
                
                % terminate if quit-button pressed
                if find(keyCode)==cfg.keyquit
                    error('Experiment terminated by user...');                     
                end
                
                % check if tap and save time (it counts as tap if
                % reponse buttons were released initially)
                if ~istap && any(keyCode)
                    % tap onset time is saved wrt sequence start time
                    currTapOnsets = [currTapOnsets,tapOnset-currSeqStartTime];
                    istap = true;
                end
                if istap && ~any(keyCode)
                    istap = false;
                end

        end

        
        %% log
        
        
        % ===========================================
        % log sequence into text file
        % ===========================================
        
        % each pattern on one row
        for i=1:length(currSeq.patternID)
            fprintf(datalog.fidStim,'%s\t%s\t%s\t%s\t%f\t%f\t%f\n', ... 
                datalog.subjectName, ...
                datalog.runNumber, ...
                currSeq.patternID{i}, ...
                currSeq.segmCateg{i}, ...
                currSeq.onsetTime(i), ...
                currSeq.F0(i), ...
                currSeq.gridIOI(i)); 
        end
        
        % ===========================================
        % log tapping into text file
        % ===========================================
                
        % each tap on one row
        % subjectID, seqi, tapOnset
        for i=1:length(currTapOnsets)                        
            fprintf(datalog.fidTap, '%s\t%s\t%d\t%f\n', ...
                datalog.subjectName, ...
                datalog.runNumber, ...
                seqi, ...
                currTapOnsets(i)); 
        end
        
        % ===========================================
        % log everything into matlab structure
        % ===========================================
        
        % save (machine) onset time for the current sequence
        datalog.data(seqi).currSeqStartTime = currSeqStartTime; 
        
        % save current sequence information (without the audio, which can
        % be easily resynthesized)
        datalog.data(seqi).seq = currSeq; 
        datalog.data(seqi).seq.outAudio = []; 
        
        % save all the taps for this sequence
        datalog.data(seqi).taps = currTapOnsets; 


            
        
         
        
        
        %% Pause

        % pause (before next sequence starts, wait for key to continue)
        if expParam.sequenceDelay
            displayInstr(expParam.delayInstruction,cfg.screen,cfg.keywait);
            WaitSecs(expParam.pauseSeq);
        end  

        
        
    end % sequence loop
    
     
    
    
    % save everything into .mat file
    saveOutput(datalog, cfg, expParam, 'savemat'); 
        
    % clean the workspace
    cleanUp(cfg); 
    
    
    
catch
    
    % save everything into .mat file
    saveOutput(datalog, cfg, expParam, 'savemat'); 
    
    % clean the workspace
    cleanUp(cfg); 
    
    psychrethrow(psychlasterror);
    
end






