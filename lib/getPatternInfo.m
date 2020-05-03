function patterns=getPatternInfo(allperms_clean, cfg, varargin)
% 
% varargin: 
%     'save_path'       string, if passed the audio will be saved to this folder for each rhythm
%     'save_label'      string that will be used as prefix for each audio filename
%     'nonmeter'        bool flag, if present noninteger ratios will be used
% 
% documentation needed
% 
%
% 
%

do_save = 0; 
if any(strcmpi(varargin,'save_path'))
   do_save = 1; 
   save_path = varargin{find(strcmpi(varargin,'save_path'))+1}; 
   if ~isdir(save_path)
      mkdir(save_path);  
   end
end
if any(strcmpi(varargin,'save_label'))
   save_label = varargin{find(strcmpi(varargin,'save_label'))+1}; 
end
        


patterns = struct(); 
for pati=1:length(allperms_clean)
    
    fprintf('pattern %d\n', pati)
    
    PE_3 = zeros(1,length(allperms_clean{pati}));     
    PE_4 = zeros(1,length(allperms_clean{pati}));     

    LHL_22 = zeros(1,length(allperms_clean{pati}));     
    LHL_32 = zeros(1,length(allperms_clean{pati})); 
    LHL_23 = zeros(1,length(allperms_clean{pati})); 
    
    pattern = cell(1,length(allperms_clean{pati})); 
    patterns(pati).phase = [0:length(allperms_clean{pati})-1]; 
    
    % go over all phases
    for phase=0:length(allperms_clean{pati})-1
        
        pattern{phase+1} = (circshift(allperms_clean{pati},phase)); 
        
        PE_3(phase+1) = syncopationPE(repmat(circshift(allperms_clean{pati},phase),1,4), 3); 
        PE_4(phase+1) = syncopationPE(repmat(circshift(allperms_clean{pati},phase),1,4), 4); 

        LHL_22_perbar = syncopationLHL(repmat(circshift(allperms_clean{pati},phase),1,4),'22', length(allperms_clean{pati}), 'perbar'); 
        LHL_22(phase+1) = LHL_22_perbar(2); 
        LHL_32_perbar = syncopationLHL(repmat(circshift(allperms_clean{pati},phase),1,4),'32', length(allperms_clean{pati}), 'perbar'); % the way the "time signature" needs to be specified is different from normal here...
        LHL_32(phase+1) = LHL_32_perbar(2); 
        LHL_23_perbar = syncopationLHL(repmat(circshift(allperms_clean{pati},phase),1,4),'23', length(allperms_clean{pati}), 'perbar'); % the way the "time signature" needs to be specified is different from normal here...
        LHL_23(phase+1) = LHL_23_perbar(2); 
    end
    
    patterns(pati).ID = pati; 
    patterns(pati).n_sounds = sum(pattern{1}); 
    patterns(pati).n_events = length(pattern{1}); 
    
    % PE summary statistics
    patterns(pati).PE_3 = PE_3; 
    patterns(pati).PE_4 = PE_4; 
    patterns(pati).rangePE_3 = max(PE_3)-min(PE_3); 
    patterns(pati).rangePE_4 = max(PE_4)-min(PE_4); 
    patterns(pati).minPE_3 = min(PE_3); 
    patterns(pati).minPE_4 = min(PE_4); 
    
    % LHL summary statistics
    patterns(pati).LHL_22 = LHL_22; 
    patterns(pati).LHL_23 = LHL_23; 
    patterns(pati).LHL_32 = LHL_32; 
    patterns(pati).rangeLHL_22 = max(LHL_22)-min(LHL_22); 
    patterns(pati).rangeLHL_23 = max(LHL_23)-min(LHL_23); 
    patterns(pati).rangeLHL_32 = max(LHL_32)-min(LHL_32); 
    patterns(pati).minLHL_22 = min(LHL_22); 
    patterns(pati).minLHL_23 = min(LHL_23); 
    patterns(pati).minLHL_32 = min(LHL_32); 
    
    % Chiu FFT
    patterns(pati).chiuFFT_mX = getChiuFFT(pattern{1}); 
    patterns(pati).chiuFFT_mX(1) = []; 
    patterns(pati).chiuFFT_z = zscore(patterns(pati).chiuFFT_mX); 
    patterns(pati).chiuFFT_z36 = mean(patterns(pati).chiuFFT_z([3,6])); 
    
    patterns(pati).pattern = pattern; 
    patterns(pati).ioi_ratios = diff(find([pattern{1},1])); 
    
    if any(strcmpi(varargin,'nonmeter'))
        patterns(pati).s = makeS(patterns(pati).ioi_ratios, cfg, 'nonmeter'); 
    else
        patterns(pati).s = makeS(pattern{1}, cfg); 
    end

    
    if do_save
        audiowrite(fullfile(save_path, sprintf('%s_%dsounds_%devents_id%d.wav',save_label, patterns(pati).n_sounds, patterns(pati).n_events, pati)), ...
                   patterns(pati).s, ...
                   cfg.fs); 
    end
    
end


if do_save
    tmp_patterns = patterns; 
    patterns = rmfield(patterns, 's'); % save without audio (too large files)
    save(fullfile(save_path, sprintf('%s_%dsounds_%devents.mat',save_label, patterns(pati).n_sounds, patterns(pati).n_events)), 'patterns', 'cfg'); 
    patterns = tmp_patterns; 
end



