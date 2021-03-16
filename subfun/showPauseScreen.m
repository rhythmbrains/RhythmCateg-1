function showPauseScreen(cfg)
  % it shows the pause screen with the relevant instructions and
  % wait till button press
  % after the button press, it waits for 1 more seconds - consider discarding
  % that - could be confusing for the participants

  iSequence = cfg.iSequence;
  allNbSequence = cfg.pattern.numSequences;

  if iSequence < allNbSequence

    % pause (before next sequence starts, wait for key to continue)
    if cfg.timing.breakDelay

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
                          iSequence, allNbSequence);
      displayInstr(fbkToDisp, cfg, ...
                   'setVolumeToggleGeneralInstr', ...
                   'generalInstrTxt', cfg.generalInstruction);

%       % change screen to "GET READY" instruction
%       displayInstr('GET READY', cfg);
%       
      % pause for N secs before starting next sequence
      WaitSecs(cfg.timing.breakDelay);
    end

  else

    % end of experient
    displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)', cfg);

    % wait 3 seconds and end the experiment
    WaitSecs(cfg.timing.stopDelay);

  end

end
