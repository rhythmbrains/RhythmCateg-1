
%
% SOMETIMES THERE ARE CRACKS IN THE AUDIO
% (maybe there's too much in the audio buffer at the same time?)
% > ask participants switch off all the other apps
%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Clear all the previous stuff
% clc; clear;
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
        'patternID','category','F0','gridIOI');
    
    % add a keypress to wait to check the monitor - for fMRI exp
    
    % task instructions
    displayInstr(expParam.taskInstruction,cfg,'waitForKeypress');
    % more instructions
    displayInstr(expParam.trialDurInstruction,cfg,'setVolume');

    % if there's wait time,..wait
    WaitSecs(expParam.onsetDelay);

    %% play sequences
    for seqi = 1:expParam.numSequences

        currSeqEvent = struct();
        responseEvents = struct();
        
        % change screen to "TAP" instruction
        displayInstr('TAP',cfg,'instrAndQuitOption');

        % construct sequence
        % % % BIDS concerns below:
        % % % DO WE NEED LINE_STRUCTURE FIELds specifically?
        % % % Or is its ok to convert the structure column-wise?
        % % % do we need cell array or character would suffice? 
        currSeq = makeSequence(cfg,seqi);


        % ===========================================
        % log sequence into text file
        % ===========================================
        % each pattern on one row
        for i=1:length(currSeq.patternID)
            fprintf(expParam.fidStim,'%d\t%d\t%s\t%s\t%f\t%f\t%f\n', ...
                expParam.subjectNb, ...
                expParam.runNb, ...
                currSeq.patternID{i}, ...
                currSeq.segmCateg{i}, ...
                currSeq.patternOnset(i), ...
                currSeq.F0(i), ...
                currSeq.gridIOI(i));
        end

        
        % ===========================================
        % stimulus save for BIDS
        % ===========================================
        % we save sequence by sequence so we clear this variable every loop
        currSeqEvent.eventLogFile = logFile.eventLogFile;
        
        % converting currSeq into column-structure for BIDS format
        for iPattern=1:length(currSeq.patternID)
            currSeqEvent(iPattern,1).trial_type  = 'dummy';
            currSeqEvent(iPattern,1).duration    = 0;
            currSeqEvent(iPattern,1).sequenceNum = seqi;
            currSeqEvent(iPattern,1).patternID   = currSeq.patternID{iPattern};
            currSeqEvent(iPattern,1).segmCateg   = currSeq.segmCateg{iPattern};
            currSeqEvent(iPattern,1).onset       = currSeq.patternOnset(iPattern);
            currSeqEvent(iPattern,1).F0          = currSeq.F0(iPattern);
            currSeqEvent(iPattern,1).gridIOI     = currSeq.gridIOI(iPattern);

        end
        
        saveEventsFile('save', expParam, currSeqEvent,'sequenceNum',...
                'patternID','segmCateg','F0','gridIOI');
            
        

        %% present stimulus, record tapping

        % response save for BIDS (set up)
        responseEvents.eventLogFile = logFile.eventLogFile;            

        % fill the buffer
        PsychPortAudio('FillBuffer', cfg.pahandle, [currSeq.outAudio;currSeq.outAudio]);

        % start playing
        currSeqStartTime = PsychPortAudio('Start', cfg.pahandle, cfg.PTBrepet,...
            cfg.PTBstartCue, cfg.PTBwaitForDevice);

        
        % keep collecting tapping until sound stops (log as you go)
        [tapOnsets, responseEvents] = mb_getResponse(cfg, ...
                                                     expParam, ...
                                                     responseEvents, ...
                                                     currSeq, ...
                                                     seqi, ...
                                                     currSeqStartTime);
        
        % response save for BIDS (write)
        saveEventsFile('save', expParam, responseEvents,'sequenceNum',...
            'patternID','segmCateg','F0','gridIOI');
            
        
        
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
        expParam.data(seqi).seq.outAudio = [];

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
