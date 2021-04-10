function ol = ol_laud_test(rng)

%Feb 9, first day with horiz scans, but maybe not all bugs out yet
% Feb 10, first portion of evening
% Mar 2, some surface strikes, maybe use 5-deg?

MPL_cals = load([getnamedpath('miniMPLcal'),'miniMPL_cal_cjf.mat']);
% dname = '20180209'
% dname = '20180210';
% dname = '20180220';
% % dname = '20180302';
% % dname = '20180319';
%  dname = '20180315';
 dname = '20180';
 all_done = false;
full =  getfullname(['2018*.mat'],'mmpl_daily','Select MPL daily mat file.');
if ~iscell(full) full = {full}; end
while ~isempty(full)&&~all_done
[~,dname,ext] = fileparts(full{1});
% mmpl = load(getfullname('20180319.mat','mmpl_daily','Select MPL daily mat file.'));
mmpl = load(full{1});
rng = [1:size(mmpl.vdata.channel_2,1)]'.*30.*unique(mmpl.vdata.bin_time)./2e-4;
[ray] = std_ray_atten(rng*1000,532);
ap_cop = 10.^(interp1(log10(MPL_cals.cjf.rng), log10(MPL_cals.cjf.ap_cop),log10(rng)));
ap_cop = ap_cop * double(mmpl.vdata.energy_monitor)./1000;
ol = 10.^interp1(log10(MPL_cals.cjf.ol.rng), log10(MPL_cals.cjf.ol.olc_mean_fit), log10(rng),'linear','extrap');

cop = mmpl.vdata.channel_2-ap_cop;
cop = cop.*dtc_tan(cop);

r.bg = rng >26.5 & rng < 29.5;
cop_bg = mean(cop(r.bg,:));
cop_r2 = (cop - ones(size(rng))*cop_bg).*(rng.^2);

figure_(35); ss(1) = subplot(2,1,1); 
imagegap(serial2hs(mmpl.time), rng, real(log10(cop_r2))); zoom('on');
caxis([-3,1.5]); 
title(['Lauder miniMPL: ',datestr(mmpl.time(1),'yyyy-mm-dd')]);
ss(2) = subplot(2,1,2);
plot(serial2hs(mmpl.time), mmpl.vdata.elevation_angle,'-o'); 
linkaxes(ss,'x');
menu('Zoom horizontally to identify the time period to use for overlap.','OK, done');
xl = xlim;xl_ = serial2hs(mmpl.time)>=xl(1)&serial2hs(mmpl.time)<=xl(2);  
xl_ = xl_ & mmpl.vdata.elevation_angle>87;

menu('Now zoom vertically for region to pin Rayleigh.','OK, done')
yl = ylim;
r.cop_test = rng>yl(1) & rng<yl(2); cop_test = mean(cop(r.cop_test,:));
r.ray_pin = rng>yl(1) & rng<yl(2); 
ray_cal = mean(ray(r.ray_pin)./mean(cop_r2(r.ray_pin,xl_),2));
ray_r2_cal = mean((ray(r.ray_pin)./rng(r.ray_pin).^2)./mean(cop(r.ray_pin,xl_),2));


figure_(39); 
plot(mean(cop_r2(:,xl_),2),rng,  '-', ray./ray_cal,rng, 'r--', ...
    mean(cop_r2(:,xl_),2)./ol,rng,'g-', ol.*ray./ray_cal,rng, 'r-'); logx
ylabel('range'); xlabel('nrb');
legend('nrb no olc','Rayleigh','nrb wi olc')
title(['Lauder MPL: ',datestr(mmpl.time(1),'yyyy-mm-dd')]);
xlim([0,yl(2)]);

figure_; ax(1) = subplot(2,1,1);
plot(serial2hs(mmpl.time), mean(cop(r.cop_test,:)),'-o');legend('blk test')
ax(2) = subplot(2,1,2);
plot(serial2hs(mmpl.time), mmpl.vdata.elevation_angle,'-x');
linkaxes([ss,ax],'x'); zoom('on'); xlim(xl);
blk = menu('Zoom or pan "blk_test" to define set the threshold','Above','Within')
if blk==1 
    blk_lim = max(ylim);
    ol_0deg = serial2hs(mmpl.time)>xl(1)&serial2hs(mmpl.time)<xl(2)&mmpl.vdata.elevation_angle==0&cop_test>blk_lim;
elseif blk==2
    blim = ylim;
    ol_0deg = serial2hs(mmpl.time)>xl(1)&serial2hs(mmpl.time)<xl(2)&mmpl.vdata.elevation_angle==0&cop_test>blim(1)&cop_test<blim(2);
end
% ol_5deg = serial2hs(mmpl.time)>xl(1)&serial2hs(mmpl.time)<xl(2)&mmpl.vdata.elevation_angle==5;
% Using 5-degree did not work well.  
cop_r2 = mean(cop_r2(:,ol_0deg),2);
figure_; plot(rng, cop_r2,'-'); logy;
ol_rng = rng(rng>=0.02 & rng<=5);
fit_done = false;
while ~fit_done
    fit_it = menu('Zoom in to define x-range over which to compute polyfit','Test','Done');
    if fit_it == 1
        fit_xl =xlim; 
        r.ol_fit = rng>fit_xl(1) & rng<fit_xl(2);
        [P_ol, S_ol, mu_ol] = polyfit(rng(r.ol_fit), real(log10(cop_r2(r.ol_fit))),1);        
        fit_xl_ii = interp1(ol_rng, [1:length(ol_rng)],fit_xl,'nearest','extrap');
        ol_fit = real(10.^(polyval(P_ol,ol_rng,[],mu_ol)));
        plot(rng(rng>=0.03 & rng<=max([5,fit_xl(2)])), cop_r2(rng>=0.03 & rng<=max([5,fit_xl(2)])),'-',...
            ol_rng, ol_fit,'r-',ol_rng(fit_xl_ii),ol_fit(fit_xl_ii),'o' );logy
    else
        fit_done = true;
    end
end
ol_corr = ol_fit./cop_r2(rng>=0.02 & rng<5);
olc = 1./ol_corr;
ol_interp = 10.^interp1(real(log10(MPL_cals.ol_smooth(2:end,1))), real(log10(MPL_cals.ol_smooth(2:end,2))),...
    real(log10(ol_rng)), 'linear','extrap');
figure_
sb(1) = subplot(2,1,1); plot(ol_rng,olc,'-',...
    ol_rng,ol_interp,'k-'); logy; logx;
legend(dname,'vendor (smoothed)','Location','SouthEast'); 


sb(2) = subplot(2,1,2); plot(ol_rng, olc./ol_interp,'c-'); legend([dname,'/vendor']); logx;
xlabel('km'); 
linkaxes(sb,'x');

MPL_cals.cjf.ol.rng = ol_rng;
MPL_cals.cjf.ol.(['olc_' dname]) = olc;
MPL_cals.cjf.ol.(['olc_fitted_' dname]) = analytic_ol(ol_rng, olc);
sav = menu('Save this overlap correction?','Yes, save it','No, abandon it');
if sav==1
save([getnamedpath('miniMPLcal'),'miniMPL_cal_cjf.mat'],'-struct','MPL_cals');
end
if menu('Close figures?','Yes','No')==1
    close('all');
end
proc = menu('Process next file?','No, repeat this one','No, all done','Yes, continue');
if proc==2
    all_done = true;
elseif proc==3
    full(1) = [];
end
end
return

MPL_cals.cjf.ol = rmfield(MPL_cals.cjf.ol,{'olc_fitted_20180224', 'olc_fitted_20180301', 'olc_fitted_20180319'});
fitted = fieldnames(MPL_cals.cjf.ol);
fitted = sort(fitted);
fitted(~foundstr(fitted,'fitted')) = [];
f = 1;
figure; plot(MPL_cals.cjf.ol.rng, MPL_cals.cjf.ol.(fitted{f}),'-'); 
logx; logy; xlabel('range [km]'); title('Overlap fits'); hold('on')
[~,dat] = strtok(fitted{f},'_'); [~,dat] = strtok(dat,'_');dat(1) = [];
legstr(f) = {dat};
mean_fitted = MPL_cals.cjf.ol.(fitted{f});
for f = 2:length(fitted)
    mean_fitted = mean_fitted + MPL_cals.cjf.ol.(fitted{f});
plot(MPL_cals.cjf.ol.rng, MPL_cals.cjf.ol.(fitted{f}),'-'); 
[~,dat] = strtok(fitted{f},'_'); [~,dat] = strtok(dat,'_');dat(1) = [];
legstr(f) = {dat};
end
mean_fitted = mean_fitted./f;
plot(MPL_cals.cjf.ol.rng, mean_fitted, 'k-*',MPL_cals.cjf.ol.rng, 10.^interp1(log10(MPL_cals.ol_smooth(2:end,1)),...
    log10(MPL_cals.ol_smooth(2:end,2)),log10(MPL_cals.cjf.ol.rng),...
    'linear','extrap'),'-m');
legstr(f+1) = {'Mean fit'};legstr(f+2) = {'Vendor (smoothed'};
legend(legstr);

figure; plot(MPL_cals.cjf.ol.rng, mean_fitted./10.^interp1(log10(MPL_cals.ol_smooth(2:end,1)),...
    log10(MPL_cals.ol_smooth(2:end,2)),log10(MPL_cals.cjf.ol.rng),'linear','extrap'),'-r'); 
legend('fit / vendor'); xlabel('range [km]'); logx;
title('Vendor-provided overlap vs horizontal fits')

MPL_cals.cjf.ol.olc_mean_fit = mean_fitted;
save([getnamedpath('miniMPLcal'),'miniMPL_cal_cjf.mat'],'-struct','MPL_cals');

