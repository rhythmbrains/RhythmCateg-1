function [subjectName, runNumber] = getSubjectID(cfg)
% Get Subject Name, run number


if cfg.debug
    
    subjectName = [];
    runNumber = [];

    
else
    
    subjectName = input('Enter Subject ID number: ','s');
    runNumber = input('Enter the run Number: ','s');
    
    
    if ~isnumeric(subjectName)
        subjectName = input('Please enter a numeric value for Subject ID : ','s');
    end
    
    if ~isnumeric(runNumber)
        runNumber = input('Please enter a numeric value for run number : ','s');
    end    
    
    
end

if isempty(subjectName)
    subjectName = '001';
end

if isempty(runNumber)
    runNumber = '666';
end





%     if exist(fullfile(pwd, '..', 'logfiles',[subjectName,'_run_',num2str(runNumber),num2str(sessionNumber),'.mat']),'file')>0
%         error('This file is already present in your logfiles. Delete the old file or rename your run!!')
%     end




end