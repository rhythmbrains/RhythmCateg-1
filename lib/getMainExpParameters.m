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
cfg.nGripPoints = 12; % length(pat_complex(1).pattern)
cfg.gridInterval = 0.2; %0.190

%sound event duration equal to gridInterval
cfg.soundDur = cfg.gridInterval;

% window of number of cycles of pattern
cfg.NcyclesPerWindow = 4;

%this needs to vary according to the pattern
cfg.currPeriod = 4;

% proportion of min number of taps to be considered as tapping within the
% window is accurate
cfg.probMinNTaps     = 0.7;

% threshold for coefficient of variation (cv) of tap-beat asynchronies (defines good/bad tapping performance in each step)
cfg.tapAsynchThresh   = 0.1; 

%% load patterns

% % % 
% later on replace it with chosen sound downloaded by download.sh script
% % %
% 
% % % 
% later on replace it with pat_complex and pat_simple by download.sh script
% % %

% 
% %for now...
% XPRhythmCateg_mkstimGrahn.m script was used to create simple and complex
% patterns

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

cfg.patternInfo = load(fullfile('.','stimuli','patternInfo.mat'));
% % %
% ideally either sounds created and be in sync with patternInfo 
% or patternInfo wil be used to make seq
% % %




% Task Instructions
    expParameters.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n'];

end