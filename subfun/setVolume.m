function [cfg] = setVolume(cfg)

  currInstrPage = 1;
  nInstrPages = length(cfg.introInstruction);
  while 1
    % display instructions and wait for action
    subAction = displayInstr(cfg.introInstruction{currInstrPage}, cfg, 'setVolumePrevNext', ...
                             'currInstrPage', currInstrPage, ...
                             'nInstrPages', nInstrPages);
    % go one instruction page forward or backward (depending on subject's action)
    if strcmp(subAction, 'oneInstrPageForward')
      currInstrPage = min(currInstrPage + 1, length(cfg.introInstruction));
    elseif strcmp(subAction, 'oneInstrPageBack')
      currInstrPage = max(currInstrPage - 1, 1);
    elseif strcmp(subAction, 'done')
      break
    end
  end

end
