function seq = makeSequence(cfg,categA,categB,varargin)
% This function constructs a stimulus sequence.
% by using makeStimMainExp.m script

% ------
% INPUT
% ------
%     cfg:          structure with confuguration info
%     categA:    
%     categB:    
% 
% ------
% OUTPUT
% ------
%     seq:          structure with stimulus sequence and info about it
%
%



%% allocate variables to log

% main output structure (we'll put everything else into it)
seq = struct(); 

% vector of F0 (pitch) values for each pattern in the sequence
seq.F0 = zeros(1, cfg.nPatternPerSegment * cfg.nSegmPerStep * cfg.nStepsPerSequence); 

% vector of gridIOI values for each pattern in the sequence
seq.gridIOI = zeros(1, cfg.nPatternPerSegment * cfg.nSegmPerStep * cfg.nStepsPerSequence); 

% segment-category (A or B) for each pattern in the sequence 
seq.segmCateg = cell(1, cfg.nPatternPerSegment * cfg.nSegmPerStep * cfg.nStepsPerSequence); 

% each pattern will have its own ID (integer number; patterns with the same
% ID number from category A vs. B will have the same inter-onset intervals,
% just rearranged in time)
seq.patternID = cell(1, cfg.nPatternPerSegment * cfg.nSegmPerStep * cfg.nStepsPerSequence); 

% cell array, each element is a grid representation of the chosen pattern
% (successively as the sequence unfolds)
seq.outGridRepresentation = cell(1, cfg.nPatternPerSegment * cfg.nSegmPerStep * cfg.nStepsPerSequence);

% audio waveform of the sequence
seq.outAudio = zeros(1,round(cfg.SequenceDur*cfg.fs)); 



%% initialize counters 

% currently chosen F0 index (indexing value in cfg.F0s, initialize to 1)
currF0idx = 1; 

% currently chosen gridIOI index (indexing value in cfg.gridIOIs, initialize to 1)
currGridIOIidx = 1; 


% currently chosen pattern ID (we need to initialize to something 
% because we'll be using this to make sure there is no direct repetition
% of patterns in the sequence)
currPatternID = Inf; 

% pattern counter (over the whole sequence)
cPat = 1; 

% current duration in the sequence as we go through the loops
currDuration = 0; 




%% loop over steps
for stepi=1:cfg.nStepsPerSequence
    
    
   
    
    
    %% loop over segments in 1 sequence
    % to make 
    for segmi=1:cfg.nSegmPerStep
        
        
        % Determine which segment category this is (A or B)
        % and set the pool of patterns. 

        % the first 'cfg.nSegmentA' segments will be category A, 
        % the rest will be B
        if ismember(segmi, [1:cfg.nSegmentA])            
            currCateg = 'A'; 
            patterns2use = categA; 
        else
            currCateg = 'B'; 
            patterns2use = categB; 
        end
        
        
        
        
        
        
        %% loop over pattern cycles in 1 segment
        % to create a segment
        for cyclei=1:cfg.nPatternPerSegment
    
            
            % --------------------------------------------------
            % ----- determine if gridIOI needs to be changed ---
            % --------------------------------------------------
            CHANGE_IOI = 0; 
            
            % gridIOI change requested every segment (and this is the first
            % cycle in the segment)
            if cfg.changeGridIOISegm && cyclei == 1
                CHANGE_IOI = 1; 
                
            % gridIOI change requested every category (and this is the first
            % cycle in the segment, and a category just changed from A->B
            % or B->A)
            elseif cfg.changeGridIOICategory && cyclei == 1 && ...
                    ( segmi == 1 || segmi == cfg.nSegmentA+1 )
                CHANGE_IOI = 1; 
                
            % gridIOI change requested every step 
            elseif cfg.changeGridIOIStep && segmi==1
                CHANGE_IOI = 1; 
                
            end
                        
            % if change of gridIOI requested, randomly choose a new gridIOI
            % do this only if there is more than 1 gridIOI to choose from
            if CHANGE_IOI && length(cfg.gridIOIs)>1
                % get gridIOI to choose from 
                gridIOI2ChooseIdx = 1:length(cfg.gridIOIs); 
                % remove gridIOI used in the previous iteration (to prevent
                % repetition in the sequence) 
                gridIOI2ChooseIdx(gridIOI2ChooseIdx==currGridIOIidx) = []; 
                % randomly select new IOI
                currGridIOIidx = randsample(gridIOI2ChooseIdx); 
            end
            
            currGridIOI = cfg.gridIOIs(currGridIOIidx); 
            
            
            % --------------------------------------------------
            % ----- determine if pitch needs to be changed -----
            % --------------------------------------------------
            CHANGE_PITCH = 0; 
            
            % pitch change requested in every pattern cycle
            if cfg.changePitchCycle
                CHANGE_PITCH = 1; 
                
            % pitch change requested in every segment (and this is the first
            % pattern cycle in the segment)
            elseif cfg.changePitchSegm && cyclei==1
                CHANGE_PITCH = 1; 
                
            % pitch change requested every category (and this is the first
            % pattern cycle in the segment, and a category just changed from A->B
            % or B->A)
            elseif cfg.changePitchCategory && cyclei==1 && ...
                    ( segmi==1 || segmi==cfg.nSegmentA+1 )
                CHANGE_PITCH = 1; 
                
            % pitch change requested only in every step 
            elseif cfg.changePitchStep && segmi==1
                CHANGE_PITCH = 1; 
                
            end
            
            % if change of pitch requested, randomly choose a new pitch
            % do this only if there is more than 1 F0 to choose from
            if CHANGE_PITCH && length(cfg.F0s)>1
                % get F0s to choose from 
                pitch2ChooseIdx = 1:length(cfg.F0s); 
                % remove F0 used in the previous iteration (to prevent
                % repetition in the sequence) 
                pitch2ChooseIdx(pitch2ChooseIdx==currF0idx) = []; 
                % randomly select new F0 idx
                currF0idx = randsample(pitch2ChooseIdx,1); 
            end
            
            currF0 = cfg.F0s(currF0idx); 
            
            
            
            % --------------------------------------------------
            % --------------- select new pattern ---------------
            % --------------------------------------------------
            
            % get pattern IDs to choose from 
            patternIDs2Choose = [patterns2use.ID]; 
            % remove the pattern ID used in the previous iteration (to prevent
            % pattern repetition in the sequence) 
            patternIDs2Choose(patternIDs2Choose==currPatternID) = []; 
            % randomly select a pattern
            currPatternID = randsample(patternIDs2Choose,1); 
            %assign the chosen pattern
            currpattern = patterns2use(currPatternID).pattern;
            % log the chosen pattern (grid representation) into the output
            seq.outGridRepresentation{1,cPat} = currpattern; 
            
            % make audio 
            [patternAudio,currEnv] = makeStimMainExp(currpattern, cfg, currGridIOI, currF0); 
           
            % create a vector for the envelopes 
            %later on change this to find whole sequence envelope?
            seq.patternEnv{cPat} = currEnv;
            
            % get current audio index in the sequence, and append the audio
            currAudioIdx = round(currDuration*cfg.fs); 
            seq.outAudiocurrAudioIdx(currAudioIdx+1:currAudioIdx+length(patternAudio)) = patternAudio; 
                        
            % save info about the selected pattern
            seq.patternID(cPat) = currPatternID; 
            seq.segmCateg{cPat} = currCateg; 
            
            

            % --------------------------------------------------
            % update current time position
            currDuration = currDuration + cfg.interPatternInterval;         

            % increase pattern counter
            cPat = cPat+1; 
            
                       
            
        end
        
        
        % add delay after each category (if applicable)
        if strcmpi(currCateg,'A')
            currDuration = currDuration + cfg.delayAfterA;         
        elseif strcmpi(currCateg,'B')
            currDuration = currDuration + cfg.delayAfterB;         
        end

        
    end
    
    
end



% save the pattern info for each category 
seq.categA = categA; 
seq.categB = categB; 


