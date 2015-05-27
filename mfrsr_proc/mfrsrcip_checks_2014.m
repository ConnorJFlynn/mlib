function mfrsrcip_checks
%%
%dV(r)/dln(r)= (C/sqrt(2pi)*sigma)*exp[-(ln(r) – ln(R))^2 / (2*sigma^2) 
cip = anc_load(getfullname_('*.cdf','cip'));
n = 0;
%%
good = cip.vdata.aerosol_optical_depth_filter2_observed>0;
Co = cip.vdata.aerosol_particle_volume_concentration_fine(good);
Ro = cip.vdata.volume_median_radius_fine(good);
sigma_o  = .5;
C1 = cip.vdata.aerosol_particle_volume_concentration_coarse(good);
R1 = cip.vdata.volume_median_radius_coarse(good);
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
 tmp = cip.vdata.direct_to_diffuse_ratio_filter1_observed;
 str = 'direct_to_diffuse_ratio_filter2';
 obs =  cip.vdata.([str,'_observed']); bad = obs<-100; obs(bad) = NaN;
modl =cip.vdata.([str,'_modeled']); bad = modl<-100; modl(bad) = NaN;
err =  cip.vdata.([str,'_modeled_error']);
myerr = -(obs - modl)./modl; 
% myerr = (obs - mod); bad = (obs < -100)|(mod<-100); myerr(bad) = NaN;
figure; plot(serial2doys(cip.time), [obs;modl;err], 'o',serial2doys(cip.time), myerr,'b.'); legend('obs','modeled','err','myerr');
title(str,'interp','none'); 
axis(v)
 
 return