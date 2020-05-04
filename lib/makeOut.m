function out = makeOut(cfg,set_target,set_standard,varargin)
% documentation needed
% 
%
% 
% 

% % % delete me after confirmed
cfg.n_target = 4; % cfg.nPatternPerSegment = 4;
cfg.n_standard = 4; % cfg.nPatternPerSegment = 4;
cfg.nCycles = 1; 
% % %

% add last parameters
% calculate the base frequency
cfg.baseT = cfg.maxGridIOI * cfg.nGridPoints * cfg.nCycles; 
cfg.baseFreq = 1/cfg.baseT;




use_nonmeter_ratios = [0,0]; 
if any(strcmpi(varargin,'nonmeter'))
    use_nonmeter_ratios = varargin{find(strcmpi(varargin,'nonmeter'))+1}; 
end

cfg.rep_rate = cfg.n_target+cfg.n_standard; 
pat_type_out = [repmat(1,1,cfg.n_target),repmat(0,1,cfg.n_standard)]; 


fprintf('\n\nminimum IOI = %.3f s\nmaximum IOI = %.3f s\n',cfg.minGridIOI,cfg.maxGridIOI); 



%%%%%%%%%%%%%%%%%% PARSE F0 CHANGE-CATEGORY %%%%%%%%%%%%%%%%%%
% % % DELETE ME AFTER CONFIRMED % % %

% % change pitch for each new pattern cycle
% cfg.changePitchCycle 	= 0;
% % change pitch for each segment
% cfg.changePitchSegm 	= 0;           
% % change pitch for each segment-category (every time A changes to B or the other way around)
% cfg.changePitchCategory = 0;    
% % change pitch for each step
% cfg.changePitchStep 	= 0; 

% % % % % %% % %% % %


pitchChangeType = 0; 
% change pitch for each step (i.e. each [segmentA-segmentB] step)
if isfield(cfg,'changePitchStep')
    if cfg.changePitchStep==1
        pitchChangeType = 1; 
    end
end
% change pitch for each pattern-type (i.e. in every step, the segmentA will have one pitch and segmentB another)
if isfield(cfg,'changePitchCategory')
    if cfg.cfg.changePitchCategory==1
        pitchChangeType = 2; 
    end
end

% change pitch for each segment
if isfield(cfg,'changePitchSegm')
    if cfg.changePitchSegm==1
        pitchChangeType = 3; 
    end
end

% change pitch for each pattern cycle
if isfield(cfg,'changePitchCycle')
    if cfg.changePitchCycle==1
        pitchChangeType = 4; 
    end
end



%%%%%%%%%%%%%%%%%% RUN %%%%%%%%%%%%%%%%%%

% allocate variables
out = struct(); 
curr_f0_idx = 1; 
out.pat_type_out = {}; 
out.pat_out = nan(cfg.nSteps,length(set_standard(1).pattern{1})); 
%out.sOut = zeros(1, round((cfg.n_target+cfg.n_standard)*cfg.nSteps*cfg.baseT*cfg.fs)); 
out.sOut = zeros(1, round(cfg.interStepInterval*cfg.nSteps*cfg.fs)); 
out.patID_out = nan(1,cfg.nSteps); 
out.LHL22_out = nan(1,cfg.nSteps); 
out.ChiuFFT_out = nan(1,cfg.nSteps); 


c_pat = 1; 
c_time_sec = 0; 


% choose random f0 to initialize
available_f0_idx = [1:length(cfg.F0s)]; 
available_f0_idx(available_f0_idx==curr_f0_idx) = []; 
curr_f0_idx = randsample(available_f0_idx,1); 
cfg.f0 = cfg.F0s(curr_f0_idx); 



for stepi=1:cfg.nSteps
    
    % choose random f0
    if pitchChangeType==1
        available_f0_idx = [1:length(cfg.F0s)]; 
        available_f0_idx(available_f0_idx==curr_f0_idx) = []; 
        curr_f0_idx = randsample(available_f0_idx,1); 
        cfg.f0 = cfg.F0s(curr_f0_idx); 
    end
    
    
    
    
    for typei=1:length(pat_type_out)
        
        % choose random f0
        if pitchChangeType==3
            available_f0_idx = [1:length(cfg.F0s)]; 
            available_f0_idx(available_f0_idx==curr_f0_idx) = []; 
            curr_f0_idx = randsample(available_f0_idx,1); 
            cfg.f0 = cfg.F0s(curr_f0_idx); 
        end


    
        % choose IOI
        cfg.IOI = cfg.gridIOIs(randsample(length(cfg.gridIOIs),1)); 
        cfg.sound_dur = cfg.IOI; 


        if pat_type_out(typei)==0

            out.pat_type_out{end+1} = 'standard'; 

            % choose pattern
            patidx = randsample(length(set_standard),1); 

            % only allow phases where the pattern starts with sound event
            allowed_phases = find(cellfun(@(x) x(1)==1, set_standard(patidx).pattern)); 
            phaseidx = randsample(allowed_phases,1);

            % choose phase based on the specified method
            if strcmpi(cfg.phase_choose_method,'random')
                phaseidx = randsample(allowed_phases,1);      
            elseif strcmpi(cfg.phase_choose_method,'extreme_LHL')
                [~,sorted_idx] = sort(set_standard(patidx).LHL_22(allowed_phases),'descend'); 
                phaseidx = allowed_phases(sorted_idx(1)); 
            elseif strcmpi(cfg.phase_choose_method,'original')
                phaseidx = 1; 
            end

            % make sound
            if use_nonmeter_ratios(1)
                s2add = makeS(set_standard(patidx).ioi_ratios, cfg, 'nonmeter'); 
            else
                s2add = makeS(set_standard(patidx).pattern{phaseidx}, cfg); 
            end

            % log 
            out.patID_out(c_pat) = set_standard(patidx).ID; 
            out.pat_out(c_pat,:) = set_standard(patidx).pattern{phaseidx}; 
            if isfield(set_standard,'LHL_22')
                out.LHL22_out(c_pat) = set_standard(patidx).LHL_22(phaseidx); 
            end
            if isfield(set_standard,'chiuFFT_z36')
                out.ChiuFFT_out(c_pat) = set_standard(patidx).chiuFFT_z36;
            end
            
            
        elseif pat_type_out(typei)==1

            out.pat_type_out{end+1} = 'target'; 

            % choose pattern
            patidx = randsample(length(set_target),1); 

            % only allow phases where the pattern starts with sound event
            allowed_phases = find(cellfun(@(x) x(1)==1, set_target(patidx).pattern)); 
            phaseidx = randsample(allowed_phases,1);

            % choose phase based on the specified method
            if strcmpi(cfg.phase_choose_method,'random')
                phaseidx = randsample(allowed_phases,1);      
            elseif strcmpi(cfg.phase_choose_method,'extreme_LHL')
                [~,sorted_idx] = sort(set_target(patidx).LHL_22(allowed_phases),'descend'); 
                phaseidx = allowed_phases(sorted_idx(1)); 
            elseif strcmpi(cfg.phase_choose_method,'original')
                phaseidx = 1; 
            end

            % make sound
            if use_nonmeter_ratios(2)
                s2add = makeS(set_target(patidx).ioi_ratios, cfg, 'nonmeter'); 
            else
                s2add = makeS(set_target(patidx).pattern{phaseidx}, cfg); 
            end

            % log 
            out.patID_out(c_pat) = set_target(patidx).ID; 
            out.pat_out(c_pat,:) = set_target(patidx).pattern{phaseidx}; 
            if isfield(set_target,'LHL_22')
                out.LHL22_out(c_pat) = set_target(patidx).LHL_22(phaseidx); 
            end
            if isfield(set_target,'chiuFFT_z36')
                out.ChiuFFT_out(c_pat) = set_target(patidx).chiuFFT_z36;
            end
        end


        % check if not longer than baseT
        if length(s2add)/cfg.fs > cfg.baseT
            warning(sprintf('trying to add %.3f sec step, but only %.3f s allowed',length(s2add)/cfg.fs, cfg.baseT))
        else
            fprintf('adding %.3f sec step\n',length(s2add)/cfg.fs); 
        end

        % find starting index
        t_idx = round(c_time_sec*cfg.fs); 

        % add the sound
        out.sOut(t_idx+1:t_idx+length(s2add)) = s2add; 
        
        
        % ========== update f0 ==========
               
        if pitchChangeType==2
            if ((pat_type_out(typei)==1 && pat_type_out(typei+1)==0) || typei==length(pat_type_out))            
                available_f0_idx = [1:length(cfg.F0s)]; 
                available_f0_idx(available_f0_idx==curr_f0_idx) = []; 
                curr_f0_idx = randsample(available_f0_idx,1); 
                cfg.f0 = cfg.F0s(curr_f0_idx); 
            end
        end
    
        
        
        % ========== update current time position ==========
        
        c_time_sec = c_time_sec + cfg.baseT;         

        % if this is last target, and delay requested, add it to the time position 
        if isfield(cfg,'delay_after_tar') && pat_type_out(typei)==1 && pat_type_out(typei+1)==0
            c_time_sec = c_time_sec + cfg.delay_after_tar;         
        end        
        % if this is last standard, and delay requested, add it to the time position 
        if isfield(cfg,'delay_after_std') && typei==length(pat_type_out)
            c_time_sec = c_time_sec + cfg.delay_after_std;         
        end
        
        c_pat = c_pat+1; 

    end
    
end


out.set_standard = set_standard; 
out.set_target = set_target; 
out.use_nonmeter_ratios = use_nonmeter_ratios; 
