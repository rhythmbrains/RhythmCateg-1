This repository contains Matlab code for tapping pilot, including:  
1. Tap Trainer  
2. Main Experiment  
  
&nbsp;  
  
**Requirements**: 
 
* Matlab  
* Psychtoolbox

&nbsp;  

To run:  

1. Download the whole repository as zip. 
2. Unzip and navigate to the downloaded folder.  
3. Download the required audio files from [this Dropbox folder](https://www.dropbox.com/sh/58i2gvcdlvjhx4l/AADfmV1PQtJRGhu-gHYzC-WIa?dl=0) and place the downloaded folder to the main directory of the project.
4. Run tapTrainer.m in Matlab to launch the Tap Trainer psychtoolbox session. 
5. Run tapMainExperiment.m in Matlab to launch the Main Experiment psychtoolbox session.  




&nbsp;  

**Tap Trainer session**  

Two sound layers are presented simultaneously (cycled seamlessly):  
* *Rhythmic pattern* is played with a tone, and doesn't change intensity over the experiment  
* *Meter cue* consists of two pulses, each played with a distinctive timbre. One marks the beat period, the other marks the fastest metric period ("grid"). 
 
The task is to tap on SPACEBAR along with the beat pulse. Good tapping performance will result in gradual decrease meter-cue volume. Eventually, the meter-cue will be completely silent and the participan is required to keep synchronized to the beat. 

The session goes over multiple rhythmic patterns with increasing difficulty (also different beat periods can be used in the future releases).  

All important parameters can be found in `/lib/getTrainingParameters.m`. The file should be sufficiently commented to make sense. 


&nbsp;  

**Main Experiment session**  

Long, non-repeating rhythmic sequences are presented. The task is to (1) find a plausible pulse, and (2) synchronize finger tapping to it.  

All important parameters  can be found in `/lib/getMainExpParameters.m`. The file should be sufficiently commented to make sense.  






