% 
% 
% TO DO: 
%     - pattern: pure tone, beat: bass, fast-grid: hihat? 
%     - make feedback nicer on the screen
%     - PTB latency test? (but audio capture device may be late anyway so no
%       point in doing this...)
%     - data logging 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all



% paths
addpath('lib')

% parameters
cfg = getParams(); 




try

    % PsychJavaTrouble;
    PsychDebugWindowConfiguration
    Screen('Preference', 'SkipSyncTests', 1);
    
    % Keyboard
    KbName('UnifyKeyNames');
    keywait     = KbName({'ENTER','RETURN'}); % press space to start bloc
    keyquit     = KbName('DELETE'); % press ESCAPE at response time to quit
    keyrtap     = KbName('SPACE'); 

    HideCursor;
    FlushEvents;
    ListenChar(2);
    
    % initiate screen
    screen              = [];
    screen.i            = max(Screen('Screens'));
    screen.res          = Screen('Resolution',screen.i);    
    screen.graycol      = GrayIndex(screen.i);
    screen.whitecol     = WhiteIndex(screen.i);
    screen.h            = Screen('OpenWindow',screen.i,screen.graycol);    
    [screen.x,screen.y] = Screen('WindowSize',screen.h);
    Screen('BlendFunction',screen.h,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    Priority(MaxPriority(screen.h));
    Screen('TextFont',screen.h,'Arial');
    Screen('TextSize',screen.h,round(screen.res.width/100));
       
    % initiate sound
    InitializePsychSound(1);
    audio_dev       = PsychPortAudio('GetDevices');
    idx             = find([audio_dev.NrInputChannels] == 0 & [audio_dev.NrOutputChannels] == 2); 
    audio           = [];
    audio.i         = audio_dev(idx).DeviceIndex;
    cfg.fs          = audio_dev(idx).DefaultSampleRate;
    audio.h         = PsychPortAudio('Open',audio.i,1,1,cfg.fs,2);
    audio.pushsize  = cfg.fs*0.010; %! push N ms only
    
    
    % instructions   
    txt = ['Welcome!\n\n', ...
           'You will hear a repeated rhythm played by a "click sound".\n', ...
           'There will also be a "bass sound", playing a regular pulse.\n\n', ...
           'Tap in synchrony with the bass sound on SPACEBAR.\n', ...
           'If your tapping is precise, the bass sound will get softer and softer.\n', ...
           'Eventually (if you are tapping well), the bass sound will disappear.\n', ...
           'Keep your internal pulse as the bass drum fades out.\n', ... 
           'Keep tapping at the positions where the bass drum was before...\n\n\n', ...
           'Good luck!\n\n']; 
    displayInstr(txt,screen,keywait);     
    
    
    
    
    
    %%%============ TRAINING LOOP ============%%%
    displayInstr('TAP',screen);     
    fbk_on_screen               = false; 
    curr_pattern_level          = 1; 
    
    
    % loop over patterns
    while 1
        

        curr_step                   = 1; 
        curr_metronome_snr_level    = 1; 
        curr_metronome_interval     = cfg.period_metronome(curr_pattern_level)*cfg.grid_interval; 
        curr_step_dur               = cfg.n_cycles_per_step * length(cfg.patterns{curr_pattern_level}) * cfg.grid_interval; 
        curr_taketap_dur            = (cfg.n_cycles_per_step * length(cfg.patterns{curr_pattern_level}) * cfg.grid_interval) - 0.200; 

        tap_max_n_taps = floor(curr_taketap_dur/curr_metronome_interval); 
        tap_min_n_taps = floor(tap_max_n_taps*cfg.min_n_taps_prop); 
        tap_perform_status = 0; % if good +1, if bad -1
        tap_maxlevel_c = 1; % how many consecutive steps have I been in maxlevel? 
        taps = []; 
        istap = false;

        % get audio for the first step
        [seq] = makeStim(cfg, curr_pattern_level, ...
                         'snr_metronome', cfg.snr_metronome(curr_metronome_snr_level));

        % first, fill the buffer with 60s silence
        PsychPortAudio('FillBuffer', audio.h, zeros(2, 60*cfg.fs)); 
        
        % start playback (note: set repetitions=0, otherwise it will not allow you to seamlessly push more data into the buffer once the sound is playing)  
        start_time = PsychPortAudio('Start', audio.h, 0, [], 1); % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);

        % now, fill buffer with audio
        audio2push = [seq.s;seq.s]; 
        requestoffsettime = 1; % offset 1 sec
        reqsampleoffset = requestoffsettime*cfg.fs; %
        [underflow] = PsychPortAudio('FillBuffer', audio.h, audio2push, 1, reqsampleoffset);

        % and update start time (by offset)
        start_time = start_time+requestoffsettime; 
        curr_step_start_time = start_time; 
        audio2push = []; 
        nsamples_audio2push = 0; 
        idx2push = 1; 

        
        % loop over metronome SNR levels
        while 1

            while GetSecs < (curr_step_start_time+curr_taketap_dur)

                % collect tapping 
                [~,secs,key_code] = KbCheck(-1);
                if find(key_code)==keyquit
                    aborted = true;
                    break
                end
                if ~istap & any(key_code)
                    taps = [taps,secs-start_time];
                    istap = true;
                end
                if istap & ~any(key_code)
                    istap = false;
                end

                % if there is any audio waiting to be pushed, push it to the buffer!
                if nsamples_audio2push
                    if idx2push+audio.pushsize > nsamples_audio2push
                        pushdata = audio2push(:,idx2push:end);
                        nsamples_audio2push = 0; 
                    else
                        pushdata = audio2push(:,idx2push:idx2push+audio.pushsize-1);
                        idx2push = idx2push+audio.pushsize;
                    end
                    [curunderflow, ~, ~] = PsychPortAudio('FillBuffer', audio.h, pushdata, 1);
                end

%                 % if there is overdue feedback on the screen, remove it
%                 if fbk_on_screen
%                     if feedback_on_screen_time>cfg.fbk_on_sceen_maxtime
%                         displayInstr('TAP',screen);   
%                         fbk_on_screen = false; 
%                     else
%                         feedback_on_screen_time = feedback_on_screen_time+
%                     end
%                 end       
                
            end      


            % Update current time! 
            % All wait-times in the loop are based on this!
            curr_step_start_time = curr_step_start_time + curr_step_dur; 


            % evaluate tapping and decide on the next step parameters
            min_taketap_time = (curr_step-1)*curr_step_dur; 
            max_taketap_time = (curr_step)*curr_step_dur; 
            curr_taps = taps(taps>min_taketap_time & taps<max_taketap_time) - min_taketap_time; 
            disp(curr_taps')
            curr_n_taps = length(curr_taps); 

            % round to the closest beat position
            target_pos = round(curr_taps/curr_metronome_interval)*curr_metronome_interval; 

            % calculate asynchronies
            tap_asynch = curr_taps - target_pos; 
            tap_cv_asynch = std(tap_asynch)/curr_metronome_interval; 

            % update tpaping performance (wrt cvASY threshold and n-taps)
            if (tap_cv_asynch < cfg.tap_cv_asynch_thr) & curr_n_taps>=tap_min_n_taps
                % good performance, one up!
                tap_perform_status = max(0,tap_perform_status); % if negative make 0
                tap_perform_status = tap_perform_status+1; 
            else
                % bad performance, one down...
                tap_perform_status = min(0,tap_perform_status); % if positive make 0
                tap_perform_status = tap_perform_status-1; 
            end

            
            
            % ---- update next step parameters ----
            
            % if last N steps were good (N == n_steps_up) -> increase level
            if tap_perform_status >= cfg.n_steps_up 
                % update counters
                tap_perform_status = 0; 
                curr_metronome_snr_level = min(curr_metronome_snr_level+1,cfg.max_snr_level); 
                % If this will be the the last level, add to the last-level
                % counter (n_max_levels; this can be different to regular
                % n_steps_up parameter)
                if curr_metronome_snr_level>=cfg.max_snr_level
                    tap_maxlevel_c = tap_maxlevel_c+1; 
                    if tap_maxlevel_c>=cfg.n_max_levels
                        PsychPortAudio('Stop',audio.h,1);
                        break 
                    end
                    txt = [sprintf('Your error was = %.3f\n\n',tap_cv_asynch), ...
                           sprintf('You are in level %d out of %d.\n\n',curr_metronome_snr_level,cfg.max_snr_level), ...
                           'This is the last level! \n\nI believe in you!']; 
                    displayInstr(txt,screen);
                % Otherwise, give positive feedback above the level-up. 
                else                
                    txt = [sprintf('your error was = %.3f\n\n',tap_cv_asynch), ...
                           sprintf('You are in level %d out of %d.\n\n',curr_metronome_snr_level,cfg.max_snr_level), ...
                           'Well done, level up! \n\nKeep going!']; 
                    displayInstr(txt,screen);
                end
                
            % if last N steps were bad (N == n_steps_down) -> decrease level
            elseif tap_perform_status <= -cfg.n_steps_down
                % update counters
                tap_perform_status = 0; 
                tap_maxlevel_c = 1; 
                curr_metronome_snr_level = max(curr_metronome_snr_level-1, 1); 
                % give feedback
                txt = [sprintf('your error was = %.3f\n\n',tap_cv_asynch), ...
                       sprintf('You are in level %d out of %d.\n\n',curr_metronome_snr_level,cfg.max_snr_level), ...
                       'Sorry, that was not good enough.\n Maybe let''s try one level below again? \n\nYou can do it!']; 
                displayInstr(txt,screen);
                
            % otherwise just give feedback and continue...
            else
                txt = [sprintf('Your error was = %.3f\n\n',tap_cv_asynch), ...
                       sprintf('You are in level %d out of %d.\n\n',curr_metronome_snr_level,cfg.max_snr_level)]; 
                displayInstr(txt,screen);
            end
            
            fprintf('current metronome-SNR level = %d\n',curr_metronome_snr_level); 

            
            
            % create audio for the next step
        [seq] = makeStim(cfg, curr_pattern_level, ...
                         'snr_metronome', cfg.snr_metronome(curr_metronome_snr_level));

            audio2push = [seq.s;seq.s];       
            nsamples_audio2push = size(audio2push,2); 
            idx2push = 1; 


            % update step counter
            curr_step = curr_step+1; 

        end

        
        curr_pattern_level = curr_pattern_level+1; 
        
        
        % instructions   
        if curr_pattern_level>cfg.max_pattern_level
            displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)',screen,keywait);  
            break
        else
            txt = sprintf('CONGRATULATIONS!\n\nYou finished this level.\n\nWhen ready to try something more difficult, press ENTER.\n\nThe new rhythm will start.\nSame instructions as before.\n\nGood luck, tapping ninja!\n\n'); 
            displayInstr(txt,screen,keywait);     
        end        
        
    
    end


    
    
    
    
    
    
    
    
    
catch e
    
    PsychPortAudio('Stop',audio.h,1);
    PsychPortAudio('Close',audio.h)
    sca
    ListenChar(0); 
    
    rethrow(e)
end
    


sca
ListenChar(0); 
PsychPortAudio('Close',audio.h)
   


