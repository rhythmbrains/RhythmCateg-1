function cfg = makefMRISeqDesign(cfg)

% this function creates counterbalanced audio sequences for fMRI in
% by using subfunction as:
% makeSequecen.m
% getAllSeqDesign.m
% makeStimMainExp.m

% It is embedded into getParams.m script but since it's
% depending on the expParam.runNb parameter, one should be causious on
% changing the function's location.(e.g. after the script gets runNb)

% if debug, put back run =1 so in the main script sequence =runNb ==1
runNb = cfg.subject.runNb;

if cfg.debug.do
    runNb = 1;
end

% path to save output
savepath = fullfile(fileparts(mfilename('fullpath')),'../');

%% Get counterbalanced sequences according to the total fMRI RUNs
%%%%%%%%%%%%
% to do!
% ADD SHUFFLE ORDER FOR STARTING WITH A OR B CATEG for BLOCK DESING !
%%%%%%%%%%%%

%%%%%%%%%%%%
% ! important, the order of arguments matters ! -> getAllSeq(categA, categB, ...)
% getAllSeqDesign(cfg.patternSimple, cfg.patternComplex, cfg, expParam);
%%%%%%%%%%%%

%%%%%%%%%%%%
% keep in mind:
% DesginFullExp (runNum, stepNum,segmentNum,patternNum)
%%%%%%%%%%%%

if runNb == 1
    
    % get the design
    [DesignFullExp, DesignSegment, DesignToneF0] = getAllSeqDesign(...
                                        cfg.pattern.patternA,...
                                        cfg.pattern.patternB, cfg);
                                    
    % add Task according to SegmentLabels
    cfg = addRandomizedTask(cfg,DesignSegment,cfg.pattern.numSequences);
    
    %save the Design
    save([savepath,'SeqDesign'],'DesignFullExp','DesignSegment','DesignToneF0','cfg');
    cfg.pattern.seqDesignFullExp = DesignFullExp;
    cfg.pattern.seqDesignSegment = DesignSegment;
    cfg.pattern.seqDesignToneF0 = DesignToneF0;
    
else
    
    design = load([savepath,'SeqDesign']);
    cfg.pattern.seqDesignFullExp = design.DesignFullExp;
    cfg.pattern.taskIdxMatrix = design.cfg.pattern.taskIdxMatrix; 
    cfg.pattern.seqDesignSegment = design.DesignSegment;
    cfg.pattern.seqDesignToneF0 = design.DesignToneF0;

    
end


%% Adding extra sessions design matrix
if runNb > cfg.pattern.numSequences && mod(runNb,3)==1
    
    %create design matrix
    [extraSeqDesign,extraSeqSegment,extraSeqToneF0] = getAllSeqDesign(cfg.pattern.patternA,...
        cfg.pattern.patternB, cfg, cfg.pattern.extraSeqNum);
    
    %create task matrix
    extracfg = addRandomizedTask(cfg,extraSeqSegment,cfg.pattern.extraSeqNum);
    
    % add and assign new design with task
    cfg.pattern.seqDesignFullExp = [cfg.pattern.seqDesignFullExp; ...
        extraSeqDesign];
    cfg.pattern.taskIdxMatrix = [cfg.pattern.taskIdxMatrix; ...
        extracfg.pattern.taskIdxMatrix];
    
    cfg.pattern.seqDesignSegment = [cfg.pattern.seqDesignSegment; ...
        extraSeqSegment]; 
    
    cfg.pattern.seqDesignToneF0 = [cfg.pattern.seqDesignToneF0; ...
        extraSeqToneF0];
    
    
    %save to be called later in runs
    DesignFullExp = cfg.pattern.seqDesignFullExp;
    DesignSegment = cfg.pattern.seqDesignSegment;
    DesignToneF0 = cfg.pattern.seqDesignToneF0;
    save([savepath,'SeqDesign'],'DesignFullExp','DesignSegment',...
                                'cfg','extracfg','extraSeqSegment',...
                                'DesignToneF0','extraSeqToneF0');
    
    fprintf('new sequence design and task added! Wohoo!\n\n');
end


end

function cfg = addRandomizedTask(cfg,Design,numSequence)

%create an empty cell to store the task==1s and 0s
taskIdxMatrix =  zeros(...
    numSequence, ...
    cfg.pattern.nStepsPerSequence,...
    cfg.pattern.nSegmPerStep, ...
    cfg.pattern.nPatternPerSegment);
    
% find the categA and categB from SegmentLabel
idxCategA = contains(Design(:),cfg.pattern.labelSegmentA);
idxCategB = contains(Design(:),cfg.pattern.labelSegmentB);

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