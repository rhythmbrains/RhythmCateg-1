function logFile = saveOutput(subjectName,runNumber,logFile, cfg, input,varargin)


if nargin > 5
    iseq = varargin{1};
    ipattern = varargin{2};
end

if isfield(cfg,'responseEvents')
    responseEvents = cfg.responseEvents;
end

%% .tsv file
%logfile name for .txt or .tsv
% % % change the naming 
DateFormat = 'yyyy_mm_dd_HH_MM';
Filename = fullfile(pwd, 'logfiles', ...
    ['sub-' subjectName, ...
    '_run-' runNumber, ...
    '_' datestr(now, DateFormat) '.txt']);

FilenameR = fullfile(pwd, 'logfiles', ...
    ['sub-' subjectName, ...
    '_run-' runNumber, '.txt']);
% % %

switch input
    
    case 'open'
        
        if ~exist('logfiles','dir')
            mkdir('logfiles')
        end
        
        
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
        %  fprintf(fid, 'SubjID\tSequenceNum\tSegmentCateg\tPatternID\tPatternOnset\tTapOnset\tKeyPresses\tPatternGridRep\tgridIOI\tF0\t\n');
        %     logFile.patternOnsets
        %     logFile.patternEnds
        %     logFile.patternDurations
        %     logFile.sequenceOnsets
        %     logFile.sequenceEnds
        %     logFile.sequenceDurations
        
        % open a tsv/txt file to write the output
        
        
        logFile.responsetxt = fopen(FilenameR, 'w'); %'a'
        
        fprintf(logFile.responsetxt,'%12s %12s %12s %12s %12s %12s \n', ...
            'SubjID', ...
            'TapOnset', ...
            'PressedKey', ...
            'KeyName', ...
            'PatternNum',...
            'SequenceNum');
        
        
        
    case 'save'
        
        
        fprintf(logFile.txt,'%12.0f %12.0f %12s %18s %12.3f %12.3f %12.3f %12.3f %12s %12s %12.3f %12.0f \n', ...
            subjectName, ...
            iseq, ...
            seq.segmCateg(ipattern), ...
            seq.patternID(ipattern), ...
            logFile.iPatOnset(ipattern,iseq), ...
            seq.outPatterns(ipattern),...
            seq.gridIOI(ipattern,iseq),...
            seq.F0(ipattern,iseq));
        
        
        
    case 'saveresponse'
        
        for iResp = 1:size(responseEvents, 1)
            
            
            fprintf(logFile.responsetxt,'%12.0f %12.3f %12.0f %12s %12.0f %12.0f\n', ...
                subjectName, ...
                responseEvents(iResp).onset - cfg.experimentStartTime, ...
                responseEvents(iResp).pressed,...
                responseEvents(iEvent,1).key_name,...
                ipattern, ...
                iseq);
            
            
        end
        
        
        
        
        
    case 'savemat'
        
        %.mat file
        save([Filename,'_all.mat'])
        
        
    case 'close'
        
        % close txt log file
        fclose(logFile.txt);
        fclose(logFile.responsetxt);
        
        
end


end
