
function cfg = initPTB(cfg)

    PsychJavaTrouble;
    
    
    
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
    
    
    
    % % %
    
    
    KbName('UnifyKeyNames');
    cfg.keywait         = KbName({'RETURN'}); % press enter to start bloc
    cfg.keyquit         = KbName('ESCAPE'); % press ESCAPE at response time to quit 
    cfg.keytap          = KbName('SPACE'); 
    cfg.keyVolUp        = KbName('UpArrow'); 
    cfg.keyVolDown      = KbName('DownArrow'); 
    cfg.keyAudioPlay    = KbName('p'); 
    cfg.keyAudioStop    = KbName('s'); 


    % now I'm using flush in getTapping.m script, so I'm going to delete
    % this
    % FlushEvents;
    
    % Don't echo keypresses to Matlab window
    % enable listening & additional keypress will be suppressed in command window
    % use CTRL+C to reenable keyboard input when necessary
    if cfg.debug
        ListenChar(0);
    else
        ListenChar(2); 
    end
    
    
    %% mouse
    % Hide the mouse cursor:
  %  HideCursor;
    
    %% init Visual
    
    %PsychDebugWindowConfiguration
    %Screen('Preference', 'SkipSyncTests', 1);
    
    cfg.screen              = [];
    cfg.screen.i            = max(Screen('Screens'));
    cfg.screen.res          = Screen('Resolution',cfg.screen.i);
    cfg.screen.graycol      = GrayIndex(cfg.screen.i);
    cfg.screen.whitecol     = WhiteIndex(cfg.screen.i);
    

    % init PTB with different options in concordance to the Debug Parameters
    if cfg.debug
        
%             % set to one because we don not care about time
%             Screen('Preference', 'SkipSyncTests', 2);
%             Screen('Preference', 'Verbosity', 0);
%             Screen('Preferences', 'SuppressAllWarnings', 2);

        if cfg.testingTranspScreen
            PsychDebugWindowConfiguration
            Screen('Preference', 'SkipSyncTests', 1);
            cfg.screen.h = Screen('OpenWindow',cfg.screen.i,cfg.screen.graycol);
            
        end
        
        
    else
        Screen('Preference', 'SkipSyncTests', 0);
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
    
    if strcmp(cfg.device, 'mac')
        
        % CHANNELS is 1 for mono sound or 2 for stereo sound
        cfg.audio.channels = 2;
        
        % pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq] ...
            %       [, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
        cfg.pahandle = PsychPortAudio('Open', [], [], 3, cfg.fs, cfg.audio.channels);
        
    else
        
        audio_dev       = PsychPortAudio('GetDevices');
        idx             = find([audio_dev.NrInputChannels] == 0 & [audio_dev.NrOutputChannels] == 2);
        cfg.audio       = [];
        cfg.audio.i     = audio_dev(idx).DeviceIndex;
        cfg.fs          = audio_dev(idx).DefaultSampleRate;
        cfg.audio.channels = audio_dev.NrOutputChannels;
        %cfg.audio.channels = 1; % we have mono sound actually
        cfg.pahandle    = PsychPortAudio('Open',cfg.audio.i,1,1,cfg.fs,cfg.audio.channels);
    end
    
    
    cfg.audio.pushsize  = cfg.fs*0.010; %! push N ms only
    cfg.requestoffsettime = 1; % offset 1 sec
    cfg.reqsampleoffset = cfg.requestoffsettime*cfg.fs; %
    
    
    %% playing parameters
    
    % sound repetition
    cfg.PTBrepet = 1;
    
    % Start immediately (0 = immediately)
    cfg.PTBstartCue = 0;
    
    % Should we wait for the device to really start (1 = yes)
    cfg.PTBwaitForDevice = 1;
    
    %% setup volume 
    
    % adapt this part
    % sound wav file hasn't defined in the main exp script!
    % you can add test sound (== cue sound?) to adjust the volume
    
    
%     cfg.sound_vol = PTB_volGUI_RME(...
%         'pahandle', cfg.pahandle,...
%         'sound', sound,...
%         'nchan', cfg.audio.channels);

        
    
    
 
    
end
    