% % Taihu afterpulse dates:
% % from Jianjun:
% % 2008 09-12, 09-16
% 
% 3/29, attenuated but a bit high
% 4/05, a bit better, lower
% 4/006, even better
% 4/17, good and low
% 5/17, good and low
% 5/19
% 5/22
% 6/08
% 6/14, 6/15
% 6/28, 6/30
% 7/13,
% 8/3
% 8/6, 8/08
% 09 / 12, 16, 17, 18, 19, Jianjun: 
% 10/08
% 
% clear sky upper atm dates for collimation check
% 4/02

% Taihu RAR files cover:
% 2008 March to 2009 March
%%
clear;
%%
close('all');
%%
%([mpl_inarg.in_dir,in_files(ind(m)).name]);
% mplpol = rd_Sigma(['E:\case_studies\hfe\China_Taihu\mpl\raw\20080912_ap\20080912.pm.mpl']);
ap_stem = '20080417';
ap_stem = '20080406';
% ap_stem = '20080912';
in_str= ['E:\case_studies\hfe\China_Taihu\mpl\raw\',ap_stem,'_ap\',ap_stem,'.pm.mpl'];
%%
mplpol = rd_Sigma(in_str);
disp(ap_stem)
%%
polV = mean(mplpol.hk.pol_V1);
cop = (mplpol.hk.pol_V1<polV);
%%
figure; ax(1) = subplot(2,1,1); 
imagesc(serial2doy(mplpol.time(cop)), mplpol.range(mplpol.r.lte_20),real(log10(mplpol.rawcts(mplpol.r.lte_20,cop) ...
   -ones(size(mplpol.range(mplpol.r.lte_20)))*mplpol.hk.bg(cop)))); 
title(['log_1_0(lidar profiles) with background subtracted: ',datestr(mplpol.time(1),'yyyy-mm-dd')]);
ylabel('range [km]');
axis('xy'); colorbar;
caxis([-3.5,1.5]);
ax(2) = subplot(2,1,2); 
imagesc(serial2doy(mplpol.time(~cop)), mplpol.range(mplpol.r.lte_20),real(log10(mplpol.rawcts(mplpol.r.lte_20,~cop) ...
   -ones(size(mplpol.range(mplpol.r.lte_20)))*mplpol.hk.bg(~cop)))); 
axis('xy'); colorbar;
ylabel('range [km]');
xlabel('time [UTC]');
caxis([-3.5,1.5]);
linkaxes(ax,'xy');
zoom('on')
%%
figure; 
mid_range = mplpol.range>3 & mplpol.r.lte_10;
mean_midrange = mean(mplpol.rawcts(mid_range,:)-ones(size(mplpol.range(mid_range)))*mplpol.hk.bg,1);
ax_bg(1) = subplot(2,1,1); 
plot(serial2doy(mplpol.time), [mplpol.hk.bg;mean_midrange],'.')
xlabel('time [Hh]')
ylabel('background')
ax_bg(2) = subplot(2,1,2); 
semilogy(serial2doy(mplpol.time), [mplpol.hk.bg;mean_midrange],'.')
xlabel('time [Hh]')
ylabel('log_1_0(background)')

linkaxes([ax,ax_bg],'x')
%%
xl = xlim;
tz = (serial2doy(mplpol.time)>xl(1))&(serial2doy(mplpol.time)<xl(2))&(mplpol.hk.bg<6e-4);
tz(tz) = IQ(abs(mean_midrange(tz)),.01);
%%
figure; imagesc(serial2doy(mplpol.time(cop&tz)), mplpol.range(mplpol.r.lte_15), real(log10(mplpol.rawcts(mplpol.r.lte_15,cop&tz)-ones([sum(mplpol.r.lte_15),1])*mplpol.hk.bg(cop&tz)))); axis('xy'); colorbar
%%
bg_new = mean(mplpol.rawcts(mplpol.r.bg,:),1);
ap_all = mean(mplpol.rawcts(:,cop&tz),2);
ap_cop_sans_bg = mean(mplpol.rawcts(:,cop&tz)-ones(size(mplpol.range))*bg_new(cop&tz),2);
ap_crs_sans_bg = mean(mplpol.rawcts(:,~cop&tz)-ones(size(mplpol.range))*bg_new(~cop&tz),2);
ap_cop_bs = 10.^backsmooth(real(log10(ap_cop_sans_bg)),.02);
ap_crs_bs = 10.^backsmooth(real(log10(ap_crs_sans_bg)),.02);
ap_taihu_test.range = mplpol.range;
ap_taihu_test.cop = ap_cop_bs;
ap_taihu_test.crs = ap_crs_bs;
save(['E:\case_studies\hfe\China_Taihu\mpl\raw\',ap_stem,'_ap\ap_taihu_',ap_stem,'.mat'],'ap_taihu_test');
% save(['E:\case_studies\hfe\China_Taihu\mpl\raw\20080912_ap\ap_taihu_20080
% 414.mat'],'ap_taihu_20080417');
%%
ap_out = ap_taihu_(mplpol.range,mplpol.time(1));
figure; plot(real(log10(ap_cop_bs)),mplpol.range, 'r',real(log10(ap_crs_bs)),mplpol.range, 'b',...
   real(log10(ap_out.cop-mean(ap_out.cop(mplpol.r.bg)))),mplpol.range,'k');
legend('cop','crs','old');
xlabel('log_1_0(afterpulse profiles)');
ylabel('range [km]');
title('Comparing new and old afterpulse corrections')
%%

ap_0912 = loadinto(['E:\case_studies\hfe\China_Taihu\mpl\raw\20080912_ap\ap_taihu_20080912.mat']);
%%
figure; plot(real(log10(ap_cop_bs)),mplpol.range, 'r',...
   real(log10(ap_0912.cop)),ap_0912.range,'k');
legend('Apr 17','Sept 12');
xlabel('log_1_0(afterpulse profiles)');
ylabel('range [km]');
title('Comparing new and old afterpulse corrections')
%%
figure; semilogy(mplpol.range(mplpol.r.lte_20), mplpol.rawcts(mplpol.r.lte_20,1:4)-ones(size(mplpol.range(mplpol.r.lte_20)))*mplpol.hk.bg(1:4), 'r',...
   mplpol.range(mplpol.r.lte_20), ap_crs_sans_bg(mplpol.r.lte_20),'b',...
   mplpol.range(mplpol.r.lte_20), ap_cop_sans_bg(mplpol.r.lte_20),'k')
title(['Background-subtracted counts and afterpulse from ',ap_stem]);
xlabel('range [km]');
%%

figure; plot(real(log10(ap_cop_sans_bg)),mplpol.range, 'r',...
   ((ap_cop_bs)),mplpol.range,'k');
legend('cop','bs');
xlabel('log_1_0(afterpulse profiles)');
ylabel('range [km]');
title('Comparing new and backsmoothed afterpulse corrections')
%%
figure; ax2(1) = subplot(2,1,1); 
imagesc(serial2doy(mplpol.time(cop)), mplpol.range(mplpol.r.lte_20),real(log10(mplpol.rawcts(mplpol.r.lte_20,cop) ...
   -ap_cop_sans_bg(mplpol.r.lte_20)*ones(size(mplpol.hk.bg(cop))) -ones(size(mplpol.range(mplpol.r.lte_20)))*mplpol.hk.bg(cop)))); 
axis('xy'); colorbar;
caxis([-3.5,1.5]);
title(['log_1_0(lidar profiles) with bg and ap subtracted: ',datestr(mplpol.time(1),'yyyy-mm-dd')]);
ylabel('range [km]');
ax2(2) = subplot(2,1,2); 
imagesc(serial2doy(mplpol.time(~cop)), mplpol.range(mplpol.r.lte_20),real(log10(mplpol.rawcts(mplpol.r.lte_20,~cop) ...
  -ap_crs_sans_bg(mplpol.r.lte_20)*ones(size(mplpol.hk.bg(~cop))) -ones(size(mplpol.range(mplpol.r.lte_20)))*mplpol.hk.bg(~cop)))); 
axis('xy'); colorbar;
caxis([-3.5,1.5]);
ylabel('range [km]');
xlabel('time [UTC]');
linkaxes(ax2,'xy');
zoom('on');
% xlim(xl)
%%
clear;
close('all');
in_str= ['E:\case_studies\hfe\China_Taihu\mpl\raw\20080402_col\20080402.pm.mpl'];
in_str= ['E:\case_studies\hfe\China_Taihu\mpl\raw\20080708_col\20080708.pm.mpl'];
in_str= ['E:\case_studies\hfe\China_Taihu\mpl\raw\20080727_col\20080727.pm.mpl'];
in_str= ['E:\case_studies\hfe\China_Taihu\mpl\raw\20080927_col\20080927.pm.mpl'];
in_str= ['E:\case_studies\hfe\China_Taihu\mpl\raw\20081110_col\20081110.pm.mpl'];
mplpol = rd_Sigma(in_str);

polV = mean(mplpol.hk.pol_V1);
cop = (mplpol.hk.pol_V1<polV);
%%
figure; ax(1) = subplot(2,1,1); 
imagesc(serial2doy(mplpol.time(cop)), mplpol.range(mplpol.r.lte_20),real(log10(mplpol.rawcts(mplpol.r.lte_20,cop) ...
   -ones(size(mplpol.range(mplpol.r.lte_20)))*mplpol.hk.bg(cop)))); 
title(['log_1_0(lidar profiles) with background subtracted: ',datestr(mplpol.time(1),'yyyy-mm-dd')]);
ylabel('range [km]');
axis('xy'); colorbar;
caxis([-3.5,1.5]);
ax(2) = subplot(2,1,2); 
imagesc(serial2doy(mplpol.time(~cop)), mplpol.range(mplpol.r.lte_20),real(log10(mplpol.rawcts(mplpol.r.lte_20,~cop) ...
   -ones(size(mplpol.range(mplpol.r.lte_20)))*mplpol.hk.bg(~cop)))); 
axis('xy'); colorbar;
ylabel('range [km]');
xlabel('time [UTC]');
caxis([-3.5,1.5]);
linkaxes(ax,'xy');
zoom('on')
%
figure; 
mid_range = mplpol.range>3 & mplpol.r.lte_10;
mean_midrange = mean(mplpol.rawcts(mid_range,:)-ones(size(mplpol.range(mid_range)))*mplpol.hk.bg,1);
ax_bg(1) = subplot(2,1,1); 
plot(serial2doy(mplpol.time), [mplpol.hk.bg;mean_midrange],'.')
xlabel('time [Hh]')
ylabel('background')
ax_bg(2) = subplot(2,1,2); 
semilogy(serial2doy(mplpol.time), [mplpol.hk.bg;mean_midrange],'.')
xlabel('time [Hh]')
ylabel('log_1_0(background)')

linkaxes([ax,ax_bg],'x')
%%
xl = xlim;
tz = (serial2doy(mplpol.time)>xl(1))&(serial2doy(mplpol.time)<xl(2))&(mplpol.hk.bg<8e-4);
sum(tz)
tz(tz&cop) = IQ(abs(mean_midrange(tz&cop)),.05);
sum(tz)
figure; imagesc(serial2doy(mplpol.time(cop&tz)), mplpol.range(mplpol.r.lte_15), real(log10(mplpol.rawcts(mplpol.r.lte_15,cop&tz)-ones([sum(mplpol.r.lte_15),1])*mplpol.hk.bg(cop&tz)))); axis('xy'); colorbar
%%
ap = loadinto(['ap_taihu_20080406.mat']);
cop_raw = mplpol.rawcts(:,cop&tz);
% cop_sans_ap = cop_raw - 1*ap.cop*ones([1,size(cop_raw,2)]);
cop_sans_ap = cop_raw - 1*interp1(ap.range, ap.cop, mplpol.range,'nearest','extrap')*ones([1,size(cop_raw,2)]);
copol = cop_sans_ap - ones(size(mplpol.range))*mean(cop_sans_ap(mplpol.r.bg,:),1);
copol2 = copol .* ((mplpol.range.^2)*ones([1,size(copol,2)]));
%
std_attn = std_ray_atten(mplpol.range);
pin_range = mplpol.range>=15 & mplpol.range<=20;
pin_C = mean(std_attn(pin_range)./mean(copol2(pin_range,:),2));
figure; semilogy(mplpol.range, mean(copol,2).*(mplpol.range.^2).*pin_C,'b-', mplpol.range,std_attn,'r-')
legend('MPL','Rayleigh')
title(['Collimation check of Taihu MPL: ',datestr(mplpol.time(1),'yyyy-mmm-dd')]);
xlabel('range [km]');
ylabel('attn bscat [1/km-sr]');
%%
figure; plot(mplpol.range, std_attn./(mean(copol,2).*(mplpol.range.^2).*pin_C),'k-')
legend('Rayleigh/MPL')
title(['Rayleigh backscatter ratio, Taihu MPL: ',datestr(mplpol.time(1),'yyyy-mmm-dd')]);
xlabel('range [km]');
ylabel('unitless');
