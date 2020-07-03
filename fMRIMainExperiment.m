

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

% % %
% provide here to specifiy the sequence length and/or call getParamsMainExp
% in here with the arguments for rhythmic sequence, control1 and control2
% designs
% % %
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

    
    % prepare the KbQueue to collect responses
    getResponse('init', cfg, expParam);
    getResponse('start',cfg,expParam);
    
    
    % Show instructions for fMRI task
    if expParam.fmriTask
        displayInstr(expParam.fmriTaskInst,cfg);
    end
    
    % wait for space key to be pressed by the experimenter
    % to make the script more verbose
    pressSpace4me
    
    % wait for trigger from fMRI
    wait4Trigger(cfg);
    
    % show fixation cross 
    if expParam.fmriTask
        drawFixationCross(cfg,expParam, expParam.fixationCrossColor);
        Screen('Flip',cfg.win);
    end
    

    % wait for dummy fMRI scans
    WaitSecs(expParam.onsetDelay);
    
    
    
    %% play sequences
    % % %
    % I'm keeping the for loop in case we change our minds on how many
    % sequence would be concetenated inside fmri
    % % %
    for seqi = 1:expParam.numSequences

        currSeq = struct();
        responseEvents = struct();
        

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
        
        % % % This one can stay here but a bit simplified maybe to record
        % in case they press something - accidents? 
        % % %
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


    end % sequence loop

    % wait while fMRI is ongoing
    WaitSecs(expParam.endDelay);
    
    % % %
    % ask for the button press tot times at the end if fmri run & give visual feedback?
    % % %
    displayInstr('Please indicate by pressing button, how many times you detected pitch changes\n\n\n',cfg);
    % wait 3 seconds for participant to read
    WaitSecs(3);
    
    % add response check and a counter to save into a mat or logfile
    % modify the below
%     % collect response 
%     [tapOnsets, countEvents] = mb_getResponse(cfg, ...
%         expParam, ...
%         countEvents, ...
%         currSeq);
%    
%     % response save for BIDS (write)
%     if isfield(countEvents,'onset')
%         saveEventsFile('save', expParam, countEvents);
%     end
    
    
    
    % % make a if loop for the finaly run: 
    if expParam.runNb == 666 %change this with the known final run#
        displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)\n\n\n Soon we will take you out!',cfg);
    else
        displayInstr('This run is over. We will shortly start the following!',cfg);
    end
    

    % wait 2 seconds for ending the screen/exp
    WaitSecs(2);
    
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
