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



%% cfg parameters
cfg = struct; 
cfg.device = 'PC';              % PC for behav, scanner for fMRI, 
cfg.eyeTracker    = false;      % Set to 'true' if you are testing in MRI and want to record ET data

%% Debug mode settings
cfg.debug               = 0 ;  % To test the script
cfg.testingTranspScreen = 0 ;  % To test with trasparent full size screen 


%% general configuration
expParameters = struct;
expParameters.task = task; 
%it won't ask you about group or session
expParameters.askGrpSess = [0 0];


%% sound levels
% assuming that participant will do the task with headphones
cfg.baseAmp = 0.5; 

% i think this cannot be smaller than cfg.Amp! ! !
cfg.PTBInitVolume = 0.3; 


% BIDS compatible logfile folder
% by default the data should be stored in an output folder created 
% outside of the scripts folder
% change that if you do not want BIDS formatting output
expParameters.outputDir = fullfile(...
    fileparts(mfilename('fullpath')), ...
    'output');


%  boolean for equating the dB across different tones for behavioral exp
if strcmpi(cfg.device, 'scanner')
    expParameters.equateSoundAmp = 0;
else
    expParameters.equateSoundAmp = 1;
    
end


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


%% download missing stimuli


% check if any required stimulus files are missing
dStim = dir(fullfile('stimuli','*')); 
fidStimList = fopen(fullfile('stimuli','REQUIRED_FILES_LIST'), 'r'); 
DOWNLOAD_STIM = 0; 
fprintf('checking for missing stimulus files...\n'); 
while 1
    
    l = fgetl(fidStimList); 
    if ~any(strcmp({dStim.name},l))
        fprintf('%s \n',l); 
        DOWNLOAD_STIM = 1; 
    end
    if feof(fidStimList)
        break
    end
end

if DOWNLOAD_STIM
    % download missing files from Dropbox
    url = 'https://www.dropbox.com/sh/baw83ib1hmf8tbe/AAAf6DHY7mw6UKXc7qQmbMN8a?dl=1';
    disp('downloading audio files from Dropbox...'); 
    urlwrite(url,'stimuli.zip'); 
    unzip('stimuli.zip','stimuli'); 
    delete('stimuli.zip')
    disp('audio downloaded successfully'); 
end



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



