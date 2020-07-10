function [cfg,expParam] = makefMRISeqDesign(cfg,expParam)

 % this function creates counterbalanced audio sequences for fMRI in 
 % by using subfunction as:
 % makeSequecen.m
 % getAllSeqDesign.m
 % makeStimMainExp.m
 
 % In the future it can be embedded into getParams.m script but since it's
 % depending on the expParam.runNb parameter, it should be causiously
 % embedded. (e.g. after the script gets runNb)

 
 %% Get counterbalanced sequences according to the total fMRI RUNs
%%%%%%%%%%%%
% ! important, the order of arguments matters ! -> getAllSeq(categA, categB, ...)
%%%%%%%%%%%%

% ADD EVEN/ODD RUNS STARTING WITH A OR B CATEG!!!

% CREATE counterbalanced sequences for every 3 sequence then multiply with
% 3 (in case they stop fMRI, or we want ot increase to 12 runs)
% expParam.numSequences = 3

if strcmp(cfg.device,'scanner')
    if expParam.runNb == 1
        DesignFullExp = getAllSeqDesign(cfg.patternSimple, cfg.patternComplex, cfg, expParam);
        save('SeqDesign','DesignFullExp');
        cfg.seqDesignFullExp = DesignFullExp;
    else
        design = load('SeqDesign');
        cfg.seqDesignFullExp = design.DesignFullExp;
    end
else
    cfg.seqDesignFullExp = getAllSeqDesign(cfg.patternSimple, cfg.patternComplex, cfg, expParam);
end





end