function getTapping(action, cfg)
% wrapper function to use KbQueue

% getTapping(action, cfg, expParameters)


responseBox = cfg.responseBox;


switch action
    
    case 'start'
        
        % Clean and realease any queue that might be opened
        KbQueueRelease(responseBox);

        % Create the keyboard queue to collect responses.
        keysOfInterest = cfg.keytap;
        KbQueueCreate(responseBox, keysOfInterest);
        
        % start listening
        fprintf('\n starting to listen to keypresses\n')
        KbQueueStart(responseBox);
        
    case 'collect'
        
%         while KbEventAvail(responseBox)
%             
%             event = KbEventGet(responseBox);
%             
%             responseEvents(end+1, :) = [event.Time event.Keycode event.Pressed];  %#ok<*AGROW>
%         end
        
        
    case 'flush'
        
        if verbose
            fprintf('\n reinitialising keyboard queue\n')
        end
       
        KbQueueFlush(responseBox);
        
        
    case 'stop'
        
        fprintf('\n stopping to listen to keypresses\n\n')
        
        KbQueueRelease(responseBox);
    

        
end


end