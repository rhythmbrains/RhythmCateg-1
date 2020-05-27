
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
end

% make sure we got access to all the required functions and inputs
addpath(genpath(fullfile(pwd, 'lib')))

% ! ! ! for now - change before sending to ANYONE ! ! !
addpath(genpath(fullfile('../../CPP_BIDS')))

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
    
    logFile  = saveEventsFile('open', expParam,[],'sequenceNum',...
        'patternID','category','F0','gridIOI');
    

    % task instructions
    displayInstr(expParam.taskInstruction,cfg,'waitForKeypress');
    % more instructions
    displayInstr(expParam.trialDurInstruction,cfg,'setVolume');

    % if there's wait time,..wait
    WaitSecs(expParam.onsetDelay);

    %% play sequences
    for seqi = 1:expParam.numSequences


        % change screen to "TAP" instruction
        displayInstr('TAP',cfg,'instrAndQuitOption');

        % construct sequence
        % % % BIDS concerns below:
        % % % DO WE NEED LINE_STRUCTURE FIELds specifically?
        % % % Or is its ok to convert the structure column-wise?
        % % % do we need cell array or character would suffice? 
        currSeq = makeSequence(cfg,seqi);

        % fill the buffer
        PsychPortAudio('FillBuffer', cfg.pahandle, [currSeq.outAudio;currSeq.outAudio]);

        % start playing
        currSeqStartTime = PsychPortAudio('Start', cfg.pahandle, cfg.PTBrepet,...
            cfg.PTBstartCue, cfg.PTBwaitForDevice);

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
                currSeq.onset(i), ...
                currSeq.F0(i), ...
                currSeq.gridIOI(i));
        end

        
        % stimulus save for BIDS
        % we save sequence by sequence so we clear this variable every loop
        currSeqEvent.eventLogFile = logFile.eventLogFile;
        
        % converting currSeq into column-structure for BIDS format
        for i=1:length(currSeq.patternID)
            currSeqEvent(i).trial_type  = 'dummy';
            currSeqEvent(i).duration    = 0;
            currSeqEvent(i).sequenceNum = seqi;
            currSeqEvent(i).patternID   = currSeq.patternID{i};
            currSeqEvent(i).segmCateg   = currSeq.segmCateg{i};
            currSeqEvent(i).onset       = currSeq.onset(i);
            currSeqEvent(i).F0          = currSeq.F0(i);
            currSeqEvent(i).gridIOI     = currSeq.gridIOI(i);
        end
        
        
        saveEventsFile('save', expParam, currSeqEvent,'sequenceNum',...
                'patternID','segmCateg','F0','gridIOI');
            
        
        
        %% record tapping (fast looop)

        currTapOnsets = mb_getResponse(cfg, currSeqStartTime);

        
        % ===========================================
        % log tapping into text file
        % ===========================================

        % each tap on one row
        % subjectID, seqi, tapOnset
        for i=1:length(currTapOnsets)
            fprintf(expParam.fidTap, '%d\t%d\t%d\t%f\n', ...
                expParam.subjectNb, ...
                expParam.runNb, ...
                seqi, ...
                currTapOnsets(i));
        end
        
        % response save for BIDS
        for i=1:length(currTapOnsets)
            responseEvents(i).sequenceNum = seqi;
            responseEvents(i).onset = currTapOnsets(i);
            responseEvents(i).duration = 0;
            responseEvents(i).trial_type = 'response';
            responseEvents(i).patternID   = currSeq.patternID{i};
            responseEvents(i).segmCateg   = currSeq.segmCateg{i};
            responseEvents(i).F0          = currSeq.F0(i);
            responseEvents(i).gridIOI     = currSeq.gridIOI(i);
            
        end

        responseEvents.eventLogFile = logFile.eventLogFile;
        
        saveEventsFile('save', expParam, responseEvents,'sequenceNum',...
            'patternID','segmCateg','F0','gridIOI');
            
%             
%             responseEvents = getResponse('check', cfg, expParameters);
%             
%             if ~isempty(responseEvents(1).onset)
%                 
%                 responseEvents.eventLogFile = logFile.eventLogFile;
%                 
%                 for iResp = 1:size(responseEvents, 1)
%                     responseEvents(iResp).onset = ...
%                         responseEvents(iResp).onset - cfg.experimentStart;
%                     responseEvents(iResp).target = expParameters.designFixationTargets(iBlock,iEvent);
%                     responseEvents(iResp).event = iEvent;
%                     responseEvents(iResp).block = iBlock;
%                 end
%                 
%                 saveEventsFile('save', expParameters, responseEvents, ...
%                     'direction', 'speed', 'target', 'event', 'block');
%             end
            
            
            
        
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
        expParam.data(seqi).taps = currTapOnsets;







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

    % Close the logfiles  - BIDS
    saveEventsFile('close', expParam, logFile);
    
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
