function [cfg,expParameters] = getParams()

% Initialize the parameters variables
% Initialize the general configuration variables
cfg = struct; 
expParameters = struct;

% % % THINK using this function tapping + main exp
expParameters.task = 'tapTraining';
% % %


%% Debug mode settings
cfg.debug               = true;  % To test the script out of the scanner, skip PTB sync

%% other parameters
% sampling rate
cfg.fs                  = 44100; 

% two pattersn to be played - will be tried from the first to the last
% rhythmic patterns (from simplest to most difficult)
cfg.patterns            = {[1 1 1 0 1 1 1 0 1 1 0 0 ],
                           [1 1 1 1 0 1 1 1 0 0 1 0 ]}; 
                       
% number of patterns
cfg.max_pattern_level   = length(cfg.patterns);   

% tapping cue sounds (metronome)
cfg.period_metronome    = [4,4]; % each pattern needs a metronome period assigned (units: N-grid-ticks)

% decreasing the DB along with the high accuracy of tapping 
cfg.snr_metronome       = [0, -14, -25, -Inf]; % SNRs between rhythm and metronome audio (to be used across levels)

% to calculate how many levels there : the exp will have 4 
% levels with different difficulty (a.k.a dB)
cfg.max_snr_level       = length(cfg.snr_metronome); % number of SNR-levels

% number of pattern cycles in each step/window of pattern: how many cycles
% of the pattern will be repeated
cfg.n_cycles_per_step   = 4; 

% time-interval of one grid-tick (IOI between events)
% it's not the duration of the sound. 
cfg.grid_interval       = 0.200; 

% threshold for coefficient of variation (cv) of tap-beat asynchronies (defines good/bad tapping performance in each step)
% the taps to be registered as correct "it" should be below the threshold
% within the 4 cycle of pattern representation the error is calculated and 
% this is the shift of tapping variation should be in the range of 10%
cfg.tap_cv_asynch_thr   = 0.1; 

% minimum N taps for the step/cycle/window to be valid (units: proportion of max. possible N taps considering the beat period)
% if they tapped less than 70% of the maximum possible number of taps
% it would be a bad trial below this point (70%)
cfg.min_n_taps_prop     = 0.7; 

% how many trials/windows do you need to go through staircase procedure
% N successive steps that need to be "good tapping" to move one SNR level up
cfg.n_steps_up          = 2; 

% N successive steps that need to be "bad tapping" to move one SNR level down
cfg.n_steps_down        = 1;

% N successive steps that need to be "good tapping" for the final level to finish
% this is the final window count to be correct in order to finish
% this is the last level (level 4)
% number of consecuitve windows in order to finish the level 4
cfg.n_steps_up_lastLevel = 3; 

% not sured atm - 
%if the feedback wil be given after each window of pattern
% cfg.fbk_on_sceen_maxtime = 2; 

%% Task

% add what to press to quit

% training
if strcmp(expParameters.task,'tapTraining')
    
    expParameters.taskInstruction = ['Welcome!\n\n', ...
        'You will hear a repeated rhythm played by a "click sound".\n', ...
        'There will also be a "bass sound", playing a regular pulse.\n\n', ...
        'Tap in synchrony with the bass sound on SPACEBAR.\n', ...
        'If your tapping is precise, the bass sound will get softer and softer.\n', ...
        'Eventually (if you are tapping well), the bass sound will disappear.\n', ...
        'Keep your internal pulse as the bass drum fades out.\n', ...
        'Keep tapping at the positions where the bass drum was before...\n\n\n', ...
        'Good luck!\n\n'];
    
% main experiment  
else
    expParameters.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n'];
end
