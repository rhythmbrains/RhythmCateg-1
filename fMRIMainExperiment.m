

% Clear all the previous stuff
if ~ismac
    close all;
    clear Screen;
else
    clc; clear;
end

% make sure we got access to all the required functions and inputs
addpath(genpath(fullfile(pwd, 'lib')))

% Define the task = 'RhythmCategFT', 'PitchFT', 'RhythmCategBlock'
% Get parameters by providing task name, device and debugmode
[cfg,expParam] = getParams('PitchFT','scanner',0);

% set and load all the subject input to run the experiment
expParam = userInputs(cfg,expParam);
expParam = createFilename(cfg,expParam);

% create randomized sequence for 9 runs
% run ==1 then it'll create 9 seq, otherwise it'll upload whats created
[cfg,expParam] = makefMRISeqDesign(cfg,expParam);
   
% get time point at the beginning of the script (machine time)
expParam.timing.scriptStartTime = GetSecs();

%% Experiment

% Safety loop: close the screen if code crashes
try
    % Init the experiment
    [cfg] = initPTB(cfg);
    
    
    % Prepare for the output logfiles - BIDS
    % saving 2 arrays long-form
    % open events logfile
    logFile  = saveEventsFile('open', expParam,[],'sequenceNum',...
        'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
        'category','F0','isTask','gridIOI','patternAmp','PE4_01', ...
        'PE4_02','PE4_03', 'PE4_04', 'PE4_05', 'PE4_06','PE4_07',...
        'PE4_08','PE4_09', 'PE4_10', 'PE4_11', 'PE4_12','minPE4',...
        'rangePE4','LHL24_01', 'LHL24_02', 'LHL24_03', 'LHL24_04',...
        'LHL24_05','LHL24_06','LHL24_07', 'LHL24_08', 'LHL24_09',...
        'LHL24_10','LHL24_11', 'LHL24_12', 'minLHL24','rangeLHL24');
    
    % open stimulation logfile - used for counting button press
    countFile  = saveEventsFile('open_stim', expParam,[],...
        'key_name','pressed','target');
    
    
    % Show instructions for fMRI task - modify to give duration and volume
    % check
    if expParam.fmriTask
        displayInstr(expParam.fmriTaskInst,cfg);
        % displayInstr(expParam.trialDurInstruction,cfg,'setVolume');
        
    end
    
    % wait for space key to be pressed by the experimenter
    % to make the script more verbose
    pressSpace4me
    
    % prepare the KbQueue to collect responses
    % it's after space keypressed because the key looked for is "space" atm
    getResponse('init', cfg, expParam);
    getResponse('start',cfg,expParam);
    
    % wait for trigger from fMRI
    wait4Trigger(cfg);
    
    % show fixation cross
    if expParam.fmriTask
        drawFixationCross(cfg,expParam, expParam.fixationCrossColor);
        Screen('Flip',cfg.win);
    end
    
    
    % and collect the timestamp
    expParam.experimentStart = GetSecs;
    
    % wait for dummy fMRI scans
    WaitSecs(expParam.timing.onsetDelay);
    
    
    %% play sequences
    
    % take the runNb corresponding sequence
    seqi = expParam.runNb;
    
    % prep for BIDS saving structures
    currSeq = struct();
    responseEvents = struct();
    
    % construct sequence
    currSeq = makeSequence(cfg,seqi);
    
    
    % fill the buffer
    PsychPortAudio('FillBuffer', cfg.pahandle, ...
        [currSeq.outAudio;currSeq.outAudio]);
    
    % start playing
    currSeqStartTime = PsychPortAudio('Start', cfg.pahandle, ...
        cfg.PTBrepet,cfg.PTBstartCue, cfg.PTBwaitForDevice);
    
    % save params for later call in BIDS saving
    expParam.timing.seqi = seqi;
    expParam.timing.currSeqStartTime = currSeqStartTime;
    expParam.timing.experimentStart = expParam.experimentStart;
    
    % ===========================================
    % stimulus save for BIDS
    % ===========================================
    
    % open a file to write sequencefor BIDS
    currSeq(1).fileID = logFile.fileID;
    
    % adding columns in currSeq for BIDS format
    for iPattern = 1:length(currSeq)
        
        %correcting onsets for fMRI trigger onset
        currSeq(iPattern,1).onset  = currSeq(iPattern,1).onset + ...
            currSeqStartTime - expParam.experimentStart;
        currSeq(iPattern,1).segmentOnset = currSeq(iPattern,1).segmentOnset...
            + currSeqStartTime - expParam.experimentStart;
        currSeq(iPattern,1).stepOnset = currSeq(iPattern,1).stepOnset...
            + currSeqStartTime - expParam.experimentStart;
        
        %adding compulsory BIDS structures
        currSeq(iPattern,1).trial_type  = 'dummy';
        currSeq(iPattern,1).duration    = 0;
        
        % adding outher interest
        currSeq(iPattern,1).sequenceNum = seqi;
        
        %calculate the task/target number
        target(iPattern,1) = currSeq(iPattern,1).isTask;
        
    end
    
    saveEventsFile('save', expParam, currSeq,'sequenceNum',...
        'segmentNum','segmentOnset','stepNum','stepOnset','patternID',...
        'segmCateg','F0','isTask','gridIOI','patternAmp','PE4','minPE4',...
        'rangePE4','LHL24','minLHL24','rangeLHL24');
    
    % ===========================================
    % log everything into matlab structure
    % ===========================================
    
    % save (machine) onset time for the current sequence
    % might be irrelevant for fMRI
    expParam.data(seqi).currSeqStartTime = currSeqStartTime;
    
    % save PTB volume
    % might be irrelevant for fMRI
    expParam.data(seqi).ptbVolume = PsychPortAudio('Volume',cfg.pahandle);
    
    % save current sequence information (without the audio, which can
    % be easily resynthesized)
%    currSeq(1).outAudio = [];
    expParam.data(seqi).seq = currSeq;
    
    
    %   end
    
    
    %% Wait for audio and delays to catch up
    % wait while fMRI is ongoing
    % stay here till audio stops
    reachHereTime = (GetSecs - expParam.experimentStart);
    audioDuration = (cfg.SequenceDur * expParam.numSeq4Run);
    
    % exp duration + delays - script reaching to till point
%     WaitSecs(audioDuration + expParam.timing.onsetDelay + ...
%         expParam.timing.endDelay - reachHereTime);
    
    %%
    
    % stay in the loop until the sequence ends
    %while GetSecs < (currSeqStartTime+cfg.SequenceDur)
    while GetSecs  < (expParam.experimentStart + audioDuration + ...
            expParam.timing.onsetDelay + expParam.timing.endDelay)
        
        % check if key is pressed
        %[~, tapTime, keyCode] = KbCheck(cfg.keyboard);
        [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard);
        
        % terminate if quit-button pressed
        if find(keyCode)==cfg.keyquit
            error('Experiment terminated by user...');
        end
    end
    
    
    
    
    
    % Check for experiment abortion from operator
%             [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard);
%             if keyIsDown && keyCode(KbName(cfg.escapeKey))
%                 stopEverything = 1;
%                 warning('OK let us get out of here')
%                 break;
%             end
    %%
    % record exp ending time
    expParam.timing.fMRIendTime = GetSecs - expParam.experimentStart;
    
    %% Check last button presses & wrap up
    % % %
    % give visual feedback?
    % % %
    displayInstr('Please indicate by pressing button, how many times you detected pitch changes\n\n\n',cfg);


    % wait for participant to press button
    WaitSecs(expParam.timing.endResponseDelay);
    
    % write down buffered responses
    countEvents = getResponse('check', cfg, expParam,1);
    
    % omits nans in logfile
    if isfield(countEvents,'onset')
        
        temp = struct();
        temp.fileID = countFile.fileID;
        
        count = 1;
        
        for iResp = 1:size(countEvents,1)
            if (~isnan(countEvents(iResp).onset))
                temp(count,1).onset = countEvents(iResp).onset - ...
                    expParam.experimentStart;
                temp(count,1).trial_type = countEvents(iResp).trial_type;
                temp(count,1).duration = countEvents(iResp).duration;
                temp(count,1).key_name = countEvents(iResp).key_name;
                temp(count,1).pressed = countEvents(iResp).pressed;
                temp(count,1).target = sum(target);
                
                count = count +1;
            end
        end
        
        countEvents = struct();
        countEvents = temp;
        
        if isfield(countEvents,'onset') 
            saveEventsFile('save', expParam,countEvents,...
                'key_name','pressed','target');
        end
        
    end

    % stop key checks
    getResponse('stop', cfg, expParam);
    
    %% wrapping up
    % last screen
    if expParam.runNb == 666 || expParam.runNb == expParam.numSequences
        displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)\n\n\n Soon we will take you out!',cfg);
    else
        displayInstr('This run is over. We will shortly start the following!',cfg);
    end
    
    % wait for ending the screen/exp
    WaitSecs(expParam.timing.endScreenDelay);
    
    % record script ending time
    expParam.timing.scriptEndTime = GetSecs - expParam.experimentStart;
    
    %% save
    % Close the logfiles (tsv)   - BIDS
    saveEventsFile('close', expParam, logFile);
    saveEventsFile('close', expParam, countFile);
    
    
    % save the whole workspace
    matFile = fullfile(expParam.outputDir, ...
        strrep(expParam.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    % clean the workspace
    cleanUp(cfg);
    
    
    
catch
    
    % save everything into .mat file
    matFile = fullfile(expParam.outputDir, ...
        strrep(expParam.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end
    
    % Close the logfiles - BIDS
    saveEventsFile('close', expParam, logFile);
    saveEventsFile('close', expParam, countFile);
    
    % clean the workspace
    cleanUp(cfg);
    
    psychrethrow(psychlasterror);
end
