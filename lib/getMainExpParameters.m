function     [cfg,expParameters] = getMainExpParameters(cfg,expParameters)
% this function generates audio sequences to be played in the man
% experiment

% % % 
% should be considered exp.parameter structure for experiment related
% parameters
% % %

% % %
% some of the below is common with getTrainingParameters.m
% can be moved to getParams.m
% % %

% % %
% consider not printing out the output "pattern 1 2 3"
% % %

%% construct pattern (smallest item in sequence)
cfg.nGridPoints = 12; % length(pat_complex(1).pattern)

% the grid interval can vary across pattern cycles (gridIOI selected 
% randomly from a set of possible values for each pattern cycle) 
cfg.minGridIOI 	= 0.190;  % minimum possible grid IOI 
cfg.maxGridIOI 	= 0.190; % maximum possible grid IOI 
cfg.nGridIOI 	= 5; 	% number of unique IOI values between the limits
cfg.gridIOIs 	= linspace((cfg.minGridIOI),(cfg.maxGridIOI),cfg.nGridIOI); 

%% construct segment
% how many pattern cycles are within each step of [ABBB]
% how many pattern in each segment A or B.
cfg.nPatternPerSegment = 4; 

%calculation duration of a segment according to your pattern & grid
durSegment = (cfg.maxGridIOI * cfg.nGridPoints * cfg.nPatternPerSegment);

%% construct step [ABBB]
% how many successive segments are presented for category A
% manw many times segment A will be sequentially repeated
cfg.nSegmentA = 1; 

% how many successive segments are presented for category B
% manw many times segment B will be sequentially repeated
cfg.nSegmentB = 3; 

% number of segments for each step
nSegmPerStep 	= cfg.nSegmentB + cfg.nSegmentA; %4; 

% there can be a pause after all segments for category A are played 
% (i.e. between A and B)
cfg.delayAfterA = 0; 
% there can be a pause after all segments for category B are played 
% (i.e. between B and A)
cfg.delayAfterB = 0; 

% if the gridIOI can vary across cycles, we need to set the time interval 
% between two successive steps to a fixed value (this must be greater or 
% equal to the maximum possible segment duration)
cfg.interStepInterval = cfg.nPatternPerSegment * 12 * cfg.maxGridIOI; 

%calculation duration of a step according to your segments
durStep = (durSegment + cfg.delayAfterA + cfg.delayAfterB) * nSegmPerStep;

%% construct whole sequence
% how many steps are in the whole sequence
% how many repetition of grouped segment [ABBB] in the whole sequence
cfg.nSteps = 10; 


%% construct other features in sequence
% the pitch (F0) of the tones making up the patterns can vary 
% (it can be selected randomly from a set of possible values)
cfg.minF0 	= 350; % minimum possible F0
cfg.maxF0 	= 900; % maximum possible F0
cfg.nF0 	= 5; % number of unique F0-values between the limits
cfg.F0s 	= logspace(log10(cfg.minF0),log10(cfg.maxF0),cfg.nF0); 

% the pitch changes are controlled by the Boolean variables below
cfg.changePitchCycle 	= 1;           % change pitch for each new pattern cycle
cfg.changePitchSegm 	= 1;           % change pitch for each segment
cfg.changePitchCategory = 1;    % change pitch for each pattern-type (every time A changes to B or the other way around)
cfg.changePitchStep 	= 1;     % change pitch for each step


%% generate sequence

% % % ASK TOMAS % % % 
% ramps within pattern? / segment? / sequence?
cfg.rampon          = 0.010; 
cfg.rampoff         = 0.050;
cfg.IOI             = 0.190;
cfg.sound_dur       = cfg.IOI; % cfg.minGridIOI ???
cfg.n_cycles        = 3; % cfg.nPatternPerSegment ??? 
cfg.f0              = 440;
% % % % % % % % % % % %

% read from txt files
grahn_pat_simple = loadIOIRatiosFromTxt(fullfile('stimuli','Grahn2007_simple.txt')); 
grahn_pat_complex = loadIOIRatiosFromTxt(fullfile('stimuli','Grahn2007_complex.txt')); 

% extract pattern info
pat_simple = getPatternInfo(grahn_pat_simple, cfg); 
pat_complex = getPatternInfo(grahn_pat_complex, cfg); 

out = makeOut(cfg, pat_simple, pat_complex); 


%% calculate the exp duration
SequenceDur = (durStep * cfg.nSteps)/60; 
fprintf('\n\ntrial duration is: %.1f minutes\n',SequenceDur);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set possible IOIs
cfg.base_T = cfg.max_IOI*12*cfg.n_cycles; 
cfg.base_freq = 1/cfg.base_T; 


% save
out_name = seqCfg2str(cfg); 
out_name_full = fullfile(base_path,'out',[out_name,'_Grahn2007-SimpleVsComplex']); 
mp3write(out.s_out, cfg.fs, [out_name_full,'.mp3']); 
save([out_name_full,'.mat'], 'cfg', 'out')


% play
clear sound
sound(out.s_out,cfg.fs)




% Task Instructions
    expParameters.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n'];

end