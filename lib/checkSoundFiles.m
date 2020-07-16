function checkSoundFiles


% check if any required stimulus files are missing to run the exp

dStim = dir(fullfile('stimuli','*')); 
fidStimList = fopen(fullfile('stimuli','REQUIRED_FILES_LIST'), 'r'); 
DOWNLOAD_STIM = 0; 
fprintf('checking for missing stimulus files...\n'); 

while 1
    
    l = fgetl(fidStimList); 
    if ~any(strcmp({dStim.name},l))
        fprintf('%s \n',l); 
        DOWNLOAD_STIM = 1; 
    end
    if feof(fidStimList)
        break
    end
end

if DOWNLOAD_STIM
    % download missing files from Dropbox
    url = 'https://www.dropbox.com/sh/baw83ib1hmf8tbe/AAAf6DHY7mw6UKXc7qQmbMN8a?dl=1';
    disp('downloading audio files from Dropbox...'); 
    urlwrite(url,'stimuli.zip'); 
    unzip('stimuli.zip','stimuli'); 
    delete('stimuli.zip')
    disp('audio downloaded successfully'); 
end

end