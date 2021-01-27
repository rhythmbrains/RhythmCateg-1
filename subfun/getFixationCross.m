function cfg = getFixationCross(cfg)
  % put a fixation cross on the screen

  drawFixation(cfg);
  Screen('Flip', cfg.screen.win);

end
