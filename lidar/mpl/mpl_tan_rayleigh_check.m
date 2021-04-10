function mpl_tan_rayleigh_check

Jan 12,13 (vertical) 19,20,22 scanning

Jan12 = load(['E:\mmpl\tan\raw_data\daily\20180112.mat']);
cop = Jan12.vdata.channel_2; 
rng_1000 = MPL_cal.ap(:,1);
cop_ap = interp1(MPL_cal.cjf.rng, MPL_cal.cjf.ap_cop, rng_1000,'linear','extrap');
cop = cop - cop_ap*(double(Jan12.vdata.energy_monitor)./1000);
% cop = cop - MPL_cal.ap_smooth(:,2)*(double(Jan12.vdata.energy_monitor)./1000);
r.bg_ = rng_1000>=27; 
cop_bg = mean(cop(r.bg_,:));
cop = cop - ones(size(rng_1000))*cop_bg;
cop_r2 = cop .* ((rng_1000.^2)*ones(size(Jan12.time)));

figure_(99); imagegap(serial2Hh(Jan12.time), rng_1000, real(log10(cop_r2))); colorbar
caxis(-1.5; 1.5);
menu('Zoom into clear sky period to test for Rayleigh.','Done');
tl = xlim; tl_ = serial2Hh(Jan12.time)>tl(1) & serial2Hh(Jan12.time)<tl(2);
figure; plot(mean(cop_r2(:,tl_),2),rng_1000,'k-'); logx;
[ray] = std_ray_atten(rng_1000*1000,532);
hold('on'); plot(600.*ray, rng_1000,'r-'); logx;

% Collimation looks OK up to 12 km. Deviation above is possibly due to actual atmos
% as Rayleigh was based on mid-lat summer, not on southern polar.
% Also reviewed behavior if vendor-provided afterpulse is used.
% Super-Rayleigh over entire profile reflecting inadequate correction.

return