function cfg = saveOutput(cfg, action, varargin)

 savePath = fullfile(cfg.dir.output, 'training');

  % make sure logiles directory exists
  if ~exist(savePath, 'dir')
    mkdir(savePath);
  end

  dateFormat = 'yyyymmdd_HHMM';
                        
  Filename = fullfile(savePath, ...
                      ['sub-' num2str(cfg.subject.subjectNb), ...
                       '_run-' num2str(cfg.subject.runNb), ...
                       '_' datestr(now, dateFormat)]);

  % cfg.outputDir = fullfile (...
  %     cfg.outputDir, ...
  %     'source', ...
  %     ['sub-' subjectGrp, sprintf(pattern, subjectNb)], ...
  %     ['ses-', sprintf(pattern, sessionNb)]);

  %% MAIN EXPERIMENT
  if strcmp(cfg.task.name, 'tapMainExp')

    switch action

      % ==================================================================================
      case 'open'

        % ----------------------------------------
        % .tsv file for stimulus
        % ----------------------------------------

        % open text file
        cfg.fidStim = fopen([Filename, '_mainStimulus.tsv'], 'w'); % 'a'

        % print header
        fprintf(cfg.fidStim, 'subjectID\trunNumber\tpatternID\tcategory\tonsetTime\tF0\tgridIOI\tpatternAmp\n');

        % ----------------------------------------
        % .tsv file for tapping
        % ----------------------------------------

        % open text file
        cfg.fidTap = fopen([Filename, '_mainTapping.tsv'], 'w'); % 'a'

        % print header
        fprintf(cfg.fidTap, 'subjectID\trunNumber\tseqi\ttapOnset\n');

        % ==================================================================================
      case 'updateStim'

        currSeq = varargin{1};

        % each pattern on one row
        for iPattern = 1:length(currSeq)
          fprintf(cfg.fidStim, '%d\t%d\t%s\t%s\t%f\t%f\t%f\t%f\n', ...
                  cfg.subject.subjectNb, ...
                  cfg.subject.runNb, ...
                  currSeq(iPattern).patternID, ...
                  currSeq(iPattern).segmCateg, ...
                  currSeq(iPattern).onset, ...
                  currSeq(iPattern).F0, ...
                  currSeq(iPattern).gridIOI, ...
                  currSeq(iPattern).patternAmp);
        end

        % ==================================================================================
      case 'updateTap'

        % each tap on one row
        fprintf(cfg.fidTap, '%d\t%d\t%d\t%f\n', ...
                cfg.subject.subjectNb, ...
                cfg.subject.runNb, ...
                cfg.seqi, ...
                varargin{1});

        % ==================================================================================
      case 'savemat'

        % save all config structures and datalog to .mat file
        save(fullfile([Filename, '_mainAll.mat']), 'cfg');

        % ==================================================================================
      case 'close'

        % close txt log files
        if isfield(cfg, 'fidStim') || isfield(cfg, 'fidTap')
          fclose(cfg.fidStim);
          fclose(cfg.fidTap);
        end

    end

    %% TAP TRAINING
  elseif strcmp(cfg.task.name, 'tapTraining')

    switch action

      % ==================================================================================
      case 'open'

        % open tsv file
        cfg.fidTapTrainer = fopen([Filename, '_tapTraining.tsv'], 'w'); % 'a'

        % print header
        fprintf(cfg.fidTapTrainer, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
                'subjectID', ...             % subject id
                'pattern', ...               % cuurent pattern index
                'patternName', ...          % name of the current pattern/track
                'instruction', ...           % listen or tap
                'seqStartTime', ...          % machine time of sequence audio start
                'cuePeriod', ...             % cue (i.e. metronome) period (N of grid-points)
                'cueLeveldB', ...            % cue (i.e. metronome) level in dB
                'analysisWin', ...          % index (count) of this analysis window (for this sequence)
                'winStartTime', ...         % analysis window start time wrt sequence start
                'tapOnset');                % tap onset time relative to sequence start time

        % ==================================================================================
      case 'update'

        % ==================================================================================
      case 'savemat'

        % remove the big audiofiles so the file is not massive
        cfg.soundTrackBeat = [];
        cfg.soundTracks = [];

        % save all config structures and datalog to .mat file
        save(fullfile([Filename, '_tapTraining.mat']), 'cfg');

        % ==================================================================================
      case 'close'

        % close txt log files
        if isfield(cfg, 'fidStim') || isfield(cfg, 'fidTap')
          fclose(cfg.fidStim);
          fclose(cfg.fidTap);
        end
    end

  end
