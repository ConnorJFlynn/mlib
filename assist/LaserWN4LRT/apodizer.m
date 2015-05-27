
function [rout] = apodizer(rin,action,aflag);

%
% function [rout] = apodizer(rin,action,aflag);
%
% Apply or remove apodization from input sprectrunm, rin
%
% Inputs:
%  rin:      [Nx1] input spectrum
%  action:   string defining what to do: "apply" or "remove"
%  aflag:    determines which apodization function to use.  1 for 
%              Beer, 2 for Kaiser Bessel,k=6
% Outputs:
%  rout:     [Nx1] output spectrum
%
% Assumes the input radiance spectrum, rin, is minimally sampled in
% spectral space.  e.g. for an input spectrum of N points, 
% the N/2 point of the ifg is the MaxOPD point.
%
% DCT 2-18-99
% DCT edited 1-4-07 to include "action" argument.  functions beer.m
% and kbapod.m appended to file.
%

rin = [flipud(rin(2:end));rin(1:end-1)];

N = length(rin);
iMD = length(rin)/2;

if aflag == 1
 apod = beer(N,iMD);
elseif aflag == 2
 apod = kbapod2(N,iMD,6);
end

switch lower(action)
  case 'apply'
    rout = fft(ifft(rin).*apod);
    rout = flipud(rout(1:iMD+1));
  case 'remove'
    rout = fft(ifft(rin)./apod);
    rout = flipud(rout(1:iMD+1));
  otherwise
    rout = NaN;
end




function apod=beer(N,MD);

%
% function apod=beer(N,MD);
%
% compute Beer apodization function
% Inputs:
%   N:  length of apodization function (double sided ifg)
%   MD: index to point where opd = MOPD (for single sided ifg)
% Outputs:
%   apod: apodization function
%
% Comments: resulting function is arranged for MATLAB style
%   ffts with ZPD at apod(1) and MOPD at apod(N/2)
%
beer=zeros(N,1);
beer(1)=1;
for i=2:N/2
	if i <= MD
		beer(i)=(1-((i-1)/MD)^2)^2;
	else
		beer(i)=0;
	end
end
beer(N/2+1:N)=flipud(beer(1:N/2));
apod=beer;


function apod = kbapod2(N, iMD, k)

%
% function apod = kbapod2(N, iMD, k)
%
% compute Kaiser-Bessel apodization function
% inputs:
%   N:  length of apodization function (double sided ifg)
%   iMD: index to point where opd = MOPD (for single sided ifg)
%   k - Kaiser-Bessel parameter (int > 0).  DEFAULT=6
%
% output
%   apod - apodization function
%
% This is a modified version of Howard Motteler's original kbapod.m 
% In this version, the resulting function is arranged for MATLAB style
% ffts with ZPD at apod(1) and MOPD at apod(N/2) (in the same manner as 
% beer.m).
%
% DCT 2-12-98
%
if ~exist('k'); k=6; end
apod = zeros(N,1);
d = linspace(0,N/2,N/2)';
x = k * sqrt(1 - (d/iMD).^2) ;
% I(x)
r = ones(N/2,1); f = 1;
for j = 1:8;
  f = f * j;
  r = r + (x/2).^(2*j) / f^2 ;
end

% I(k)
s = 1; f = 1;
for j = 1:8;
  f = f * j;
  s = s + (k/2).^(2*j) / f^2 ;
end
c = (abs(d) <= iMD) .* r / s;
apod(1:N/2)=c;
apod(N/2+1:N) = flipud(c);

