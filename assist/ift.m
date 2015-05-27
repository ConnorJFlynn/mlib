
function [a,b] = ift(x,y,sidesin,sidesout)

% function [a,b] = ift(x,y,sidesin,sidesout)
%
% ifft y, where y=f(x)
% get y = ifft(yft), and xft
% where y = f(x)
%
%
% sides = 1 for one-sided (will be made two-sided before FT)
%			note: for one-sided can have any number of points
%			assumes that the spectrum starts from 0 frequency
%
% Note: the format must be as follows:
%
% 	for single sided:
% 		spectrum must start with zero frequency and end with 
%       nyquist critical frequency.  It can have even or odd 
%       number of points (will end up even)
%
%	for double sided:
%		must be in following format already ...
%		zero frequency up to nyquist frequency, then
%		negative of one less than nyquist frequency down to
%		negative of one more than zero frequency
%
%   to optimize we should use a factor of 2 number of points for 
%       double-sided but in this code we use factor of 2 number of 
%       points plus one point (zero nu)
%       this should be fixed in future versions.
%
%
%
% Inverse Fourier Transform
% Penny Rowe
% July 26, modified March 3, 2000 and March 26, 2000


% make y vector into row vectors
dims = size(y);
if dims(1)==1
    % already row vector
elseif dims(2)==1
    y=y';
end
   

% Note: assuming we start with an interferogram and fft to get a spectrum
% or alternatively start with a spectrum and ifft to get an interferorgram
% Then the following is true
%
% spectrum(1) = sum(interferogram)
% interferogram(1) = sum(spectrum)/10
%
% So, in going from the spectrum to the interferogram (ift), we want
% the integral under the spectrum to equal the integral under the
% interferogram, so we make the first point be the integral under the 
% spectrum


if sidesin == 1

    % Flip to make the left hand side,
    rhs = fliplr(y(2:length(y)-1));

    % note: the spectrum must be anti-symmetric!
    y = [real(y)-1i*imag(y) rhs];

    % Note: we have 2 x number of points - 2


elseif sidesin ==2
    x = x(find(x>=0));
    % donothing
else
    error('sidesin =1 for one-sided, 2 for 2-sided');
end


% I assume everything is perfect already
% Now ifft using Matlab's built in code
b = ifft(y);


% make a a vector of integers, starting from zero
N = 2*length(x)-2;
n = (0:length(x)-1);
n = [n -fliplr(n(2:length(n)-1))];
dx = x(2)-x(1);

% now multiply by da to scale properly
a = (1/(N*dx)) * n;

if sidesout==2
   %donothing
elseif sidesout==1
   inds = find(a>=0);
   a = a(inds);
   b = b(inds);
end






