
function cfg = initPTB(cfg)

    PsychJavaTrouble;
    
    
    
    %% init keyboard
    
    KbName('UnifyKeyNames');
    cfg.keywait     = KbName({'RETURN'}); % press enter to start bloc
    cfg.keyquit     = KbName('DELETE'); % press ESCAPE at response time to quit 
    cfg.keytap     = KbName('SPACE'); 


    FlushEvents;
    
    % Don't echo keypresses to Matlab window
    % enable listening & additional keypress will be suppressed in command window
    % use CTRL+C to reenable keyboard input when necessary
    ListenChar(2); 
    
    
    %% mouse
    % Hide the mouse cursor:
    HideCursor;
    
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
        
        %     % set to one because we don not care about time
        %     Screen('Preference', 'SkipSyncTests', 2);
        %     Screen('Preference', 'Verbosity', 0);
        %     Screen('Preferences', 'SuppressAllWarnings', 2);

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
    Screen('TextFont',cfg.screen.h,'Arial');
    Screen('TextSize',cfg.screen.h,round(cfg.screen.res.width/100));
       
    

    
    
    %% init Audio


    InitializePsychSound(1);
    
    if strcmp(cfg.device, 'mac')
        
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
        cfg.pahandle    = PsychPortAudio('Open',cfg.audio.i,1,1,cfg.fs,cfg.audio.channels);
    end
    
    
    cfg.audio.pushsize  = cfg.fs*0.010; %! push N ms only
    cfg.requestoffsettime = 1; % offset 1 sec
    cfg.reqsampleoffset = cfg.requestoffsettime*cfg.fs; %
    
    
    
    %% setup volume 
    
    % adapt this part
    % sound wav file hasn't defined in the main exp script!
    % you can add test sound (== cue sound?) to adjust the volume
    
    
%     cfg.sound_vol = PTB_volGUI_RME(...
%         'pahandle', cfg.pahandle,...
%         'sound', sound,...
%         'nchan', cfg.audio.channels);

        
    
    
 
    
end
    