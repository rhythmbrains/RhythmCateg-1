function cfg=getParams()

cfg = []; 
cfg.fs                  = 44100; % sampling rate
cfg.patterns            = {[1 1 1 0 1 1 1 0 1 1 0 0 ],
                           [1 1 1 1 0 1 1 1 0 0 1 0 ]};        % rhythmic patterns (from simplest to most difficult)     
cfg.max_pattern_level   = length(cfg.patterns);   % number of patterns
cfg.period_metronome    = [4,4]; % each pattern needs a metronome period assigned (units: N-grid-ticks)
cfg.snr_metronome       = [0, -14, -25, -Inf]; % SNRs between rhythm and metronome audio (to be used across levels)
cfg.max_snr_level       = length(cfg.snr_metronome); % number of SNR-levels

cfg.n_cycles_per_step   = 4; % number of pattern cycles in each step
cfg.grid_interval       = 0.200; % time-interval of one grid-tick (IOI between events)
cfg.tap_cv_asynch_thr   = 0.1; % threshold for coefficient of variation of tap-beat asynchronies (defines good/bad tapping performance in each step)
cfg.min_n_taps_prop     = 0.7; % minimum N taps for the step to be valid (units: proportion of max. possible N taps considering the beat period)
cfg.n_steps_up          = 2; % N successive steps that need to be "good tapping" to move one SNR level up
cfg.n_steps_down        = 1; % N successive steps that need to be "bad tapping" to move one SNR level down
cfg.n_max_levels        = 3; % N successive steps that need to be "good tapping" for the final level to finish

cfg.fbk_on_sceen_maxtime = 2; 