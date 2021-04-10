% Check mplpolfs.b1 and 1smplcmask1zwang.c1 for consistency

c1 = anc_load;

bscat = c1.vdata.backscatter; 
bscat(bscat==-9999) = NaN;
figure; imagesc(c1.time, c1.vdata.height, real(log10(bscat))); axis('xy'); dynamicDateTicks
xl_ = serial2Hh(c1.time)>6 & serial2Hh(c1.time)<9;
r2 = c1.vdata.height.^2;
figure; plot( mean(bscat(:,xl_),2).*r2,c1.vdata.height, 'r-'); logx
figure;  imagesc(c1.time(xl_), c1.vdata.height, real(log10(bscat(:,xl_)))); axis('xy')
b1 = anc_load; 
xlb_ = serial2Hh(b1.time)>6 & serial2Hh(b1.time)<9;
cop = b1.vdata.signal_return_co_pol - ones(size(b1.vdata.range))*b1.vdata.background_signal_co_pol;
crs = b1.vdata.signal_return_cross_pol - ones(size(b1.vdata.range))*b1.vdata.background_signal_cross_pol;
cop = mean(cop(:,xlb_),2); crs = mean(crs(:,xlb_),2); bscat_b1 = cop + 2.*crs;
bscat_b1 = bscat_b1 ./ mean(b1.vdata.energy_monitor(xlb_));
r2_b1 = b1.vdata.range.^2; r2_b1(b1.vdata.range<=0) = NaN;r2_b1(b1.vdata.range>30) = NaN;
figure; plot(bscat_b1 .* r2_b1, b1.vdata.range, '-'); logx

ray = sonde_ray_atten(anc_load(getfullname('*sonde*.cdf','sonde','Select sonde file')),c1.vdata.height);
figure; plot(10.*ray, c1.vdata.height, 'g*'); logx; legend('Rayleigh')
figure; plot(9.5e-4.*ray, c1.vdata.height, 'g*'); logx; legend('Rayleigh')


hsrl = anc_load(getfullname('*.nc','hsrl'));
figure; plot(hsrl.vdata.atten_beta_r_backscat,hsrl.vdata.altitude./1000,'-');  logx; ylim([2,8])