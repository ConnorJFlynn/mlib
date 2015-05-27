% A simple program that uses your internet address to locate where you are
% in the world and return an estimated latitude and longitude.
%
% Usage:  [lat,lon] = latlon()

function varargout = latlon(varargin)
% Version 1.0
%
% This function will also return the individual latitude and longitude if
% called using latlon(1) and latlon(2) respectively however this is
% discouraged as each call will crate a new trace and hence increase run
% time.

position = '';r=1:2;
if(nargin == 1); 
    if(isnumeric(varargin{1})); r=varargin{1};
    else position = varargin{1};end
end
try
    d=regexp(urlread(['http://paulschou.com/tools/sbdart/latlon.php?'...
    urlencode(position)]),'^([-\d\.]+)\s+([-\d\.]+)\s+([^\n]+)','tokens');
catch
	error('You must be on the internet for this code to work');
end
d{1}{1} = str2num(d{1}{1});d{1}{2} = str2num(d{1}{2});
if(nargout == 3)
	varargout = {d{1}{1:3}};
elseif(nargout == 2)
    varargout = [d{1}{1:2}];
elseif(nargout < 2)
    varargout{1} = [d{1}{r}];
end
