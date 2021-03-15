function [subAction] = displayInstr(instrTxt, cfg, varargin)
  % varargin:
  %
  %     'setVolume' displays intrTxt and offers possibility for the
  %     participant to set the volume
  %
  %     'setVolumeAndGeneralInstrOption' displays intrTxt and offers possibility for the
  %     participant to set the volume, or toggle general instructions for the
  %     expeiment
  %         - !!! in varargin, provide also:
  %                 generalInstrTxt :   string,
  %                                     text of the genral task instruction to display
  %                                     if toggled
  %
  %     'waitForKeypress' displays intrTxt and waits for keypress to continue
  %
  %     'instrAndQuitOption' displays intrTxt and info about experiment
  %     termination (quit option)
  %
  %     if no varargin provided, the function only displays intrTxt on the screen and returns

  % This optional variable can be used to inform the script about particpant's action.
  % E.g. if participants wants to move one instruction-page back, we can let the script
  % know through this output variable.
  subAction = [];

  Screen('TextFont', cfg.screen.win, cfg.text.font);
  Screen('TextSize', cfg.screen.win, cfg.text.size);

  %% volume setting
  if any(strcmpi(varargin, 'setVolume'))

    % put volume-setting audio into buffer
    fillSoundBuffer(cfg.volumeSettingSound, ...
                    cfg.audio.fs, ...
                    cfg.audio.pahandle, ...
                    cfg.audio.channels(1), ...
                    0); 

    % set allowed keys
    allowedKeys = [cfg.keyboard.audioPlay, cfg.keyboard.audioStop, ...
                   cfg.keyboard.volDown, cfg.keyboard.volUp, ...
                   cfg.keyboard.wait, cfg.keyboard.quit];

    % wait for participatnt's response
    while 1

      % display instructions in the center of cfg.screen
      DrawFormattedText(cfg.screen.win, instrTxt, 'center', 'center', cfg.color.white);

      % display continue option on the bottom of the screen
      DrawFormattedText(cfg.screen.win, 'Press [ENTER] to continue...', ...
                        'center', cfg.screen.winHeight * 0.9, cfg.color.white);

      % display quit option in the cfg.screen corner
      txt = sprintf([sprintf(' Press [%s] to play test sound\n', ...
                             KbName(cfg.keyboard.audioPlay)), ...
                     sprintf(' Press [%s] to stop test sound\n', ...
                             KbName(cfg.keyboard.audioStop)), ...
                     sprintf(' Press [%s] to increase volume\n', ...
                             KbName(cfg.keyboard.volUp)), ...
                     sprintf(' Press [%s] to decrease volume\n', ...
                             KbName(cfg.keyboard.volDown)), ...
                     sprintf('\n Volume = %d%%\n', ...
                             round(PsychPortAudio('Volume', cfg.audio.pahandle) * 100)) ...
                    ]);
      tbx     = Screen('TextBounds', cfg.screen.win, txt);
      width   = tbx(3);
      height  = tbx(4);
      r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
      r = AlignRect(r, cfg.screen.winRect, RectLeft, RectTop);
      DrawFormattedText(cfg.screen.win, txt, r(RectLeft), r(RectBottom), ...
                        cfg.color.white);

      % display quit option
      txt = sprintf('press [%s] to quit the whole experiment  ', ...
                    KbName(cfg.keyboard.quit));
      tbx     = Screen('TextBounds', cfg.screen.win, txt);
      width   = tbx(3);
      height  = tbx(4);
      r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
      r = AlignRect(r, cfg.screen.winRect, RectRight, RectTop);
      DrawFormattedText(cfg.screen.win, txt, r(RectLeft), r(RectBottom), ...
                        cfg.color.white);

      Screen('Flip', cfg.screen.win);

      % wait for keypress
      keyCodePressed = waitForKeyKbCheck(allowedKeys);

      if ismember(keyCodePressed, cfg.keyboard.audioPlay)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        PsychPortAudio('Start', cfg.audio.pahandle);

      elseif ismember(keyCodePressed, cfg.keyboard.audioStop)
        PsychPortAudio('Stop', cfg.audio.pahandle);

      elseif ismember(keyCodePressed, cfg.keyboard.volUp)
        oldVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
        newVolume = min(oldVolume + 0.05, 1);
        PsychPortAudio('Volume', cfg.audio.pahandle, newVolume);

      elseif ismember(keyCodePressed, cfg.keyboard.volDown)
        oldVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
        newVolume = max(oldVolume - 0.05, 0);
        PsychPortAudio('Volume', cfg.audio.pahandle, newVolume);

      elseif ismember(keyCodePressed, cfg.keyboard.wait)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        break

      elseif ismember(keyCodePressed, cfg.keyboard.quit)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        error('experiment terminated by user');

      end

    end

    %% volume setting and option to go previous/next in the instruction pages
  elseif any(strcmpi(varargin, 'setVolumePrevNext'))
    %
    %      !!! IMPORTANT !!! -> specify in varargin:
    %         currInstrPage :     int
    %                             which instruction page are we currently at?
    %         nInstrPages :       int
    %                             how many instruction pages are there before
    %                             continuing?

    % put volume-setting audio into buffer
    fillSoundBuffer(cfg.volumeSettingSound, ...
                    cfg.audio.fs, ...
                    cfg.audio.pahandle, ...
                    cfg.audio.channels(1), ...
                    0); 


    % set allowed keys
    allowedKeys = [cfg.keyboard.audioPlay, cfg.keyboard.audioStop, ...
                   cfg.keyboard.volDown, cfg.keyboard.volUp, ...
                   cfg.keyboard.instrBack, cfg.keyboard.instrNext, ...
                   cfg.keyboard.wait, cfg.keyboard.quit];

    % get current instruction page index from varargin
    if any(strcmpi(varargin, 'currInstrPage'))
      currInstrPage = varargin{find(strcmpi(varargin, 'currInstrPage')) + 1};
    else
      warning('instruction page index not specified');
      currInstrPage = [0];
    end
    % get total number of instruction pages from varargin
    if any(strcmpi(varargin, 'nInstrPages'))
      nInstrPages = varargin{find(strcmpi(varargin, 'nInstrPages')) + 1};
    else
      warning('number of instruction pages not specified');
      nInstrPages = [0];
    end

    % wait for participatnt's response
    while 1

      % display instructions in the center of cfg.screen
      DrawFormattedText(cfg.screen.win, instrTxt, 'center', 'center', ...
                        cfg.color.white);

      % display continue option on the bottom of the screen
      % ! only if we're at the last instruction page !
      if currInstrPage == nInstrPages
        DrawFormattedText(cfg.screen.win, 'Press [ENTER] to continue...', ...
                          'center', cfg.screen.winHeight * 0.9, cfg.color.white);
      end

      % display quit option in the cfg.screen corner
      txt = sprintf([sprintf(' Press [%s] to play test sound\n', ...
                             KbName(cfg.keyboard.audioPlay)), ...
                     sprintf(' Press [%s] to stop test sound\n', ...
                             KbName(cfg.keyboard.audioStop)), ...
                     sprintf(' Press [%s] to increase volume\n', ...
                             KbName(cfg.keyboard.volUp)), ...
                     sprintf(' Press [%s] to decrease volume\n', ...
                             KbName(cfg.keyboard.volDown)), ...
                     sprintf('\n Volume = %d%%\n', ...
                             round(PsychPortAudio('Volume', cfg.audio.pahandle) * 100)) ...
                    ]);
      tbx     = Screen('TextBounds', cfg.screen.win, txt);
      width   = tbx(3);
      height  = tbx(4);
      r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
      r = AlignRect(r, cfg.screen.winRect, RectLeft, RectTop);
      DrawFormattedText(cfg.screen.win, txt, r(RectLeft), r(RectBottom), ...
                        cfg.color.white);

      % display quit option
      txt = sprintf('press [%s] to quit the whole experiment  ', ...
                    KbName(cfg.keyboard.quit));
      tbx     = Screen('TextBounds', cfg.screen.win, txt);
      width   = tbx(3);
      height  = tbx(4);
      r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
      r = AlignRect(r, cfg.screen.winRect, RectRight, RectTop);
      DrawFormattedText(cfg.screen.win, txt, r(RectLeft), r(RectBottom), ...
                        cfg.color.white);

      % display previous option for instruction pages
      txt = sprintf([sprintf('page %d/%d \n', currInstrPage, nInstrPages), ...
                     sprintf('press [%s] to go forward\n', ...
                             KbName(cfg.keyboard.instrNext)), ...
                     sprintf('press [%s] to go back\n', ...
                             KbName(cfg.keyboard.instrBack)) ...
                    ]);
      nLines  = 3;
      tbx     = Screen('TextBounds', cfg.screen.win, txt);
      width   = tbx(3);
      height  = tbx(4);
      r = [0 0 width height + nLines * Screen('TextSize', cfg.screen.win)];
      r = AlignRect(r, cfg.screen.winRect, RectRight, RectBottom);
      DrawFormattedText(cfg.screen.win, txt, r(RectLeft), r(RectTop), ...
                        cfg.color.white);

      Screen('Flip', cfg.screen.win);

      % wait for keypress
      keyCodePressed = waitForKeyKbCheck(allowedKeys);

      if ismember(keyCodePressed, cfg.keyboard.audioPlay)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        PsychPortAudio('Start', cfg.audio.pahandle);

      elseif ismember(keyCodePressed, cfg.keyboard.audioStop)
        PsychPortAudio('Stop', cfg.audio.pahandle);

      elseif ismember(keyCodePressed, cfg.keyboard.volUp)
        oldVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
        newVolume = min(oldVolume + 0.05, 1);
        PsychPortAudio('Volume', cfg.audio.pahandle, newVolume);

      elseif ismember(keyCodePressed, cfg.keyboard.volDown)
        oldVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
        newVolume = max(oldVolume - 0.05, 0);
        PsychPortAudio('Volume', cfg.audio.pahandle, newVolume);

      elseif ismember(keyCodePressed, cfg.keyboard.wait) && ...
              currInstrPage == nInstrPages
        PsychPortAudio('Stop', cfg.audio.pahandle);
        subAction = 'done';
        break

      elseif ismember(keyCodePressed, cfg.keyboard.instrNext)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        subAction = 'oneInstrPageForward';
        break

      elseif ismember(keyCodePressed, cfg.keyboard.instrBack)
        subAction = 'oneInstrPageBack';
        break

      elseif ismember(keyCodePressed, cfg.keyboard.quit)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        error('experiment terminated by user');

      end

    end

    %% display instructions, give option to 1) set volume, 2) display general instruction
  elseif any(strcmpi(varargin, 'setVolumeToggleGeneralInstr'))

    % look for general intruction text in varargin
    if any(strcmpi(varargin, 'generalInstrTxt'))
      generalInstrTxt = varargin{find(strcmpi(varargin, 'generalInstrTxt')) + 1};
    else
      error(['You need to call displayInstr function with ''generalInstrTxt'' '...
             'in the varargin. Otherwise I don''t know what general '...
             'instructions to display...']);
    end

    % put volume-setting audio into buffer
    fillSoundBuffer(cfg.volumeSettingSound, ...
                    cfg.audio.fs, ...
                    cfg.audio.pahandle, ...
                    cfg.audio.channels(1), ...
                    0); 


    % set allowed keys
    allowedKeys = [cfg.keyboard.audioPlay, cfg.keyboard.audioStop, ...
                   cfg.keyboard.volDown, cfg.keyboard.volUp, ...
                   cfg.keyboard.wait, cfg.keyboard.toggleInstr, ...
                   cfg.keyboard.quit];

    % boolean used to toggle general instruction display
    generalInstrOnScreen = false;

    % wait for participatnt's response
    while 1

      if generalInstrOnScreen
        % we are displaying general instructions for the experiment

        if iscell(generalInstrTxt)
            % if this is cell, unpack the string (we asume that general
            % instr is only 1 page)
            generalInstrTxt = generalInstrTxt{1}; 
        end
        % display instructions in the center of cfg.screen.win
        DrawFormattedText(cfg.screen.win, generalInstrTxt, 'center', ...
                          'center', cfg.color.white);

        % display continue option on the bottom of the screen
        DrawFormattedText(cfg.screen.win, ...
                          'Press [I] to toggle instructions, or [ENTER] to continue...', ...
                          'center', cfg.screen.winHeight * 0.9, cfg.color.white);

      else
        % we are displaying normal setVolume display

        % display instructions in the center of cfg.screen
        DrawFormattedText(cfg.screen.win, instrTxt, 'center', ...
                          'center', cfg.color.white);

        % display continue option on the bottom of the screen
        DrawFormattedText(cfg.screen.win, ...
                          'Press [I] to toggle instructions, or [ENTER] to continue...', ...
                          'center', cfg.screen.winHeight * 0.9, cfg.color.white);

        % display quit option in the cfg.screen corner
        txt = sprintf([sprintf(' Press [%s] to play test sound\n', ...
                               KbName(cfg.keyboard.audioPlay)), ...
                       sprintf(' Press [%s] to stop test sound\n', ...
                               KbName(cfg.keyboard.audioStop)), ...
                       sprintf(' Press [%s] to increase volume\n', ...
                               KbName(cfg.keyboard.volUp)), ...
                       sprintf(' Press [%s] to decrease volume\n', ...
                               KbName(cfg.keyboard.volDown)), ...
                       sprintf('\n Volume = %d%%\n', ...
                               round(PsychPortAudio('Volume', cfg.audio.pahandle) * 100)) ...
                      ]);
        tbx     = Screen('TextBounds', cfg.screen.win, txt);
        width   = tbx(3);
        height  = tbx(4);
        r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
        r = AlignRect(r, cfg.screen.winRect, RectLeft, RectTop);
        DrawFormattedText(cfg.screen.win, txt, r(RectLeft), ...
                          r(RectBottom), cfg.color.white);

        % display quit option
        txt = sprintf('press [%s] to quit the whole experiment  ', ...
                      KbName(cfg.keyboard.quit));
        tbx     = Screen('TextBounds', cfg.screen.win, txt);
        width   = tbx(3);
        height  = tbx(4);
        r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
        r = AlignRect(r, cfg.screen.winRect, RectRight, RectTop);
        DrawFormattedText(cfg.screen.win, txt, r(RectLeft), ...
                          r(RectBottom), cfg.color.white);

      end

      Screen('Flip', cfg.screen.win);

      % wait for keypress
      keyCodePressed = waitForKeyKbCheck(allowedKeys);

      if ismember(keyCodePressed, cfg.keyboard.audioPlay)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        PsychPortAudio('Start', cfg.audio.pahandle);

      elseif ismember(keyCodePressed, cfg.keyboard.audioStop)
        PsychPortAudio('Stop', cfg.audio.pahandle);

      elseif ismember(keyCodePressed, cfg.keyboard.volUp)
        oldVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
        newVolume = min(oldVolume + 0.05, 1);
        PsychPortAudio('Volume', cfg.audio.pahandle, newVolume);

      elseif ismember(keyCodePressed, cfg.keyboard.volDown)
        oldVolume = PsychPortAudio('Volume', cfg.audio.pahandle);
        newVolume = max(oldVolume - 0.05, 0);
        PsychPortAudio('Volume', cfg.audio.pahandle, newVolume);

      elseif ismember(keyCodePressed, cfg.keyboard.toggleInstr)

        % update the bool
        generalInstrOnScreen = ~generalInstrOnScreen;

      elseif ismember(keyCodePressed, cfg.keyboard.wait)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        break

      elseif ismember(keyCodePressed, cfg.keyboard.quit)
        PsychPortAudio('Stop', cfg.audio.pahandle);
        error('experiment terminated by user');

      end

    end

    %% display instructions and wait for keypress
  elseif any(strcmpi(varargin, 'waitForKeypress'))

    % display instructions in the center of cfg.screen
    DrawFormattedText(cfg.screen.win, instrTxt, 'center', ...
                      'center', cfg.color.white);

    % display continue option on the bottom of the screen
    DrawFormattedText(cfg.screen.win, ...
                      'Press [ENTER] to continue...', 'center', ...
                      cfg.screen.winHeight * 0.9, cfg.color.white);

    % display quit option
    txt = sprintf('press [%s] to quit the whole experiment  ', ...
                  KbName(cfg.keyboard.quit));
    tbx     = Screen('TextBounds', cfg.screen.win, txt);
    width   = tbx(3);
    height  = tbx(4);
    r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
    r = AlignRect(r, cfg.screen.winRect, RectRight, RectTop);
    DrawFormattedText(cfg.screen.win, txt, r(RectLeft), ...
                      r(RectBottom), cfg.color.white);

    Screen('Flip', cfg.screen.win);

    % wait for participant's keypress to continue
    keyCodePressed = waitForKeyKbCheck([cfg.keyboard.wait, cfg.keyboard.quit]);

    if ismember(keyCodePressed, cfg.keyboard.wait)
      PsychPortAudio('Stop', cfg.audio.pahandle);
      return

    elseif ismember(keyCodePressed, cfg.keyboard.quit)
      PsychPortAudio('Stop', cfg.audio.pahandle);
      error('experiment terminated by user');

    end

    %% display instructions and quit option but don't wait
  elseif any(strcmpi(varargin, 'instrAndQuitOption'))
    %     if there is additional feedback you'd like to display, you can specify it in varargin
    %         fbktxt:     string
    %                     text of additional feecback that will appear on the bottom of
    %                     the screen

    % look for additional feedback, if requested display it
    if any(strcmpi(varargin, 'fbktxt'))
      fbktxt = varargin{find(strcmpi(varargin, 'fbktxt')) + 1};
      % switcht to mono font
      Screen('TextFont', cfg.screen.win, 'Consolas');
      DrawFormattedText(cfg.screen.win, fbktxt, 'center', ...
                        cfg.screen.winHeight * 0.75, cfg.color.white);
      % switch font back to default
      Screen('TextFont', cfg.screen.win, cfg.text.font);
    end

    % display instructions in the center of cfg.screen
    DrawFormattedText(cfg.screen.win, instrTxt, 'center', ...
                      'center', cfg.color.white);

    % display small-font quit option
    Screen('TextSize', cfg.screen.win, cfg.text.size * 0.7);
    txt = sprintf( ...
                  '(in case of emergency, press [%s] to terminate the experiment)  ', ...
                  KbName(cfg.keyboard.quit));
    tbx     = Screen('TextBounds', cfg.screen.win, txt, [], [], [], []);
    width   = tbx(3);
    height  = tbx(4);
    r = [0 0 width height + Screen('TextSize', cfg.screen.win)];
    r = AlignRect(r, cfg.screen.winRect, RectRight, RectTop);
    DrawFormattedText(cfg.screen.win, txt, r(RectLeft), ...
                      r(RectBottom), cfg.color.white);
    Screen('TextSize', cfg.screen.win, cfg.text.size);

    Screen('Flip', cfg.screen.win);

    %% display instructions
  else

    % display instructions in the center of cfg.screen
    DrawFormattedText(cfg.screen.win, instrTxt, 'center', ...
                      'center', cfg.text.color);

    Screen('Flip', cfg.screen.win);

  end
