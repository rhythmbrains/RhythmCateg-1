function datalog = saveOutput(datalog, cfg, expParam, action)


% make sure logiles directory exists 
if ~exist('logfiles','dir')
    mkdir('logfiles')
end

DateFormat = 'yyyy_mm_dd_HH_MM';

Filename = fullfile(pwd, 'logfiles', ...
    ['sub-' datalog.subjectName, ...
    '_run-' datalog.runNumber, ...
    '_' datestr(now, DateFormat)]);


switch action
    
    
    % ==================================================================================
    case 'open'
        
        
        
        %----------------------------------------
        % .tsv file for stimulus
        %----------------------------------------
             
        % open text file
        datalog.fidStim = fopen([Filename,'_stimulus.txt'], 'w'); %'a'
        
        % print header
        fprintf(datalog.fidStim,'subjectID\trunNumber\tpatternID\tcategory\tonsetTime\tF0\tgridIOI\n'); 
        
        
        %----------------------------------------
        % .tsv file for tapping
        %----------------------------------------

        % open text file
        datalog.fidTap = fopen([Filename,'_tapping.txt'], 'w'); %'a'
        
        % print header
        fprintf(datalog.fidTap, 'subjectID\trunNumber\tseqi\ttapOnset\n'); 
        
        
        
    % ==================================================================================
    case 'update'
        
    % ==================================================================================
    case 'savemat'
        
        % save all config structures and datalog to .mat file
        save(fullfile([Filename,'_all.mat']), 'datalog', 'cfg', 'expParam')
       
        
    % ==================================================================================
    case 'close'
      
        % close txt log files
        fclose(datalog.fidStim);
        fclose(datalog.fidTap);
        
        
end



