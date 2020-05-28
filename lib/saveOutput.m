function expParam = saveOutput(cfg, expParam, action,varargin)


% make sure logiles directory exists 
if ~exist('logfiles','dir')
    mkdir('logfiles')
end

dateFormat = 'yyyymmdd_HHMM';

Filename = fullfile(pwd, 'logfiles', ...
    ['sub-' num2str(expParam.subjectNb), ...
    '_run-' num2str(expParam.runNb), ...
    '_' datestr(now, dateFormat)]);

% expParam.outputDir = fullfile (...
%     expParam.outputDir, ...
%     'source', ...
%     ['sub-' subjectGrp, sprintf(pattern, subjectNb)], ...
%     ['ses-', sprintf(pattern, sessionNb)]);


%% MAIN EXPERIMENT
if strcmp(expParam.task,'tapMainExp')

    switch action

        % ==================================================================================
        case 'open'

            %----------------------------------------
            % .tsv file for stimulus
            %----------------------------------------

            % open text file
            expParam.fidStim = fopen([Filename,'_mainStimulus.tsv'], 'w'); %'a'

            % print header
            fprintf(expParam.fidStim,'subjectID\trunNumber\tpatternID\tcategory\tonsetTime\tF0\tgridIOI\n'); 

            %----------------------------------------
            % .tsv file for tapping
            %----------------------------------------

            % open text file
            expParam.fidTap = fopen([Filename,'_mainTapping.tsv'], 'w'); %'a'

            % print header
            fprintf(expParam.fidTap, 'subjectID\trunNumber\tseqi\ttapOnset\n'); 

        % ==================================================================================
        case 'updateStim'
            
            currSeq = varargin{1};
            
            % each pattern on one row
            for iPattern=1:length(currSeq)
                fprintf(expParam.fidStim,'%d\t%d\t%s\t%s\t%f\t%f\t%f\n', ...
                    expParam.subjectNb, ...
                    expParam.runNb, ...
                    currSeq(iPattern).patternID, ...
                    currSeq(iPattern).segmCateg, ...
                    currSeq(iPattern).onset, ...
                    currSeq(iPattern).F0, ...
                    currSeq(iPattern).gridIOI);
            end
            
        % ==================================================================================     
        case 'updateTap'
            
            % each tap on one row
            fprintf(expParam.fidTap, '%d\t%d\t%d\t%f\n', ...
                expParam.subjectNb, ...
                expParam.runNb, ...
                expParam.seqi, ...
                varargin{1});
            
        % ==================================================================================
        case 'savemat'

            % save all config structures and datalog to .mat file
            save(fullfile([Filename,'_mainAll.mat']),'cfg', 'expParam')

        % ==================================================================================
        case 'close'

            % close txt log files
            if isfield(expParam,'fidStim') || isfield(expParam,'fidTap')
                fclose(expParam.fidStim);
                fclose(expParam.fidTap);
            end

    end

    
    
%% TAP TRAINING
elseif strcmp(expParam.task,'tapTraining')
    
    switch action

        % ==================================================================================
        case 'open'

            % open tsv file
            expParam.fidTapTrainer = fopen([Filename,'_tapTraining.tsv'], 'w'); %'a'

            % print header
            fprintf(expParam.fidTapTrainer, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
            'subjectID',...             % subject id
            'pattern',...               % pattern 
            'seqStartTime',...          % machine time of sequence audio start
            'cuePeriod',...             % cue (i.e. metronome) period (N of grid-points)
            'cueLeveldB',...            % cue (i.e. metronome) level in dB 
            'analysisWin', ...          % index (count) of this analysis window (for this sequence)
            'winStartTime', ...         % analysis window start time wrt sequence start
            'tapOnset');                % tap onset time relative to sequence start time

        % ==================================================================================
        case 'update'

        % ==================================================================================
        case 'savemat'

            % save all config structures and datalog to .mat file
            save(fullfile([Filename,'_tapTraining.mat']),'cfg', 'expParam')

        % ==================================================================================
        case 'close'

            % close txt log files
            if isfield(expParam,'fidStim') || isfield(expParam,'fidTap')
                fclose(expParam.fidStim);
                fclose(expParam.fidTap);
            end
    end

    
    
end
