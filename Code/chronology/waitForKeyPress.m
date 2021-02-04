function varargout = waitForKeyPress
% waitForKeyPress Wait for key press and return pressed key
%   WAITFORKEYPRESS halts the code until a keyboard key is pressed and
%   optionally returns the name of the key.
%
%   Syntax
%     WAITFORKEYPRESS
%     keyname = WAITFORKEYPRESS
%
%   Description
%     WAITFORKEYPRESS halts code execution until a keyboard key is pressed.
%     keyname = WAITFORKEYPRESS additionally returns the name of the
%       pressed key.
%
%   Example(s)
%     WAITFORKEYPRESS
%     keyname = WAITFORKEYPRESS
%
%
%   Input Arguments
%
%
%   Output Arguments
%     keyname - Name of pressed key
%       char
%         The name of the pressed key returned as a char vector.
%
%
%   Name-Value Pair Arguments
%
%
%   See also WAITFORBUTTONPRESS
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

    % Initialize
    isKey   = false;
    
    % Wait until a keyboard key is pressed/ignores mouse clicks
    while ~isKey 
        isKey  	= waitforbuttonpress();
    end
    
    % Extract most recently pressed key name
    KeyName	= get(gcf,'CurrentKey');

    varargout{1}    = KeyName;
end