function [cfg,expParam] = makefMRISeqDesign(cfg,expParam)

% this function creates counterbalanced audio sequences for fMRI in
% by using subfunction as:
% makeSequecen.m
% getAllSeqDesign.m
% makeStimMainExp.m

% In the future it can be embedded into getParams.m script but since it's
% depending on the expParam.runNb parameter, it should be causiously
% embedded. (e.g. after the script gets runNb)
% if debug, put back run =1 so in the main script sequence =runNb ==1
if cfg.debug 
    expParam.runNb = 1;
end

%% Get counterbalanced sequences according to the total fMRI RUNs
% ADD SHUFFLE ORDER FOR STARTING WITH A OR B CATEG for BLOCK DESING !

% CREATE counterbalanced sequences for every 3 sequence then multiply with
% 3 (in case they stop fMRI, or we want ot increase to 12 runs)
% expParam.numSequences = 3

expParam.fmriTask = true;


%%%%%%%%%%%%
% ! important, the order of arguments matters ! -> getAllSeq(categA, categB, ...)
% getAllSeqDesign(cfg.patternSimple, cfg.patternComplex, cfg, expParam);
%%%%%%%%%%%%

if strcmp(cfg.device,'scanner')
    if expParam.runNb == 1
        
        %make the design
        DesignFullExp = getAllSeqDesign(cfg.patternSimple, cfg.patternComplex, cfg, expParam);
        
        if expParam.fmriTask
            %create an empty cell to store the task==1s and 0s
            cfg.fMRItaskidx =  zeros(...
                expParam.numSequences, ...
                cfg.nStepsPerSequence,...
                cfg.nSegmPerStep, ...
                cfg.nPatternPerSegment);
            
            % find the categA and categB
            idxCategA = contains(DesignFullExp(:),cfg.labelCategA);
            idxCategB = contains(DesignFullExp(:),cfg.labelCategB);
            
            %count the number of categA and categB
            categANum = sum(idxCategA);
            categBNum = sum(idxCategB);
            
            % take the 10%
            expParam.categANumTask = round(categANum*0.1);
            expParam.categBNumTask = round(categBNum*0.1);
            
            %create zero array
            categA = zeros(categANum,1);
            categB = zeros(categBNum,1);
            
            %assign ones (marking for target)
            categA(1:expParam.categANumTask) = 1;
            categB(1:expParam.categBNumTask) = 1;
            
            %and shuffle the order or target across seq (runs), steps, segments, ...
            idxCategATarget = Shuffle(categA);
            idxCategBTarget = Shuffle(categB);
            
            %save it to expParams for using the order in makeSequence.m
            cfg.fMRItaskidx(idxCategA)= idxCategATarget;
            cfg.fMRItaskidx(idxCategB)= idxCategBTarget;
            
        end
        
        %save the Design
        save('SeqDesign','DesignFullExp','cfg');
        cfg.seqDesignFullExp = DesignFullExp;
        
    else
        
        design = load('SeqDesign');
        cfg.seqDesignFullExp = design.DesignFullExp;
        cfg.fMRItaskidx = design.cfg.fMRItaskidx;
        
    end
    

end


end