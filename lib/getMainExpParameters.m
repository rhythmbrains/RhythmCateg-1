function     [cfg,expParameters] = getMainExpParameters(cfg,expParameters)


% to use in the tapping accuracy calculation, I need:
% - load pattern
% - n_event = 12 (gridPoints = 12)
% - n_sounds (gridSounds = 5,6,7 ?)
% - grid_interval = 0.190 
% - cfg.soundDur = cfg.gridInterval ?
% - cfg.Ncycles (per window) : how many cycles
% of the pattern will be repeated
% - cfg.min_n_taps_prop     = 0.7;
% - cfg.tap_cv_asynch_thr   = 0.1; 

%% load patterns

% % % 
% later on replace it with chosen sound downloaded by download.sh script
% % %
% 
% % % 
% later on replace it with pat_complex and pat_simple by download.sh script
% % %

% 
% %for now...
% XPRhythmCateg_mkstimGrahn.m script was used to create simple and complex
% patterns

% cfg.seq = out.s_out;
% 
% % check sound amplitude for clipping
% if max(abs(cfg.seq))>1 
%     warning('sound amplitude larger than 1...normalizing'); 
%     cfg.seq = cfg.seq./max(abs(seq.s)); 
% end
% 
% filename = 'stimuli/Grahn2007-SimpleVsComplex.wav';
% audiowrite(filename, cfg.seq, cfg.fs);


[sound_pattern,~]   = audioread(fullfile('.','stimuli','Grahn2007-SimpleVsComplex.wav'));
cfg.seq = sound_pattern;

cfg.patternInfo = load(fullfile('.','stimuli','patternInfo.mat'));
% % %
% ideally either sounds created and be in sync with patternInfo 
% or patternInfo wil be used to make seq
% % %




% Task Instructions
    expParameters.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n'];

end