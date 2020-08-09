function cfg = getParams(task,device,debugmode)
% NOTE: in order to use behav + fMRI with 1 getParams, we are using
% getParam with 3 aguments so it won't interfere with behav script
% CB edit 0n 09/07/2020


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



%% Init parameter structures
cfg = struct; 

%% set the type of your computer
if IsWin
    cfg.stimComp='windows';
elseif ismac
    cfg.stimComp = 'mac';
elseif IsLinux
    cfg.stimComp = 'linux';
end

%% Debug mode settings
cfg.debug.do        = debugmode ;  
cfg.debug.transpWin = true;     % To test the script with trasparent full size screen
cfg.debug.smallWin  = false;
cfg.verbose         = 1;        % add here and there some explanations with if verbose is ON. 

%% MRI settings
cfg.testingDevice = device;         % 'pc': does not care about trigger(for behav) - otherwise use 'mri'
cfg.mri.triggerNb = 4;              % first #Triggers will be dummy scans
cfg.mri.triggerKey = 's';           % Set the letter sent by the trigger to sync stimulation and volume acquisition
cfg.eyeTracker.do = false;          % Set to 'true' if you are testing in MRI and want to record ET data

cfg.fmriTask = true;                % is it really useful? 
%% general configuration
%for BIDS format: 
cfg.task.name = task;                % should be calling behav or fmri
cfg.subject.askGrpSess = [0 0]; % it won't ask you about group or session

% set and load all the subject input to run the experiment
cfg = userInputs(cfg);
cfg = createFilename(cfg);

%% monitor
% Monitor parameters - fMRI - CHANGE with fMRI parameters
cfg.monitorWidth  	  = 42;  % Monitor Width in cm
cfg.screenDistance    = 134; % Distance from the screen in cm
cfg.diameterAperture  = 8;   % Diameter/length of side of aperture in Visual angles

% Monitor parameters for PTB
cfg.white  = [255 255 255];
cfg.black  = [ 0   0   0 ];
cfg.gray   = mean([cfg.black; cfg.white]);
cfg.background.color  = cfg.gray;
cfg.text.color        = cfg.white;
cfg.text.font         = 'Arial'; %'Courier New'
cfg.text.size         = 30; %18
%cfg.text.style        = 1;

    
%% sound levels
cfg.baseAmp = 0.5;
cfg.PTBInitVolume = 0.3;

%  boolean for equating the dB across different tones for behavioral exp
cfg.equateSoundAmp = 1;

% BIDS non-compatible logfile folder
cfg.dir.output = fullfile(...
    fileparts(mfilename('fullpath')), ...
    'output');
    
if strcmpi(cfg.testingDevice, 'mri')
    
    cfg.baseAmp = 0.99; 
    cfg.PTBInitVolume = 1; 

    %  boolean for equating the dB across different tones for behavioral exp
    cfg.equateSoundAmp = 0;
    
    % BIDS compatible logfile folder
    cfg.dir.output = fullfile(...
        fileparts(mfilename('fullpath')),'..', ...
        'output');
end

%% audio other parameters
% sampling rate
cfg.fs = 44100; 
% channels is 1 for mono sound or 2 for stereo sound
cfg.audio.channels = 2;

%% download missing stimuli (.wav)
soundpath = fullfile(fileparts(mfilename('fullpath')));
checkSoundFiles(soundpath);

%% Timing 

% % %
% convert waitSecs according to the TR = 2.28
cfg.timing.onsetDelay = 3 * 2.28; %Number of seconds before the rhythmic sequence (exp) are presented
cfg.timing.endDelay = 3 * 2.28; % Number of seconds after the end of all stimuli before ending the fmri run! 
% % %

% ending timings for fMRI
cfg.timing.endScreenDelay = 2; %end the screen after thank you screen
% delay for script ending
cfg.timing.endResponseDelay = 13; % wait for participant to response for counts

% these are for behavioral exp delays
cfg.sequenceDelay = 1; %wait in between sequences? y/n
cfg.pauseSeq = 1; % give a pause of below seconds in between sequences


% define ideal number of sequences to be made
% multiple of 3 is balanced design
cfg.pattern.numSequences = 6;

if cfg.debug.do
     cfg.pattern.numSequences = 2;
end
      
if strcmpi(cfg.testingDevice,'mri')
    cfg.pattern.numSequences = 9;
    cfg.pattern.numSeq4Run = 1; % for an fMRI run time calculation
end



%% fMRI task
% it'll display a fixation cross during the fMRI run
% Also makes the task design in makefMRISeqDesign.m

% For now, I'll insert 3 task versions here to be called in
% makeStimMainExp.m 

if strcmpi(cfg.testingDevice,'mri')
    
    % Used Pixels here since it really small and can be adjusted during the experiment
    cfg.fixCrossDimPix               = 10;   % Set the length of the lines (in Pixels) of the fixation cross
    cfg.lineWidthPix                 = 4;    % Set the line width (in Pixels) for our fixation cross
    cfg.xDisplacementFixCross        = 0;    % Manual displacement of the fixation cross
    cfg.yDisplacementFixCross        = 0;    % Manual displacement of the fixation cross
    cfg.fixationCrossColor           = cfg.white;
    
    %calculate the location coord for cross
    cfg.xCoords = [-cfg.fixCrossDimPix cfg.fixCrossDimPix 0 0] ...
        + cfg.xDisplacementFixCross;
    cfg.yCoords = [0 0 -cfg.fixCrossDimPix cfg.fixCrossDimPix] ...
        + cfg.yDisplacementFixCross;
    cfg.allCoords = [cfg.xCoords; cfg.yCoords];
    
    % set default for no-task 
    cfg.isTask.Idx = 0;
    
    % how many targets within 1 pattern
    cfg.isTask.numEvent = 1;

    % piano keys 
    % read the audio files and insert them into cfg
    targetList = dir(fullfile(soundpath,'stimuli/Piano*.wav'));
    
    for isound = 1:length(targetList)
        [S,cfg.fs] = audioread(fullfile('stimuli',targetList(isound).name));
        cfg.isTask.targetSounds{isound} = S';
    end
 
end





%% more parameters to get according to the type of experiment
% this part is solely for behavioral exp
% control fMRI script has its getxxx.m instead of in here (getParam.m)
if strcmp(cfg.task.name,'tapTraining')
    
    % get tapping training parameters
    cfg = getTrainingParameters(cfg);
    
elseif strcmp(cfg.task.name,'tapMainExp') || strcmp(cfg.task.name,'RhythmCategFT')
    
    % get main experiment parameters
    cfg = getMainExpParameters(cfg);
    
elseif strcmp(cfg.task.name,'RhythmCategBlock')
    % get main experiment parameters
    cfg = getBlockParameters(cfg);
    
elseif strcmp(cfg.task.name,'PitchFT')
    
    cfg = getPitchParameters(cfg);
    
end




%% differentiating response button (subject) from keyboard(experimenter)
% cfg.responseBox would be the testingDevice used by the participant to give his/her response: 
%   like the button box in the scanner or a separate keyboard for a behavioral experiment
%
% cfg.keyboard is the keyboard on which the experimenter will type or press the keys necessary 
%   to start or abort the experiment.
%   The two can be different or the same.

% Using empty vectors should work for linux when to select the "main"
% keyboard. 


cfg.keyboard.keyboard = [];
cfg.keyboard.responseBox = [];

% After connecting fMRI response button to the laptop, 
% LOOK what are the experimenters' keyboard & fmri responseKey 
% by using GetKeyboardIndices below.
% copy-paste these this into command window 
% then you can assign device number to the main keyboard or the response
% box. 
% otherwise it's set for PTB to assign. 
[keyboardNumbers, keyboardNames] = GetKeyboardIndices;

disp(keyboardNumbers);
disp(keyboardNames);


switch lower(cfg.testingDevice)
    
    
    % this part might need to be adapted because the "default" device
    % number might be different for different OS or set up
    
    case 'pc'
        
        cfg.keyboard = [];
        cfg.responseBox = [];
        
        %behavioral exp keys to check
        cfg.keywait         = KbName({'RETURN'}); % press enter to start bloc
        cfg.keyquit         = KbName('ESCAPE'); % press ESCAPE at response time to quit
        cfg.keyToggleInstr  = KbName({'I'}); % press I to show/remove general instructions from the screen
        cfg.keytap          = KbName('SPACE');
        cfg.keyVolUp        = KbName('UpArrow');
        cfg.keyVolDown      = KbName('DownArrow');
        cfg.keyAudioPlay    = KbName('p');
        cfg.keyAudioStop    = KbName('s');
        cfg.keyInstrBack    = KbName('b');
        cfg.keyInstrNext    = KbName('n');
        
        if ismac
            cfg.keyboard.keyboard = [];
            cfg.keyboard.responseBox = [];
        end
        
    case 'mri'
        
    
    % it'll only look for space press -
    % later on change with the responseBox indices/numbers! ! !
    cfg.keyboard.responseKey = {'space','d','a'};
    
    %esc key for both behav and fmri exp
    cfg.escapeKey       = KbName('ESCAPE'); % press ESCAPE at response time to quit
   % cfg.keyboard.escapeKey = 'ESCAPE'; %use this with the latest CPP_PTB
   % repo


    otherwise
        
        cfg.keyboard.keyboard = [];
        cfg.keyboard.responseBox = [];
        
end


%%
if cfg.debug.do
    fprintf('\n\n\n\n')
    fprintf('######################################## \n')
    fprintf('##  DEBUG MODE, NOT THE ACTUAL EXP CODE  ## \n')
    fprintf('######################################## \n\n')    
end



