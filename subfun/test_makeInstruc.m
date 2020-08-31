function test_suite = test_makeInstruc %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_makeInstrucDefault()


%% set up
loadPathInstr = fullfile(fileparts(mfilename('fullpath')), 'instr','mainExp');

%% create test data
expectedStructure = [];
cfg = [];
expectedStructure = makeInstruc('instrMainExpIntro',loadPathInstr,expectedStructure, 'introInstruction');


dirInstr = dir(fullfile(loadPathInstr,'instrMainExpIntro*')); 
cfg.introInstruction = cell(1,length(dirInstr)); 
for i=1:length(dirInstr)
    instrFid = fopen(fullfile(loadPathInstr, dirInstr(i).name),'r','n','UTF-8'); 
    while ~feof(instrFid)
        cfg.introInstruction{i} = [cfg.introInstruction{i}, fgets(instrFid)]; 
    end
    fclose(instrFid); 
end

%% test
assertEqual(expectedStructure, cfg);


end


function test_makeInstrucGeneral()

%% set up
loadPathInstr = fullfile(fileparts(mfilename('fullpath')), 'instr','mainExp');


%% create test data
expectedStructure = [];
cfg = [];
expectedStructure = makeInstruc('instrMainExpGeneral',loadPathInstr,expectedStructure, 'generalInstruction');


dirInstr = dir(fullfile(loadPathInstr,'instrMainExpGeneral')); 
cfg.generalInstruction = ''; 
instrFid = fopen(fullfile(loadPathInstr, dirInstr.name),'r','n','UTF-8'); 
while ~feof(instrFid)
    cfg.generalInstruction = [cfg.generalInstruction, fgets(instrFid)]; 
end
fclose(instrFid);


end