function [seq] = makeStim(cfg,curr_pattern_level,varargin)


% add parameters to output structure 
seq             = []; 
seq.fs          = cfg.fs; 
seq.pattern     = cfg.patterns{curr_pattern_level}; 
seq.metronome   = repmat([1,zeros(1,cfg.period_metronome(curr_pattern_level)-1)],1,floor(length(seq.pattern)/4)); 
seq.n_cycles    = cfg.n_cycles_per_step; 
seq.dur         = length(seq.pattern)*seq.n_cycles*cfg.grid_interval; 
seq.n_samples   = round(seq.dur*seq.fs); 


% load audio samples
[sound_pattern,~]   = audioread(fullfile('.','stimuli','tone440Hz_10-50ramp.wav')); % rimshot_015
sound_pattern       = 1/3 * sound_pattern; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

[sound_metronome,~] = audioread(fullfile('.','stimuli','Kick8.wav')); 
sound_metronome     = mean(sound_metronome,2); % average L and R channels
sound_metronome     = 1/3 * sound_metronome; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

[sound_grid,~]      = audioread(fullfile('.','stimuli','Perc5_cut.wav')); 
sound_grid          = mean(sound_grid,2); % average L and R channels
sound_grid          = 1/3 * sound_grid; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome


% equalize RMS
rms_pat         = rms(sound_pattern); 
rms_metr        = rms(sound_metronome); 
rms_grid        = rms(sound_grid); 

max_allowed_rms = min([rms_pat, rms_metr, rms_grid]); 

sound_pattern   = sound_pattern/rms_pat * max_allowed_rms; 
sound_metronome = sound_metronome/rms_metr * max_allowed_rms; 
sound_grid      = sound_grid/rms_grid * max_allowed_rms; 


% set metronome and grid level based on requested SNR (pattern/metronome, dB)
if any(strcmp(varargin,'snr_metronome'))
    seq.snr_metronome = varargin{find(strcmp(varargin,'snr_metronome'))+1};     
else
    seq.snr_metronome = -Inf; 
end

rms_metr = rms(sound_metronome);
sound_metronome = sound_metronome/rms_metr * rms_metr*10^(seq.snr_metronome/20); 

rms_grid = rms(sound_grid); 
sound_grid = sound_grid/rms_grid * rms_grid*10^(seq.snr_metronome/20); 

% further attenuate grid sound 
sound_grid = sound_grid * 1/4; 



% generate pattern sequence
seq_pattern = zeros(1,seq.n_samples); 
s_pat_idx = round( (find(repmat(seq.pattern,1,seq.n_cycles))-1) * cfg.grid_interval * seq.fs ); 
for i=1:length(s_pat_idx)   
    seq_pattern(s_pat_idx(i)+1:s_pat_idx(i)+length(sound_pattern)) = sound_pattern; 
end


% generate metrononme sequence
seq_metronome = zeros(1,seq.n_samples); 
s_metr_idx = round( (find(repmat(seq.metronome,1,seq.n_cycles))-1) * cfg.grid_interval * seq.fs ); 
for i=1:length(s_metr_idx)   
    seq_metronome(s_metr_idx(i)+1:s_metr_idx(i)+length(sound_metronome)) = sound_metronome; 
end

% generate grid sequence
seq_grid = zeros(1,seq.n_samples); 
s_grid_idx = round( (find(ones(1,seq.n_cycles*length(seq.pattern)))-1) * cfg.grid_interval * seq.fs ); 
for i=1:length(s_grid_idx)   
    seq_grid(s_grid_idx(i)+1:s_grid_idx(i)+length(sound_grid)) = sound_grid; 
end



% add them together
seq.s = seq_pattern + seq_metronome + seq_grid; 


% check sound amplitude for clipping
if max(abs(seq.s))>1 
    warning('sound amplitude larger than 1...normalizing'); 
    seq.s = seq.s./max(abs(seq.s)); 
end






% % create pure tone and save as audio sample
% seq.rampon = 0.010; 
% seq.rampof = 0.050; 
% seq.tone_dur = 0.100; 
% seq.tone_f0 = 440; 
% 
% env_event = ones(1,round(seq.tone_dur*seq.fs)); 
% env_event(1:round(seq.rampon*seq.fs)) = linspace(0,1,round(seq.rampon*seq.fs)) .* env_event(1:round(seq.rampon*seq.fs)); 
% env_event(end-round(seq.rampof*seq.fs)+1:end) = linspace(1,0,round(seq.rampof*seq.fs)) .* env_event(end-round(seq.rampof*seq.fs)+1:end); 
% t_event = [0:length(env_event)-1]/seq.fs; 
% s_event = sin(2*pi*t_event*seq.tone_f0); 
% s_event = s_event .* env_event; 
% 
% audiowrite('./stimuli/tone440Hz_10-50ramp.wav',s_event,seq.fs)


