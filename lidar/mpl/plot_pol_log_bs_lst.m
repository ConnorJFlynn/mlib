function plot_pol_log_bs_lst(polavg,inarg)
% plot_pol_log_bs(polavg,inarg)
% polavg contains averaged mplpol data
% inarg has the following optional elements 
% .mat_dir
% .png_dir 
% .fig_dir
% .cop_snr = 2;
% .ldr_snr = 1.5;
% .ldr_error_limit = .25;
% .cv_log_bs = [1.5,4.5];
%    
% Now plotting attenuated backscatter ratio (using std atm for Rayleigh)
if ~exist('polavg','var')
   polavg_file = getfullname_('*.mat','polavg');
   polavg = loadinto(polavg_file);
   polavg.statics.fname = polavg_file;
end
if ~exist('inarg','var');
   inarg = [];
   cop_snr = 1.5;
   ldr_snr = 1.5;
   ldr_error_limit = 50;
   cv_log_bs = [1.5,4.5]; 
   cv_dpr = [-2,0];
   ranges = [12,6,3];
   fstem = 'sgpmplpol_3flynn.';
   fig = gcf;
   vis = 'on';
   set(fig,'visible',vis);
else
   if isfield(inarg,'mat_dir')
      mat_dir = inarg.mat_dir;
   else
      mat_dir = [];
   end
   if isfield(inarg,'fig_dir')
      fig_dir = inarg.fig_dir;
   else
      fig_dir = [];
   end
   if isfield(inarg,'png_dir')
      png_dir = inarg.png_dir;
   else
      png_dir = [];
   end
   if isfield(inarg,'ldr_snr')
      ldr_snr = inarg.ldr_snr;
   else
      ldr_snr = 1.5;
      ldr_error_limit = .25;
   end
   if isfield(inarg,'cop_snr')
      cop_snr = inarg.cop_snr;
   else
      cop_snr = 2;
   end
   if isfield(inarg,'ldr_error_limit')
      ldr_error_limit = inarg.ldr_error_limit;
   else
         ldr_error_limit = .25;
   end
   if isfield(inarg,'fstem')
      fstem = inarg.fstem;
   else
      fstem = 'ufo_mplpol_1flynn.';
   end
   if isfield(inarg,'vis')
      vis = inarg.vis;
   else
      vis = 'off';
   end
   if isfield(inarg,'fig')
      fig = inarg.fig;
   else
      fig = gcf;
   end
   if isfield(inarg,'cv_log_bs')
      cv_log_bs = inarg.cv_log_bs;
   else
      cv_log_bs = [1.5,4.5];
   end
   if isfield(inarg,'cv_dpr')
      cv_dpr = inarg.cv_dpr;
   else
      cv_dpr = [-2,0];
   end
      if isfield(inarg,'plot_ranges')
      ranges = inarg.plot_ranges;
   else
      ranges = [15,5,2];
   end
end
%    vis = 'off';
%%
[pstr,fname,ext] = fileparts(polavg.statics.fname); fname = [fname, ext];
in_dir = [pstr,filesep];
if strcmp([filesep,'mat',filesep],in_dir(end-4:end))
   in_dir(end-3:end) = [];
end
png_dir = [in_dir, 'png',filesep];
fig_dir = [in_dir, 'fig',filesep];
mat_dir = [in_dir, 'mat',filesep];
% in_dir = ['C:\case_studies\ISDAC\MPL\MPL_raw\'];
if ~exist(png_dir, 'dir')
   mkdir(png_dir);
end
if ~exist(fig_dir, 'dir')
   mkdir(fig_dir);
end
if ~exist(mat_dir, 'dir')
   mkdir(mat_dir);
end
% polavg.time = polavg.time - floor(97.5./15)./24;
% cv_bs = [2,5];
% cv_bs = [2,5]; % for ISDAC due to weaker signal compared to NIM.
% cv_dpr = mpl_inarg.cv_dpr;
%% Determine if we are plotting 0-12 or 12-24
hh_HH = [floor(serial2Hh(polavg.time(1))),ceil(floor(serial2Hh(polavg.time(1)))+(polavg.time(end)-polavg.time(1))*24)];
if floor(polavg.time(1))==floor(polavg.time(end))
   hh_HH_str1 = [sprintf('%0.2d',hh_HH(1)),'-',sprintf('%0.2d',hh_HH(2)),' UTC'];
   hh_HH_str2 = ['.',sprintf('%0.2d',hh_HH(1)),'_',sprintf('%0.2d',hh_HH(2)),'UTC'];
else
   hh_HH_str1 = [datestr(polavg.time(end),'yyyy-mm-dd')];
   hh_HH_str2 = [datestr(polavg.time(end),'.yyyymmdd')];
end
% if serial2Hh(polavg.time(1))>=12
%    am_pm = [12,24];
%    am_pm_str1 = '12-24 UTC';
%    am_pm_str2 = '.12_24UTC';
% else
%    am_pm = [0,12];
%    am_pm_str1 = '00-12 UTC';
%    am_pm_str2 = '.00_12UTC';
% end
% max_hr = 24*(polavg.time(end)-polavg.time(1));


% r.lte_20 = polavg.range>0 & polavg.range<=15;
r.lte_20 = polavg.r.lte_20;
if isfield(polavg,'std_attn_prof')
   std_attn_prof = polavg.std_attn_prof(polavg.r.lte_20);
else
   [std_attn_prof,tau, ray_tod] = std_ray_atten(polavg.range(polavg.r.lte_20));
end
mask = ones(size(polavg.cop));
mask(polavg.r.lte_20,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
mask(polavg.cop_snr<cop_snr) = NaN;
end_time = floor(polavg.time(end));

figure(fig); 
set(gcf,'visible',vis);
set(gcf,'position',[18    72   819   708]);
x = 24*(polavg.time-floor(polavg.time(1)))-6;
y = polavg.range(r.lte_20);
z1 = real(log10(mask(r.lte_20,:).*polavg.attn_bscat(r.lte_20,:)));
ax(1) = subplot(2,1,1,'position',[0.10    0.5838    0.71    0.3412]); imagegap(x, y, z1); 
caxis(cv_log_bs); 
cb1 = colorbar;
set(cb1,'position',[0.858    0.5812    0.0524    0.3432]);
set(ax(1),'position',[0.10    0.5838    0.71    0.3412]);
ax1_pos = get(ax(1),'position');
cb1_pos = get(cb1,'position');
axis('xy'); 
% colormap(jet_rgb); 
colormap(comp_map3); 
% colormap(jet_bw)
set(ax(1),'TickDir','out');
% colormap('hijet');  
ylim([0,max(ranges)]); 
% cv_bs = 10.^cv_bs;
titlestr = ['log_1_0(attenuated backscattering ratio) for ',datestr(polavg.time(1), 'yyyy-mm-dd ')];
title(ax(1),titlestr);

ylabel('range (km)');
mask = ones(size(polavg.cop));
ldr_error = abs(polavg.ldr)./polavg.ldr_snr;
mask(polavg.ldr_snr<ldr_snr | ldr_error>ldr_error_limit) = NaN;
z2 = real(log10(mask(r.lte_20,:).*polavg.ldr(r.lte_20,:)));
ax(2) = subplot(2,1,2); 
imagegap(x, y, z2); 
axis('xy'); 
xlabel('time (local)');
% colormap('jet_rgb'); 
% colormap('hijet');
% colormap(comp_map3);
% colormap(jet_bw)
titlestr = ['log_1_0(linear depolarization ratio) for ',datestr(polavg.time(1), 'yyyy-mm-dd ')];
title(ax(2),titlestr);

caxis(cv_dpr); cb2 = colorbar;
cb2_pos = get(cb2,'position');
set(cb2,'position',[cb1_pos(1),cb2_pos(2),cb1_pos(3),cb2_pos(4)]);
ax2_pos = get(ax(2),'position');
set(ax(2),'position',[ax1_pos(1)    ax2_pos(2)    ax1_pos(3)    ax2_pos(4)]);
set(ax(2),'TickDir','out');
ylim([0,max(ranges)]); 
tick_label = get(cb2,'YTickLabel');
ytick = get(cb2,'YTick');

xl = xlim; xl = round(xl);
if xl(1)==xl(2) 
   xl(2) = xl(1)+1;
end
xlim(xl);

% title(['log_1_0(volume linear depolarization ratio) with ldr snr > ',num2str(ldr_snr)])
% ylabel('range (km)');
% xlabel('time (UTC)')


%  cmap = colormap(comp_map);
% cv_bs = [0,4000];
% The following lines are used in debug mode to manually adjust the color
% scales and to capture the settings for use throughout the rest of the
% function
caxis(ax(1),cv_log_bs);
cv_log_bs = caxis(ax(1));
cv_dpr = caxis(ax(2));
cmap = colormap;

[rgb,color_sqr] = rgb_weight(x,y,z2,z1,cmap,cv_dpr,cv_log_bs,0.3,mask(r.lte_20,:));
% ax(3) = subplot(3,1,3); 
figure(fig+1); 
set(fig+1,'visible',vis);
set(gcf,'position',[17          70        1043         319]);
ax2(1) = subplot('position',[0.0800    0.1500    0.560    0.7600]);
% set(ax2(1),'position',[0.0800    0.1500    0.560    0.7600])
ax2(2) = subplot('position',[0.6864    0.15    0.2500    0.76]);
% cb_1 = linspace(cv_dpr(1), cv_dpr(2),length(cmap));
% cb_2 = linspace(cv_bs(1),cv_bs(2),length(cmap))';
% zz1 = ones(size(cb_2))*cb_1;
% zz2 = cb_2*ones(size(cb_1));
% rgb_2 = rgb_weight(cb_1,cb_2,zz1',zz2',cmap,cv_dpr,cv_bs,.15);
axes(ax2(2));
imagegap(cv_log_bs,cv_dpr,color_sqr);
% image(10.^cv_bs,10.^cv_dpr,color_sqr);axis('xy');axis('square');logy; logx;
set(fig+1,'visible',vis);
% imagegap(cb_2',cb_1',rgb_2);
axis(ax2(2),'square');
title('composite colormap')
xlabel('log_1_0(atten bscat ratio)')
ylabel('log_1_0(ldr)')
set(gca,'YAxisLoc','right')
set(ax2(2),'TickDir','out');
% set(ax2(2),'position',[0.15    0.2    0.1567    0.2359])
% set(ax2(2),'xcolor','red','ycolor','red','color','red')

axes(ax2(1));
imagegap(x,y,rgb); 
set(fig+1,'visible',vis);
ylabel('range (km)');
set(ax2(1),'TickDir','out');
xlab = xlabel('time (local)');


titlestr = ['Composite image: backscatter (brightness), depolarization (color) ',[datestr(polavg.time(1), 'yyyy-mm-dd ')]];
% titlestr = ['Composite image: log10 of backscatter ratio (brightness), log10 of linear depolarization ratio (color) '];
title(ax2(1),titlestr, 'interpreter','none');

% set(ax2(1),'units','normalized');
% axv = get(ax2(1),'position');
% set(ax2(1),'position',[axv(1), axv(2), .8,.8]);


% csqr = colorsquare(cv_dpr, cv_bs,cmap);
% imagegap(cb_1,cb_2,y,csqr);


% set(gcf,'visible',vis) 
% axes(ax2(1))
% set(ax(3),'TickDir','out');
% ax2 = gca;


linkaxes([ax,ax2(1)],'xy');
% xl = xlim; xl = round(xl);
% if xl(1)==xl(2) 
%    xl(2) = xl(1)+1;
% end
xlim(xl);
xlim([6,18]);
% xlim(am_pm);
% set(cb,'YTickLabel',tick_label);
% set(cb,'YTick',ytick);
% fout_name = [inarg.fstem,datestr(polavg.time(1),'yyyymmdd'),'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.mat'];
% save([mat_dir, fout_name],'polavg', '-mat');


set(fig,'visible','on');
   fname1 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_2panel.',];
   saveas(fig, [fig_dir,filesep,fname1,'fig']);
%    set(fig,'visible',vis);

axes(ax2(1));
set(fig+1,'visible','on');
   fname2 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_composite.'];
   saveas(fig+1, [fig_dir,filesep,fname2,'fig']);
%    set(fig+1,'visible',vis);
   
for rr = fliplr(ranges)
% figure(1);set(gcf,'visible',vis)
   ylim([0,rr]);
   fname1 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_2panel.',num2str(rr),'km.'];
   fname2 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_composite.',num2str(rr),'km.'];
   if ~isempty(png_dir)
%       saveas(fig,[png_dir, filesep, fname1, 'emf']);
      saveas(fig,[png_dir, filesep, fname1, 'png']);
      set(fig+1, 'PaperPositionMode','auto');
%       saveas(fig+1,[png_dir, filesep, fname2, 'emf']);   
      saveas(fig+1,[png_dir, filesep, fname2, 'png']);
%        saveas(fig+1, [fig_dir,filesep,fname2,'fig']);
%       print(gcf, '-dpng', [png_dir, filesep, fname, 'png']) ;
   end
% figure(12);set(gcf,'visible',vis)
%    ylim([0,rr]);
%    fname = [fstem,'composite.',datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.',num2str(rr),'km.'];
%    if ~isempty(png_dir)
%       print(gcf, '-dpng', [png_dir, filesep, fname, 'png']) ;
%    end      
end
