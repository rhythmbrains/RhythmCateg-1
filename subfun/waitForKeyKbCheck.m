function keyCodePressed=waitForKeyKbCheck(keywait)
% keywait:      vector, each entry is the numeric code of one key that is
%               allowed

keyCodePressed=0;
KbReleaseWait; 
while ~ismember(keyCodePressed,keywait)
        [secs, keyCode] = KbWait();
        keyCodePressed = find(keyCode);         
end    
KbReleaseWait; 