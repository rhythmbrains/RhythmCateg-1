function checkAbort(cfg)
% Check for experiment abortion from operator
global stopEverything

[keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard.keyboard);

if keyIsDown && keyCode(KbName(cfg.escapeKey))
    
    stopEverything = true;
    
    cleanUp();
    
    error('Escape key press detected: aborting experiment.')
    
end

end