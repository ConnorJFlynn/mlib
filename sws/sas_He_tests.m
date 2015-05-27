%% Dec 23, 2009
% band geometry to block sun from SAS-Ze
% Assume initial clear aperture of 12.5 mm diam
% Thorlabs collimator has effective FL of 33 mm.  
% Fiber core diameter is 0.6 mm = 600 micron.
% Fiber projected FOV tan_theta = .3 ./ 33
tan_theta = .3 ./ 33;  % so divergent ray expand less than 1 mm per 100 mm of travel
theta = atan(.3 ./ 33).*(180./pi) % = 0.5209 deg
% I think this all means that we can get by with a 15 mm diam window
d = 15;
d = d + 2.5; % bit more than a mm cushion on each side
tan_alpha = tan(1*pi/180);
R = 25.4.* 8;
D = 2.*R .* tan_alpha + d;
D = 25.4;
% Let d = 1" = 25.4
% So I think this system will block the sun without entering the FOV until
% the sun is within beta of zenith or about 6 degrees of zenith.
beta = (180./pi).*atan((D+d)./(2.*R));




%%

L = 8.*25.4; % Length of baffle
D = 2 .* 25.4; % 2" Thorlabs
R = D./2; 
r1 = 10/2; % Designed clear aperture

alpha = .5; alpha = alpha.*pi/180; 
tana = tan(alpha);
r2 = r1 + L.*tana;

N = 4;
aa = (N-3).*tana;
bb = N.*(2.*r1 + L.*tana) -4.*r1 + L.*tana + 2.*R; 
cc = -2.*L.*(R-r1);
W = (-bb + sqrt(bb.^2-4.*aa.*cc))./(2.*aa);
% This W implies 
a = R - r1 -W.* tana; % and
b = r2 + R  -a; % and
X = L - W; % and
tan_theta = b./X;
theta_deg = atan(tan_theta).*180./pi;
%
% To prevent crossing ray from striking internal surface baffle location W
% must be less than W_ below:
W_ = (L.*tan_theta - r1 - r2)./(tana + tan_theta)

%% Computing completely blocked and partially blocked angles for different
%% diffuser and shadowband geometries.
d = 4;
D = 7;
R = 25.4*6.5;
alpha = atan((D-d)./(2.*R));
beta = atan((D+d)./(2.*R));
mm = (D - d - 2.*R.*tan(0.25*pi/180))./2;
deg = atan(mm./R).*180./pi;
[alpha, beta].*180/pi
[mm, deg]

%%
% Examining effect of increased tolerance in terms of blocked angle or
% linear dimension of band shadow at distance to diffuser.
% Sun is ~1/2 degree in apparent size, so divergent half-angle is 1/4 deg.
% MFR diffuser is 8 mm diam.
% We want to shade the entire diffuser with a band whose angular position
% is know to +/- 0.1 degree.

%Start by requiring a larger divergent angle of 1/2 degree.  
d = 8;
tan_alpha = tan(0.5*pi/180);
R = 25.4.* 8;
D = 2.*R .* tan_alpha + d;
% D = 11.5466 mm to cover 
% so if we let D = 12.5 mm we have a .5 mm cushion on each edge
% And this yields an as-built alpha = atan(D-d)./2R
alpha = (180./pi).*atan((12.5-8)./(2.*R))
% as built alpha = .6344
beta = (180./pi).*atan((12.5+8)./(2.*R))
% as built beta = 2.8877

% Now try the actual 1/4 degree divergent angle but incorporate a cushion
% around the diffuser 
d = 9 ; %0.5 mm cushion at each edge, equivalent to above
tan_alpha = tan(0.35*pi/180); % divergent angle of sun plus angular tolerance
R = 25.4.* 8;
D = 2.*R .* tan_alpha + d;
% D = 11.4826
% We've already built in a 0.5 mm cushion and the angular tolerance.  
% Let D = 12 mm for convenient units
D = 11.5;
%% This is the one I like for the MFR diffuser, 
d = 8;
alpha = (180./pi).*atan((D-d)./(2.*R));
% As built alpha = 0.4934
beta = (180./pi).*atan((D+d)./(2.*R));
% As built beta = 2.7471
%%
d = 10 ; %1 mm cushion at each edge, equivalent to above
tan_alpha = tan(0.35*pi/180); % divergent angle of sun plus angular tolerance
R = 25.4.* 8;
D = 2.*R .* tan_alpha + d;
%
% D = 12.4826
% We've already built in a 1 mm cushion and the angular tolerance.  
D = 12.5;
d = 8;
alpha = (180./pi).*atan((D-d)./(2.*R));
% As built alpha = 0.6344
beta = (180./pi).*atan((D+d)./(2.*R));
% As built beta = 2.8877
%%
% Now what if we can machine a 2 or 3 mm diam diffuser?
d = 3; % now accommodate 0.5 mm cushion on each side
d = d + 1;
tan_alpha = tan(0.4*pi/180); % divergent angle of sun plus angular tolerance + .05 for good measure
R = 8 .* 25.4;
D = 2.*R .* tan_alpha + d;
%%
% let D = 6.8373; d = 2;
D = 7; d = 2;
alpha = (180./pi).*atan((D-d)./(2.*R));
% As built alpha = 0.7049
beta = (180./pi).*atan((D+d)./(2.*R));
% As built beta = 1.2686

%%
% Now try for 2" mini-baffle
% I need to re-derive this without vanes.  This will yield one less bounce
% but a moderately deeper baffle (by the vane width)
% And ODD bounces return to sky rather than even.
L = 2.*25.4; % Length of baffle
D = 2.3; % 2" Thorlabs
R = D./2; 
r1 = 1.1; % Designed clear aperture

alpha = 1; alpha = alpha.*pi/180; 
tana = tan(alpha);
r2 = r1 + L.*tana;

N = 4;
aa = (N-3).*tana;
bb = N.*(2.*r1 + L.*tana) -4.*r1 + L.*tana + 2.*R; 
cc = -2.*L.*(R-r1);
W = (-bb + sqrt(bb.^2-4.*aa.*cc))./(2.*aa);
% This W implies 
a = R - r1 -W.* tana; % and
b = r2 + R  -a; % and
X = L - W; % and
tan_theta = b./X;
theta_deg = atan(tan_theta).*180./pi;
%
% To prevent crossing ray from striking internal surface baffle location W
% must be less than W_ below:
W_ = (L.*tan_theta - r1 - r2)./(tana + tan_theta)
