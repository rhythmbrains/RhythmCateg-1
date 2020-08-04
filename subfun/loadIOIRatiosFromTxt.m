function [patterns,ioi_ratios] = loadIOIRatiosFromTxt(load_path)

patterns = {}; 
ioi_ratios = {}; 

fid = fopen(fullfile(load_path),'r'); 
while ~feof(fid)
    l = fgetl(fid); 
    l(isspace(l)) = []; 
    tmp_pat = zeros(1,length(l)); 
    c = 0; 
    tmp_pat(c+1) = 1; 
    for i=1:length(l)
        c = c + str2num(l(i)); 
        tmp_pat(c+1) = 1; 
    end
    ioi_ratios(end+1) = {diff(find(tmp_pat))}; 
    % remove last sound event
    tmp_pat(end) = []; 
    patterns(end+1) = {tmp_pat}; 
end
fclose(fid); 



