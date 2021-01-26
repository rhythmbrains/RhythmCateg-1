function showPauseScreen
% it shows the pause screen with the relevant instructions and
% wait till button press
% after the button press, it waits for 3 more seconds - consider discarding
% that - could be confusing for the participants

if iSequence<cfg.pattern.numSequences
    
    % pause (before next sequence starts, wait for key to continue)
    if cfg.sequenceDelay
        
        % show sequence-specific instruction if there is some
        % defined
        if ~isempty(cfg.seqSpecificDelayInstruction{iSequence})
            displayInstr(cfg.seqSpecificDelayInstruction{iSequence}, ...
                cfg, ...
                'setVolumeToggleGeneralInstr', ...
                'generalInstrTxt', cfg.generalInstruction);
        end
        
        % show general instruction after each sequence
        fbkToDisp = sprintf(cfg.generalDelayInstruction, ...
            iSequence, cfg.pattern.numSequences);
        displayInstr(fbkToDisp, cfg, ...
            'setVolumeToggleGeneralInstr', ...
            'generalInstrTxt', cfg.generalInstruction);
        
        % pause for N secs before starting next sequence
        WaitSecs(cfg.pauseSeq);
    end
    
else
    
    % end of experient
    displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)',cfg);
    
    % wait 3 seconds and end the experiment
    WaitSecs(3);
    
end

end