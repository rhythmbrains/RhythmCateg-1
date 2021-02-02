function [tapData, startTime, trialTerminated] = playSound(s, ...
                                                           fs, ...
                                                           pahandle, ...
                                                           nChannelsOut, ...
                                                           nChannelsIn, ...
                                                           trigChan, ...
                                                           initPushDur, ...
                                                           pushDur, ...
                                                           keyStop)

% This function performs audio playback while pushing small chunks of audio
% into the buffer, while the sound is playing. 
% This can help greatly to decrease RAM demands when using long audio
% sequences and many channels. 

% The amount of audio you can push during continuous buffer refill in PTB 
% cannot be more than what has already been played. 
% 
% |--------------------------------|
%         first pushed audio
% 
%            wait until here
% |-----------------|--------------|
%   already played    to-be played
% 
% |-----------------|
% this much can be pushed at this timepoint without overflow
%   
%     
% First push needs to be longer, e.g. 5 seconds. After that first push, we
% need to wait a reasonable time to have space in the buffer 
%     
% Then we refill in small chunks until the end time of whole audio
% sequence. 
% 
% 
% !!! IMPORTANT !!! Make sure you don't try to display too much text on the
% screen while doing the continuous playback. Depending on how strong your
% computer is, this will produce cracks!!! 
% 
% !!! IMPORTANT !!! textprogressbar will complain if there is a newline
% on the command line, which is for some reason introduced when assignment
% to a variable with camelCase name is executed by the script. 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n-> PLAYBACK STARTED <- \n\n(if you need to stop the sound immediately, hold down DELETE)\n\n'); 

%  PsychPortAudio('Stop', pahandle);


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

trialTerminated = 0; 

sDur = length(s)/fs; 

pushSamples = round(pushDur*fs);  

initPushSamples = round(initPushDur*fs); 

% wait until half of the initial push duration before starting to pushing
% small chunks 
initPushWaitTime = initPushDur/2; 

% preallocate taping data
tapData = zeros(2, round((sDur+10)*fs) ); 

currTapIdx = 0; 

currAudioIdx = 0; 

% first push of audio into the buffer
currAudioIdx = pushData(pahandle, ...
                        s, ...
                        trigPulse, ...
                        currAudioIdx, ...
                        trigChan, ...
                        initPushSamples, ...
                        nChannelsOut, ...
                        'first'); 


% start playback
startTime = PsychPortAudio('Start',pahandle,0,[],1);  % handle, repetitions, when=0, waitForStart

% NOTE: above, need to set repetitions=0, otherwise it will not
% allow you to seamlessly push more data into the buffer once the
% sound is playing

% initialise progress bar...
textprogressbar('trial progress: '); 

%%%%%%% PLAYBACK LOOP %%%%%%%

currTime = startTime; 

% wait half of first push size
waitUntilTime = currTime + initPushWaitTime; 

% update progress bar every initPushWaitTime seconds (this works quite well) 
waitUntilTimeProgressBar = currTime + initPushWaitTime; 

while 1       
    
    currTime = WaitSecs('UntilTime', waitUntilTime); 
    
    waitUntilTime = currTime + pushDur;
        
    % update progress bar
    if currTime > waitUntilTimeProgressBar
        percentProgress = (currTime-startTime)/sDur*100; 
        textprogressbar(percentProgress);
        waitUntilTimeProgressBar = currTime + initPushWaitTime; 
    end
    
    % push samll chunk of audio data into the buffer
    currAudioIdx = pushData(pahandle, ...
                            s, ...
                            trigPulse, ...
                            currAudioIdx, ...
                            trigChan, ...
                            pushSamples, ...
                            nChannelsOut, ...
                            'regular'); 
            
    if isinf(currAudioIdx)        
        % audio is ending, wait until it stops
        % pahandle [, waitForEndOfPlayback=0] [, blockUntilStopped=1] [, repetitions] [, stopTime]
        PsychPortAudio('Stop', pahandle, 1, 1, [], startTime+sDur); 
        break
    end
            
    % fetch data from the audio buffer (tapping)
    [tapData, currTapIdx] = fetchData(pahandle, tapData, currTapIdx, nChannelsIn); 

    % if DELETE pressed terminate the trial
    [keyDown, secs, keyCode] = KbCheck(-1);
    if ismember(find(keyCode),[keyStop])
        trialTerminated = 1; 
        PsychPortAudio('Stop', pahandle); 
        break 
    end

end

% do the final fetch from the input buffer (just to be sure)
[tapData, currTapIdx] = fetchData(pahandle, tapData, currTapIdx, nChannelsIn); 

textprogressbar(' end of playback');

end



function currAudioIdx = pushData(pahandle, s, trigPulse, currAudioIdx, trigChan, pushSamples, nChannelsOut, pushType)

    % push data into the audio buffer
        
    % this will be the last push 
    if currAudioIdx+pushSamples > length(s)
        audio2push              = zeros(nChannelsOut, length(s)-currAudioIdx); 
        audio2push(1,:)         = s(1, currAudioIdx+1:end); % left earphone
        audio2push(2,:)         = s(2, currAudioIdx+1:end); % right earphone
        if nChannelsOut>=5
            audio2push(5,:)     = s(1, currAudioIdx+1:end); % copy of stimulus -> feed back to IN8 and record with tapping
        end
        if trigChan>0 && nChannelsOut>=trigChan
            audio2push(trigChan,:) = trigPulse(currAudioIdx+1:end); 
        end
        currAudioIdx            = inf; 

    % this will a regular push 
    else
        audio2push              = zeros(nChannelsOut, pushSamples); 
        audio2push(1,:)         = s(1, currAudioIdx+1:currAudioIdx+pushSamples); % left earphone
        audio2push(2,:)         = s(2, currAudioIdx+1:currAudioIdx+pushSamples); % right earphone
        if nChannelsOut>=5
            audio2push(5,:)     = s(1, currAudioIdx+1:currAudioIdx+pushSamples); % copy of stimulus -> feed back to IN8 and record with tapping
        end
        if trigChan>0 && nChannelsOut>=trigChan
            audio2push(trigChan,:) = trigPulse(currAudioIdx+1:currAudioIdx+pushSamples); 
        end
        currAudioIdx            = currAudioIdx+pushSamples; 
    end 

    if  ~isempty(audio2push) 
        % first push 
        if strcmpi(pushType,'first')
            PsychPortAudio('FillBuffer',pahandle, audio2push);
        % continuous refill push 
        else
            PsychPortAudio('FillBuffer',pahandle, audio2push, 1);
        end
    end


end

function [tapData, currTapIdx] = fetchData(pahandle, tapData, currTapIdx, nChannelsIn)

    fetchedAudio = PsychPortAudio('GetAudioData', pahandle); 

    if ~isempty(fetchedAudio)
        if nChannelsIn>=8
            % extract channel 1 with tapping box, and channel 8 with stimulus copy
            tapData(:,currTapIdx+1:currTapIdx+size(fetchedAudio,2)) = fetchedAudio([1,8],:); 
        elseif nChannelsIn>=2
            % extract channel 1 with tapping box, and channel 2 with stimulus copy
            tapData(:,currTapIdx+1:currTapIdx+size(fetchedAudio,2)) = fetchedAudio([1,2],:); 
        else
            % extract channel 1 with tapping box
            tapData(:,currTapIdx+1:currTapIdx+size(fetchedAudio,2)) = fetchedAudio(1,:); 
        end
        currTapIdx = currTapIdx + size(fetchedAudio,2);
    end
end