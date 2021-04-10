function mpl_ap_tan_cloud_blocked

%15-Feb-2018 10:17:18-15:30:56, strongly attenuated beam
% Plot of raw copol (channel 2) shows strong linear relationship between
% logx - logy versus range above 400 m up to several km.
% Use a linear fit over this region to extrapolate AP < 400 nm.
% Presume to use fitting technique from MPL processing out to max range (30km?)
% Subtract this minimum amount from the BG estimate 

% generate image of uncorrected signal vs time.  Zoom into period of time
% when strongly attenuated.

Path = getnamedpath('miniMPL','Select miniMPL daily path');
save_path = [Path 'processed_data\']; if ~isadir(save_path) mkdir(save_path); end
save_plot_path = [Path 'processed_data_plots\'];
if ~isadir(save_plot_path) mkdir(save_plot_path); end

cal_path = 'E:\mmpl\ER2019\calibration_uc\';
if isafile([cal_path,'calibration_uc.nc'])
    MPL_cal = anc_load([cal_path,'calibration_uc.nc']);
end

STR = 'UC'; % southern ocean voyage
fname = getfullname([Path '*.mat'],'miniMPL','*.mat');


figure_(29); ax(1) = subplot(2,1,1); 
imagegap(serial2Hh(mpl.time), rng, real(log10(mpl.vdata.channel_2)));zoom('on');
ax(2) = subplot(2,1,2);
plot(serial2Hh(mpl.time), mpl.vdata.background_average_2,'*');logy; zoom('on');
linkaxes(ax,'x');

menu('Zoom into beam blocked time at night.','Done');
tl = xlim;
tl_ = serial2Hh(mpl.time)>=tl(1) & serial2Hh(mpl.time)<=tl(2);

figure_(30); ax(1) = subplot(2,1,1); 
imagegap(serial2Hh(mpl.time(tl_)), rng, real(log10(mpl.vdata.channel_2(:,tl_))));zoom('on');
ax(2) = subplot(2,1,2);
plot(serial2Hh(mpl.time(tl_)), mpl.vdata.background_average_2(:,tl_),'*');logy; zoom('on');
linkaxes(ax,'x');

cop_ap = mean(mpl.vdata.channel_2(:,tl_),2);
crs_ap = mean(mpl.vdata.channel_1(:,tl_),2);
em = mean(double(mpl.vdata.energy_monitor(tl_))./1000);
if ~isavar('rng')
    rng = linspace(14.989e-3, 29.9792, length(cop_ap))';
end

dk = 4e-4;ddk = 1e-4; sm = 20;
v = [.5,30,-1,1];
figure_(30); 
ax(1) = subplot(2,1,1); 
plot(rng, cop_ap-dk,'b-', rng, crs_ap-dk,'r-'); logy; logx; 
ax(2) = subplot(2,1,2);
plot(rng,(crs_ap-dk)./(cop_ap-dk),'-', ...
    rng, smooth((crs_ap-dk)./(cop_ap-dk),sm),'k-'); logx; zoom('yon')
xlabel('range'); 
linkaxes(ax,'x'); axis(v);

done = false;

while ~done   
    adj = menu('Modify dark subtraction:','Up','Down','finer','smoother','less smooth','Done');
    v = axis(ax(2));
    if adj==1
        dk = dk - ddk;
    elseif adj==2
        dk = dk + ddk;
    elseif adj == 3
        ddk = ddk./2;
    elseif adj ==4
        sm = sm + 5;
    elseif adj ==5
        sm = max([5,sm -5]);
    elseif adj==6
        done = true;
    end
    ax(1) = subplot(2,1,1);
    plot(rng, cop_ap-dk,'b-', rng, crs_ap-dk,'r-'); logy; logx;
    ax(2) = subplot(2,1,2);
    plot(rng,(crs_ap-dk)./(cop_ap-dk),'-', rng, smooth((crs_ap-dk)./(cop_ap-dk),sm),'k-'); logx; zoom('yon')
    xlabel('range');
    axis(v);
end
cop_ap_em = (cop_ap -dk)./em; 
crs_ap_em = (crs_ap -dk)./em;
% Next, zoom into a near-range region where ratio between afterpulse is
% pretty flat and use that range to define the fit-range that will be used
% to extrapolate near-range afterpulse.
menu('Now zoom into a near-range region where ratio between cop and crs is flat','OK');
xl_ap1 = xlim;
xl_ap1_ = rng>=xl_ap1(1) & rng<=xl_ap1(2);
% Now compute log-log fit of ap(xl_ap1_) vs rng(xl_ap1_)
[P_cop_ap1,~,mu_cop_ap1] = polyfit(log10(rng(xl_ap1_)), log10(cop_ap_em(xl_ap1_)),1);
[P_crs_ap1,~,mu_crs_ap1] = polyfit(log10(rng(xl_ap1_)), log10(crs_ap_em(xl_ap1_)),1);
cop_ap1 = 10.^polyval(P_cop_ap1,log10(rng(rng<xl_ap1(2))),[],mu_cop_ap1);
crs_ap1 = 10.^polyval(P_crs_ap1,log10(rng(rng<xl_ap1(2))),[],mu_crs_ap1);
figure; plot(rng(rng<xl_ap1(2)),cop_ap1,'b--',rng(rng<xl_ap1(2)),crs_ap1,'r--'); logx; logy;
%The near range extrapolation looks pretty good.
rng_near = rng(rng<xl_ap1(2)); 
% Next, we compute a fit of the ratio in log-lin space from 1:30
clear rng_logmn ap_rat_mn ap_cop_logmn ap_crs_logmn
r_log = logspace(log10(2),log10(15),50);
for ii = length(r_log):-1:2
    ii_ = rng>r_log(ii-1)&rng<=r_log(ii);
    Ns(ii-1) = sum(ii_);
    rng_logmn(ii-1) = 10.^mean(log10(rng(ii_)));
    ap_cop_logmn(ii-1) = 10.^mean(log10(cop_ap_em(ii_)));
    ap_crs_logmn(ii-1) = 10.^mean(log10(crs_ap_em(ii_)));
    ap_rat_mn(ii-1) = mean(crs_ap_em(ii_)./cop_ap_em(ii_));
end
rng_logmn=rng_logmn'; ap_cop_logmn = ap_cop_logmn'; 
ap_crs_logmn = ap_crs_logmn'; ap_rat_mn = ap_rat_mn';
figure_; plot(rng_logmn, ap_cop_logmn, '*',rng_logmn, ap_crs_logmn,'x',...
    rng_logmn, ap_rat_mn.*ap_cop_logmn, 'o'); logx; logy;
 plot(rng_logmn, ap_rat_mn, 'k*-'); logx

 
% This ratio looks pretty good.  Now we fit it, and we'll use it to infer the cross-pol
% aftepulse from the co-pol (which has better statistics)
% The log-averaged copol and crspol also look quite good. Rather than fit
% them over the entire range, we can use the log-averaged values and only
% fit the last three to get the far range point.
% So far, this all looks very good but is apparently higher than Israels AP
% curves.  It is possible these are too high owing to contributions from
% the clouds out to 200 meters.  To check this possibility, I'll look at
% the few profiles at 0 El when apparently the beam was striking the ocean.

[P_rat_ap2,~,mu_rat_ap2] = polyfit(log10(rng_logmn),ap_rat_mn,2);
rat_ap2 = polyval(P_rat_ap2,log10(rng_logmn),[],mu_rat_ap2); %rat_ap2 = rat_ap2';

figure_; plot(rng_logmn, ap_cop_logmn, '*',rng_logmn, ap_crs_logmn,'x',...
    rng_logmn, rat_ap2.*ap_cop_logmn, 'ko'); logx; logy;
 plot(rng_logmn, ap_rat_mn, 'k*-'); logx

figure; plot(rng_logmn,rat_ap2,'g-');
ap_rat = interp1(rng_logmn, rat_ap2, rng, 'linear','extrap');

% So, use the near-range extrapolation of cop_ap and crs_ap , and interpolate 
% between ap_cop_logmn and rat_ap2 in log-space over the rest of the range
% to infer crs_ap over the full range.
% and copol ap over the full.
[rng_cjf,ij] = sort([rng(rng<xl_ap1(2));rng_logmn]);
ap_cop_cjf = [cop_ap1; ap_cop_logmn]; ap_cop_cjf = ap_cop_cjf(ij);
ap_crs_cjf = [crs_ap1; ap_cop_logmn .* rat_ap2]; ap_crs_cjf = ap_crs_cjf(ij);

figure; plot(rng_cjf, [ap_cop_cjf, ap_crs_cjf],'-');logy; logx;

MPL_cal.vdata.ap_copol = interp1(rng_cjf, ap_cop_cjf, rng, 'linear','extrap');
MPL_cal.vdata.ap_crosspol = interp1(rng_cjf, ap_crs_cjf, rng, 'linear','extrap');
plot(rng, [MPL_cal.vdata.ap_copol, MPL_cal.vdata.ap_crosspol],'-');logy; logx;
title(datestr(mpl.time(1),'yyyymmdd'))
MPL_cal.vatts.ap_copol.cjf = 'From cloud-blocked 2019072026';
MPL_cal.vatts.ap_crosspol.cjf = 'From cloud-blocked 20190726';
save([cal_path,'calibration_uc.cjf.20190726.mat'],'-struct','MPL_cal')
% save([cal_path,'miniMPL_cal_cjf.mat'], '-struct','MPL_cal');
