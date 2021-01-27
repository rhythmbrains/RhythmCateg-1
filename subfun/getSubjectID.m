function [datalog] = getSubjectID(cfg)
  % Get integer values for Subject Name, run number,
  % saves them into a datalog structure

  if cfg.debug

    subjectNumber = '666';
    runNumber = '666';

  else

    % subject
    subjectNumber = str2double(input('Enter Subject ID number: ', 's'));
    subjectNumber = checkInput(subjectNumber);

    % run
    runNumber = str2double(input('Enter the run Number: ', 's'));
    runNumber = checkInput(runNumber);

  end

  % assign them into its structure to carry around
  datalog.subjectNb = subjectNumber;
  datalog.runNb = runNumber;

end

function input2check = checkInput(input2check)

  while isnan(input2check) || fix(input2check) ~= input2check || input2check < 0
    input2check = str2double(input('Please enter a positive integer: ', 's'));
  end

end
