function outStr = getErrorStr(errProp, cfg)
% This function makes a nice string showing the proportial tapping error
% that can be directly displayed as feedback to the participant. 
% 
% Input: 
% -----
%     errProp :       float
%                     tapping error expressed as proportion of the tapping period
%                     must have range [0,1]
%     cfg :           struct
%                     tapTrainer config structure, must contain subfield "tapCvAsynchThr"
% Output: 
% ------
%     errStr :        string
%                     nicely formatted feedback for participant
%                     

N = 25; 

% transform error into performance level measure by
% 1) invert the error index to get a measure of how "good" (instead of how "bad") they tapped
perfLevel = (1-errProp); 
% 2) trim at 0.5 because it can't go below this anyway
perfLevel = max(perfLevel, 0.5); 
% 3) rescale from 0 to 1 again
perfLevel = (perfLevel-0.5) / 0.5; 

if isnan(errProp)
    % no taps were executed, give 0 feedback
    lineIdx = 1; 
else
    % map the performance level onto the visual scale
    lineIdx = round( perfLevel * N); 
end
scalePnts = repmat('_',1,N); 
scalePnts(lineIdx) = '#'; 


% get threshold they need to achieve to success
% 1) invert 
thrLevel = (1-cfg.tapCvAsynchThr); 
% 2) trim at 0.5 
thrLevel = max(thrLevel, 0.5); 
% 3) rescale from 0 to 1 again
thrLevel = (thrLevel-0.5) / 0.5; 
% map onto the visual scale
thrIdx = round(thrLevel * N); 


thrPnts = repmat(' ',1,N); 
thrPnts(thrIdx) = 'v'; 


thrStr = ['   ', thrPnts , '   ']; 
errStr = ['- |', scalePnts , '| +']; 
outStr = sprintf('%s\n%s',thrStr,errStr); 