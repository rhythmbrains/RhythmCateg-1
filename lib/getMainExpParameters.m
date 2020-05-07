function     [cfg,expParam] = getMainExpParameters(cfg,expParam)
% this function generates audio sequences to be played in the man
% experiment

% % % 
% should be considered exp.parameter structure for experiment/sequence related
% parameters
% % %

% % %
% some of the below is common with getTrainingParameters.m
% can be moved to getParams.m
% % %


% % %
% start the sequence with one B-category segment that will be discarded during analysis
% % %

% % %

% add breaks between every sequence? "would you like to continue, y/n, in
% the mean time, matlab prepares the following sequence & loads it to the
% buffer. 
% every sequence can be a "run". (Run the scripts 6 times)

% % %

% wait before running the exp
expParam.onsetDelay =0;

%wait in between sequences? y/n
expParam.sequenceDelay = 1;
% give a pause of below seconds in between sequences
expParam.pauseSeq = 1; 

% define ideal number of sequences to be made
expParam.numSequences = 1; % 6 

%% contruct individual sound events (that will make up each pattern)

% define envelope shape of the individual sound event
% all parameters are defined relative to the gridIOI (as proportion of gridIOI)
% we don't use minGridIOI to keep everything proportional if the gridIOI is
% allowed to change across cycles
% And ramps are applied to each sound event

% total sound duration proportion to gridIOI _/```\_  
cfg.soundDurProp             = 1; % 100% of gridIOI
% onset ramp duration  _/     
cfg.eventRampon          = 0.05; % 5% of gridIOI 
% offset ramp duration       \_ 
cfg.eventRampoff         = 0.020; % 10% of gridIOI


%% construct pattern (smallest item in sequence)
cfg.nGridPoints = 12; % length(pat_complex(1).pattern)

% the grid interval can vary across steps or segments (gridIOI selected 
% randomly from a set of possible values for each new step or segment) 
cfg.minGridIOI 	= 0.190;  % minimum possible grid IOI 
cfg.maxGridIOI 	= 0.190; % maximum possible grid IOI 
cfg.nGridIOI 	= 5; 	% number of unique IOI values between the limits
cfg.gridIOIs 	= linspace((cfg.minGridIOI),(cfg.maxGridIOI),cfg.nGridIOI); 

cfg.interPatternInterval = cfg.nGridPoints * cfg.maxGridIOI; 

%================================================================
% The gridIOI changes are controlled by the Boolean variables below. 
% change gridIOI for each segment
cfg.changeGridIOISegm       = 0;           
% change gridIOI for each segment-type (every time A changes to B or the other way around)
cfg.changeGridIOICategory   = 0;    
% change gridIOI for each step
cfg.changeGridIOIStep       = 0;     


%% construct segment

% % how many times the pattern will be repeated/cycle through
% % % % it's inserted in makeStimMainExp.m as cfg.nCyclesPerPattern
% % % %
% cfg.nCyclesPerPattern = 1;

% how many pattern cycles are within each step of [ABBB]
% how many pattern in each segment A or B.
cfg.nPatternPerSegment = 4; % 6


% there can be a pause after all segments for category A are played 
% (i.e. between A and B)
cfg.delayAfterA = 0; 
% there can be a pause after all segments for category B are played 
% (i.e. between B and A)
cfg.delayAfterB = 0; 

% if the gridIOI can vary across pattern cycles, we need to set the time 
% interval between two successive segments to a fixed value (this must be 
% greater or equal to the maximum possible segment duration)
cfg.interSegmInterval = cfg.nPatternPerSegment * cfg.interPatternInterval; 

%durSeg = cfg.interSegmInterval;

%% construct step [ABBB]
% how many successive segments are presented for category A
% manw many times segment A will be sequentially repeated
cfg.nSegmentA = 1; 

% how many successive segments are presented for category B
% manw many times segment B will be sequentially repeated
cfg.nSegmentB = 3; 

% number of segments for each step
cfg.nSegmPerStep = cfg.nSegmentB + cfg.nSegmentA; %4; 

%calculation duration (s) of a step 
cfg.interStepInterval = (cfg.interSegmInterval * cfg.nSegmPerStep) + ...
                        (cfg.delayAfterA * cfg.nSegmentA) + ... 
                        (cfg.delayAfterB * cfg.nSegmentB);

%% construct whole sequence
% how many steps are in the whole sequence
% how many repetition of grouped segment [ABBB] in the whole sequence
cfg.nStepsPerSequence = 2; % 5


% calculate trial duration (min)
cfg.SequenceDur = (cfg.interStepInterval * cfg.nStepsPerSequence); 
fprintf('\n\nsequence duration is: %.1f minutes\n',cfg.SequenceDur/60);



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
% change pitch for each segment-category (every time A changes to B or the other way around)
cfg.changePitchCategory = 0;    
% change pitch for each step
cfg.changePitchStep 	= 0;     


%% create two sets of patterns

% read from txt files
grahnPatSimple = loadIOIRatiosFromTxt(fullfile('stimuli','Grahn2007_simple.txt')); 
grahnPatComplex = loadIOIRatiosFromTxt(fullfile('stimuli','Grahn2007_complex.txt')); 

% get different metrics of the patterns
patternSimple = getPatternInfo(grahnPatSimple, cfg); 
patternComplex = getPatternInfo(grahnPatComplex, cfg); 


%% generate sequence

% % % % % % 
% this should be done before each trial starts, it would take lots of
% memory to generate everything before the experient starts...
% consider making all the sequences BEFORE the start of experiment
% or during the previous sequence playing
% % % % % % 

% consider blocking the fprintf
seq = makeSequence(cfg, patternSimple, patternComplex); 

% try to load all seq into cfg
cfg.seq = seq;


% save output sequence info cfg
%cfg.seq = seq.outAudio;


%% extract below numbers for preallocation in logFile
expParam.numPatterns = length(seq.patternID) * expParam.numSequences;


%% Task Instructions
    expParam.taskInstruction = ['Welcome to the main experiment!\n\n', ...
        'Good luck!\n\n', ...
        sprintf('\n\nsequence duration is: %.1f minutes\n',cfg.SequenceDur/60);
                               ];

                           
   expParam.delayInstruction = [sprintf('The %d out of %d is over!\n\n',cfg.iseq, ...
       expParameters.numSequences), ...
        'You can give a break. When you want to continue, press ENTER. \n\n',...
        'Good luck!\n\n', ...
                               ];
                                     
end