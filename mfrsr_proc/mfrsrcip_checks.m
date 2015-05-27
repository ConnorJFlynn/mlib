function mfrsrcip_checks
%%
%dV(r)/dln(r)= (C/sqrt(2pi)*sigma)*exp[-(ln(r) – ln(R))^2 / (2*sigma^2) 
cip = ancload(getfullname_('*.cdf','cip'));
n = 0;
%%
good = cip.vars.aerosol_optical_depth_filter2_observed.data>0;
Co = cip.vars.aerosol_particle_volume_concentration_fine.data(good);
Ro = cip.vars.volume_median_radius_fine.data(good);
sigma_o  = .5;
C1 = cip.vars.aerosol_particle_volume_concentration_coarse.data(good);
R1 = cip.vars.volume_median_radius_coarse.data(good);
sigma_1  = .7;
%%
n = n+1;

%
r = (10:10:10000)'./1000;

dVdlnr_o = (Co(n)./(sqrt(2*pi).*sigma_o)).*exp( -((log(r)-log(Ro(n))).^2)./(2*sigma_o.^2));
dVdlnr_1 = (C1(n)./(sqrt(2*pi).*sigma_1)).*exp( -((log(r)-log(R1(n))).^2)./(2*sigma_1.^2));

figure(5); loglog( r,dVdlnr_o+dVdlnr_1,'r-' );
xlim([.1,10]);
%%
disp(['Still some work to do with matching up the CIP and MIE'])
tic
 retval = SizeDist_Optics(1.5024+0.0031i, 1000.*r(1:10:end), dVdlnr_o(1:10:end)+dVdlnr_1(1:10:end), 500, 'density',1.3)
toc
 %%

 
 return