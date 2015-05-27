% With band axis aligned to SAZ, band motion is restricted in scattering
% angle according to SZA as below.  
%%
sza = (90-10).*pi./180;
saz = 0.*pi./180; % The choice of SAZ is arbitrary since we align our band relative to it.
sun_xyz = [sin(sza).*sin(saz), sin(sza).*cos(saz), cos(sza)];
band = [-90:90];% This defines the solid arc of the band in zenith angle
band_angle = ([-90:1:90].*pi./180)';% This defines the orientation of the band versus vertical.
%
band_xyz = 
sky_xyz = [sun_xyz(1)+cos(saz).*cos(sza).*sin(band_angle), sun_xyz(2)+sin(saz).*cos(sza).*sin(band_angle), ...
   cos(sza).*cos(band_angle)];
%
%%
d_xyz = ones([length(ba),1])*sun_xyz - sky_xyz;
figure(1); plot([-90:1:90], d_xyz, 'o'); 
legend('x','y','z')
set(gcf,'position',[22   396   560   420]);
%
dot_xyz = sum((ones([length(ba),1])*sun_xyz) .* sky_xyz,2);
%
scats = acos(dot_xyz);
%
%%
figure(2); plot([-90:1:90]',scats.*180./pi,'o');
title(['nearest band scattering angle for sza = ',num2str(sza.*180./pi)]);
ylabel('scattering angle [deg]');
xlabel('band angle [deg]');
set(gcf,'position',[858   386   560   420]);
%%