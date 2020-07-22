function logFile = getVariable2Save
% to make main script pretty, we are using this mini function.
% we are adding whatever we want to be saved
% and their corresponding array length into logFile structure. 


logFile = struct();

% define the extra columns: they will be added to the tsv files in the order the user input them
logFile.extraColumns = {'sequenceNum', 'segmentNum', 'segmentOnset', ...
    'stepNum', 'stepOnset', 'patternID', 'segmentCateg', 'F0', 'isTask', ...
    'gridIOI', 'patternAmp', 'minPE4', 'rangePE4', 'minLHL24', ...
    'rangeLHL24', 'LHL24', 'PE4'};
    
% define the extra columns: they will be added to the tsv files in the order the user input them,
% convert the cell of column name into a structure
    if iscell(logFile(1).extraColumns)
        tmp = struct();
        for iExtraColumn = 1:numel(logFile(1).extraColumns)
            extraColumnName = logFile(1).extraColumns{iExtraColumn};
            tmp.(extraColumnName) = struct('length', 1);
        end
        logFile(1).extraColumns = tmp;
    end
    
% logFile.extraColumns.sequenceNum.length = 1;
% logFile.extraColumns.segmentOnset.length = 1;
% logFile.extraColumns.stepNum.length = 1;
% logFile.extraColumns.stepOnset.length = 1;
% logFile.extraColumns.patternID.length = 1;
% logFile.extraColumns.segmentCateg.length = 1;
% logFile.extraColumns.F0.length = 1;
% logFile.extraColumns.isTask.length =1;
% logFile.extraColumns.gridIOI.length = 1;
% logFile.extraColumns.patternAmp.length = 1;
% logFile.extraColumns.minPE4.length = 1;
% logFile.extraColumns.rangePE4.length = 1;
% logFile.extraColumns.minLHL24.length = 1;
% logFile.extraColumns.rangeLHL24.length = 1;

 
logFile(1).extraColumns.LHL24.length = 12; % will set 12 columns with names LHL24-01, LHL24-02, ...
logFile(1).extraColumns.PE4.length = 12;


end