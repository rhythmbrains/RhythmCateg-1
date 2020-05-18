function displayInstr(instrTxt,cfg,varargin)
% varargin:   
% 
%     'setVolume' displays intrTxt and offers possibility for the
%     participant to set the volume 
% 
%     'waitForKeypress' displays intrTxt and waits for keypress to continue
% 
%     'instrAndQuitOption' displays intrTxt and info about experiment
%     termination (quit option)
% 
%      if no varargin provided, the function only displays intrTxt on the screen and returns

Screen('TextFont',cfg.screen.h,cfg.textFont);
Screen('TextSize',cfg.screen.h,cfg.textSize);

%% volume setting  

if any(strcmpi(varargin,'setVolume'))
    
    % put volume-setting audio into buffer
    PsychPortAudio('FillBuffer',cfg.pahandle,cfg.volumeSettingSound); 
    
    % set allowed keys  
    allowedKeys = [cfg.keyAudioPlay, cfg.keyAudioStop, ...
                   cfg.keyVolDown, cfg.keyVolUp, ...
                   cfg.keywait, cfg.keyquit]; 
               
    % wait for participatnt's response          
    while 1
        
        % display instructions in the center of cfg.screen 
        DrawFormattedText(cfg.screen.h,instrTxt,'center','center',cfg.screen.whitecol); 

        % display continue option on the bottom of the screen
        DrawFormattedText(cfg.screen.h,'Press ENTER to continue...','center',cfg.screen.y*0.9,cfg.screen.whitecol); 

        % display quit option in the cfg.screen corner
        txt = sprintf([sprintf('Press ''%s'' to play test sound\n',KbName(cfg.keyAudioPlay)), ...
               sprintf('Press ''%s'' to stop test sound\n',KbName(cfg.keyAudioStop)), ...
               sprintf('Press ''%s'' to increase volume\n',KbName(cfg.keyVolUp)), ...
               sprintf('Press ''%s'' to decrease volume\n',KbName(cfg.keyVolDown)), ...
               sprintf('\nVolume = %d%%\n',round(PsychPortAudio('Volume',cfg.pahandle)*100)), ...
               ]); 
        tbx     = Screen('TextBounds', cfg.screen.h, txt);
        width   = tbx(3);
        height  = tbx(4);
        cfg.screen.screenRect = Screen('Rect', cfg.screen.h);
        r = [0 0 width height + Screen('TextSize', cfg.screen.h)];
        r = AlignRect(r,cfg.screen.screenRect,RectLeft,RectTop);
        [oldX,oldY] = DrawFormattedText(cfg.screen.h, txt, r(RectLeft), r(RectBottom), cfg.screen.whitecol);

        
        % display quit option 
        txt = sprintf('press ''%s'' to quit the whole experiment',KbName(cfg.keyquit)); 
        tbx     = Screen('TextBounds', cfg.screen.h, txt);
        width   = tbx(3);
        height  = tbx(4);
        cfg.screen.screenRect = Screen('Rect', cfg.screen.h);
        r = [0 0 width height + Screen('TextSize', cfg.screen.h)];
        r = AlignRect(r,cfg.screen.screenRect,RectRight,RectTop);
        [oldX,oldY] = DrawFormattedText(cfg.screen.h, txt, r(RectLeft), r(RectBottom), cfg.screen.whitecol);
        
        
        Screen('Flip', cfg.screen.h);      

        % wait for keypress
        keyCodePressed = waitForKeyKbCheck(allowedKeys); 
        
        if ismember(keyCodePressed, cfg.keyAudioPlay)
            PsychPortAudio('Stop',cfg.pahandle); 
            PsychPortAudio('Start',cfg.pahandle); 
            
        elseif ismember(keyCodePressed, cfg.keyAudioStop)
            PsychPortAudio('Stop',cfg.pahandle); 

        elseif ismember(keyCodePressed, cfg.keyVolUp)         
            oldVolume = PsychPortAudio('Volume',cfg.pahandle); 
            newVolume = min(oldVolume+0.05, 1); 
            PsychPortAudio('Volume',cfg.pahandle,newVolume);
            
        elseif ismember(keyCodePressed, cfg.keyVolDown)
            oldVolume = PsychPortAudio('Volume',cfg.pahandle); 
            newVolume = max(oldVolume-0.05, 0); 
            PsychPortAudio('Volume',cfg.pahandle,newVolume);
 
        elseif ismember(keyCodePressed, cfg.keywait)
            PsychPortAudio('Stop',cfg.pahandle); 
            break
            
        elseif ismember(keyCodePressed, cfg.keyquit)
            PsychPortAudio('Stop',cfg.pahandle); 
            warning('experiment terminated by user'); 
            
        end
        
        
    end
    
    
elseif any(strcmpi(varargin,'waitForKeypress'))
    %% display instructions and wait for keypress 
    
    % display instructions in the center of cfg.screen 
    DrawFormattedText(cfg.screen.h,instrTxt,'center','center',cfg.screen.whitecol); 

    % display continue option on the bottom of the screen
    DrawFormattedText(cfg.screen.h,'Press ENTER to continue...','center',cfg.screen.y*0.9,cfg.screen.whitecol); 

    % display quit option 
    txt = sprintf('press ''%s'' to quit the whole experiment',KbName(cfg.keyquit)); 
    tbx     = Screen('TextBounds', cfg.screen.h, txt);
    width   = tbx(3);
    height  = tbx(4);
    cfg.screen.screenRect = Screen('Rect', cfg.screen.h);
    r = [0 0 width height + Screen('TextSize', cfg.screen.h)];
    r = AlignRect(r,cfg.screen.screenRect,RectRight,RectTop);
    [oldX,oldY] = DrawFormattedText(cfg.screen.h, txt, r(RectLeft), r(RectBottom), cfg.screen.whitecol);

    
    Screen('Flip', cfg.screen.h);      
    
    
    % wait for participant's keypress to continue 
    keyCodePressed = waitForKeyKbCheck([cfg.keywait,cfg.keyquit]);  
    
    if ismember(keyCodePressed, cfg.keywait)
        PsychPortAudio('Stop',cfg.pahandle); 
        return
        
    elseif ismember(keyCodePressed, cfg.keyquit)
        PsychPortAudio('Stop',cfg.pahandle); 
        warning('experiment terminated by user'); 

    end

elseif any(strcmpi(varargin,'instrAndQuitOption'))
    %% display instructions and quit option but don't wait
    
    % display instructions in the center of cfg.screen 
    DrawFormattedText(cfg.screen.h,instrTxt,'center','center',cfg.screen.whitecol); 

    % display small-font quit option 
    Screen('TextSize',cfg.screen.h,cfg.textSize*0.7);
    txt = sprintf('(in case of emergency, press ''%s'' to terminate the experiment)',KbName(cfg.keyquit)); 
    tbx     = Screen('TextBounds', cfg.screen.h, txt,[],[],[],[]);
    width   = tbx(3);
    height  = tbx(4);
    cfg.screen.screenRect = Screen('Rect', cfg.screen.h);
    r = [0 0 width height + Screen('TextSize', cfg.screen.h)];
    r = AlignRect(r,cfg.screen.screenRect,RectRight,RectTop);
    [oldX,oldY] = DrawFormattedText(cfg.screen.h, txt, r(RectLeft), r(RectBottom), cfg.screen.whitecol);    
    Screen('TextSize',cfg.screen.h,cfg.textSize);
    
    Screen('Flip',cfg.screen.h); 
    
    
    
else
    %% display instructions 
    
    % display instructions in the center of cfg.screen 
    DrawFormattedText(cfg.screen.h,instrTxt,'center','center',cfg.screen.whitecol); 

    Screen('Flip',cfg.screen.h); 
    
end





