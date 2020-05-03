function saveOutput


% .tsv file
%logfile name for .tsv (for this script only)
DateFormat = 'yyyy_mm_dd_HH_MM';
Filename = fullfile(pwd, 'output', ...
    ['sub-' SubjName, ...
    '_run-' Run, ...
    '_case-n-' expLength, ...
    '_' datestr(now, DateFormat) '.tsv']);

% create the logfile folder 
% ans 7 means that a directory exist
if exist('logFile', 'dir') ~= 7
    mkdir('logFile');
end

% open a tsv file to write the output (for this script only)
fid = fopen(Filename, 'a');
fprintf(fid, 'SubjID\tSequenceNum\tSegment\tSequence\tTapOnset\t\tStimEnvelop\n');



end
