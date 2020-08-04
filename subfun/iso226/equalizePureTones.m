function newAmplitudes = equalizePureTones(F0s,oldAmplitude, calibPhon)

% Calculates SPL (dB) equated amplitudes for each given tone
% F0s that pure tones have been made and calculates the new amplitudes.
% Set the new amplitudes to be used sine tones amplitudes

% ------
% INPUT
% ------
%   F0s:                pure tones
%   oldAmplitude:       default =  1
%   calibPhon:          in dB, default =75
% ------ 
% OUTPUT
% ------    
%   newAmplitudes:      sound pressure level equated amplitudes




% % The only problem is that our sonud system is not calibrated. However,
% % let's pretend it is and we set the sound volume such that pure tone at 
% % 1k Hz with amplitude = 1 will give 75 dB SPL on our calibration sound 
% % level meter. This is equivalent to 75 phon at 1k Hz.

% % (note: with amplitude = 1, rms = 1/sqrt(2) = 0.7071, but because these 
% % are just sine waves it's the same thing...)

if nargin<3 || isempty(calibPhon)
    calibPhon = 75;
    
    if nargin<2 || isempty(oldAmplitude)
        oldAmplitude = 1;
    end
end

% Let's see the gain we need at our frequencies of interest to achieve the
% same phon level as our calibration 1k tone. 
[spl,freq] = iso226(calibPhon);

% interpolate
splF0s = spline(freq,spl,F0s); 


% gain needed
needGain =  splF0s - calibPhon; 

% we will construct pure tones at our target frequencies with same rms as
% the 1k calibration tone (just set the amplitude to 1). Then we apply gain
% to each tone accordingly. 
newAmplitudes = oldAmplitude .* 10.^(needGain/20); 


end