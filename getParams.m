function [cfg,expParameters] = getParams()

% Initialize the parameters variables
% Initialize the general configuration variables
cfg = struct; 
expParameters = struct;

% % % THINK using this function tapping + main exp
expParameters.task = 'tapTraining'; % tapTraining or tapMainExp to run main experiment
% % %


%% Debug mode settings
cfg.debug               = true;  % To test the script
cfg.testingTranspScreen = true;  % To test with trasparent full size screen 
% not sure that's helpful now 
% what I wanted : in debug mode, do not flip the monitor, no hide cursor,
% no blocking keyboard - just play the sounds

%% set the type of your computer

answer = input('\nIs your OS  Mac? y/n? : ','s');
if isempty(answer) || strcmp(answer,'n')
    cfg.device='windows';
else
    cfg.device = 'mac';
end
%% other parameters
% sampling rate
cfg.fs = 44100; 


%% more parameters to get according to thetype of experiment
if strcmp(expParameters.task,'tapTraining')
    % get tapping training parameters
    [cfg,expParameters] = getTrainingParameters(cfg,expParameters);

    
elseif strcmp(expParameters.task,'tapMainExp')
    % get main experiment parameters
    [cfg,expParameters] = getMainExpParameters(cfg,expParameters);
    
end


%% differentiating response button (subject) from keyboard(experimenter)
% cfg.responseBox would be the device used by the participant to give his/her response: 
%   like the button box in the scanner or a separate keyboard for a behavioral experiment
%
% cfg.keyboard is the keyboard on which the experimenter will type or press the keys necessary 
%   to start or abort the experiment.
%   The two can be different or the same.

% Using empty vectors should work for linux when to select the "main"
%   keyboard. You might have to try some other values for MacOS or Windows
cfg.keyboard = []; 
cfg.responseBox = []; 
