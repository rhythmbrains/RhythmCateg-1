

%% plot equal loudness curves

figure;

freq2plot = logspace(log10(20),log10(12500),100); 

for phon = 0:10:90
    
    % equal loudness data
    [spl,freq] = iso226(phon);
    
    % interpolate
    spl2plot = spline(freq,spl,freq2plot); 
    
    % plot the reference point (1000 Hz) where 1 phon = 1 dB SPL
    plot(1000,phon,'.r');
    text(1000,phon+3,num2str(phon));
    
    % equal loudness curve
    semilogx(freq,spl,'r','linew',1.7); % original frequencies
    semilogx(freq2plot,spl2plot,'k','linew',1.7); % spline interpolation
    
    hold on
end

axis([0 13000 0 140]);
grid on % draw grid
xlabel('Frequency (Hz)');
ylabel('Sound Pressure in Decibels');
hold off;
 
%%

% As we're working with simple sine tones, it's very easy to equalize phon
% levels with simple amplitude multiplication. 

% here are tone frequencies (F0s) we will use
F0s = logspace(log10(350),log10(900),5);

% The only problem is that our sonud system is not calibrated. However,
% let's pretend it is and we set the sound volume such that pure tone at 
% 1k Hz with amplitude = 1 will give 75 dB SPL on our calibration sound 
% level meter. This is equivalent to 75 phon at 1k Hz.
calibPhon = 75; 
% (note: with amplitude = 1, rms = 1/sqrt(2) = 0.7071, but because these 
% are just sine waves it's the same thing...)

% Let's see the gain we need at our frequencies of interest to achieve the
% same phon level as our calibration 1k tone. 
[spl,freq] = iso226(calibPhon);

% interpolate
splF0s = spline(freq,spl,F0s); 
  
% let's plot it just to be suure the spline worked ;)
figure;
semilogx(freq,spl,'k','linew',1.7); % original frequencies
hold on
semilogx(F0s,splF0s,'ro','MarkerFaceColor','r'); % spline interpolation

% gain needed
needGain =  splF0s - calibPhon; 

% we will construct pure tones at our target frequencies with same rms as
% the 1k calibration tone (just set the amplitude to 1). Then we apply gain
% to each tone accordingly. 
oldAmplitude = 1; 
newAmplitudes = oldAmplitude .* 10.^(needGain/20); 


% let's check we have the requested gain
fprintf('\n\ndifference between requested and achieved gain at each F0: \n')
disp( ((20 * log10(newAmplitudes / oldAmplitude)) - needGain)' )



%%

% ok, done. Now let's just set the amplitudes of our sine tones to newAmplitudes



