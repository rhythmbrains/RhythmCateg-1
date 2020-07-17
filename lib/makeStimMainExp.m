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
smallEnv = cell(1,length(pattern));
smallT = cell(1,length(pattern));
c=0;
s =[];

for cyclei=1:nCycles
    for i=1:length(pattern)
        
        %get the idx for inserting events
        idx = round(c*currGridIOI*cfg.fs);
        
        %insert sound or no-sound event
        env(idx+1:idx+length(envEvent)) = pattern(i) * envEvent;
        
        %store each event into a cell array
        smallEnv{i} = env(idx+1:idx+length(envEvent));
        smallT{i} = t(idx+1:idx+length(envEvent));
        
        c=c+1;
    end
end


% create carrier according to isTask
if isTask
    
    % check the current F0
    % find the corresponding cfg.targetSound
    targetSoundIdx = cfg.isTask.F0Idx;
    currTargetS = cfg.targetSounds{1,targetSoundIdx};
    
%     % take 1 channel
%     % later on adapt for stereo
%     currTargetS =  currTargetS(2,:);
 
    % find first N non-zero element
    % numEvent defined in getParam.m
    idxTask = find(pattern);
    if cfg.isTask.numEvent < length(idxTask)
        idxTask = idxTask(1:cfg.isTask.numEvent);
    end
    
    for iEvent = 1:length(pattern)
        
        % find the targeted env & time
        currEnv = smallEnv{iEvent};
        currTime = smallT{iEvent};
        
        % insert piano key when thre's target
        if ismember(iEvent,idxTask) % target - piano key
            currS = currTargetS.*currEnv;
            % not amp here
            % yes amp
            % apply the amplitude
            % currS = currS.* currAmp;
            
        else % no target = sine wave   
            currS = sin(2*pi*currF0*currTime);
            currS = currS.* currEnv;
            % apply the amplitude
            currS = currS.* currAmp;
        end
        
        %assign it to big array
        s = [s currS];
    end

    
else
    % create carrier
    s = sin(2*pi*currF0*t);
    % apply envelope to the carrier
    s = s.* env;
    % apply the amplitude
    s = s.* currAmp;
end






% % to visualise 1 pattern
% figure; plot(t,s);
% ylim([-1.5,1.5])





