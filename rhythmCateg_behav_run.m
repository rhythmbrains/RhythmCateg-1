% let's run behavioral experiment


% Clear all the previous stuff
if ~ismac
  close all;
  clear Screen;
else
  clc;
  clear;
end

% make sure we got access to all the required functions and inputs
initEnv();

task = 'RhythmFT';
subject = 66;
runNb = 1;
tapMainExperiment(task, subject, runNb)

task = 'RhythmBlock';
runNb = 1;
tapMainExperiment(task, subject, runNb)

task = 'RhythmFT';
subject = 66;
runNb = 2;
tapMainExperiment(task, subject, runNb)