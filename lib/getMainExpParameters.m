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

% wait before running the exp
expParameters.onsetDelay =0;

%% contruct individual sound events (that will make up each pattern)

% define envelope shape of the individual sound event
% all parameters are defined relative to the gridIOI (as proportion of gridIOI)
% we don't use minGridIOI to keep everything proportional if the gridIOI is
% allowed to change across cycles
% 
% total sound duration _/???\_  
cfg.event_dur             = 1; % 100% of gridIOI
% onset ramp duration  _/     
cfg.event_rampon          = 0.05; % 5% of gridIOI 
% offset ramp duration       \_ 
cfg.event_rampoff         = 0.020; % 10% of gridIOI


%% construct pattern (smallest item in sequence)
cfg.nGridPoints = 12; % length(pat_complex(1).pattern)

% the grid interval can vary across steps or segments (gridIOI selected 
% randomly from a set of possible values for each new step or segment) 
cfg.minGridIOI 	= 0.190;  % minimum possible grid IOI 
cfg.maxGridIOI 	= 0.190; % maximum possible grid IOI 
cfg.nGridIOI 	= 5; 	% number of unique IOI values between the limits
cfg.gridIOIs 	= linspace((cfg.minGridIOI),(cfg.maxGridIOI),cfg.nGridIOI); 

%================================================================
% The gridIOI changes are controlled by the Boolean variables below. 
% change gridIOI for each segment
cfg.changegridIOISegm       = 0;           
% change gridIOI for each segment-type (every time A changes to B or the other way around)
cfg.changegridIOICategory   = 0;    
% change gridIOI for each step
cfg.changegridIOIStep       = 0;     



%% construct segment
% how many pattern cycles are within each step of [ABBB]
% how many pattern in each segment A or B.
cfg.nPatternPerSegment = 4; 

% there can be a pause after all segments for category A are played 
% (i.e. between A and B)
cfg.delayAfterA = 0; 
% there can be a pause after all segments for category B are played 
% (i.e. between B and A)
cfg.delayAfterB = 0; 

% if the gridIOI can vary across cycles, we need to set the time interval 
% between two successive segments to a fixed value (this must be greater or 
% equal to the maximum possible segment duration)
cfg.interSegmInterval = cfg.nPatternPerSegment * cfg.nGridPoints * cfg.maxGridIOI; 



%% construct step [ABBB]
% how many successive segments are presented for category A
% manw many times segment A will be sequentially repeated
cfg.nSegmentA = 1; 

% how many successive segments are presented for category B
% manw many times segment B will be sequentially repeated
cfg.nSegmentB = 3; 

% number of segments for each step
nSegmPerStep = cfg.nSegmentB + cfg.nSegmentA; %4; 

%calculation duration of a step 
cfg.interStepInterval = cfg.interSegmInterval * nSegmPerStep + ...
                        cfg.delayAfterA * cfg.nSegmentA + ... 
                        cfg.delayAfterB * cfg.nSegmentB;

                    
%% construct whole sequence
% how many steps are in the whole sequence
% how many repetition of grouped segment [ABBB] in the whole sequence
cfg.nSteps = 10; 


% calculate trial duration
SequenceDur = (durStep * cfg.nSteps)/60; 
fprintf('\n\ntrial duration is: %.1f minutes\n',SequenceDur);



%% construct pitch features of the stimulus 
% the pitch (F0) of the tones making up the patterns can vary 
% (it can be selected randomly from a set of possible values)
cfg.minF0 	= 350; % minimum possible F0
cfg.maxF0 	= 900; % maximum possible F0
cfg.nF0 	= 5; % number of unique F0-values between the limits
cfg.F0s 	= logspace(log10(cfg.minF0),log10(cfg.maxF0),cfg.nF0); 

%================================================================
% The pitch changes are controlled by the Boolean variables below. 
% NOTE: the parameters work together hierarchically, i.e. if you set
% cfg.changePitchCycle = TRUE, then it's obvious that pitch will be changed
% also every segment and step...

% change pitch for each new pattern cycle
cfg.changePitchCycle 	= 0;
% change pitch for each segment
cfg.changePitchSegm 	= 0;           
% change pitch for each segment-type (every time A changes to B or the other way around)
cfg.changePitchCategory = 0;    
% change pitch for each step
cfg.changePitchStep 	= 0;     


%% create two sets of patterns

% read from txt files
grahn_pat_simple = loadIOIRatiosFromTxt(fullfile('stimuli','Grahn2007_simple.txt')); 
grahn_pat_complex = loadIOIRatiosFromTxt(fullfile('stimuli','Grahn2007_complex.txt')); 

% get different metrics of the patterns
pat_simple = getPatternInfo(grahn_pat_simple, cfg); 
pat_complex = getPatternInfo(grahn_pat_complex, cfg); 


%% generate sequence

% this should be done before each trial starts, it would take lots of
% memory to generate everything before the experient starts...

% consider blocking the fprintf
out = makeOut(cfg, pat_simple, pat_complex); 

% save output sequence info cfg
cfg.seq = out.sOut;


%% extract in 1 sequence below numbers for preallocation
%     expParameters.numPatterns = 
%     expParameters.numSounds =
%     expParameters.numSequences =

%% Task Instructions
    expParameters.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n'];

end