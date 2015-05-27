function dif_corrs = hemisp_correction_sashe(coscorr);
%hemisp_corr = hemisp_correction(angle_corrs);
% Calculates the effect on the diffuse hemispheric due to
% non-lambertian sensor response
% To compute the correction required, invert this number

%% Computing difcor for SASHe
% Want to match previous method for MFRSR provided by Kiedron, incorporated
% in the function hemisp_correction.  This uses the cos_corr structure
% initially populated during read_solarfile.  These represent the factor
% (I_meas/I_ideal) as a function of "bench angle" and also "zenith angle".
% It would be nice to have one of these in hand to make sure we're really
% doing an apples for apples process with the SAS-He.

% coscorr has two columns, cos(zenith angle), and the corresponding
% correction value by which the raw direct irradiances are multiplied to
% correct for the diffuser response.

%Also  note that this function has an internal function "cos_correction" defined below
coscorr = load(['D:\case_studies\SAS\systems\SASHe2_AMF1\coscor_500_PVC_final.txt']);% From Jim Barnard, Dec 12, 2012
coscorr = load(['D:\case_studies\SAS\systems\SASHe2_AMF1\pvcsasheM1.coscor']); % From Brian Ermold, Dec 10, 2012 (use Jim's)
coscorr = load(['D:\case_studies\SAS\systems\SASHe2_AMF1\sgpsasheC1.coscor']); % From Brian Ermold, Dec 10, 2012
coscorr(:,3) = acosd(coscorr(:,1));

k=pi/180; %convert from degrees to radians

da=2; %//step in azimuth angle 
dz = 2;%//step in zenith angle
hemisp_corr = zeros(1,10);

for zen = 0:dz:89 %start in azimuth angle
    % this assumes azimuthal symmetry
    % note the inversion of "cos_correction" to yield the effect.
        coscor = 1 ./ cos_correction(coscorr,zen); % //value of cosine correction from SolarInfo for zenith and azimuth za and az angles and for filter p
   for az = 0:da:359 %start in zenith angle
  
      r=1 ;%//isotropic
      hemisp_corr(10)=hemisp_corr(10)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(1)=hemisp_corr(1)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor
      r=1+2*cos(k*zen) ;%//Moon-Spencer
      hemisp_corr(2)=hemisp_corr(2)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(3)=hemisp_corr(3)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor

      sza=0 ;%//Rayleigh
      r=sin(k*sza)*sin(k*zen)*cos(k*az)+cos(k*zen)*cos(k*zen);
      r=1+r^2;
      hemisp_corr(4)=hemisp_corr(4)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(5)=hemisp_corr(5)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor

      sza=45 ;%//Rayleigh
      r=sin(k*sza)*sin(k*zen)*cos(k*az)+cos(k*zen)*cos(k*zen);
      r=1+r^2;
      hemisp_corr(6)=hemisp_corr(6)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(7)=hemisp_corr(7)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor

      sza=90 ;%//Rayleigh
      r=sin(k*sza)*sin(k*zen)*cos(k*az)+cos(k*zen)*cos(k*zen);
      r=1+r^2;
      hemisp_corr(8)=hemisp_corr(8)+sin(k*zen)*cos(k*zen)*r*da*dz*k*k ;%//the case of ideal Lambertian sensor
      hemisp_corr(9)=hemisp_corr(9)+sin(k*zen)*cos(k*zen) *r*coscor*da*dz*k*k ;%//the case of real (SolarInfo) sensor
   end %azimuth
end % zen

%//diffuse cosine corrections



hemisp_corr(1)=hemisp_corr(1)/hemisp_corr(10) ;%//isotropic
hemisp_corr(3)=hemisp_corr(3)/hemisp_corr(2) ;%//Moon-Spencer
hemisp_corr(5)=hemisp_corr(5)/hemisp_corr(4) ;%//Rayleigh sza=0
hemisp_corr(7)=hemisp_corr(7)/hemisp_corr(6) ;%//Rayleigh sza=45
hemisp_corr(9)=hemisp_corr(9)/hemisp_corr(8) ;%//Rayleigh sza=90

dif_corrs.diffuse.isotropic = hemisp_corr(1);
dif_corrs.diffuse.moonspencer = hemisp_corr(3);
dif_corrs.diffuse.Rayleigh0 = hemisp_corr(5);
dif_corrs.diffuse.Rayleigh45 = hemisp_corr(7);
dif_corrs.diffuse.Rayleigh90 = hemisp_corr(9);
dif_corrs.diffuse.mean45zen = 1./mean(cos_correction(coscorr, [45,45,45,45] ));


dif_corrs.mean_all = mean([dif_corrs.isotropic,dif_corrs.moonspencer,dif_corrs.Rayleigh0,dif_corrs.Rayleigh45,dif_corrs.Rayleigh90,dif_corrs.mean45zen]);

return

function cos_cor = cos_correction(coscorr,zen)
cos_cor = interp1(coscorr(:,3), coscorr(:,2), zen);
return
