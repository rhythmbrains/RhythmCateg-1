function wait4Trigger(cfg)

if strcmp(cfg.device,'Scanner')

    fprintf('Waiting for trigger \n');

    DrawFormattedText(cfg.win,'Waiting For Trigger',...
        'center', 'center', cfg.textColor);
    Screen('Flip', cfg.win);

    triggerCounter=0;

    while triggerCounter < cfg.numTriggers
        
        [keyIsDown, ~, keyCode, ~] = KbCheck(-1);

        if strcmp(KbName(keyCode),cfg.triggerKey)

            triggerCounter = triggerCounter+1 ;

            fprintf('Trigger %s \n', num2str(triggerCounter));

            DrawFormattedText(cfg.win,['Trigger ',num2str(triggerCounter)],'center', 'center', cfg.textColor);
            Screen('Flip', cfg.win);

            while keyIsDown
                [keyIsDown, ~, ~, ~] = KbCheck(-1);
            end

        end
    end
end
end
