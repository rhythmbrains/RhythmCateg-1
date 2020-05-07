function responseEvents = getResponse(action, cfg)
% wrapper function to use KbQueue

% getResponse('collect', cfg)


responseBox = cfg.responseBox;

responseEvents = struct;
responseEvents.onset = [];
responseEvents.trial_type = [];
responseEvents.duration = [];
responseEvents.key_name = [];
responseEvents.pressed = [];


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
        
        
%         if verbose
%             fprintf('\n checking recent keypresses\n')
%         end
        
        iEvent = 1;
         
        while KbEventAvail(responseBox)
            
            event = KbEventGet(responseBox);
                
            responseEvents(iEvent,1).onset = event.Time;
            responseEvents(iEvent,1).trial_type = 'response';
            responseEvents(iEvent,1).duration = 0;
            responseEvents(iEvent,1).key_name = KbName(event.Keycode);
            responseEvents(iEvent,1).pressed =  event.Pressed;
            
            
            iEvent = iEvent + 1;
            
        end
        
        
    case 'flush'
        
%         if verbose
%             fprintf('\n reinitialising keyboard queue\n')
%         end
       
        KbQueueFlush(responseBox);
        
        
    case 'stop'
        
        fprintf('\n stopping to listen to keypresses\n\n')
        
        KbQueueRelease(responseBox);
    

        
end


end