function fitted_olc = analytic_ol_uc(rng, olc, pin_R)
% fitted_olc = analytic_ol_uc(rng, olc, pin_R)
% Requires rng (range) and olc (overlap)
% Defining terms from Stelmaszczyk overlap paper...
% s is telescope aperture diameter
% e(R) is size of transmitted beam at range R

% Work below incorporates Stelmaszczyk paper with analytic form
% for Overlap "Geometric Compression"
% OCIS codes: 010.3640, 280.0280, 110.6770

%Might be able to use location of maxima observed in OL-corrected Rayleigh
%to better bracket the basis set.

% Also, explore taking log10 of basis sets so that negative coefficients
% represent various amplitudes of the basis set 

olc(rng==0) = []; rng(rng==0)= [];

tmp_fig = figure; plot(rng, olc, 'o'); logx;logy
rng_in = rng; olc_in = olc;
menu('Zoom to define lower range cut as first visible point','OK, done');
v = axis; x_bot = v(1);y_bot = v(3);
menu('Zoom to define upper range cut as last visible point','OK, done');
v = axis; x_top = v(2); y_top = v(4);
bnd = rng>=x_bot & rng<=x_top & olc>=y_bot & olc<=y_top
olc = olc(bnd);
rng = rng(bnd);
if ~isavar('pin_R')
    pin_R = max(rng);
end
close(tmp_fig);
R = 10:10:10000; 
% Choice of log is driven by fact that overlap looks almostly straight on a log-logscale
logR = [log10(min(rng)):log10(rng(7)./rng(6)):log10(max(rng))]; r_log = 10.^logR;
for ii = length(r_log):-1:2
    ii_ = rng>=r_log(ii-1)&rng<r_log(ii);
    Ns(ii-1) = sum(ii_);
    rng_logmn(ii-1) = 10.^mean(log10(rng(ii_)));
    olc_logmn(ii-1) = 10.^mean(log10(olc(ii_)));
end
NaNs = isnan(olc_logmn)|isnan(rng_logmn);
olc_logmn(NaNs) = []; rng_logmn(NaNs) = [];
% figure; plot(rng, olc, 'o',rng_logmn, olc_logmn,'-'); logx;logy
olc_logmn = 10.^interp1(real(log10(rng_logmn)), real(log10(olc_logmn)),...
    real(log10([min(rng), rng_logmn, max(rng)])),'pchip','extrap'); 
rng_logmn = [min(rng), rng_logmn, max(rng)];
[rng_logmn,xx]=unique(double(floor(rng_logmn*1e5)./1e5)); olc_logmn = olc_logmn(xx);
% plot(rng, olc, 'o',rng_logmn, olc_logmn,'-'); logx;logy
R = rng_logmn.*1000; 
T = .200; % diameter of telescope primary
s = .001; % telescope aperture (sometimes same as primary diameter)
f = 1.000; % telescope focal length
phi = 1.5e-3; % telescope FOV = s/f in radians
g0 = 0.20; % laser initial diameter
d0 = 0; % offset between telecope axis and laser initiation
Theta = phi./2; % Difference between laser beam P vector and telescope axis.  
% Ideally Theta is zero, but realistically it may be non-zero
b = f.*R/ (R-f); % distance from center of primary to image
del = phi.*10.^linspace(-.9,-.05,12); % laser beam divergence as log-spaced factor of phi
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
ray = std_ray_atten(rng); ray = ray;
X_ray = 10.^interp1(log10(R), log10(Xi'), log10(rng*1000),'linear','extrap');
figure; Rs = plot(rng, (ray*ones([1,length(del)])).* (X_ray.^2),'-',rng(1:10:end),ray(1:10:end).*olc(1:10:end),'-o'); logy;recolor(Rs,[1:length(Rs)]);

Rs = plot(R./1000,Xi.^2,'-',rng, olc,'c-'); xlabel('km'); logx; logy;recolor(Rs,[1:length(Rs)])
hold('on'); plot(R./1000,olc_logmn,'m*')
% Construct basis set from Xi and stronger powers of Xi
V = [Xi', Xi'.^1.15, Xi'.^1.1, Xi'.^1.15, Xi'.^1.25, Xi'.^1.5, Xi'.^1.5, Xi'.^2, Xi'.^2.5]';
K =[];
while isempty(K) || any(K==0)
   V(K==0,:) = [];
   K =olc_logmn/V; % K[1xR] = [1xC] / [RxC], when dividing matrices, flip denom dims, cancel like inner
end
fitted_ol = (K * V)';    % [1xC] = [1xR]*[RxC], when multiplying matrices, cancel like inner dims
ol_gt_1 = fitted_ol>1;
if sum(ol_gt_1)>1
   [PP,~,MM]= polyfit(log10(R(ol_gt_1)'),fitted_ol(ol_gt_1),1);
   top = polyval(PP,log10(pin_R*1000),[],MM);
   [R,xx] = unique([R,pin_R.*1000]); 
   fitted_ol = [fitted_ol' top]; fitted_ol = fitted_ol(xx);
end
fitted_ol = fitted_ol./max(fitted_ol);
% fitted_olc = 10.^interp1(log10(R),log10(fitted_ol),log10(pin_R*1000),'linear','extrap');
% fitted_ol(end) = 1; fitted_ol = [fitted_ol; 1]; R = [R,1000.*max(rng)]';
% [R, xx] = unique(R); fitted_ol = fitted_ol(xx);
fitted_olc = 10.^interp1(log10(R),log10(fitted_ol),log10(rng_in*1000),'linear');
high = rng_in>=max(R./1000);
fitted_olc(high) = interp1(log10(R),(fitted_ol),(rng_in(high)*1000),'nearest','extrap');
figure; plot(rng_in, olc_in,'.c-', R./1000, fitted_ol,'rx-',rng_in, fitted_olc,'k-'); logx; logy; 
legend('in','fitted');

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