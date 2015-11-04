%scat_weights returns vectors of dtheta and weights
%   for calculating angular-weighted scattering.
% Inputs [theta1, wt1, theta2, wt2...]
% Returns [theta, dtheta, weightarr] where there is only one dtheta and
%   weightarr begins with normal cos, backscat cos, then inputs
function [theta, dtheta, wtlist] =IntegScat(varargin)

angres = 0.25;        % Tad did 720 angles: this is in degrees

nang = 180/angres;
degs = (0:angres:180)';
theta = d2r(degs);

% calculate weights 
wtlist = {};

%basic weighting functions: sin(theta) & bkscat sin
wt1 = sin(theta);
wtlist{1} = wt1;
bsflag = real(degs>90);
bsflag(find(degs==90)) = 0.5;
wtlist{2} = wt1 .* bsflag;

% process varargin
isargval = false;

for i=1:length(varargin)
    wtmat = varargin{i};
    wttemp = interp(wtmat(:,1), wtmat(:,2), degs)';
    if size(wttemp, 1) == 1
        wtlist{i+2} = wttemp';
    else
        wtlist{i+2} = wttemp;
    end
end

% calculate d-theta
dtheta = zeros(size(theta));        %ensure it's same shape as theta
dtheta(2:nang) = d2r(angres);
dtheta(1) = d2r(angres*0.5);
dtheta(nang+1) = d2r(angres*0.5);

return

% degree to radian
function rang = d2r(ang)
   rang = ang * pi/180;
return

