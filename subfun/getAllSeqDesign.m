function [seqDesignFullExp, seqDesignSegment, seqDesignToneF0] = getAllSeqDesign(categA,categB,cfg,varargin)
% [seqDesignFullExp, seqDesignToneNumber] = getAllSeqDesign(categA,categB,cfg,varargin)

% this function designs the sequences for the whole experiment in a way
% that the number of times each pattern is included is counterbalanced and
% randomized as much as possible

% of course, the possibility of full counterbalancing depends on the number
% of sequences, steps, segments, and patterns requested in the experiment
if nargin>3
    numSequences = varargin{1};
else
    numSequences = cfg.pattern.numSequences;
end

% create a separate "reservoir" with available patterns for each segment 
% (e.g. A, B, B, B)
[patterns2chooseA{1:cfg.pattern.nSegmentA}] = deal(categA); 
[patterns2chooseB{1:cfg.pattern.nSegmentB}] = deal(categB); 

patterns2choose = [patterns2chooseA, patterns2chooseB]; 


% allocate result with dimension: sequence x step x segm x pattern
% allocate for patternID CELL
seqDesignFullExp = cell(numSequences, ...
    cfg.pattern.nStepsPerSequence, cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment); 
% allocate for segmentLabel CELL
seqDesignSegment = cell(numSequences, ...
    cfg.pattern.nStepsPerSequence, cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment); 


% allocate for Tone Numbers ARRAY
seqDesignPatNb = zeros(numSequences, ...
    cfg.pattern.nStepsPerSequence, cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment); 

% allocate for pitch/F0 ARRAY
seqDesignToneF0 = zeros(numSequences, ...
    cfg.pattern.nStepsPerSequence, cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment, cfg.pattern.nGridPoints); 





% currently chosen F0 index (indexing value in cfg.pattern.F0s, initialize to 1)
currF0idx = 1; 

counter = 1;

for seqi=1:numSequences

    for stepi=1:cfg.pattern.nStepsPerSequence 

        for segmi=1:cfg.pattern.nSegmPerStep
            
            for pati=1:cfg.pattern.nPatternPerSegment

                % check if there are any patterns left in the reservoir for
                % this segment 
                % if no, refill it with the whole pattern set for that category
                if isempty(patterns2choose{segmi})
                    % Determine which segment category this is (A or B)
                    % (the first 'cfg.pattern.nSegmentA' segments will be category A, 
                    % the rest will be category B)
                    if ismember(segmi, [1:cfg.pattern.nSegmentA])            
                        patterns2choose{segmi} = categA; 
                    else
                        patterns2choose{segmi} = categB; 
                    end
                end
                
                % pick a pattern from the current category
                chosenPatIdx = randsample(length(patterns2choose{segmi}),1); 
                
                % get its ID tag
                chosenPatID = patterns2choose{segmi}(chosenPatIdx).ID; 
                chosenPatNb = patterns2choose{segmi}(chosenPatIdx).n_sounds;
               
                chosenSegmentID = patterns2choose{segmi}(chosenPatIdx).segmentLabel;
               
%                % change pitch in every tone/event
                if cfg.pattern.changePitchTone && strcmp(chosenSegmentID,'A') 
                   
                   whichTone = find(patterns2choose{segmi}(chosenPatIdx).pattern);
                   
                   for iTone=1:chosenPatNb
                       
                       if mod(counter,cfg.pattern.nF0) == 1
                           counter = 1;
                           disp('-----')
                           arrayPitchIdx = Shuffle(1:cfg.pattern.nF0);
                           
                           % prevent repetition of pitch in sequential
                           while arrayPitchIdx(1) == currF0idx
                               % shuffle the F0 array & get one F0
                               arrayPitchIdx = Shuffle(1:cfg.pattern.nF0);
                           end

                       end

                       % assign
                       currF0idx = arrayPitchIdx(counter); 
                       
                       disp(currF0idx)
                       
                       seqDesignToneF0(seqi,stepi,segmi,pati,whichTone(iTone)) = currF0idx; 
                       counter = counter + 1;
                   end
                end
                   
                % write pattern ID to the result
                % dims: [seq x step x segm x pat]
                seqDesignFullExp{seqi,stepi,segmi,pati} = chosenPatID; 
                seqDesignPatNb(seqi,stepi,segmi,pati) = chosenPatNb;
                seqDesignSegment{seqi,stepi,segmi,pati} = chosenSegmentID;
                
                % remove the picked pattern from the available pool
                patterns2choose{segmi}(chosenPatIdx) = []; 
                
            end
        end
    end
end

if all(cellfun(@isempty, patterns2choose))
    disp('hooray, the constructed audio sequences are fully counterbalanced ;)')
else
    disp('ouch, the experiment is NOT fully counterbalanced :(')
end



