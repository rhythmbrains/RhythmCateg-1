function [cfg] = makeBehavInstruction(cfg)
% this function makes ALL behavioral task instructions by calling
% makeInstruc script as well as a small for loop which reads from already made-text files
% to create/read for sequence  instructions


cfg.dir.instr = fullfile(fileparts(mfilename('fullpath')), 'subfun',...
                         'instr','mainExp');
% refractor below
% -------------------
% intro instructions  # 1
% -------------------
cfg = makeInstruc('instrMainExpIntro',cfg.dir.instr,cfg, 'introInstruction');
% ------------------------
% general task instructions # 2
% ------------------------
cfg = makeInstruc('instrMainExpGeneral',cfg.dir.instr,cfg, 'generalInstruction');
% ------------------------------------------------
% instruction showing info about sequence curation 
% ------------------------------------------------
cfg.trialDurInstruction = [sprintf('Trial duration will be: %.1f minutes\n\n',...
                           cfg.pattern.SequenceDur/60), ...
                            'Set your volume now. \n\n\nThen start the experiment whenever ready...\n\n'];                       
% ------------------------------
% sequence-specific instructions
% ------------------------------
% this is general instruction displayed after each sequence
cfg.generalDelayInstruction = ['The %d out of %d is over!\n\n', ...
                            'You can have a break. \n\n',...
                            'Good luck!\n\n']; 


% For each sequence, there can be additional instructions. 
% Save as text file with name: 'instrMainExpDelay#', 
% where # is the index of the sequence after which the
% instruction should appear. 

dirInstr = dir(fullfile(cfg.dir.instr,'instrMainExpDelay*')); 
cfg.seqSpecificDelayInstruction = cell(1, cfg.pattern.numSequences); 

for i=1:length(dirInstr)
    
    targetSeqi = regexp(dirInstr(i).name, '(?<=instrMainExpDelay)\d*', 'match'); 
    targetSeqi = str2num(targetSeqi{1}); 
    instrFid = fopen(fullfile(cfg.dir.instr, dirInstr(i).name),'r','n','UTF-8'); 
    
    while ~feof(instrFid)
        cfg.seqSpecificDelayInstruction{targetSeqi} = [...
            cfg.seqSpecificDelayInstruction{i}, fgets(instrFid)]; 
    end
    
    fclose(instrFid);
end