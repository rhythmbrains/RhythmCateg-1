% 
% 
% TO DO: 
%     - pattern: pure tone, beat: bass, fast-grid: hihat? 
%     - make feedback nicer on the screen
%     - PTB latency test? (but audio capture device may be late anyway so no
%       point in doing this...)
%     - data logging 
%     - test on Windows

% notes from Cer's trials

% 000. Add to instructions: before the instructions they should set the 
% level into comfortable
% level so they can/might block the tapping space keyboard sound. 
% be in a quite place 
% % add this info into instructions: DELETE should work - we have it in the script

% 0.1. The screen info does not go away after the first stage 
% (where it says "congratulations") is done 
% also maybe it's either good to inform people to read the screen or insert
% a beep tone indiating it's ended.

% 2. considering people like me, a.k.a. negative controls (Gil did it in 
% 4min, I couldn't finish, maybe it's better to divide it into blocks
% intead of looping through infinite times. Hence, I'd use for loop instead
% of while loop
% >> break after certain count number// time out // 

% 3. What I meant by creating a word doc is to write down how the code
% calcualtes the error // what's the timing parameter // "what the computer
% does"

% 5. Let?s check the complexity
% checkcode('tapTrainer_PTB.m', '-cyc')




%% low importance stuff:
% PascalCase ? Which is also common in PTB ? 
% be consisted across the code- including the variables)

% Notes from Remi on how to code better:

% ?
% Structure
% Try to minimize the number of files you need to touch to change the 
% behavior of your code.

% Have a separate file where you set all your experiment / analysis 
% parameters and load that.?

% Have all the other function except the main script into a separate folder.?

% Then there is the "refactoring" issue.?
% Avoid copy-pasta or this might lead to?spaghetti code?
% - if you are copy-pasting some code inside or across a function/script: STOP. 
% Turn it into a function: it takes one more minute but it will save you 
% hours in the long run. This should almost become a conditioned reflex.
% - if you are copying a function between projects, seriously consider 
% creating a library of functions that you can easily add to projects.


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
PsychPortAudio('Close');


tic

% paths
addpath('lib')

% parameters
cfg = getParams(); 




try

    PsychJavaTrouble;
    PsychDebugWindowConfiguration
    Screen('Preference', 'SkipSyncTests', 1);
    
    % Keyboard
    KbName('UnifyKeyNames');
    keywait     = KbName({'RETURN'}); % press enter to start bloc
    keyquit     = KbName('DELETE'); % press ESCAPE at response time to quit 
    keytap     = KbName('SPACE'); 

    HideCursor;
    FlushEvents;
    ListenChar(2); % enable listening & additional keypress will be suppressed in command window
    % use CTRL+C to reenable keyboard input when necessary
    
    
    % could be made a function 
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
       
    

    
    %could be made a function? not maybe.
    % at this tage it's slightly confusing to read. //audio.h //audio.i//
    % channel = 2; makes it easier to read
    % also we are not changing frequency 
    % consider below:
    % dev_n_channels = 2;
    % pahandle = PsychPortAudio('Open', [], [], 3, freq, dev_n_channels);
    
    % initiate sound
    InitializePsychSound(1);
    audio_dev       = PsychPortAudio('GetDevices');
    idx             = find([audio_dev.NrInputChannels] == 0 & [audio_dev.NrOutputChannels] == 2); 
    audio           = [];
    audio.i         = audio_dev(idx).DeviceIndex;
    cfg.fs          = audio_dev(idx).DefaultSampleRate;
    audio.h         = PsychPortAudio('Open',audio.i,1,1,cfg.fs,2);
    audio.pushsize  = cfg.fs*0.010; %! push N ms only
    
    
    requestoffsettime = 1; % offset 1 sec
    reqsampleoffset = requestoffsettime*cfg.fs; %
    

    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % instructions   
    % what to press to quit
    % bigger font - be careful with the screensize
    % etc..
    
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
    
    % simultenaous feedback 
    % fbk_on_screen               = false; 
    
    curr_pattern_level          = 1; 
   
    % pattern has 12 events
    % metromnome interval is 4 event
    
    
    % loop over patterns (atm, n pattern = 2)
    while 1
        
        % once the pattern is repeated 4 times, the script looks back in
        % this time window, and in the next "step" ...
        curr_step                   = 1; 
        
        % dB changes in the loop - tapping cue (decreases over time if the
        % error rate is low(er))
        % which dB sound will be played choose the index in the list
        curr_cue_dB_level    = 1; 
        
        %number of grip points between two tapping cue sounds
        %convert the grip interval to target inter-tap-interval in seconds.
        % every 800ms there'll be a cue sound to tap along
        curr_metronome_interval     = cfg.period_metronome(curr_pattern_level)*cfg.grid_interval;
        
        % atm, total duration of the pattern window (4 x pattern)
        curr_step_dur               = cfg.n_cycles_per_step * length(cfg.patterns{curr_pattern_level}) * cfg.grid_interval; 
        
        % to calculate the max #taps
        curr_taketap_dur            = curr_step_dur - 0.200; 
        
        %to be used later on to calculate the min number that participant
        %has to tap - 
        tap_max_n_taps = floor(curr_taketap_dur/curr_metronome_interval);
        % to calculate 70% of this max taps
        tap_min_n_taps = floor(tap_max_n_taps*cfg.min_n_taps_prop); 
        
        
        % counters for calculating the tapping accuracy later on
        tap_perform_status = 0; % if good +1, if bad -1
        tap_maxlevel_c = 1; % how many consecutive steps have I been in maxlevel? 
        taps = []; 
        istap = false;

        
        % get audio for the first step/window (4 x pattern)
        [seq] = makeStim(cfg, curr_pattern_level, ...
                         'snr_metronome', cfg.snr_metronome(curr_cue_dB_level));

        % first, fill the buffer with 60s silence
        

        % to get a buffer longer than what you are pushing
        % allocate the buffer
        
        % if case some stays too long in the while loop, we will need this
        % buffer to allocate
        PsychPortAudio('FillBuffer', audio.h, zeros(2, 60*cfg.fs)); 
        
        
        
        
        
        % start playback (note: set repetitions=0, otherwise it will not allow you to seamlessly push more data into the buffer once the sound is playing)  
        % starts to play whats in the buffer and play on whatever is in on
        % a seamlessly in the loop
        start_time = PsychPortAudio('Start', audio.h, 0, [], 1); 
        % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
        
        % ceren can try with 1 sound input into two channels
        audio2push = [seq.s;seq.s]; 

        
        %silence is going, then we will upload to the buffer audio sequence after the
        % 1s of silent has started
        [underflow] = PsychPortAudio('FillBuffer', audio.h, audio2push, 1, reqsampleoffset);

        % and update start time (by offset)
        % start time = actual time of audio seq presented
        start_time = start_time+requestoffsettime; 
        curr_step_start_time = start_time; 
       % audio2push = []; 
        nsamples_audio2push = 0; 
        idx2push = 1; 

        
        % loop over pattern windows in which we change the dB levels atm
        while 1
            
            % tapping while loop
            while GetSecs < (curr_step_start_time+curr_taketap_dur)

                % collect tapping 
                [~,secs,key_code] = KbCheck(-1);
                if find(key_code)==keyquit
                    
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

            %let's look at the last window to analyse the tapping
            % evaluate tapping and decide on the next step/window parameters
            %look at which window you are in (curr_step_
            % taps you will consider : step_dur
            min_taketap_time = (curr_step-1)*curr_step_dur; 
            max_taketap_time = (curr_step)*curr_step_dur;
            
            % we will only take the taps which are relevant - in our
            % current window
            %test test 
            %curr_taps = [0:0.8:6.2] + randn(1,8)*0.1
            curr_taps = taps(taps>min_taketap_time & taps<max_taketap_time) - min_taketap_time; 
            
            %making tapping vector
            disp(curr_taps')
            curr_n_taps = length(curr_taps); 


            % round to the closest beat position
            % there are target positions set by the cue. But they can skip
            % a tap and still be good in synch. round the mto the closest
            % beat positions. that will give you the target position. and
            % you calculate the how far your target + your current taps
            target_pos = round(curr_taps/curr_metronome_interval)*curr_metronome_interval; 

            % calculate asynchronies
            tap_asynch = curr_taps - target_pos; 
            %first normalise it by the interval. because your variability
            %is proportional to the legnth of the interval (equalise across
            %different time interval/tempi)
            %then std it 
            tap_cv_asynch = std(tap_asynch/curr_metronome_interval); 
            
            

            % update tapping performance (wrt cvASY threshold and n-taps)
            % tap_perform_status = -1, 0, 1, 2, 3, ...(correctness)
            if (tap_cv_asynch < cfg.tap_cv_asynch_thr) && curr_n_taps>=tap_min_n_taps
                % good performance, one up!
                tap_perform_status = max(0,tap_perform_status); % if negative make 0
                tap_perform_status = tap_perform_status+1; 
            else
                % bad performance, one down...
                tap_perform_status = min(0,tap_perform_status); % if positive make 0
                tap_perform_status = tap_perform_status-1; 
            end

            
            
            % ---- update next step parameters ----
            % staircase here to adapt
            
            % if last N steps were good (N == n_steps_up) -> increase level
            if tap_perform_status >= cfg.n_steps_up 
                % update counters
                tap_perform_status = 0; 
                curr_cue_dB_level = min(curr_cue_dB_level+1,cfg.max_snr_level); 
                
                
                % If this will be the the last level, add to the last-level
                % counter (n_max_levels; this can be different to regular
                % n_steps_up parameter)
                if curr_cue_dB_level==cfg.max_snr_level
                    tap_maxlevel_c = tap_maxlevel_c+1;
                    
                    if tap_maxlevel_c>=cfg.n_max_levels
                        PsychPortAudio('Stop',audio.h,1);
                        break 
                    end
                    txt = [sprintf('Your error was = %.3f\n\n',tap_cv_asynch), ...
                           sprintf('You are in level %d out of %d.\n\n',curr_cue_dB_level,cfg.max_snr_level), ...
                           'This is the last level! \n\nI believe in you!']; 
                    displayInstr(txt,screen);
                % Otherwise, give positive feedback above the level-up. 
                else                
                    txt = [sprintf('your error was = %.3f\n\n',tap_cv_asynch), ...
                           sprintf('You are in level %d out of %d.\n\n',curr_cue_dB_level,cfg.max_snr_level), ...
                           'Well done, level up! \n\nKeep going!']; 
                    displayInstr(txt,screen);
                end
                
            % if last N steps were bad (N == n_steps_down) -> decrease level
            elseif tap_perform_status <= -cfg.n_steps_down
                % update counters
                tap_perform_status = 0; 
                tap_maxlevel_c = 1; 
                curr_cue_dB_level = max(curr_cue_dB_level-1, 1); 
                % give feedback
                txt = [sprintf('your error was = %.3f\n\n',tap_cv_asynch), ...
                       sprintf('You are in level %d out of %d.\n\n',curr_cue_dB_level,cfg.max_snr_level), ...
                       'Sorry, that was not good enough.\n Maybe let''s try one level below again? \n\nYou can do it!']; 
                displayInstr(txt,screen);
                
            % otherwise just give feedback and continue...
            else
                txt = [sprintf('Your error was = %.3f\n\n',tap_cv_asynch), ...
                       sprintf('You are in level %d out of %d.\n\n',curr_cue_dB_level,cfg.max_snr_level)]; 
                displayInstr(txt,screen);
            end
            
            fprintf('current metronome-SNR level = %d\n',curr_cue_dB_level); 

            
            
            % create audio with the new dB level for the next step/window
        [seq] = makeStim(cfg, curr_pattern_level, ...
                         'snr_metronome', cfg.snr_metronome(curr_cue_dB_level));

            audio2push = [seq.s;seq.s];   
            %update the push variable
            nsamples_audio2push = size(audio2push,2); 
            idx2push = 1; 


            % update step counter
            curr_step = curr_step+1; 

        end

        
        curr_pattern_level = curr_pattern_level+1; 
        
        
        % %%%%%%%%%%%% THIS CAN BE OUT OF THE LOOP %%%%%%%%%%%%%%%%%%%%%
        % instructions   
        if curr_pattern_level>cfg.max_pattern_level
            displayInstr('DONE. \n\n\nTHANK YOU FOR PARTICIPATING :)',screen,keywait);  
            break
        else
            txt = sprintf('CONGRATULATIONS!\n\nYou finished this level.\n\nWhen ready to try something more difficult, press ENTER.\n\nThe new rhythm will start.\nSame instructions as before.\n\nGood luck, tapping ninja!\n\n'); 
            displayInstr(txt,screen,keywait);     
        end        
        
    
    end


    
    
    
    
    
    
    
    
    
catch err
    
    PsychPortAudio('Stop',audio.h,1);
    PsychPortAudio('Close',audio.h)
    sca
    ListenChar(0); 
    
    rethrow(err)
end
    


sca
ListenChar(0); 
PsychPortAudio('Close',audio.h)
   
%take the last time
expTime = toc;

%% print the duration of the exp
% fprintf('\nTRAINING IS OVER!!\n');
% fprintf('\n==================\n\n');

% fprintf('\nyou have tested %d trials for STATIC and %d trials for MOTION conditions\n\n', ...
%     (numEvents-numTargets)/2, (numEvents-numTargets)/2);

fprintf('\nexp. duration was %f minutes\n\n', expTime/60);

