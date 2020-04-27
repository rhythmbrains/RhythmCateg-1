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


