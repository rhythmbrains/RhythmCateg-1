function cfg = initPTB(cfg)


% check for octave:
if IsOctave
    checkOctave()
end


% check for OpenGL compatibility, abort otherwise:
AssertOpenGL;


%%
    PsychJavaTrouble;

    
    
    KbName('UnifyKeyNames');
    cfg.keywait         = KbName({'RETURN'}); % press enter to start bloc
    cfg.keyToggleInstr  = KbName({'I'}); % press I to show/remove general instructions from the screen
    cfg.keyquit         = KbName('ESCAPE'); % press ESCAPE at response time to quit 
    cfg.keytap          = KbName('SPACE'); 
    cfg.keyVolUp        = KbName('UpArrow'); 
    cfg.keyVolDown      = KbName('DownArrow'); 
    cfg.keyAudioPlay    = KbName('p'); 
    cfg.keyAudioStop    = KbName('s'); 
    cfg.keyInstrBack    = KbName('b'); 
    cfg.keyInstrNext    = KbName('n'); 

    
    % Don't echo keypresses to Matlab window
    % enable listening & additional keypress will be suppressed in command window
    % use CTRL+C to reenable keyboard input when necessary
    ListenChar(-1); 

    
    
    %% mouse
    % Hide the mouse cursor:
    HideCursor;
    
    %% init Visual
    
    cfg.screen              = [];
    cfg.screen.i            = max(Screen('Screens'));
    cfg.screen.res          = Screen('Resolution',cfg.screen.i);
    cfg.screen.graycol      = GrayIndex(cfg.screen.i);
    cfg.screen.whitecol     = WhiteIndex(cfg.screen.i);
    

    % init PTB with different options in concordance to the Debug Parameters
    if cfg.debug
        
        % set to one because we don not care about time
        Screen('Preference', 'SkipSyncTests', 2);
        Screen('Preference', 'Verbosity', 0);
        Screen('Preferences', 'SuppressAllWarnings', 2);

        if cfg.testingTranspScreen
            PsychDebugWindowConfiguration
            Screen('Preference', 'SkipSyncTests', 1);
        end
        
        cfg.screen.h = Screen('OpenWindow',cfg.screen.i,cfg.screen.graycol);
            
        
        
    else       
       % we do not need high accuracy for the screen atm
       % Screen('Preference', 'SkipSyncTests', 0); 
        Screen('Preference', 'SkipSyncTests', 1); 
        cfg.screen.h = Screen('OpenWindow',cfg.screen.i,cfg.screen.graycol);
        
    end
    
    
    
    [cfg.screen.x,cfg.screen.y] = Screen('WindowSize',cfg.screen.h);
    
    % Enable alpha-blending, set it to a blend equation useable for linear
    % superposition with alpha-weighted source.
    Screen('BlendFunction',cfg.screen.h,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    
   
    %% Timing 
    % Set priority for script execution to realtime priority:
    Priority(MaxPriority(cfg.screen.h));
    
    %% text 
    % Select specific text font, style and size:
    cfg.textSize = 30; 
    cfg.textFont = 'Arial'; 
    
    Screen('TextFont',cfg.screen.h,cfg.textFont);
    Screen('TextSize',cfg.screen.h,cfg.textSize);
       
    

    
    
    %% init Audio


    InitializePsychSound(1);
    
    % CHANNELS is 1 for mono sound or 2 for stereo sound
    cfg.audio.channels = 2;
    
    if any(strcmp(cfg.stimComp,{'mac','linux'}))
        
                
        % pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq] ...
            %       [, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
        % cfg.pahandle = PsychPortAudio('Open', [], [], 3, cfg.fs, cfg.audio.channels);
        % change the latency to:
        % Try to get the lowest latency that is possible under the constraint of reliable playback
        cfg.pahandle = PsychPortAudio('Open', [], [], 3, cfg.fs, cfg.audio.channels);

        
    else
                
        % get audio device list
        audio_dev       = PsychPortAudio('GetDevices');
        
        % find output device using WASAPI deiver
        idx             = find([audio_dev.NrInputChannels] == 0 & ...
                               [audio_dev.NrOutputChannels] == 2 & ...
                               ~cellfun(@isempty, regexp({audio_dev.HostAudioAPIName},'WASAPI')));
        
        % save device ID
        cfg.audio.i     = audio_dev(idx).DeviceIndex;
        
        % get device's sampling rate
        cfg.fs          = audio_dev(idx).DefaultSampleRate;
        
        % the latency is not important - but consistent latency is! Let's try with WASAPI driver. 
        cfg.pahandle    = PsychPortAudio('Open', cfg.audio.i, 1, 3, cfg.fs, cfg.audio.channels);
        % cfg.pahandle = PsychPortAudio('Open', [], [], 0, cfg.fs, cfg.audio.channels);

    end
    
    % set initial PTB volume for safety (participants can adjust this manually
    % at the begining of the experiment)
    PsychPortAudio('Volume', cfg.pahandle, cfg.PTBInitVolume); 
    
    cfg.audio.pushsize  = cfg.fs*0.010; %! push N ms only
    cfg.requestoffsettime = 1; % offset 1 sec
    cfg.reqsampleoffset = cfg.requestoffsettime*cfg.fs; %
    
    
    % playing parameters
    
    % sound repetition
    cfg.PTBrepet = 1;
    
    % Start immediately (0 = immediately)
    cfg.PTBstartCue = 0;
    
    % Should we wait for the device to really start (1 = yes)
    cfg.PTBwaitForDevice = 1;
    

end

    %% init keyboard
    % % %
    % set in getParams instead
    % can be called from cfg structure to make actual names
    
%      % Check the state of the keyboard.
%     [ keyIsDown, seconds, keyCode ] = KbCheck;
% 
%     % If the user is pressing a key, then display its code number and name.
%     if keyIsDown
% 
%         % Note that we use find(keyCode) because keyCode is an array.
%         % See 'help KbCheck'
%         fprintf('You pressed key %i which is %s\n', find(keyCode), KbName(keyCode));
% 
%         if keyCode(escapeKey)
%             break;
%         end
%         
%         % If the user holds down a key, KbCheck will report multiple events.
%         % To condense multiple 'keyDown' events into a single event, we wait until all
%         % keys have been released.
%         KbReleaseWait;
%     end
    