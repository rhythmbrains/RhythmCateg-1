function responseEvents = checkTapping(cfg)
% % %
% not used function atm. Consider deleting it
% % % 


% The queue will be listening to key presses on the response box as defined
% in the cfg structure : see setParameters for more details



while GetSecs < (curr_step_start_time+curr_taketap_dur)
    
    % collect tapping
    [~,secs,key_code] = KbCheck(-1);
    
    % terminate if quit-button pressed
    if find(key_code)==cfg.keyquit
        error('Experiment terminated by user...');
    end
    
    % if they did not press delete, it looks or any response
    % button and saves the time
    if ~istap && any(key_code)
        taps = [taps,secs-start_time];
        istap = true;
    end
    
    % it counts as tap if reponse buttons were released
    % initially
    if istap && ~any(key_code)
        istap = false;
    end
    
    
end

            
% Get all the keypresses and return them as an array responseEvents
%
% Time   Keycode   Pressed
% 
% Pressed == 1  --> the key was pressed
% Pressed == 0  --> the key was released
%
% KbName(responseEvents(:,2)) will give all the keys pressed

% responseEvents = [];
%
% responseBox = cfg.responseBox;
%
%
%
%         while KbEventAvail(responseBox)
%
%             event = KbEventGet(responseBox);
%
%             responseEvents(end+1, :) = [event.Time event.Keycode event.Pressed];  %#ok<*AGROW>
%         end