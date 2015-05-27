function diffuse = difcor(angle_corrs);
%diffuse = difcor(angle_corrs);
% Calculates the correction required of the diffuse hemispheric due to
% non-lambertian sensor response
% Assumes that the supplied angle corrections are correct for the
% deployment hemisphere.  That is, if southern hemisphere swap E for W
% and N for S.

k=pi/180; %convert from degrees to radians

da=2; %//step in azimuth angle 
dz = 2;%//step in zenith angle
hemisp_corr = zeros(1,10);
% 1 is for diffuse cosine correction under isotropic radiation
% 10 is ideal for isotropic radiation so 1/10 would be the correction?

% 3 is for diffuse cosine correction for Moon-Spencer
% 2 is ideal for Moon-Spencer so 3/2 would be the correction?

% 5 is diffuse correction for Rayleigh sza=0 
% 4 is ideal for Rayleight sza=0 so correction is 5/4

% 6 is ideal for Rayleight sza=45
% 7 is diffuse correction for Rayleigh sza=45 so correction is 7/6

% 8 is ideal for Rayleigh sza=90 (sun rise/set) so correction is 9/8
% 9 is diffuse correction Rayleigh sza=90
for zen = 0:dz:89 %start in azimuth angle
   for az = 0:da:359 %start in zenith angle
      coscor = 1 ./ cos_correction(angle_corrs,az,zen); % //value of cosine correction from SolarInfo for zenith and azimuth za and az angles and for filter p
      r=1 ;%//isotropic
      hemisp_corr(10)=hemisp_corr(10)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(1)=hemisp_corr(1)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor
      r=1+2*cos(k*zen) ;%//Moon-Spencer
      hemisp_corr(2)=hemisp_corr(2)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(3)=hemisp_corr(3)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor

      sza=0 ;%//Rayleigh
      r=sin(k*sza)*sin(k*zen)*cos(k*az)+cos(k*sza)*cos(k*zen);
      r=1+r^2;
      hemisp_corr(4)=hemisp_corr(4)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(5)=hemisp_corr(5)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor

      sza=45 ;%//Rayleigh
      r=sin(k*sza)*sin(k*zen)*cos(k*az)+cos(k*sza)*cos(k*zen);
      r=1+r^2;
      hemisp_corr(6)=hemisp_corr(6)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(7)=hemisp_corr(7)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor

      sza=90 ;%//Rayleigh
      r=sin(k*sza)*sin(k*zen)*cos(k*az)+cos(k*sza)*cos(k*zen);
      r=1+r^2;
      hemisp_corr(8)=hemisp_corr(8)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(9)=hemisp_corr(9)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor
   end %azimuth
end % zen

%//diffuse cosine corrections

angle_corrs.diffuse.mean45zen = 1./mean(cos_correction(angle_corrs,[0,90,180,270], [45,45,45,45] ));

hemisp_corr(1)=hemisp_corr(1)/hemisp_corr(10) ;%//isotropic
hemisp_corr(3)=hemisp_corr(3)/hemisp_corr(2) ;%//Moon-Spencer
hemisp_corr(5)=hemisp_corr(5)/hemisp_corr(4) ;%//Rayleigh sza=0
hemisp_corr(7)=hemisp_corr(7)/hemisp_corr(6) ;%//Rayleigh sza=45
hemisp_corr(9)=hemisp_corr(9)/hemisp_corr(8) ;%//Rayleigh sza=90

diffuse.isotropic = hemisp_corr(1);
diffuse.moonspencer = hemisp_corr(3);
diffuse.Rayleigh0 = hemisp_corr(5);
diffuse.Rayleigh45 = hemisp_corr(7);
diffuse.Rayleigh90 = hemisp_corr(9);
diffuse.mean45zen = angle_corrs.diffuse.mean45zen;
diffuse.mean_all = mean([diffuse.isotropic,diffuse.moonspencer,diffuse.Rayleigh0,diffuse.Rayleigh45,diffuse.Rayleigh90,diffuse.mean45zen]);

