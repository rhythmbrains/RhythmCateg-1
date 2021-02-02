function fillSoundBuffer(s,fs,pahandle,nChannelsOut,nChannelsIn,trigChan)


% make s 2xN
if size(s,1)>size(s,2)
    s = s'; 
end

% make stereo if needed                                                           
if size(s,1)==1
    s = [s;s]; 
    warning('making stereo'); 
end
  
% make 100ms trigger pulse
trigPulse = zeros(1,length(s)); 
trigPulse(1:round(0.100*fs)) = 1; 

audio2push              = zeros(nChannelsOut, length(s)); 
audio2push(1,:)         = s(1,:); % left earphone
audio2push(2,:)         = s(2,:); % right earphone
if nChannelsOut>=5
    audio2push(5,:)     = s(1,:); % copy of stimulus -> feed back to IN8 and record with tapping
end
if trigChan>0 && nChannelsOut>=trigChan
    audio2push(trigChan,:) = trigPulse(:); % trigger 
end

PsychPortAudio('FillBuffer',pahandle, audio2push);

