function [s,env] = makeStimMainExp(pattern, cfg, currGridIOI, currF0,varargin)
% this function creates pattern cycles according to the grid that was
% provided 
% if nCycles = 1, it will create only 1 time repeated pattern

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

% I added as varargin in case you are using this function somewhere else
% than the tapMainExperiment
if nargin<5
    currAmp = 1;
else 
    currAmp = varargin{1};
end

if isfield(cfg,'fMRItaskidx')
    isTask = cfg.isTask.Idx;
    F0Task = cfg.isTask.F0;
else
    isTask =[];   
end

%% make envelope for the individual sound event 

% number of samples for the onset ramp (proportion of gridIOI)
ramponSamples   = round(cfg.eventRampon * cfg.fs); 

% number of samples for the offset ramp (proportion of gridIOI)
rampoffSamples  = round(cfg.eventRampoff * cfg.fs); 

% individual sound event duration defined as proportion of gridIOI
envEvent = ones(1, round(cfg.soundDur * cfg.fs)); 

% make the linear ramps
envEvent(1:ramponSamples) = envEvent(1:ramponSamples) .* linspace(0,1,ramponSamples); 
envEvent(end-rampoffSamples+1:end) = envEvent(end-rampoffSamples+1:end) .* linspace(1,0,rampoffSamples); 



%% synthesize whole pattern


% if there is no field in the cfg structure specifying requested number of
% cycles, set it to 1 
% how many times the pattern will be repeated/cycle through
if isfield(cfg,'nCyclesPerPattern')
    nCycles = cfg.nCyclesPerPattern; 
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

            idx = round(c*currGridIOI*cfg.fs); 


            env(idx+1:idx+length(envEvent)) = pattern(i) * envEvent; 
        end
        c=c+1; 
    end
end

% create carrier according to isTask
if isTask
    if isTask
        if cfg.isTask.long
            % change the pitch of whole pattern
            s = sin(2*pi*F0Task*t);
        elseif cfg.isTask.medium
            %change the pitch only 3 events
            s = sin(2*pi*F0Task*t);
        else
            %change the pitch of  1 event
            s = sin(2*pi*F0Task*t);
        end
    end
else
    % create carrier
    s = sin(2*pi*currF0*t);
end


% apply envelope to the carrier
s = s.* env;

% apply the amplitude
s = s.* currAmp;


% % to visualise 1 pattern
% figure; plot(t,s);
% ylim([-1.5,1.5])





