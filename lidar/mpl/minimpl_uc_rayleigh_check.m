function minimpl_uc_rayleigh_check

% Candidate dates, 8/01, 8/04, 8/05?, 8/07, 8/12, 8/14, 8/18
mmpl_fname = getfullname('*.mat','mmpl_ray','Select file to test collimation');
% mmpl = load(['E:\mmpl\ER2019\minimpl\nc_mpl2nc\daily\20190801.mat']);
mmpl = load(mmpl_fname);
cop = mmpl.vdata.channel_2; 
crs = mmpl.vdata.channel_1;
ap_hex = anc_load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.nc']);
ap_lid = load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.lid_on.mat']);
ap_cld = load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.cloudblocked.mat']);
% figure; plot(ap_lid.vdata.ap_range, [ap_lid.vdata.ap_copol,ap_lid.vdata.ap_crosspol],'-',...
%     ap_lid.vdata.ap_range, [ap_cld.vdata.ap_copol,ap_cld.vdata.ap_crosspol],'-',...
%     ap_hex.vdata.ap_range, [ap_hex.vdata.ap_copol, ap_hex.vdata.ap_crosspol],'-'); logy; logx
rng = ap_lid.vdata.ap_range;
% cop_sans_hex = cop - ap_hex.vdata.ap_copol*(double(mmpl.vdata.energy_monitor)./1000);
cop_sans_lid = cop - ap_lid.vdata.ap_copol*(double(mmpl.vdata.energy_monitor)./1000);
crs_sans_lid = crs - ap_lid.vdata.ap_crosspol*(double(mmpl.vdata.energy_monitor)./1000);
% cop_sans_cld = cop - ap_cld.vdata.ap_copol*(double(mmpl.vdata.energy_monitor)./1000);
r.bg_ = rng>=27;
% cop_sans_hex_bg = cop_sans_hex - ones(size(rng))*mean(cop_sans_hex(r.bg_,:));
cop_sans_lid_bg = cop_sans_lid - ones(size(rng))*mean(cop_sans_lid(r.bg_,:));
crs_sans_lid_bg = crs_sans_lid - ones(size(rng))*mean(crs_sans_lid(r.bg_,:));
% cop_sans_cld_bg = cop_sans_cld - ones(size(rng))*mean(cop_sans_cld(r.bg_,:));

% Need to add a little bit back in to account for portion of signal at 30
% km inadvertantly subtracted with background
% cop_hex_r2 = (cop_sans_hex_bg+2.8e-5) .* ((rng.^2)*ones(size(mmpl.time)));
cop_lid_r2 = (cop_sans_lid_bg+2.8e-5) .* ((rng.^2)*ones(size(mmpl.time)));
crs_lid_r2 = (crs_sans_lid_bg+2.8e-5) .* ((rng.^2)*ones(size(mmpl.time)));
% cop_cld_r2 = (cop_sans_cld_bg+2.8e-5) .* ((rng.^2)*ones(size(mmpl.time)));

figure_(99); ss(1) = subplot(2,1,1); 
imagegap(serial2Hh(mmpl.time), rng, real(log10(cop_lid_r2))); colorbar
title(['miniMPL copol: ',datestr(mmpl.time(1), 'yyyy-mm-dd')])
caxis([-1.5, 1]);
ss(2) = subplot(2,1,2);
imagegap(serial2Hh(mmpl.time), rng, real(log10(crs_lid_r2))); colorbar
title('miniMPL crosspol')
caxis([-3, 0]);
linkaxes(ss,'xy'); zoom('on')
menu('Zoom into clear sky period to test for Rayleigh.','Done');
tl = xlim; tl_ = serial2Hh(mmpl.time)>tl(1) & serial2Hh(mmpl.time)<tl(2);
figure; plot(mean(cop_lid_r2(:,tl_),2),rng,'-'); logx;xlabel('nrb'); ylabel('range [km]');
legend('lid')
% figure; plot(mean(cop_hex_r2(:,tl_),2),rng,'-',mean(cop_lid_r2(:,tl_),2),rng,'-',...
%     mean(cop_cld_r2(:,tl_),2),rng,'-'); logx;xlabel('nrb'); ylabel('range [km]');
% legend('hex','lid','cld')
[ray] = std_ray_atten(rng*1000,532);
% hold('on'); 
hold('on'); plot(858.*ray, rng,'m-'); logx;
ap_lid.vdata.ol_overlap(1) = 0;
ol = interp1(ap_lid.vdata.ol_range, ap_lid.vdata.ol_overlap,rng,'linear','extrap');

 ol_fit = analytic_ol_uc(ap_lid.vdata.ol_range(ap_lid.vdata.ol_range<=4),ap_lid.vdata.ol_overlap(ap_lid.vdata.ol_range<=4),6);
ol_fit_interp = interp1(ap_lid.vdata.ol_range(ap_lid.vdata.ol_range>0&ap_lid.vdata.ol_range<=4),ol_fit,rng,'linear','extrap');
ol_fit_interp(ol_fit_interp<=0) = NaN;
plot(mean(cop_lid_r2(:,tl_),2)./ol_fit_interp,rng,'r-'); logx;xlabel('nrb'); ylabel('range [km]');
legend('lid','mol','OL')
% Collimation looks OK up to 12 km. Deviation above is possibly due to actual atmos
% as Rayleigh was based on mid-lat summer, not on southern polar.
% Also reviewed behavior if vendor-provided afterpulse is used.
% Sub Rayleigh indicating too strong of an AP subtraction

figure; plot(mean(cop_lid_r2(:,tl_),2),rng,'-',mean(cop_lid_r2(:,tl_),2)./ol_fit_interp,rng,'r-'); logx;xlabel('nrb'); ylabel('range [km]');
legend('lid')
[ray] = std_ray_atten(rng*1000,532);
% hold('on'); 
hold('on'); plot(850.*ray, rng,'m-'); logx;
legend('wi/o OLC','wi OlC','mol')

cop_wio_olc_lte10 = mean(cop_lid_r2(rng>0.03&rng<=10,tl_),2); rng_sub = rng(rng>.03&rng<=10);
mol_sub = ray(rng>0.03&rng<=10);
vs_ray = analytic_ol_uc(rng_sub, cop_wio_olc_lte10./(850.*mol_sub));


figure; plot(cop_wio_olc_lte10,rng_sub,'-',cop_wio_olc_lte10./(vs_ray.^1.05),rng_sub,'r-'); logx;xlabel('nrb'); ylabel('range [km]');
legend('lid')
[ray_sub] = std_ray_atten(rng_sub*1000,532);
% hold('on'); 
hold('on'); plot(850.*ray_sub, rng_sub,'m-'); logx;
legend('wi/o OLC','wi OlC','mol')

alcf = anc_load(['E:\mmpl\ER2019\minimpl\alcf\lidar\2019-08-14T00_00_00.nc']);


return