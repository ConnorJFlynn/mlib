
function [nu, yft] = ft(x,y,sidesin,sidesout)

% function [nu, yft] = ft(x,y,sidesin,sidesout)
%
% fft y, where y=f(x)
% get yft = fft(y), and nu
% where yft = f(nu)
%
% sides = 1 for one-sided (will be made two-sided)
% sides = 2 for two-sided
%
% Fourier Transform
% Penny Rowe
% July 26, modified March 3, 2000


% make vectors into row vectors
dims = size(x);
if dims(1)==1
   % already row vector
elseif dims(2)==1
   x=x';
end
dims = size(y);
if dims(1)==1
	% already row vector
elseif dims(2)==1
	y=y';
end


if sidesin == 1
   y2 = fliplr(y(2:length(y)-1));
   y = [y y2]; % original
   
   % The following appears not to work:
   %y2 = fliplr(y(2:length(y)-1));   
   %rhs = fliplr(y(2:length(y)-1));
   %y = [rhs real(y)-1i*imag(y) ];

elseif sidesin ==2
   % get positive values of x only
   x = x(x>=0);
else 
   fprintf('error: sidesin =1 for one-sided, 2 for 2-sided');
   return
end

yft = fft(y);

% make a a vector of integers, starting from zero
N = 2*length(x)-2;
n = (0:length(x)-1);
n = [n -fliplr(n(2:length(n)-1))];
dx = x(2)-x(1);

nu = (1/(N*dx)) * n;

if sidesout==2
   %donothing
elseif sidesout==1
   inds = find(nu>=0);
   nu = nu(inds);
   yft = yft(inds);
end

