function     [cfg,expParameters] = getMainExpParameters(cfg,expParameters)


% to use in the tapping accuracy calculation, I need:
% - load pattern
% - n_sounds (gridSounds = 5,6,7 ?)

% % %
% some of the below is common with getTrainingParameters.m
% can be moved to getParams.m
% % %

% equals to n_events in pattern
% could vary according to the stimuli set
cfg.nGridPoints = 12; % length(pat_complex(1).pattern)
cfg.gridInterval = 0.2; %0.190

%sound event duration equal to gridInterval
cfg.soundDur = cfg.gridInterval;






%% load patterns

% % % 
% later on replace it with chosen sound downloaded by download.sh script
% % %


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simple - complex  

% % %
% Tomas' will comment in doc 
% % %
% set sequence parameters
% window of number of cycles of pattern
cfg.NcyclesPerWindow = 4;
%cfg.n_cycles = 1; 

cfg.n_steps = 4; 
cfg.n_target = 4; 
cfg.n_standard = 4; 
cfg.phase_choose_method = 'original'; 

% set possible IOIs
cfg.min_IOI = 0.190; 
cfg.max_IOI = 0.190; 
cfg.n_IOI = 5; 
cfg.IOIs = linspace((cfg.min_IOI),(cfg.max_IOI),cfg.n_IOI); 

cfg.base_T = cfg.max_IOI*12*cfg.n_cycles; 
cfg.base_freq = 1/cfg.base_T; 

cfg.delay_after_tar = 0; 
cfg.delay_after_std = 3; 

% set possible f0s
cfg.n_f0 = 5; 
cfg.min_f0 = 350; 
cfg.max_f0 = 900; 
cfg.f0s = logspace(log10(cfg.min_f0),log10(cfg.max_f0),cfg.n_f0); 
cfg.change_pitch_pattern = 1;           % change pitch for each new pattern
cfg.change_pitch_step = 1;              % change pitch for each step (i.e. each [target-standard] cycle)
cfg.change_pitch_type = 1;              % change pitch for each pattern-type (i.e. in every step, the target will have one pitch and standard another)

% generate sequence (target,standard)
out = makeOut(cfg, pat_simple, pat_complex); 

% save
out_name = seqCfg2str(cfg); 
out_name_full = fullfile(base_path,'out',[out_name,'_Grahn2007-SimpleVsComplex']); 
mp3write(out.s_out, cfg.fs, [out_name_full,'.mp3']); 
save([out_name_full,'.mat'], 'cfg', 'out')


% play
clear sound
sound(out.s_out,cfg.fs)


%% %%%%%
% [sound_pattern,~]   = audioread(fullfile('.','stimuli','Grahn2007-SimpleVsComplex.wav'));
% cfg.seq = sound_pattern;
% 
% cfg.patternInfo = load(fullfile('.','stimuli','patternInfo.mat'));
% % %
% ideally either sounds created and be in sync with patternInfo 
% or patternInfo wil be used to make seq
% % %




% Task Instructions
    expParameters.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n'];

end