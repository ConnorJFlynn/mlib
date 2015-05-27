function status = hsrl_poster_scraps
% MPL / HSRL poster plots

% First test day was Apr 12.
% Also look at Apr 6 (after midnight)

%%
% Repeat of previous work...
% Then look at addt. days

fullname = getfullname_('*.hdf','hsrl','Select hdf file')
%Get HDF info
[pathname, filename, ext] = fileparts(fullname);
pathname = [pathname filesep];
filename = [filename, ext];
S = hdfinfo([pathname,filename]);
%Read in variable names
names = {S.SDS.Name};
flight_str = ['Flight ',filename(1:8),' ',filename(10:11)];

%%

%cast these into a mat structure for convenience
gps_time = hdfread([pathname filename],'gps_time');
gps_date = hdfread([pathname filename],'gps_date');
hsrl.time = (datenum(gps_date,'mm/dd/yyyy')+double(mod(gps_time,24))'./24);
hsrl.lat = hdfread([pathname filename],'gps_lat');
hsrl.lon = hdfread([pathname filename],'gps_lon');
site.lat = 71.32;
site.lon = -156.62;
hsrl.dist = geodist(hsrl.lat,hsrl.lon,site.lat, site.lon)./1000;
%%
near_site = 5; % km
hsrl.near_site = hsrl.dist <= (near_site); % meters
disp([flight_str,' has ',num2str(sum(hsrl.near_site)),' points within ',num2str(near_site),' km.'])

hsrl.altitude = hdfread([pathname filename],'Altitude')./1000;
hsrl.Temperature = hdfread([pathname filename],'Temperature');
hsrl.Pressure = hdfread([pathname filename],'Pressure');
hsrl.Number_Density = hdfread([pathname filename],'Number_Density');
hsrl.x532_ext = hdfread([pathname filename],'532_ext'); %Has NaNs
hsrl.x532_bsc = hdfread([pathname filename],'532_bsc');
hsrl.x532_bsr = hdfread([pathname filename],'532_bsr');
hsrl.x532_bsc_Sa = hdfread([pathname filename],'532_bsc_Sa');
hsrl.x532_dep = hdfread([pathname filename],'532_dep');
hsrl.x532_total_attn_bsc = hdfread([pathname filename],'532_total_attn_bsc');
%%
lat_N = 71.41;
lat_S = 71.23;
lon_E = -156.35;
lon_W = -156.9;
[min_dist,ind] = min(hsrl.dist);
figure;
o_time = (hsrl.time - floor(hsrl.time(1))).*24;
scatter(hsrl.lon,hsrl.lat,200,o_time,'filled');
cb = colorbar; 
set(cb,'fontsize',18,'fontweight','bold','fontname','Tahoma');
set(gcf,'position',[77    92   858   706]);
set(gca,'fontsize',24,'fontweight','bold','fontname','Tahoma');
xlabel('longitude','fontsize',24,'fontweight','bold','fontname','Tahoma');
ylabel('lattitude','fontsize',24,'fontweight','bold','fontname','Tahoma');
title({'King Air flight path over NSA site',flight_str }, 'fontsize',24,'fontweight','bold','fontname','Tahoma');
hold('on');
set(cb,'fontsize',24,'fontweight','bold','fontname','Tahoma');
gt = text('string','[UTC]','fontsize',18,'fontweight','bold','fontname','Tahoma',...
   'units','normalized','position',[[1.00289 1.06172 0]]);

these = plot(hsrl.lon,hsrl.lat, 'k-', site.lon,site.lat,'ro', site.lon,site.lat,'r.','markersize',24);
set(these(1),'linewidth',3); 
set(these(2),'markersize',24,'markeredgecolor','r','markerfacecolor','g','linewidth',5);
set(these(3),'markersize',24,'color','r');
axis([lon_W, lon_E, lat_S, lat_N]);
ta = annotation('textarrow','position',[0.3671    0.2436    0.1177    0.2139],'string',' NSA Site ','fontsize',24,...
   'fontweight','bold','fontname','Tahoma','linewidth',3,'color',[0.8471 0.1608 0],...
   'textcolor','r','textedgecolor','r','headstyle','plain');
ka = annotation('textarrow','position',[0.6608    0.7365   -0.1177   -0.3329],'string',{'HSRL times','and locations'},'fontsize',18,...
   'fontweight','bold','fontname','Tahoma','linewidth',3,'color','k',...
   'textcolor','k','textedgecolor','none','headstyle','plain');
ke = annotation('textarrow','position',[0.3811    0.7592    0.0373   -0.0694],'string',{'5 km radius','from NSA Site'},'fontsize',18,...
   'fontname','Tahoma','fontweight','bold','linewidth',3,'color','k',...
   'textcolor','k','textedgecolor','none','headstyle','plain');
el = annotation('ellipse',[0.3248    0.2774    0.3539    0.4234],'linestyle','--','linewidth',2);
hold('off')
%%
caxis([21,26])

%%
mpl = loadinto;
%%
[alpha_R, beta_R] = ray_a_b(hsrl.Temperature(ind,:),hsrl.Pressure(ind,:),532e-9);
topdn_atten = topdown_atten((hsrl.altitude), hsrl.Temperature(ind,:),hsrl.Pressure(ind,:), 532e-9, (hsrl.x532_ext(ind,:)), (hsrl.x532_bsc(ind,:)));
nearby = find(hsrl.near_site);
for ff = 1:length(nearby)
botup_atten(ff,:) = lidar_atten_profs(hsrl.altitude, hsrl.Temperature(nearby(ff),:),hsrl.Pressure(nearby(ff),:), 532e-9, hsrl.x532_ext(nearby(ff),:), hsrl.x532_bsc(nearby(ff),:));
end
% To check, plot topdn, botup, and measured total_atten
%%
% figure;
% set(gcf,'position',[77    92   858   706]);
% semilogx(hsrl.x532_total_attn_bsc(ind,:), hsrl.altitude,'k',...
%    topdn_atten, hsrl.altitude,'r',...
% botup_atten, hsrl.altitude,'b')
%%

dwn = downsample(hsrl.x532_total_attn_bsc(hsrl.near_site,:),sum(hsrl.near_site));
dwn = downsample(botup_atten, sum(hsrl.near_site));
mpl_times = unique(round(interp1( mpl.time,[1:length(mpl.time)],hsrl.time(hsrl.near_site))));
mpl_times = [min(mpl_times)-1;mpl_times; max(mpl_times)+1];
mean_mpl = mean(mpl.attn_bscat(mpl.r.lte_10,mpl_times),2);
figure; 
set(gcf,'position',[77    92   858   706]);
%%
semilogx(dwn, hsrl.altitude,'-',  mean_mpl./160,mpl.range(mpl.r.lte_10),'g');
zoom('on')
%%
yl.yl = ylim;
yl.mpl = (mpl.range>=yl.yl(1))&(mpl.range<=yl.yl(2));
yl.hsrl = (hsrl.altitude>=yl.yl(1))&(hsrl.altitude<=yl.yl(2));
cal_val = mean(mean_mpl(yl.mpl))./mean(dwn(yl.hsrl));

ol_lines = semilogx( mean_mpl./cal_val,mpl.range(mpl.r.lte_10),'g-',dwn, hsrl.altitude,'k-' );
set(gca,'fontsize',24,'fontweight','bold','fontname','Tahoma');
set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');
set(ol_lines(1),'linewidth',3); set(ol_lines(2),'linewidth',2);
xlabel('atten. bscat coef [1/km]');
ylabel('range [km]')
title({'MPL without overlap correction',['Flight ',filename(1:8),' ',filename(10:11)]} );
h_mpl = annotation('textarrow','position',[0.2977    0.5085    0.0798   -0.1985],'string',{'uncorrected','MPL profile'},'fontsize',18,...
   'fontweight','bold','fontname','Tahoma','linewidth',3,'color',[0,155/255,0],...
   'textcolor',[0,155/255,0],'textedgecolor','none','textbackgroundcolor','w','headstyle','plain');
h_hsrl = annotation('textarrow','position',[0.7044    0.6254   -0.1091   -0.2764],'string',{'HSRL profile'},'fontsize',18,...
   'fontweight','bold','fontname','Tahoma','linewidth',3,'color',[0,0,0],...
   'textcolor',[0,0,0],'textedgecolor','none','textbackgroundcolor','w','headstyle','plain');
axis([0.0003 ,0.005, 0, 5.20]);
%%

% figure; 
% set(gcf,'position',[77    92   858   706]);
% semilogx(hsrl.x532_total_attn_bsc(ind,:),hsrl.altitude,'g-', topdn_atten,hsrl.altitude,'r-',botup_atten,hsrl.altitude,'b-' );
% set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');
% %%

cal_mpl = mean(mpl.attn_bscat(mpl.r.lte_10,mpl_times),2)./cal_val;
botup_MPL = interp1(mpl.range(mpl.r.lte_10), cal_mpl, hsrl.altitude);

ol_corr_raw.range = hsrl.altitude;
ol_corr_raw.ol = dwn./botup_MPL;
ol_corr_fit_0406  = ISDAC_hsrl_corr_20080406_L1(hsrl.altitude);
ol_corr_fit_0412  = hsrl_ol_corr(hsrl.altitude);
ol_corr_fit_0416  = ISDAC_hsrl_corr_20080416_L2(hsrl.altitude);
figure; 
set(gcf,'position',[77    92   858   706]);
plots = semilogx(ol_corr_raw.ol,ol_corr_raw.range,'ko', ol_corr_fit_0416,hsrl.altitude,'r-');
set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');
set(gca,'fontsize',24,'fontweight','bold','fontname','Tahoma');
set(plots(1),'linewidth',2,'markersize',12); set(plots(2),'linewidth',3); 
xlabel('correction factor');
ylabel('range [km]');
title({'MPL correction factor',['Flight ',filename(1:8),' ',filename(10:11)]} );
axis([1,300,0,5.2])

% %%
% % Add to this one until we have all the corrections displayed...
% figure; 
% set(gcf,'position',[77    92   858   706]);
% subplot(1,2,1); plots1 = semilogx(ol_corr_fit_0406,hsrl.altitude,'r-',...
%    ol_corr_fit_0412,hsrl.altitude,'g-', ...
%    ol_corr_fit_0416,hsrl.altitude,'b-');
% set(plots1(1), 'linewidth',3);
% set(plots1(2), 'linewidth',3,'color',[0,155/255,0]);
% set(plots1(3), 'linewidth',3);
% set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');
% set(gca,'fontsize',24,'fontweight','bold','fontname','Tahoma');
% xlabel('correction');
% ylabel('range [km]');
% ylim([0,5.2]);
% xlim([1,100]);
% 
% subplot(1,2,2); plots
% mean_ol = mean([ol_corr_fit_0406;ol_corr_fit_0412;ol_corr_fit_0416]);
% plots2 = plot(100.*abs(ol_corr_fit_0406-mean_ol)./mean_ol,hsrl.altitude,'r-',...
%    100.*abs(ol_corr_fit_0412-mean_ol)./mean_ol,hsrl.altitude,'g-',...
%    100.*abs(ol_corr_fit_0416-mean_ol)./mean_ol,hsrl.altitude,'b-');
% set(plots2(1), 'linewidth',3);
% set(plots2(2), 'linewidth',3,'color',[0,155/255,0]);
% set(plots2(3), 'linewidth',3);
% set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');
% set(gca,'fontsize',24,'fontweight','bold','fontname','Tahoma')
% xlabel('% deviation')
% axis([0    15         0    5.2000]);
% 


% %%
% figure;
% set(gcf,'position',[77    92   858   706]);
% ol_lines = semilogx( mean_mpl./cal_val, mpl.range(mpl.r.lte_10),'g-',dwn, hsrl.altitude,'k-',...
%    (ISDAC_hsrl_corr_20080416_L2(mpl.r.lte_10)).*mean_mpl./cal_val, mpl.range(mpl.r.lte_10),'g-');
% set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');
% %
% set(gca,'fontsize',24,'fontweight','bold','fontname','Tahoma');
% set(ol_lines(1),'linewidth',3); set(ol_lines(2),'linewidth',2);
% xlabel('atten. bscat coef [1/km]');
% ylabel('range [km]')
% title({'MPL with overlap correction',['Flight ',filename(1:8),' ',filename(10:11)]} );
% h_mpl = annotation('textarrow','position',[0.2977    0.5085    0.0798   -0.1985],'string',{'MPL profile','corrected'},'fontsize',18,...
%    'fontweight','bold','fontname','Tahoma','linewidth',3,'color',[0,155/255,0],...
%    'textcolor',[0,155/255,0],'textedgecolor','none','textbackgroundcolor','w','headstyle','plain');
% h_hsrl = annotation('textarrow','position',[0.7044    0.6254   -0.1091   -0.2764],'string',{'HSRL profile'},'fontsize',18,...
%    'fontweight','bold','fontname','Tahoma','linewidth',3,'color',[0,0,0],...
%    'textcolor',[0,0,0],'textedgecolor','none','textbackgroundcolor','w','headstyle','plain');
% axis([0.0003 ,0.005, 0, 5.20]);
% %%


figure; 
set(gcf,'position',[77    92   858   706]);
plot((diff2(log(topdn_atten./botup_MPL)./4))./(diff2(hsrl.altitude))-alpha_R,hsrl.altitude, 'k');
set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');


figure; 
set(gcf,'position',[77    92   858   706]);
plot( hsrl.x532_ext(ind,:), hsrl.altitude,'-g' );
set(gca,'xgrid','on','xminorgrid','on','ygrid','on','yminorgrid','on');
