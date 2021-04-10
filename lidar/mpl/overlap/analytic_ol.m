function fitted_olc = analytic_ol(rng, olc)
%fitted_olc = analytic_ol(rng, olc)
% olc is the apparent overlap from small values at near range to unity at convergence 
% Defining terms from Stelmaszczyk overlap paper...
% s is telescope aperture diameter
% e(R) is size of transmitted beam at range R

% Work below predates reading of Stelmaszczyk paper with analytic form
% for Overlap "Geometric Compression"

R = 10:10:5000; 
logR = [log10(min(rng)):log10(rng(2)./rng(1)):log10(max(rng))]; r_log = 10.^logR;
for ii = length(r_log):-1:2
    ii_ = rng>r_log(ii-1)&rng<=r_log(ii);
    Ns(ii-1) = sum(ii_);
    rng_logmn(ii-1) = 10.^mean(log10(rng(ii_)));
    olc_logmn(ii-1) = 10.^mean(log10(olc(ii_)));
end
figure; plot(rng_logmn, olc_logmn,'-'); logx;logy
R = rng_logmn.*1000; 
T = .200; % diameter of telescope primary
s = .001; % detector aperture 
f = 0.500; % telescope focal length
phi = 2e-3; % telescope FOV = s/f
g0 = 0.030; % laser initial diameter
d0 = 0; % offset between telecope axis and laser initiation
Theta = phi./2; % Difference between laser beam P vector and telescope axis.  
% Ideally Theta is zero, but realistically it may be non-zero
b = f.*R/ (R-f); % distance from center of primary to image
del = phi.*10.^linspace(-.125,-0.0125,5); % laser beam divergence as log-spaced factor of phi
clear Xi
for dd = length(del):-1:1
G = g0 + del(dd).*R; % diameter of spot at distance R
B = G.*b./R ; %magnification of image
e = f.*(G + T)./R;% diameter of laser spot in image plane
% v_R = f.*(d0-Theta.*R)./R;
r_e_gt_s = e>s;
r_e_lte_s = e<=s;
Xi(dd,:) = ones(size(R));
Xi(dd,r_e_gt_s) = (s.^2)./(e(r_e_gt_s).^2);
end

figure; plot(R./1000,Xi.^1.5,'-',rng, olc,'c-',R./1000,olc_logmn,'m*'); xlabel('km'); logx; logy
% Construct basis set from Xi and stronger powers of Xi
V = [Xi'.^1.1, Xi'.^1.25,Xi'.^1.5, Xi'.^1.75]';

K =[];
while isempty(K) || any(K==0) 
    V(K==0,:) = [];
    K =olc_logmn/V; % K[1xR] = [1xC] / [RxC], when dividing matrices, flip denom dims, cancel like inner
end
     fitted_ol = (K * V)';    % [1xC] = [1xR]*[RxC], when multiplying matrices, cancel like inner dims
fitted_ol(end) = 1; fitted_ol = [fitted_ol; 1]; R = [R,1000.*max(rng)]'; 
fitted_olc = 10.^interp1(log10(R),log10(fitted_ol),log10(rng*1000),'pchip','extrap');
figure; plot(rng, olc,'.b-', rng, fitted_olc,'k-'); logx; logy
legend('measured','fitted')
xlabel('range [km]')
% diameter D of outgoing pulse is D = A + tan(HalfAngle).*R;
% subtended full-angle is approximately D/R
% Overlap correction will be ratio of the square of the FOV/subAngle
% The FOV is approx 200 um / f.  Let f ~ 1 m, FOV ~200e-6;


return
% The focal distance of image formed of pulse located at R is given by
% 1/S + 1/R = 1/f
% ==> S = f/R, and the ratio S/R = f/R^2 is the relative size, at the image
% plane.  So the diameter in the image plane is 
% D' = (A + tan(HalfAngle)*R)*f/R2
% D' = fA/R2 + f*tan(HalfAngle)/R
% And the overlap correction is the detector diameter (d / D')^2
% let f = 1 m 
% let A = 0.2 m
% let HalfAngle = 25 uR
% let d = 200 um

A = 0.1; % Aperture of transceiver
HA = 50e-6; % divergence angle of beam
R = [15:15:15e3]; % Range in meters 
D = A + tan(HA).*R;
FOV = 2e-4;
subAngle = D./R;
OC2 = (FOV./subAngle).^2; OC2(OC2>1) = 1;

figure; plot(R, 1./OC2 -1,'-');logy



% end