# This repository contains Matlab code for tapping pilot, including:  

1. Tap Trainer  
2. Main Experiment  

## Requirements:

Make sure that the following softwares are installed and added to the matlab / octave path.

For instructions see the following links:

| Requirements                                             | Used version |
|----------------------------------------------------------|--------------|
| [PsychToolBox](http://psychtoolbox.org/)                 | >=3.0.14     |
| [Matlab](https://www.mathworks.com/products/matlab.html) | >=2016b      |
| or [octave](https://www.gnu.org/software/octave/)        | 5.1          |

## To run:  

1. Restart your computer, and close all apps that might consume resources (keep only Matlab)<sup>*</sup>. 
2. Download the whole repository as zip.
3. Unzip and navigate to the downloaded folder.  
4. Put your mouse away and make sure you have space around your keyboard. 
5. Make sure you are in a quiet environment, and you are wearing earphones. 
6. Run tapTrainer.m in Matlab to launch the Tap Trainer psychtoolbox session.
7. Run tapMainExperiment.m in Matlab to launch the Main Experiment psychtoolbox session.  

\* If you hear cracks in the audio during the experiment you might have an app running that loads your processor. Try finding and closing this app. If it doesn't work, please contact us.    

### Tap Trainer session

Participants complete a number of trials. In each trial, a rhythmic stimulus is presented. The stimulus can be a seamlessly cycled pattern, or an audio-track that is played only once. 

The task can be to either just listen, or to tap on [SPACEBAR] along with the pulse (beat). Tapping the pulse can be guided by an additional sound (meter-cue, e.g. bass or clap sound). Tapping precisely with the meter-cue will result in gradual decrease meter-cue volume. Eventually, the meter-cue will be completely silent and the participant is required to keep synchronized to the pulse.

All important parameters can be found in `/lib/getTrainingParameters.m`. The file should be sufficiently commented to make sense.

### Main Experiment session

Long, non-repeating rhythmic sequences are presented. The task is to (1) find a plausible pulse, and (2) synchronize finger tapping to it.  

All important parameters  can be found in `/lib/getMainExpParameters.m`. The file should be sufficiently commented to make sense.  
