function [s, env] = makeStimMainExp(pattern, cfg, currGridIOI, currF0, varargin)
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
  if nargin < 5
    currAmp = 1;
  else
    currAmp = varargin{1};
  end

  if isfield(cfg.pattern, 'taskIdxMatrix')
    isTask = cfg.isTask.Idx;

  else
    isTask = [];
  end
  %% make envelope for the individual sound event

  % number of samples for the onset ramp (proportion of gridIOI)
  ramponSamples   = round(cfg.pattern.eventRampon * cfg.fs);

  % number of samples for the offset ramp (proportion of gridIOI)
  rampoffSamples  = round(cfg.pattern.eventRampoff * cfg.fs);

  % individual sound event duration defined as proportion of gridIOI
  envEvent = ones(1, round(cfg.pattern.eventDur * cfg.fs));

  % make the linear ramps
  envEvent(1:ramponSamples) = envEvent(1:ramponSamples) .* linspace(0, 1, ramponSamples);
  envEvent(end - rampoffSamples + 1:end) = envEvent(end - rampoffSamples + 1:end) .* linspace(1, 0, rampoffSamples);

  % [~, envEvent] = makeEvent(cfg,currF0);

  %% synthesize whole pattern

  % if there is no field in the cfg structure specifying requested number of
  % cycles, set it to 1
  % how many times the pattern will be repeated/cycle through
  if isfield(cfg, 'nCyclesPerPattern')
    nCycles = cfg.pattern.nCyclesPerPattern;
  else
    nCycles = 1;
  end

  % construct time vector
  t = [0:round(nCycles * length(pattern) * currGridIOI * cfg.fs) - 1] / cfg.fs;

  % construct envelope for the whole pattern
  env = zeros(1, length(t));
  smallEnv = cell(1, length(pattern));
  smallT = cell(1, length(pattern));
  c = 0;

  for cyclei = 1:nCycles
    for i = 1:length(pattern)

      % get the idx for inserting events
      idx = round(c * currGridIOI * cfg.fs);

      % insert sound or no-sound event
      env(idx + 1:idx + length(envEvent)) = pattern(i) * envEvent;

      % store each event into a cell array
      smallEnv{i} = env(idx + 1:idx + length(envEvent));
      smallT{i} = t(idx + 1:idx + length(envEvent));

      c = c + 1;
    end
  end

  % by default for behav exp - do the following
  % create carrier
  s = sin(2 * pi * currF0 * t);

  % apply envelope to the carrier
  s = s .* env;

  % apply the amplitude
  s = s .* currAmp;

  %% for fMRI exp - do the following addition
  % calculate the rms for normalisation
  % events idx in the pattern
  idxTask = find(pattern);

  %% create carrier according to isTask/testingDevice
  if isTask

    % display(targetSoundIdx);

    % find first N non-zero element
    % number of targets (numEvent) in a pattern is defined in getParam.m
    if cfg.isTask.numEvent < length(idxTask)
      % take the second tone in pattern as target
      idxTask = idxTask(2:1 + cfg.isTask.numEvent);
    end

    % check the current F0 & find the corresponding cfg.targetSound
    if length(cfg.isTask.F0Idx) == 1
      targetSoundIdx = cfg.isTask.F0Idx;
    else
      targetSoundIdx = cfg.isTask.F0Idx(idxTask);
    end

    %     disp(targetSoundIdx);
    currTargetS = cfg.isTask.targetSounds{targetSoundIdx}; %

  end

  if strcmpi(cfg.testingDevice, 'mri')

    s = [];

    % use rms ratio for target
    currAmp = cfg.isTask.rmsRatio;

    for iEvent = 1:length(pattern)

      % find the targeted env & time
      currEnv = smallEnv{iEvent};
      currTime = smallT{iEvent};

      % insert piano key when there's target
      if isTask && ismember(iEvent, idxTask) % target - piano key

        % apply envelop to the target
        currS = currTargetS .* currEnv;

        % no target = sine wave
      else

        if length(currF0) > 1
          if pattern(iEvent)
            currS = sin(2 * pi * currF0(iEvent) * currTime);
            currS = currS .* currEnv;
            % apply the amplitude
            currS = currS .* currAmp;
          else
            currS = sin(2 * pi * currF0(1) * currTime);
            currS = currS .* currEnv;
            % apply the amplitude
            currS = currS .* currAmp;
          end
        else
          currS = sin(2 * pi * currF0 * currTime);
          currS = currS .* currEnv;
          % apply the amplitude
          currS = currS .* currAmp;
        end
      end

      % assign it to big array
      s = [s currS];
    end
  end

end

% % to visualise 1 pattern
% figure; plot(t,s);
% ylim([-1.5,1.5])
