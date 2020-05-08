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
        
                
        % Prevent spilling of keystrokes into console. If you use ListenChar(2)
        % this will prevent you from using KbQueue.
        ListenChar(-1);
        
        % Clean and realease any queue that might be opened
        KbQueueRelease(responseBox);
        
        %% Defines keys
        % list all the response keys we want KbQueue to listen to
        
        % by default we listen to all keys
        % but if responseKey is set in the parameters we override this
        keysOfInterest = ones(1,256); 
        
        fprintf('\n Will be listening for key presses on : ')
        
        if isfield(expParam, 'responseKey') && ~isempty(cfg.keytap)
            
            keysOfInterest = zeros(1,256);
            
            for iKey = 1:numel(expParameters.responseKey)
                fprintf('\n  - %s ', expParameters.responseKey{iKey})
                responseTargetKeys(iKey) = KbName(expParameters.responseKey(iKey)); %#ok<*SAGROW>
            end
            
            keysOfInterest(responseTargetKeys) = 1;
           
        else
            
            fprintf('ALL KEYS.')
            
        end
        
        fprintf('\n\n')
        
        % Create the keyboard queue to collect responses.
        KbQueueCreate(responseBox, keysOfInterest);

        fprintf('\n starting to listen to keypresses\n')
        
        KbQueueStart(responseBox);
        
        
        
%         % Clean and realease any queue that might be opened
%         KbQueueRelease(responseBox);
% 
%         % Create the keyboard queue to collect responses.
%         keysOfInterest = cfg.keytap;
%         KbQueueCreate(responseBox, keysOfInterest);
%         
%         % start listening
%         fprintf('\n starting to listen to keypresses\n')
%         KbQueueStart(responseBox);
%         
    case 'collect'
        
        
%         if verbose
%             fprintf('\n checking recent keypresses\n')
%         end
        
        iEvent = 1;
        
        % % % not sure if this function is working or doing what I want
        while KbEventAvail(responseBox)
            
            event = KbEventGet(responseBox);
        % % %        
            responseEvents(iEvent,1).onset = event.Time;
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