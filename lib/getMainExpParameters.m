function     [cfg,expParameters] = getMainExpParameters(cfg,expParameters)




cfg.rampon          = 0.010; 
cfg.rampoff         = 0.050;

% time-interval of one grid-tick (IOI between events)
% it's not the duration of the sound. 
cfg.grid_interval       = 0.200;  %cfg.IOI

cfg.sound_dur       = cfg.grid_interval; 
cfg.f0              = 440; 

% number of pattern cycles in each step/window of pattern: how many cycles
% of the pattern will be repeated
cfg.n_cycles_per_step        = 3; 

cfg.nonmeter_ratios = [1, 1.4, 3.5, 4.5]; 


%% load patterns

% % % 
% later on replace it with chosen sound downloaded by download.sh script
% % %
% 
% % download grahn_pat_complex & grahn_pat_simple maybe?
% % then we do not need to have loadIOIRatiosFromTxt function in lib
% 
% % or download the sound input whole together? 
% 
% grahn_pat_simple = loadIOIRatiosFromTxt(fullfile(base_path,'Grahn2007_simple.txt')); 
% 
% grahn_pat_complex = loadIOIRatiosFromTxt(fullfile(base_path,'Grahn2007_complex.txt')); 
% 
% 
% % get syncopation for each pattern
% 
% 
% pat_simple = getPatternInfo(grahn_pat_simple, cfg); 
% 
% pat_complex = getPatternInfo(grahn_pat_complex, cfg); 
% 
% pat_nonmetric = getPatternInfo(grahn_pat_complex, cfg, 'nonmeter'); 
% 
% 
% %
% n_events = unique([pat_simple.n_sounds]); 
% 
% % CONSTRUCT STIMULUS
% % simple - complex  
% 
% % set sequence parameters
% cfg.n_cycles = 1; 
% cfg.n_steps = 4; 
% cfg.n_target = 4; 
% cfg.n_standard = 4; 
% cfg.phase_choose_method = 'original'; 
% 
% % set possible IOIs
% cfg.min_IOI = 0.190; 
% cfg.max_IOI = 0.190; 
% cfg.n_IOI = 5; 
% cfg.IOIs = linspace((cfg.min_IOI),(cfg.max_IOI),cfg.n_IOI); 
% 
% cfg.base_T = cfg.max_IOI*12*cfg.n_cycles; 
% cfg.base_freq = 1/cfg.base_T; 
% 
% cfg.delay_after_tar = 0; 
% cfg.delay_after_std = 3; 
% 
% % set possible f0s
% cfg.n_f0 = 5; 
% cfg.min_f0 = 350; 
% cfg.max_f0 = 900; 
% cfg.f0s = logspace(log10(cfg.min_f0),log10(cfg.max_f0),cfg.n_f0); 
% cfg.change_pitch_pattern = 1;           % change pitch for each new pattern
% cfg.change_pitch_step = 1;              % change pitch for each step (i.e. each [target-standard] cycle)
% cfg.change_pitch_type = 1;              % change pitch for each pattern-type (i.e. in every step, the target will have one pitch and standard another)
% 
% % generate sequence (target,standard)
% out = makeOut(cfg, pat_simple, pat_complex); 
% 
% 
% %for now... 
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % simple - nonmeter  
% 
% 
% % set parameters
% cfg.n_cycles = 3; 
% cfg.n_steps = 32; 
% cfg.n_target = 1; 
% cfg.n_standard = 2; 
% cfg.phase_choose_method = 'original'; 
% 
% % set possible IOIs
% cfg.min_IOI = 0.170; 
% cfg.max_IOI = 0.220; 
% cfg.n_IOI = 5; 
% cfg.IOIs = linspace((cfg.min_IOI),(cfg.max_IOI),cfg.n_IOI); 
% 
% cfg.base_T = cfg.max_IOI*12*cfg.n_cycles * 1.1; 
% cfg.base_freq = 1/cfg.base_T; 
% 
% % set possible f0s
% cfg.n_f0 = 5; 
% cfg.min_f0 = 300; 
% cfg.max_f0 = 1000; 
% cfg.f0s = logspace(log10(cfg.min_f0),log10(cfg.max_f0),cfg.n_f0); 
% 
% % generate sequence
% out = makeOut(cfg, pat_nonmetric, pat_simple, 'nonmeter',[1,0]); 
% 
% % save
% out_name = seqCfg2str(cfg); 
% out_name_full = fullfile(base_path,'out',[out_name,'_Grahn2007-SimpleVsNonmetric']); 
% audiowrite([out_name_full,'.wav'], out.s_out, cfg.fs); 
% save([out_name_full,'.mat'], 'cfg', 'out')
% 
% 
% % play
% clear sound
% sound(out.s_out,cfg.fs)





% Task Instructions
    expParameters.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n'];

end