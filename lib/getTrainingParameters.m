function [cfg,expParam] = getTrainingParameters(cfg,expParam)

% % % 

% check if some parameters could be inserted  into
% getParams.m script instead

% % %

% patterns/tracks to be played - will be tried from the first to the last
% rhythmic patterns
cfg.patterns            = {'Bugz_4_Hugz_Dub(120BPM).wav', ...
                            [1 1 1 1 0 1 1 1 0 0 1 0 ],...                             
                            [1 1 1 1 0 1 1 1 0 0 1 0 ]}; 
                       
% number of patterns
cfg.nPatterns   = length(cfg.patterns);   

% find which items are audio tracks
cfg.isTrackIdx = find( cellfun(@(x)strcmp(class(x),'char'), cfg.patterns) ); 

nTracks = length(cfg.isTrackIdx); 

%% tapping training parameters
% tapping cue sounds (metronome)
cfg.cuePeriodGrid = [4,4,3]; % each pattern needs a metronome period assigned (units: N-grid-ticks)

% time-interval of one grid-tick (IOI between events)
% it's not necessarily the duration of the sound. 
% This needs to be set separately for each pattern (or track)
cfg.gridIOI = [0.125, 0.200, 0.200]; 

% decreasing the DB along with the high accuracy of tapping 
cfg.cueDB = [0, -15, -Inf]; % [0, -14, -25, -Inf] SNRs between rhythm and metronome audio (to be used across levels)

% to calculate how many difficulty levels there (in dB)
% or number of SNR-levels
cfg.nCueDB = length(cfg.cueDB); 

% number of pattern cycles in each step/window of pattern: how many cycles
% of the pattern will be repeated
cfg.nCyclesPerWin = 4; 

% duration (in seconds) of the each step/window of pattern
cfg.winDur = cfg.nCyclesPerWin * ( cellfun(@length, cfg.patterns) .* cfg.gridIOI ); 

% threshold for coefficient of variation (cv) of tap-beat asynchronies (defines good/bad tapping performance in each step)
% the taps to be registered as correct "it" should be below the threshold
% within the 4 cycle of pattern representation the error is calculated and 
% this is the shift of tapping variation should be in the range of 10%
cfg.tapCvAsynchThr = 0.160; 

% minimum N taps for the step/cycle/window to be valid (units: proportion of max. possible N taps considering the beat period)
% if they tapped less than 70% of the maximum possible number of taps
% it would be a bad trial below this point (70%)
cfg.minNtapsProp = 0.7; 

%% staircase parameters 
% how many trials/windows do you need to go through staircase procedure
% N successive steps that need to be "good tapping" to move one SNR level up
cfg.nWinUp = 2; 

% N successive steps that need to be "bad tapping" to move one SNR level down
cfg.nWinDown = 1;

% N successive steps/windows that need to be "good tapping" for the final level to finish
% this is in the  last level (level cfg.nCueDB)
cfg.nWinUp_lastLevel = 3; 

% duration (secs) for which real-time feedback will be displayed on screen during tapping 
cfg.fbkOnScreenMaxtime = 5; 




%% load wav files to make sounds

% load audio samples
soundPattern    = audioread(fullfile('.','stimuli','tone440Hz_10-50ramp.wav')); % rimshot_015
soundPattern    = 1/3 * soundPattern; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

soundBeat       = audioread(fullfile('.','stimuli','Kick8.wav')); 
soundBeat       = mean(soundBeat,2); % average L and R channels
soundBeat       = 1/3 * soundBeat; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

soundGrid       = audioread(fullfile('.','stimuli','Perc5_cut.wav')); 
soundGrid       = mean(soundGrid,2); % average L and R channels
soundGrid       = 1/3 * soundGrid; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

soundBeatTrack  = audioread(fullfile('.','stimuli','clap_005.wav')); 
soundBeatTrack  = mean(soundBeatTrack,2); % average L and R channels
soundBeatTrack  = 1/3 * soundBeatTrack; % set amplitude to 1/3 to prevent clipping after adding pattern+metronome

% equalize RMS
rmsPat          = rms(soundPattern); 
rmsBeat         = rms(soundBeat); 
rmsGrid         = rms(soundGrid); 
maxAllowedRms   = min([rmsPat, rmsBeat, rmsGrid]); 

cfg.soundPattern    = soundPattern/rmsPat * maxAllowedRms; 
cfg.soundBeat       = soundBeat/rmsBeat * maxAllowedRms; 
cfg.soundGrid       = soundGrid/rmsGrid * maxAllowedRms; 
cfg.soundBeatTrack  = soundBeatTrack/rmsGrid * maxAllowedRms; 

% prepare cell for audio tracks
cfg.soundTracks = cell(1, length(cfg.patterns)); 
% prepare cell for metronome tracks
cfg.soundTrackBeat = cell(1, length(cfg.patterns)); 

for tracki=1:nTracks
    % load audio track
    sTrack = audioread(fullfile('.','stimuli',cfg.patterns{cfg.isTrackIdx(tracki)}));
    % make it mono and transpose to row vector
    sTrack = mean(sTrack,2)' ;     
    % set RMS
    sTrack = sTrack/rms(sTrack) * maxAllowedRms; 
    % assign it to config
    cfg.soundTracks{cfg.isTrackIdx(tracki)} = sTrack;     
    
    % generate beat sequence as audio track! (we don't use grid here)
    gridIOI     = cfg.gridIOI(cfg.isTrackIdx(tracki)); 
    beatPeriod  = cfg.cuePeriodGrid(cfg.isTrackIdx(tracki)) * gridIOI ; 
    seqDur      = round(length(sTrack) / cfg.fs); 
    nBeatsInSeq = floor(seqDur/beatPeriod); 
    beatTimes   = beatPeriod * [0 : nBeatsInSeq-1]; 
    seqBeat       = zeros(1,length(sTrack)); 

    sBeatIdx = round( beatTimes * cfg.fs ); 
    for i=1:length(sBeatIdx)   
        seqBeat(sBeatIdx(i)+1:sBeatIdx(i)+length(cfg.soundBeatTrack)) = cfg.soundBeatTrack; 
    end

    cfg.soundTrackBeat{cfg.isTrackIdx(tracki)} = seqBeat; 

    % get window duration in seconds
    cfg.winDur(cfg.isTrackIdx(tracki)) = cfg.nCyclesPerWin * ...
                                         cfg.cuePeriodGrid(cfg.isTrackIdx(tracki)) * ...
                                         beatPeriod; 
    
end



%% generate example stimulus/sequence for only volume setting

volTestSound = makeStimTrain(cfg,1,1,0); 
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