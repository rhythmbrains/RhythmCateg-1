function [seq] = makeStimTrain(cfg,currPatterni,cueDBleveli)


% add parameters to output structure 
seq                 = []; 
seq.fs              = cfg.fs; 
seq.pattern         = cfg.patterns{currPatterni}; 
seq.cueDB           = cfg.cueDB(cueDBleveli); 
seq.cue             = repmat([1,zeros(1,cfg.cuePeriod(currPatterni)-1)],...
                                1,floor(length(seq.pattern)/cfg.cuePeriod(currPatterni))); 
seq.nCycles         = cfg.nCyclesPerWin; 
seq.dur             = length(seq.pattern)*seq.nCycles*cfg.gridIOI; 
seq.nSamples        = round(seq.dur*seq.fs); 


% load audio samples
[soundPattern,~]   = audioread(fullfile('.','stimuli','tone440Hz_10-50ramp.wav')); % rimshot_015
soundPattern       = 1/3 * soundPattern; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

[soundBeat,~] = audioread(fullfile('.','stimuli','Kick8.wav')); 
soundBeat     = mean(soundBeat,2); % average L and R channels
soundBeat     = 1/3 * soundBeat; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

[soundGrid,~]      = audioread(fullfile('.','stimuli','Perc5_cut.wav')); 
soundGrid          = mean(soundGrid,2); % average L and R channels
soundGrid          = 1/3 * soundGrid; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome


% equalize RMS
rmsPat         = rms(soundPattern); 
rmsBeat        = rms(soundBeat); 
rmsGrid        = rms(soundGrid); 

maxAllowedRms = min([rmsPat, rmsBeat, rmsGrid]); 

soundPattern   = soundPattern/rmsPat * maxAllowedRms; 
soundBeat = soundBeat/rmsBeat * maxAllowedRms; 
soundGrid      = soundGrid/rmsGrid * maxAllowedRms; 

% % set metronome/cue and grid level based on requested SNR/dB (pattern/metronome, dB)
% if any(strcmp(varargin,'snr_metronome'))
%     seq.snr_metronome = varargin{find(strcmp(varargin,'snr_metronome'))+1};     
% else
%     seq.snr_metronome = -Inf; 
% end

rmsBeat = rms(soundBeat);
soundBeat = soundBeat/rmsBeat * rmsBeat*10^(seq.cueDB/20); 

rmsGrid = rms(soundGrid); 
soundGrid = soundGrid/rmsGrid * rmsGrid*10^(seq.cueDB/20); 

% further attenuate grid sound 
soundGrid = soundGrid * 1/4; 



% generate pattern sequence
seqPattern = zeros(1,seq.nSamples); 
sPatIdx = round( (find(repmat(seq.pattern,1,seq.nCycles))-1) * cfg.gridIOI * seq.fs ); 
for i=1:length(sPatIdx)   
    seqPattern(sPatIdx(i)+1:sPatIdx(i)+length(soundPattern)) = soundPattern; 
end


% generate metrononme sequence
seqBeat = zeros(1,seq.nSamples); 
sBeatIdx = round( (find(repmat(seq.cue,1,seq.nCycles))-1) * cfg.gridIOI * seq.fs ); 
for i=1:length(sBeatIdx)   
    seqBeat(sBeatIdx(i)+1:sBeatIdx(i)+length(soundBeat)) = soundBeat; 
end

% generate grid sequence
seqGrid = zeros(1,seq.nSamples); 
sGridIdx = round( (find(ones(1,seq.nCycles*length(seq.pattern)))-1) * cfg.gridIOI * seq.fs ); 
for i=1:length(sGridIdx)   
    seqGrid(sGridIdx(i)+1:sGridIdx(i)+length(soundGrid)) = soundGrid; 
end



% add them together
seq.s = seqPattern + seqBeat + seqGrid; 


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


