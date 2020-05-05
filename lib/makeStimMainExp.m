function [s,env] = makeStimMainExp(pattern, cfg, currGridIOI, currF0)
% 
% ------
% INPUT
% ------
%   pattern:        vector of grid representation of the rhtthmic
%                   pattern to create (e.g. [1,1,1,0,1,1,1,0,0,1,...])
%   cfg: 
% 
% ------ 
% OUTPUT
% ------    
%   s:             audio waveform of the output
%   env:           envelope of the output




%% envelope for the individual sound event 

% number of samples for the onset ramp (proportion of gridIOI)
ramponSamples   = round(currGridIOI * cfg.eventRampon * cfg.fs); 

% number of samples for the offset ramp (proportion of gridIOI)
rampoffSamples  = round(currGridIOI * cfg.eventRampoff * cfg.fs); 

% individual sound event duration defined as proportion of gridIOI
envEvent = ones(1, round(currGridIOI * cfg.soundDur * cfg.fs)); 

% make the linear ramps
envEvent(1:ramponSamples) = envEvent(1:ramponSamples) .* linspace(0,1,ramponSamples); 
envEvent(end-rampoffSamples+1:end) = envEvent(end-rampoffSamples+1:end) .* linspace(1,0,rampoffSamples); 



%% synthesize whole pattern


% if there is no field in the cfg structure specifying requested number of
% cycles, set it to 1 
if isfield(cfg,'nCycles')
    nCycles = cfg.nCycles; 
else
    nCycles = 1;  
end

% construct time vector
t = [0 : round(nCycles * length(pattern) * currGridIOI * cfg.fs)-1]/cfg.fs; 

% construct envelope for the whole pattern 
env = zeros(1,length(t)); 
c=0; 
for cyclei=1:nCycles
    for i=1:length(pattern)
        if pattern(i)
            idx = round(c*cfg.IOI*cfg.fs); 
            env(idx+1:idx+length(envEvent)) = pattern(i) * envEvent; 
        end
        c=c+1; 
    end
end

% create carrier 
s = sin(2*pi*currF0*t); 

% apply envelope to the carrier
s = s.* env;




