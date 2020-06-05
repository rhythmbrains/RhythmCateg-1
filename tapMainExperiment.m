
%
% SOMETIMES THERE ARE CRACKS IN THE AUDIO
% (maybe there's too much in the audio buffer at the same time?)
% > ask participants switch off all the other apps
%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Clear all the previous stuff
if ~ismac
    close all;
    clear Screen;
else 
    clc; clear;
end

% make sure we got access to all the required functions and inputs
addpath(genpath(fullfile(pwd, 'lib')))


% Get parameters
[cfg,expParam] = getParams('tapMainExp');

% set and load all the subject input to run the experiment
expParam = userInputs(cfg,expParam);
expParam = createFilename(cfg,expParam);



% get time point at the beginning of the experiment (machine time)
expParam.experimentStartTime = GetSecs();

%% Experiment

% Safety loop: close the screen if code crashes
try
    % Init the experiment
    [cfg] = initPTB(cfg);

    % Prepare for the output logfiles
    expParam = saveOutput(cfg, expParam, 'open');
    
    % Prepare for the output logfiles - BIDS
    logFile  = saveEventsFile('open', expParam,[],'sequenceNum',...
        'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
        'category','F0','gridIOI','patternAmp');
    
 
            
    % add a keypress to wait to check the monitor - for fMRI exp
    
    
    
    % task instructions
    displayInstr(expParam.taskInstruction,cfg,'waitForKeypress');
    % more instructions
    displayInstr(expParam.trialDurInstruction,cfg,'setVolume');

    % if there's wait time,..wait
    WaitSecs(expParam.onsetDelay);

    %% play sequences
    for seqi = 1:expParam.numSequences

        currSeq = struct();
        responseEvents = struct();
        
        % change screen to "TAP" instruction
        displayInstr('TAP',cfg,'instrAndQuitOption');

        % construct sequence
        currSeq = makeSequence(cfg,seqi);


        % ===========================================
        % log sequence into text file
        % ===========================================
        
        saveOutput(cfg, expParam, 'updateStim',currSeq);

        
        % ===========================================
        % stimulus save for BIDS
        % ===========================================
        % we save sequence by sequence so we clear this variable every loop
        currSeq(1).fileID = logFile.fileID;
        
        % adding columns in currSeq for BIDS format
        for iPattern=1:length(currSeq)
            currSeq(iPattern,1).trial_type  = 'dummy';
            currSeq(iPattern,1).duration    = 0;
            currSeq(iPattern,1).sequenceNum = seqi;            
        end
        
        saveEventsFile('save', expParam, currSeq,'sequenceNum',...
        'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
        'category','F0','gridIOI','patternAmp');
            
        

        %% present stimulus, record tapping

        % response save for BIDS (set up)
        responseEvents.fileID = logFile.fileID;            

        % fill the buffer
        PsychPortAudio('FillBuffer', cfg.pahandle, [currSeq.outAudio;currSeq.outAudio]);

        % start playing
        currSeqStartTime = PsychPortAudio('Start', cfg.pahandle, cfg.PTBrepet,...
            cfg.PTBstartCue, cfg.PTBwaitForDevice);

        
        % keep collecting tapping until sound stops (log as you go)
        expParam.seqi = seqi;
        expParam.currSeqStartTime = currSeqStartTime;
        
        [tapOnsets, responseEvents] = mb_getResponse(cfg, ...
            expParam, ...
            responseEvents, ...
            currSeq);
        
        
        % response save for BIDS (write)
        if isfield(responseEvents,'onset')
            
            
            saveEventsFile('save', expParam, responseEvents,'sequenceNum',...
                'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
                'category','F0','gridIOI','patternAmp');

    
        end
        
        % ===========================================
        % log everything into matlab structure
        % ===========================================

        % save (machine) onset time for the current sequence
        expParam.data(seqi).currSeqStartTime = currSeqStartTime;

        % save PTB volume
        expParam.data(seqi).ptbVolume = PsychPortAudio('Volume',cfg.pahandle);

        % save current sequence information (without the audio, which can
        % be easily resynthesized)
        expParam.data(seqi).seq = currSeq;
        expParam.data(seqi).seq(1).outAudio = [];

        % save all the taps for this sequence
        expParam.data(seqi).taps = tapOnsets;







        %% Pause

        if seqi<expParam.numSequences
            % pause (before next sequence starts, wait for key to continue)
            if expParam.sequenceDelay
                fbkToDisp = sprintf(expParam.delayInstruction, seqi, expParam.numSequences);
                displayInstr(fbkToDisp,cfg,'setVolume');
                WaitSecs(expParam.pauseSeq);
            end

        else
            % end of experient
            displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)',cfg);
            % wait 3 seconds and end the experiment
            WaitSecs(3);
        end

    end % sequence loop




    % save everything into .mat file
    saveOutput(cfg, expParam, 'savemat');
    saveOutput(cfg, expParam, 'close');

    % Close the logfiles (tsv)   - BIDS
    saveEventsFile('close', expParam, logFile);
    
    
    % save the whole workspace 
    matFile = fullfile(expParam.outputDir, strrep(expParam.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    
    % clean the workspace
    cleanUp(cfg);



catch

    % save everything into .mat file
    saveOutput(cfg, expParam, 'savemat');
    saveOutput(cfg, expParam, 'close');
    % Close the logfiles - BIDS
    saveEventsFile('close', expParam, logFile);

    % clean the workspace
    cleanUp(cfg);

    psychrethrow(psychlasterror);
end
