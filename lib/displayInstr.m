function displayInstr(txt,screen,varargin)
% displayInstr(txt,screen,[keywait])

DrawFormattedText(screen.h,txt,'center','center',screen.whitecol); 

if ~isempty(varargin)
    keywait = varargin{1};     
    DrawFormattedText(screen.h,'Press ENTER to continue...','center',screen.y*0.9,screen.whitecol); 
end

Screen('Flip',screen.h); 

if ~isempty(varargin)
    idx = waitForKeyKbCheck(keywait); 
end
