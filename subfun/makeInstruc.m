function structure = makeInstruc(instName, loadPathInstr, structure, fieldName, varargin)

  % -------------------
  % intro instructions  # 1
  % -------------------
  % These need to be saved in separate files, named: 'instrMainExpIntro#'
  % The text in each file will be succesively (based on #) displayed on
  % the screen at the begining of the experiment. Every time, the script
  % will wait for a keypress.

  % example call:
  % cfg = makeInstruc('instrMainExpIntro',loadPathInstr,cfg, 'introInstruction');

  % ------------------------
  % general task instructions # 2
  % ------------------------
  % This is a general summary of the instructions. Participants can toggle
  % these on the screen between sequences if they forget, or want to make
  % sure they understand their task.

  % example call:
  % cfg = makeInstruc('instrMainExpGeneral',loadPathInstr,cfg, 'generalInstruction');

  if nargin > 4
    % will load other instructions
    action = varargin{1};
  end

  dirInstr = dir(fullfile(loadPathInstr, [instName, '*']));

  structure.(fieldName) = cell(1, length(dirInstr));

  for i = 1:length(dirInstr)
    instrFid = fopen(fullfile(loadPathInstr, dirInstr(i).name), 'r', 'n', 'UTF-8');
    while ~feof(instrFid)
      structure.(fieldName){i} = [structure.(fieldName){i}, fgets(instrFid)];
    end
    fclose(instrFid);
  end

end
