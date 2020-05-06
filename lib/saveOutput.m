function logFile = saveOutput(subjectName,runNumber,logFile, cfg, input)



switch input
    
    case 'open'
        
        if ~exist('logfiles','dir')
            mkdir('logfiles')
        end
        
        
        %% .tsv file
        %logfile name for .txt or .tsv
        DateFormat = 'yyyy_mm_dd_HH_MM';
        Filename = fullfile(pwd, 'logfiles', ...
            ['sub-' subjectName, ...
            '_run-' runNumber, ...
            '_' datestr(now, DateFormat) '.txt']);

        
        % open a tsv/txt file to write the output 
        logFile.txt = fopen(Filename, 'w'); %'a'
        fprintf(logFile.txt,'%12s %12s %12s %18s %12s %12s %12s %12s %12s %12s %12s %12s \n', ...
            'SubjID', ...
            'SequenceNum', ...
            'SegmentCateg', ...
            'PatternID', ...
            'PatternOnset', ...
            'PatternEnd', ...
            'PatternDuration', ...
            'TapOnset', ...
            'KeyPresses', ...
            'PatternGridRep',...
            'gridIOI',...
            'F0');
%         fprintf(fid, 'SubjID\tSequenceNum\tSegmentCateg\tPatternID\tPatternOnset\tTapOnset\tKeyPresses\tPatternGridRep\tgridIOI\tF0\t\n');

        %     logFile.patternOnsets
        %     logFile.patternEnds
        %     logFile.patternDurations
        %     logFile.sequenceOnsets
        %     logFile.sequenceEnds
        %     logFile.sequenceDurations

        
        

        
    case 'save'
        
%         % Event txt_Logfile
%         fprintf(logFile.EventTxtLogFile,'%12.0f %12.0f %12.0f %18.0f %12.2f %12.5f %12.5f %12.5f \n',...
%             iBlock, ...
%             iEventsPerBlock, ...
%             logFile.iEventDirection, ...
%             logFile.iEventIsFixationTarget, ...
%             logFile.iEventSpeed, ...
%             logFile.eventOnsets(iBlock, iEventsPerBlock), ...
%             logFile.eventEnds(iBlock, iEventsPerBlock), ...
%             logFile.eventDurations(iBlock, iEventsPerBlock));
        
    case 'savemat'
        
        %.mat file
        save(fullfile('logfiles',[Filename,'_all.mat']))
        
        
    case 'close'
        
        % close txt log file
        fclose(logFile.txt);
        
        
end


end
