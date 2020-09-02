function [seqDesignFullExp, seqDesignToneNumber] = getAllSeqDesign(categA,categB,cfg,varargin)

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
seqDesignFullExp = cell(numSequences, ...
    cfg.pattern.nStepsPerSequence, cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment); 

seqDesignToneNumber = zeros(numSequences, ...
    cfg.pattern.nStepsPerSequence, cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment); 

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
                chosenToneNumID = patterns2choose{segmi}(chosenPatIdx).n_sounds;
                % write pattern ID to the result
                % dims: [seq x step x segm x pat]
                seqDesignFullExp{seqi,stepi,segmi,pati} = chosenPatID; 
                seqDesignToneNumber(seqi,stepi,segmi,pati) = chosenToneNumID;
                
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




