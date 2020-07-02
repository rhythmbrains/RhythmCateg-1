

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

    
    % Prepare for the output logfiles - BIDS
    logFile  = saveEventsFile('open', expParam,[],'sequenceNum',...
        'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
        'category','F0','gridIOI','patternAmp','PE4','minPE4',...
        'rangePE4','LHL24','minLHL24','rangeLHL24');
    
 
            
    % wait for space key to be pressed by the experimenter
    % to make the script more verbose
    pressSpace4me
    
    
    % consider checking KbCheck if it works here
    % getResponse('init', xx)
    % getResponse('start',xx)
    
    
    % Show instructions for fMRI task
    if expParam.fmriTask
        displayInstr(expParam.fmriTaskInst,cfg);
    end
    
    % wait for trigger from fMRI
    wait4Trigger(cfg);
    
    % show fixation cross 
    if expParam.fmriTask
        drawFixationCross(cfg,expParam, expParam.fixationCrossColor);
        Screen('Flip',cfg.win);
    end
    
    % "omit" the behav instructions 
    WaitSecs(expParam.onsetDelay);
    
    % show instructions and do initial volume setting
    currInstrPage = 1; 
    nInstrPages = length(expParam.introInstruction); 
    while 1
        % display instructions and wait for action
        subAction = displayInstr(expParam.introInstruction{currInstrPage}, cfg, 'setVolumePrevNext', ...
                                 'currInstrPage', currInstrPage, ...
                                 'nInstrPages', nInstrPages); 
        % go one instruction page forward or backward (depending on subject's action)                      
        if strcmp(subAction,'oneInstrPageForward')
            currInstrPage = min(currInstrPage+1, length(expParam.introInstruction)); 
        elseif strcmp(subAction,'oneInstrPageBack')
            currInstrPage = max(currInstrPage-1, 1); 
        elseif strcmp(subAction,'done')
            break
        end
    end
        
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
        'segmCateg','F0','gridIOI','patternAmp','PE4','minPE4',...
        'rangePE4','LHL24','minLHL24','rangeLHL24');


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
                'segmCateg','F0','gridIOI','patternAmp','PE4','minPE4',...
                'rangePE4','LHL24','minLHL24','rangeLHL24');

    
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
        currSeq(1).outAudio = [];
        expParam.data(seqi).seq = currSeq;

        % save all the taps for this sequence
        expParam.data(seqi).taps = tapOnsets;



        %% Pause
        %change this part for fMRI 

        if seqi<expParam.numSequences
            
            % pause (before next sequence starts, wait for key to continue)
            if expParam.sequenceDelay % change this for fMRI exp
                
                % show sequence-specific instruction if there is some
                % defined
                if ~isempty(expParam.seqSpecificDelayInstruction{seqi})
                    displayInstr(expParam.seqSpecificDelayInstruction{seqi}, ...
                                 cfg, ...
                                 'setVolumeToggleGeneralInstr', ...
                                 'generalInstrTxt', expParam.generalInstruction);
                end
                
                % show general instruction after each sequence
                fbkToDisp = sprintf(expParam.generalDelayInstruction, seqi, expParam.numSequences);
                displayInstr(fbkToDisp, ...
                             cfg, ...
                             'setVolumeToggleGeneralInstr', ...
                             'generalInstrTxt', expParam.generalInstruction);
                
                % pause for N secs before starting next sequence
                WaitSecs(expParam.pauseSeq);
            end
            
        else
            
            % end of experient
            displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)',cfg);
            
            % wait 3 seconds and end the experiment
            WaitSecs(3);
            
        end

    end % sequence loop



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
    matFile = fullfile(expParam.outputDir, strrep(expParam.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    % Close the logfiles - BIDS
    saveEventsFile('close', expParam, logFile);

    % clean the workspace
    cleanUp(cfg);

    psychrethrow(psychlasterror);
end
