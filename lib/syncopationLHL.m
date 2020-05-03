function res = syncopationLHL(pattern, meter, events_in_cycle, varargin)


% 
% in this new version put gruping hiearchy instead of meter. E.g. '23' is
% grouping by 2 elements and then by 3 hierarchically
% 
% 
% 

% 
% "If N is a note that precedes a rest, R, and R has a metric weight greater than or equal to N, 
% then the pair (N, R) is said to constitute a monophonic syncopation."
% 
% If N < R
% Syncopation = R - N







if strcmpi(meter,'22')
    salience = [0,-2,-1,-2]; 
    weightgrid = repmat(salience, 1, ceil(size(pattern,2)/length(salience))); 
elseif strcmpi(meter,'23')
    salience = [0,-2,-1,-2,-1,-2]; 
    weightgrid = repmat(salience, 1, ceil(size(pattern,2)/length(salience))); 
elseif strcmpi(meter,'32')
    salience = [0,-2,-2,-1,-2,-2]; 
    weightgrid = repmat(salience, 1, ceil(size(pattern,2)/length(salience))); 
elseif strcmpi(meter,'223')
    salience = [0,-3,-2,-3, -1,-3,-2,-3, -1,-3,-2,-3]; 
    weightgrid = repmat(salience, 1, ceil(size(pattern,2)/length(salience))); 
elseif strcmpi(meter,'322')
    salience = [0,-3,-3,-2,-3,-3, -1,-3,-3,-2,-3,-3]; 
    weightgrid = repmat(salience, 1, ceil(size(pattern,2)/length(salience))); 
elseif strcmpi(meter,'232')
    salience = [0,-3,-2,-3,-2,-3, -1,-3,-2,-3,-2,-3]; 
    weightgrid = repmat(salience, 1, ceil(size(pattern,2)/length(salience))); 
else
    error('fuck you')
end
    
    
if any(strcmpi(varargin, 'perbar'))
    
    nbars = length(pattern)/events_in_cycle; 

    res = zeros(size(pattern,1),nbars); 
    for file=1:size(pattern,1)
        synidx = 0; 
        bar=1; 
        for i=1:size(pattern,2)
            if pattern(file,i)
                c=1; 
                tmpx = []; 
                while 1
                    if (i+c)>size(pattern,2)
                        break
                    elseif pattern(file,i+c)==1
                        break
                    elseif pattern(file,i+c)==0
                        tmpx = [tmpx, weightgrid(i+c)]; 
                    end
                    c = c+1; 
                end
                if any(tmpx>weightgrid(i))
                    synidx = synidx + (max(tmpx)-weightgrid(i)); 
                end
            end
            if mod(i+1,events_in_cycle)==0
               res(file, bar) = synidx; 
               synidx=0; 
               bar = bar+1;  
            end
        end
    end
    
    
else
    
    
    res = zeros(1,size(pattern,1)); 

    for file=1:size(pattern,1)
        synidx = 0; 
        for i=1:size(pattern,2)
            if pattern(file,i)
                c=1; 
                tmpx = []; 
                while 1
                    if (i+c)>size(pattern,2)
                        break
                    elseif pattern(file,i+c)==1
                        break
                    elseif pattern(file,i+c)==0
                        tmpx = [tmpx, weightgrid(i+c)]; 
                    end
                    c = c+1; 
                end
                if any(tmpx>weightgrid(i))
                    synidx = synidx + (max(tmpx)-weightgrid(i)); 
                end
            end
        end

        res(file) = synidx; 
    end

    
end



