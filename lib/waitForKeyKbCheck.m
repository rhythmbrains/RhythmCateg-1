function idx=waitForKeyKbCheck(keywait)

idx=0;
KbReleaseWait; 
while ~ismember(idx,keywait)
        [secs, key_code] = KbWait();
        idx = find(key_code);         
end    
KbReleaseWait; 