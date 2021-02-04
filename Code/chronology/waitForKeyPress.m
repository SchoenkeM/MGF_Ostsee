function varargout = waitForKeyPress()
% WAITFORKEYPRESS halts the code until a keyboard key is pressed and
% optionally returns the name of the key.
%
% usage:
% KeyName = WAITFORKEYPRESS()
%
% (c) 2017-2021 David Clemens
%          dclemens@geomar.de
%
%   See also WAITFORBUTTONPRESS
%

    isKey   = false;
    while ~isKey % wait until a keyboard key is pressed/ignores mouse clicks
        isKey  	= waitforbuttonpress();
    end
    KeyName	= get(gcf,'CurrentKey');

    varargout{1}    = KeyName;

end