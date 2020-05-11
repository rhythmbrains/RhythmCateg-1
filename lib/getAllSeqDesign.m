function res = getAllSeqDesign(categA,categB,cfg,expParam)

% this function designs the sequences for the whole experiment in a way
% that the number of times each pattern is included is counterbalanced and
% randomized as much as possible

% of course, the possibility of full counterbalancing depends on the number
% of sequences, steps, sements, and patterns requested in the experiment

patterns2choose = {categA,categB}; 

res = cell(expParam.numSequences, cfg.nStepsPerSequence, cfg.nSegmPerStep, cfg.nPatternPerSegment); 

for seqi=1:expParam.numSequences

    for stepi=1:cfg.nStepsPerSequence 

        for segmi=1:cfg.nSegmPerStep
            
            for pati=1:cfg.nPatternPerSegment

                % Determine which segment category this is (A or B)
                % (the first 'cfg.nSegmentA' segments will be category A, 
                % the rest will be category B)
                if ismember(segmi, [1:cfg.nSegmentA])            
                    categIdx = 1; 
                    % check if the category is empty in the avaiable pool of
                    % patterns
                    % if so, refill it with the whole set for that category
                    if isempty(patterns2choose{categIdx})
                        patterns2choose{categIdx} = categA; 
                    end
                else
                    categIdx = 2; 
                    % check if the category is empty in the avaiable pool of
                    % patterns
                    % if so, refill it with the whole set for that category
                    if isempty(patterns2choose{categIdx})
                        patterns2choose{categIdx} = categB; 
                    end
                end
                
                % pick a pattern from the current category
                chosenPatIdx = randsample(length(patterns2choose{categIdx}),1); 
                
                % get its ID tag
                chosenPatID = patterns2choose{categIdx}(chosenPatIdx).ID; 
                
                % write pattern ID to the result
                % dims: [seq x step x segm x pat]
                res{seqi,stepi,segmi,pati} = chosenPatID; 

                % remove the picked pattern from the available pool
                patterns2choose{categIdx}(chosenPatIdx) = []; 
                
                
            end
        end
    end
end

if all(cellfun(@isempty, patterns2choose))
    disp('hooray, the experiment is fully counterbalanced ;)')
else
    disp('ouch, the experiment is NOT fully counterbalanced :(')
end




