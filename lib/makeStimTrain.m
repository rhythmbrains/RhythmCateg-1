function [seq] = makeStimTrain(cfg,currPatterni,cueDBleveli,soundIdx)
% 
% Input
% -----
% cfg : struct
%     configuration structure
% currPatterni: int
%     index of the currently played pattern (or track)
% cueDBleveli: int
%     index of the currently used cue dB level
% audioIdx: int
%     optional, current index position direclty after the audio that's been already 
%     pushed to buffer and played
% 
% Output
% ------
% seq : struct
%     structure with the generated audio and information 
% 
%============================================================================================


%% this is an audio track that has been loaded
if ismember(currPatterni, cfg.isTrackIdx)
    
    % check that we have the audioIdx in the input
    if nargin<4
        error('you need to supply audioIdx when calling makeStimTrain with audio track!')
    end
        
    seq                 = []; 
    seq.fs              = cfg.fs; 
    seq.cueDB           = cfg.cueDB(cueDBleveli); 
    seq.idxEnd          = min(soundIdx + round(cfg.winDur(currPatterni)*cfg.fs), ...
                              length(cfg.soundTracks{currPatterni}) ); 
    
    % scale beat track rms
    soundBeat = cfg.soundTrackBeat{currPatterni}(soundIdx+1 : seq.idxEnd); 
    rmsBeat = rms(soundBeat); 
    soundBeat = soundBeat/rmsBeat * rmsBeat*10^(seq.cueDB/20); 
            
    % add sound track + beat track
    seq.s = cfg.soundTracks{currPatterni}(soundIdx+1:seq.idxEnd) + soundBeat; 
    
    % check if we are at the end of audio track, if yes, send a flag
    if seq.idxEnd == length(cfg.soundTracks{currPatterni})
        seq.AUDIO_END = 1; 
    end
    
%% this is a pattern that needs to be synthesized
else

    % add parameters to output structure 
    seq                 = []; 
    seq.fs              = cfg.fs; 
    seq.pattern         = cfg.patterns{currPatterni}; 
    seq.cueDB           = cfg.cueDB(cueDBleveli); 
    seq.cue             = repmat([1,zeros(1,cfg.cuePeriodGrid(currPatterni)-1)],...
                                    1,floor(length(seq.pattern)/cfg.cuePeriodGrid(currPatterni))); 
    seq.nCycles         = cfg.nCyclesPerWin; 
    seq.dur             = length(seq.pattern)*seq.nCycles*cfg.gridIOI(currPatterni); 
    seq.nSamples        = round(seq.dur*seq.fs); 

    seq.idxEnd          = 0; % dummy, only used for audiotracks

    % set the requested cue dB
    rmsBeat = rms(cfg.soundBeat);
    cfg.soundBeat = cfg.soundBeat/rmsBeat * rmsBeat*10^(seq.cueDB/20); 

    rmsGrid = rms(cfg.soundGrid); 
    cfg.soundGrid = cfg.soundGrid/rmsGrid * rmsGrid*10^(seq.cueDB/20); 

    % further attenuate grid sound (fixed attenuation)
    cfg.soundGrid = cfg.soundGrid * 1/4; 



    % generate pattern sequence
    seqPattern = zeros(1,seq.nSamples); 
    sPatIdx = round( (find(repmat(seq.pattern,1,seq.nCycles))-1) * cfg.gridIOI(currPatterni) * seq.fs ); 
    for i=1:length(sPatIdx)   
        seqPattern(sPatIdx(i)+1:sPatIdx(i)+length(cfg.soundPattern)) = cfg.soundPattern; 
    end

    % generate metrononme sequence
    seqBeat = zeros(1,seq.nSamples); 
    sBeatIdx = round( (find(repmat(seq.cue,1,seq.nCycles))-1) * cfg.gridIOI(currPatterni) * seq.fs ); 
    for i=1:length(sBeatIdx)   
        seqBeat(sBeatIdx(i)+1:sBeatIdx(i)+length(cfg.soundBeat)) = cfg.soundBeat; 
    end

    % generate grid sequence
    seqGrid = zeros(1,seq.nSamples); 
    sGridIdx = round( (find(ones(1,seq.nCycles*length(seq.pattern)))-1) * cfg.gridIOI(currPatterni) * seq.fs ); 
    for i=1:length(sGridIdx)   
        seqGrid(sGridIdx(i)+1:sGridIdx(i)+length(cfg.soundGrid)) = cfg.soundGrid; 
    end

    % add them together
    seq.s = seqPattern + seqBeat + seqGrid; 

end


% check sound amplitude for clipping
if max(abs(seq.s))>1 
    warning('sound amplitude larger than 1...normalizing'); 
    seq.s = seq.s./max(abs(seq.s)); 
end
