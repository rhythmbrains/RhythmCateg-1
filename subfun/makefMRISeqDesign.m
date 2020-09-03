function cfg = makefMRISeqDesign(cfg)

% this function creates counterbalanced audio sequences for fMRI in
% by using subfunction as:
% makeSequecen.m
% getAllSeqDesign.m
% makeStimMainExp.m

% In the future it can be embedded into getParams.m script but since it's
% depending on the expParam.runNb parameter, it should be causiously
% embedded. (e.g. after the script gets runNb)
% if debug, put back run =1 so in the main script sequence =runNb ==1
runNb = cfg.subject.runNb;

if cfg.debug.do
    runNb = 1;
end

% path to save output
savepath = fullfile(fileparts(mfilename('fullpath')),'../');

%% Get counterbalanced sequences according to the total fMRI RUNs
% to do!
% ADD SHUFFLE ORDER FOR STARTING WITH A OR B CATEG for BLOCK DESING !


%%%%%%%%%%%%
% ! important, the order of arguments matters ! -> getAllSeq(categA, categB, ...)
% getAllSeqDesign(cfg.patternSimple, cfg.patternComplex, cfg, expParam);
%%%%%%%%%%%%


if runNb == 1
    
    % get the design
    [DesignFullExp, ~] = getAllSeqDesign(cfg.pattern.patternSimple,...
        cfg.pattern.patternComplex, cfg);
    % DesginFullExp (runNum, stepNum,segmentNum,patternNum)

    cfg = addRandomizedTask(cfg,DesignFullExp,cfg.pattern.numSequences);
    
    
    %save the Design
    save([savepath,'SeqDesign'],'DesignFullExp','cfg');
    cfg.pattern.seqDesignFullExp = DesignFullExp;
    
else
    
    design = load([savepath,'SeqDesign']);
    cfg.pattern.seqDesignFullExp = design.DesignFullExp;
    cfg.pattern.taskIdxMatrix = design.cfg.pattern.taskIdxMatrix; 
    
end


% for extra sessions Design adding
if runNb > cfg.pattern.numSequences && mod(runNb,3)==1
    
    %create design matrix
    [extraSeqDesign,~] = getAllSeqDesign(cfg.pattern.patternSimple,...
        cfg.pattern.patternComplex, cfg, cfg.pattern.extraSeqNum);
    
    %create task matrix
    extracfg = addRandomizedTask(cfg,extraSeqDesign);
    
    % add and assign new design with task
    DesignFullExp = [DesignFullExp; extraSeqDesign];
    cfg.pattern.seqDesignFullExp = DesignFullExp;
    cfg.pattern.taskIdxMatrix = [cfg.pattern.taskIdxMatrix; ...
        extracfg.pattern.taskIdxMatrix];
    
    %save
    save([savepath,'SeqDesign'],'DesignFullExp','cfg','extracfg');
    
end


end

function cfg = addRandomizedTask(cfg,Design,numSequence)

%create an empty cell to store the task==1s and 0s
taskIdxMatrix =  zeros(...
    numSequence, ...
    cfg.pattern.nStepsPerSequence,...
    cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment);
    
% find the categA and categB
idxCategA = contains(Design(:),cfg.pattern.labelCategA);
idxCategB = contains(Design(:),cfg.pattern.labelCategB);

%count the number of patterns categA and categB
categANum = sum(idxCategA);
categBNum = sum(idxCategB);


% take the 10%
% of patterns
cfg.pattern.categANumTarget = round(categANum*0.1);
cfg.pattern.categBNumTarget = round(categBNum*0.1);


%create zero array
categA = zeros(categANum,1);
categB = zeros(categBNum,1);


%assign 1s to indicate the targets
categA(1:cfg.pattern.categANumTarget) = 1;
categB(1:cfg.pattern.categBNumTarget) = 1;

%and shuffle the order or target across seq (runs), steps, segments, ...
idxCategATarget = Shuffle(categA);
idxCategBTarget = Shuffle(categB);


%save it to expParams for using the order in makeSequence.m
taskIdxMatrix(idxCategA)= idxCategATarget;
taskIdxMatrix(idxCategB)= idxCategBTarget;

% control for all the beginning on runs == beginning of
% sequences
% A(irun,1,1,1) is equal to A(irun)
for irun=1:length(taskIdxMatrix)
    while taskIdxMatrix(irun) == 1
        
        idxCategATarget = Shuffle(categA);
        taskIdxMatrix(idxCategA)= idxCategATarget;
        
    end
    if taskIdxMatrix(irun)
        sprintf('There''s a target in the first pattern!');
    end
end

cfg.pattern.taskIdxMatrix = taskIdxMatrix;

end