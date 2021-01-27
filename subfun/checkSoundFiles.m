function checkSoundFiles(path)
  % this mini function checks if in the specified path (must be provided as
  % input) the stimuli folder and required lists of .wav files exits. If it
  % does not exist, it installed as .zip and unzip them in that specified
  % path.

  %% MUST provide the following
  % folder name to check
  fName = 'stimuli';
  % text to read file names
  fRead = 'REQUIRED_FILES_LIST';
  % link to download
  ulrName = 'https://www.dropbox.com/sh/baw83ib1hmf8tbe/AAAf6DHY7mw6UKXc7qQmbMN8a?dl=1';
  % file zip
  fZip = [fName, '.zip'];

  %% start - do stuff

  % set to default
  DOWNLOAD_STIM = 0;

  % check if any required stimulus files are missing to run the exp
  dStim = dir(fullfile(path, fName, '*'));

  fidStimList = fopen(fullfile(path, fName, fRead), 'r');

  fprintf('checking for missing stimulus files...\n');

  while 1

    l = fgetl(fidStimList);
    if ~any(strcmp({dStim.name}, l))
      fprintf('%s \n', l);
      DOWNLOAD_STIM = 1;
    end
    if feof(fidStimList)
      break
    end
  end

  if DOWNLOAD_STIM
    % download missing files from Dropbox
    url = ulrName;
    disp('downloading audio files from Dropbox...');
    urlwrite(url, fZip);
    unzip(fZip, fName);
    delete(fZip);
    disp('audio downloaded successfully');
  end

  fprintf('All files are in order! Wohooo! Ready to go...\n');
end
