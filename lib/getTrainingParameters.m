function [cfg,expParam] = getTrainingParameters(cfg,expParam)

% % % 

% check if some parameters could be inserted  into
% getParams.m script instead

% % %

% patterns to be played - will be tried from the first to the last
% rhythmic patterns (from simplest to most difficult)
cfg.patterns            = {[1 1 1 0 1 1 1 0 1 1 0 0 ],...
                           [1 1 1 0 1 1 1 0 1 1 0 0 ],...
                           [1 1 1 1 0 1 1 1 0 0 1 0 ],... 
                           [1 1 1 1 0 1 1 1 0 0 1 0 ]}; 
                       
% number of patterns
cfg.nPatterns   = length(cfg.patterns);   

%% tapping training parameters
% tapping cue sounds (metronome)
cfg.cuePeriod    = [4,3,4,3]; % each pattern needs a metronome period assigned (units: N-grid-ticks)

% decreasing the DB along with the high accuracy of tapping 
cfg.cueDB       = [0, -25, -Inf]; % [0, -14, -25, -Inf] SNRs between rhythm and metronome audio (to be used across levels)

% to calculate how many difficulty levels there (in dB)
% or number of SNR-levels
cfg.nCueDB       = length(cfg.cueDB); 

% number of pattern cycles in each step/window of pattern: how many cycles
% of the pattern will be repeated
cfg.nCyclesPerWin   = 4; 

% time-interval of one grid-tick (IOI between events)
% it's not necessarily the duration of the sound. 
cfg.gridIOI       = 0.200; 

% threshold for coefficient of variation (cv) of tap-beat asynchronies (defines good/bad tapping performance in each step)
% the taps to be registered as correct "it" should be below the threshold
% within the 4 cycle of pattern representation the error is calculated and 
% this is the shift of tapping variation should be in the range of 10%
cfg.tapCvAsynchThr   = 0.160; 

% minimum N taps for the step/cycle/window to be valid (units: proportion of max. possible N taps considering the beat period)
% if they tapped less than 70% of the maximum possible number of taps
% it would be a bad trial below this point (70%)
cfg.minNtapsProp     = 0.7; 

%% staircase parameters 
% how many trials/windows do you need to go through staircase procedure
% N successive steps that need to be "good tapping" to move one SNR level up
cfg.nWinUp          = 2; 

% N successive steps that need to be "bad tapping" to move one SNR level down
cfg.nWinDown        = 1;

% N successive steps/windows that need to be "good tapping" for the final level to finish
% this is in the  last level (level cfg.nCueDB)
cfg.nWinUp_lastLevel = 3; 

% duration (secs) for which real-time feedback will be displayed on screen during tapping 
cfg.fbkOnScreenMaxtime = 5; 

%% generate example stimulus/sequence for only volume setting

volTestSound = makeStimTrain(cfg,1,1); 
% make sequence for 2 channels
cfg.volumeSettingSound = repmat(volTestSound.s,2,1); 



%% Instructions

% general task instructions and intro
instrFid = fopen(fullfile('lib','instr','instrTrainingIntro1'),'r'); 
expParam.taskInstruction = []; 
while ~feof(instrFid)
    expParam.taskInstruction = [expParam.taskInstruction, fgets(instrFid)]; 
end
fclose(instrFid); 


% after each pattern (each sequence), these can be specific instruction
% that explains some important concepts that should be learned by the
% participants. 
expParam.afterSeqInstruction = cell(1,length(cfg.patterns)); 

% loop through each pattern to present instr for each level
for pati=1:length(cfg.patterns)
    % look in the instr folder
    if exist(fullfile('lib','instr',sprintf('instrTrainingAfterRhythm%d',pati)))
        % if you can find a text file, load it
        instrFid = fopen(fullfile('lib','instr',sprintf('instrTrainingAfterRhythm%d',pati)),'r'); 
        tmptxt = []; 
        while ~feof(instrFid)
            tmptxt = [tmptxt, fgets(instrFid)]; 
        end
        fclose(instrFid); 
        expParam.afterSeqInstruction{pati} = tmptxt; 
    else
        % if not, just write empty text
        expParam.afterSeqInstruction{pati} = ''; 
    end    
end


end