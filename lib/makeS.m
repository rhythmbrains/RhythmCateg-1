function [s,env] = makeS(pattern, cfg, varargin)
% pattern can be also a set of IOI ratios add "ioi_ratios" into varargin
% in case you want non-integer ratios, add also "nonmeter" into varargin

% documentation needed
% 
%
% 
%


rampon_samples = round(cfg.rampon*cfg.fs); 
rampoff_samples = round(cfg.rampoff*cfg.fs); 
duty_samples = round(cfg.soundDur*cfg.fs); 

env_event = ones(1,floor(cfg.fs*(cfg.soundDur))); 
env_event(1:rampon_samples) = env_event(1:rampon_samples) .* linspace(0,1,rampon_samples); 
env_event(end-rampoff_samples+1:end) = env_event(end-rampoff_samples+1:end) .* linspace(1,0,rampoff_samples); 


if any(strcmpi(varargin,'nonmeter'))
    
    IOIs_cycle = cfg.IOI*cfg.nonmeter_ratios(pattern); 
    dur_cycle = sum(IOIs_cycle); 
    t = [0 : round(dur_cycle*cfg.nCycles*cfg.fs)-1]/cfg.fs; 
    
    env = zeros(1,length(t)); 
    t_pos=0; 
    idx = round(t_pos*cfg.fs); 
    env(idx+1:idx+length(env_event)) = env_event; 
    for cyclei=1:cfg.nCycles
        for i=1:length(IOIs_cycle)
            if cyclei==cfg.nCycles && i==length(IOIs_cycle)
                break
            end
            t_pos = t_pos + IOIs_cycle(i); 
            idx = round(t_pos*cfg.fs); 
            env(idx+1:idx+length(env_event)) = env_event; 
        end
    end    
    
    
elseif any(strcmpi(varargin,'ioi_ratios'))
    
    
    IOIs_cycle = cfg.IOI*pattern; 
    dur_cycle = sum(IOIs_cycle); 
    t = [0 : round(dur_cycle*cfg.nCycles*cfg.fs)-1]/cfg.fs; 
    
    env = zeros(1,length(t)); 
    t_pos=0; 
    idx = round(t_pos*cfg.fs); 
    env(idx+1:idx+length(env_event)) = env_event; 
    for cyclei=1:cfg.nCycles
        for i=1:length(IOIs_cycle)
            if cyclei==cfg.nCycles && i==length(IOIs_cycle)
                break
            end
            t_pos = t_pos + IOIs_cycle(i); 
            idx = round(t_pos*cfg.fs); 
            env(idx+1:idx+length(env_event)) = env_event; 
        end
    end    
    
    
else

    t = [0 : round(cfg.fs*cfg.IOI*length(pattern)*cfg.nCycles)-1]/cfg.fs; 

    c=0; 
    env = zeros(1,length(t)); 
    for cyclei=1:cfg.nCycles
        for i=1:length(pattern)
            if pattern(i)
                idx = round(c*cfg.IOI*cfg.fs); 
                env(idx+1:idx+length(env_event)) = pattern(i).*env_event; 
            end
            c=c+1; 
        end
    end
    

end


s = sin(2*pi*cfg.f0*t); 
s = s.* env;




