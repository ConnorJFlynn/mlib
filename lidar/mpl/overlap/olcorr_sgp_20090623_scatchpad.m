%This code was used to manually patch the overlap correction at SGP for
%June 23, 2009.  The basic idea is to assume a well-mixed boundary layer
%and attempt to recreate that behavior.  Based on a ceilometer from Vic
%(CL31) the time period from 18:00-19:50 UTC looks most useful.

%So, zooming into this region and fine tuning the times to get a cluster of profiiles with low variability.
%I've created two patches.  
% patch_1 takes a linear fit of profiles from 
% (y>=0.7)&(y<=0.95), and then patches below the mid-point of this range mainly impacting < 0.5 km.
% This helps but still seems to under-correct, possibly because the
% slope of the profiles is already due to using the incorrect overlap to
% begin with.
% patch_2 attempts to address this by simply taking the highest point at
% about 1.2 km and assuming the slope for nearer range needs to be
% corrected away.  This seems to help a bit more but still leaves something
% to be desired.  Perhaps the backscatter should be increasing towards the
% ground, not staying level, similar to the slope observed between 1.5 and
% 2 km.  Could fit to this but there is a hump between 1.2 and 1.5 km, so we'd probably have
% to compute the fit, then shift to the peak value at 1.2 and correct from there on down. 
% Okay, so far patch #3 looks the best.  
% I'm going to save the original, plus all three patches in a new file.


%%

figure; 
mask = ones(size(polavg.cop));
mask(polavg.r.lte_15,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
mask(polavg.cop_snr<cop_snr) = NaN;
x = 24*(polavg.time-floor(polavg.time(1)));
y = polavg.range(r.lte_15);
z1_ = real(log10((mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:))./((polavg.range(r.lte_15).^2)*ones(size(polavg.time)))));
% z1 = real(log10(mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:)));
axx(1) = subplot(2,1,1); imagegap(x, y, z1_); 
axis('xy'); 
% colormap(jet_rgb); 
colormap(comp_map3); 
set(axx(1),'TickDir','out');
% colormap('hijet');  
ylim([0,5]); 
% cv_bs = 10.^cv_bs;
caxis(cv_bs); colorbar;
titlestr = ['log10(attenuated backscattering ratio) for ',datestr(polavg.time(1), 'yyyy-mm-dd '),am_pm_str1];
title(axx(1),titlestr, 'interpreter','none');

ylabel('range (km)');
mask = ones(size(polavg.cop));
ldr_error = abs(polavg.ldr)./polavg.ldr_snr;
mask(polavg.ldr_snr<ldr_snr | ldr_error>ldr_error_limit) = NaN;
% z2 = real(log10(mask(r.lte_15,:).*polavg.d(r.lte_15,:)));
z2 = real(log10(mask(r.lte_15,:).*polavg.ldr(r.lte_15,:)));
axx(2) = subplot(2,1,2); 
imagegap(x, y, z2); 
axis('xy'); 
xlabel('time (UTC)');
% colormap('jet_rgb'); 
% colormap('hijet');
colormap(comp_map3);
titlestr = ['log10(linear depolarization ratio) for ',datestr(polavg.time(1), 'yyyy-mm-dd '),am_pm_str1];
title(axx(2),titlestr, 'interpreter','none');

caxis(cv_dpr); cb_d = colorbar;
linkaxes(axx,'xy')
%%
tl = xlim;
%%
v = axis(zz2);
tl = [19.15,tl(2)];

t.ol = serial2Hh(polavg.time)>=tl(1) & serial2Hh(polavg.time)<=tl(2);
z1_ = real(log10((mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:))./((polavg.range(r.lte_15).^2)*ones(size(polavg.time)))));
z2_ = real(log10((mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:))));

figure; zz1 = subplot(2,1,1); ll = plot(y,z1_(:,t.ol),'-'); recolor(ll,serial2Hh(polavg.time(t.ol))); colorbar;
zz2 = subplot(2,1,2); ll = plot(y,z2_(:,t.ol),'-'); recolor(ll,serial2Hh(polavg.time(t.ol))); colorbar;
linkaxes([zz1,zz2],'x')
axis(zz2,v)

%%
r.bad = polavg.range<.09;
fit_r = (y>=0.7)&(y<=0.95);
r_patch = y<=((.7+.95)./2);
P = polyfit(y(fit_r),mean(z2_(fit_r,t.ol),2),1);
figure;

ff = plot(y(r_patch),z2_(r_patch,t.ol),'-'); recolor(ll,serial2Hh(polavg.time(t.ol))); colorbar;
hold('on');
plot(y(r_patch),polyval(P,y(r_patch)),'r-');
log10_ol_patch = polyval(P,y(r_patch)) - mean(z2_(r_patch,t.ol),2);

%%
ol_patch = ones(size(polavg.ol_corr));
ol_patch(r.lte_15(r_patch)) = 10.^(log10_ol_patch);

ol_patch(r.bad) = NaN;
%%
log10_ol_patch2 = 0.4 - mean(z2_(y<1.2,t.ol),2);
ol_patch2 = ones(size(polavg.ol_corr));
ol_patch2(r.lte_15(y<1.2)) = 10.^(log10_ol_patch2);
r.bad = polavg.range<.09;
ol_patch2(r.bad) = NaN;
%%
% Trying for patch #3, fitting top region from 1.5 to 2 to get the slope,
% then adjusting the intercept to match the peak at 1.2 km.

top_fit_r = (y>=1.5)&(y<=2);
no_nan = z2_(top_fit_r,t.ol); no_nan(:,6) = []; no_nan(:,2) = [];
P_top = polyfit(y(top_fit_r),mean(no_nan,2),1);
P_top(2)=P_top(2)+.097;
figure;
%%

ff = plot(y(y<3),mean(z2_(y<3,t.ol),2),'-'); recolor(ll,serial2Hh(polavg.time(t.ol))); colorbar;
hold('on');
plot(y(y<3),polyval(P_top,y(y<3)),'r-');
log10_ol_patch3 = polyval(P_top,y(y<=1.2)) - mean(z2_(y<=1.2,t.ol),2);
ol_patch3 = ones(size(polavg.ol_corr));
ol_patch3(y<=1.2) = 10.^(log10_ol_patch3);
ol_patch3(r.bad) = NaN;
%%
ol_patch = ones(size(polavg.ol_corr));
ol_patch(r.lte_15(r_patch)) = 10.^(log10_ol_patch);

% log10_ol_patch = polyval(P,y(r_patch)) - mean(z2_(r_patch,t.ol),2);
%%

figure; 
mask = ones(size(polavg.cop));
mask(polavg.r.lte_15,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
mask(polavg.cop_snr<cop_snr) = NaN;
x = 24*(polavg.time-floor(polavg.time(1)));
y = polavg.range(r.lte_15);
z3_ = real(log10((ol_patch3(r.lte_15)*ones(size(polavg.time))).*(mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:))));
% z1 = real(log10(mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:)));
azz(1) = subplot(2,1,1); imagegap(x, y, z3_); 
axis('xy'); 
% colormap(jet_rgb); 
colormap(comp_map3); 
set(azz(1),'TickDir','out');
% colormap('hijet');  
ylim([0,5]); 
% cv_bs = 10.^cv_bs;
caxis(cv_bs); colorbar;
titlestr = ['patched ol_corr log10(attenuated backscattering ratio) for ',datestr(polavg.time(1), 'yyyy-mm-dd '),am_pm_str1];
title(azz(1),titlestr, 'interpreter','none');

ylabel('range (km)');
mask = ones(size(polavg.cop));
ldr_error = abs(polavg.ldr)./polavg.ldr_snr;
mask(polavg.ldr_snr<ldr_snr | ldr_error>ldr_error_limit) = NaN;
% z2 = real(log10(mask(r.lte_15,:).*polavg.d(r.lte_15,:)));
z2 = real(log10(mask(r.lte_15,:).*polavg.ldr(r.lte_15,:)));
azz(2) = subplot(2,1,2); 
imagegap(x, y, z2); 
axis('xy'); 
xlabel('time (UTC)');
% colormap('jet_rgb'); 
% colormap('hijet');
colormap(comp_map3);
titlestr = ['log10(linear depolarization ratio) for ',datestr(polavg.time(1), 'yyyy-mm-dd '),am_pm_str1];
title(azz(2),titlestr, 'interpreter','none');

caxis(cv_dpr); cb_d = colorbar;
linkaxes(azz,'xy');
%%

sgp_2009_06_23_ol_corr.range = polavg.range;
sgp_2009_06_23_ol_corr.ol_corr_orig = polavg.ol_corr;
sgp_2009_06_23_ol_corr.patch_1 = ol_patch;
sgp_2009_06_23_ol_corr.patch_2 = ol_patch2;
sgp_2009_06_23_ol_corr.patch_3 = ol_patch3;
sgp_2009_06_23_ol_corr.ol_corr = polavg.ol_corr .* ol_patch3;
%%
clear cols
cols(:,1) = sgp_2009_06_23_ol_corr.range;
cols(:,2) = sgp_2009_06_23_ol_corr.ol_corr;
cols(:,3) = sgp_2009_06_23_ol_corr.ol_corr_orig;
cols(:,4) = sgp_2009_06_23_ol_corr.patch_1;
cols(:,5) = sgp_2009_06_23_ol_corr.patch_2;
cols(:,6) = sgp_2009_06_23_ol_corr.patch_3;
cols =double(cols);
%%


save('C:\matlib\sgp_2009_06_23_ol_corr.dat','cols', '-ascii');

