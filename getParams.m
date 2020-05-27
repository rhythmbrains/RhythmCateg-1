function [cfg,expParameters] = getParams(task)
% Initialize the parameters variables
% Initialize the general configuration variables
% =======
% INPUT: 
% =======
%     task:             string specifying the current task to get parameters for
%                       (tapTraining or tapMainExp)
% =======
% OUTPUT: 
% =======
%     cfg:
%     expParameters:



% parameters
cfg = struct; 
cfg.device = 'PC'; % PC for behav, scanner for fMRI, 
cfg.eyeTracker    = false;      % Set to 'true' if you are testing in MRI and want to record ET data



% general configuration
expParameters = struct;
expParameters.task = task; 

% assuming that participant will do the task with headphones:
expParameters.soundAmp = 0.2;

%% BIDS compatible logfile folder
% by default the data will be stored in an output folder created where the
% setParamters.m file is
% change that if you want the data to be saved somewhere else
expParameters.outputDir = fullfile(...
    fileparts(mfilename('fullpath')), '..', ...
    'output');

%% Debug mode settings
cfg.debug               = 1 ;  % To test the script
cfg.testingTranspScreen = 1 ;  % To test with trasparent full size screen 


%% set the type of your computer
if IsWin
    cfg.stimComp='windows';
elseif ismac
    cfg.stimComp = 'mac';
elseif IsLinux
    cfg.stimComp = 'linux';
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
% TL: I think -1 should work? 
% CB: I do not know, feel free to add that


[cfg.keyboardNumbers, cfg.keyboardNames] = GetKeyboardIndices;
cfg.keyboardNumbers
cfg.keyboardNames


switch lower(cfg.device)
    
    
    % this part might need to be adapted because the "default" device
    % number might be different for different OS or set up
    
    case 'pc'
        
        cfg.keyboard = [];
        cfg.responseBox = [];
        
        if ismac
            cfg.keyboard = [];
            cfg.responseBox = [];
        end
        
    case 'scanner'
        
    otherwise
        
        cfg.keyboard = [];
        cfg.responseBox = [];
        
end


%%
if cfg.debug
    fprintf('\n\n\n\n')
    fprintf('######################################## \n')
    fprintf('##  DEBUG MODE, NOT THE ACTUAL EXP CODE  ## \n')
    fprintf('######################################## \n\n')
end



