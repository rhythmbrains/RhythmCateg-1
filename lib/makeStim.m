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
[sound_pattern,~]   = audioread(fullfile('.','stimuli','rimshot_015.wav')); 
sound_pattern       = 0.5 * sound_pattern; % set amplitude to 0.5 to prevent clipping after adding pattern+metronome

[sound_metronome,~] = audioread(fullfile('.','stimuli','Kick8.wav')); 
sound_metronome     = mean(sound_metronome,2); % average L and R channels
sound_metronome     = 0.5 * sound_metronome; % set amplitude to 0.5 to prevent clipping after adding pattern+metronome


% equalize RMS
rms_pat = rms(sound_pattern); 
rms_metr = rms(sound_metronome); 
max_allowed_rms = min(rms_pat, rms_metr); 
sound_pattern = sound_pattern/rms_pat * max_allowed_rms; 
sound_metronome = sound_metronome/rms_metr * max_allowed_rms; 


% set metronome level based on requested SNR (pattern/metronome, dB)
if any(strcmp(varargin,'snr_metronome'))
    seq.snr_metronome = varargin{find(strcmp(varargin,'snr_metronome'))+1};     
else
    seq.snr_metronome = -Inf; 
end
rms_metr = rms(sound_metronome); 
sound_metronome = sound_metronome/rms_metr * rms_metr*10^(seq.snr_metronome/20); 


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


% add them together
seq.s = seq_pattern + seq_metronome; 


% check sound amplitude for clipping
if max(abs(seq.s))>1 
    warning('sound amplitude larger than 1...normalizing'); 
    seq.s = seq.s./max(abs(seq.s)); 
end






