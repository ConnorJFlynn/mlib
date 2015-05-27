function kassianov_MPL_plots;
% MPLplots for Kassianov for cloud fraction paper


stem = ['C:\case_studies\mplpolavg\mat\'];
%%
figure(1); 


% First column plot outerwidths 0.4417    0.1526
% Second column plot outerwidths 0.4417    0.1526
sb(1) = subplot(4,2,1);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070624.doy175.mat']);
bs_lst(sb(1),mpl);
% first row anchor

set(sb(1),'XTicklabel',[]);
%%
tx = text( .03,0.8617,'2007-06-24','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');
%%
ylabel('range (km)')

sb(3) = subplot(4,2,3);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070716.doy197.mat']);
bs_lst(sb(3),mpl);
set(sb(3),'XTicklabel',[]);
tx = text(.03,0.8617,'2007-07-16','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');
ylabel('range (km)')

sb(5) = subplot(4,2,5);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070717.doy198.mat']);
bs_lst(sb(5),mpl);
set(sb(5),'XTicklabel',[]);
tx = text(.03,0.8617,'2007-07-17','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');
ylabel('range (km)')

sb(7) = subplot(4,2,7);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070718.doy199.mat']);
bs_lst(sb(7),mpl);
tx = text(.03,0.8617,'2007-07-18','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');
ylabel('range (km)')
xlabel('Time (CST), hour');

sb(2) = subplot(4,2,2);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070720.doy201.mat']);
bs_lst(sb(2),mpl); 
set(sb(2),'XTicklabel',[],'YTicklabel',[]);
tx = text(.03,0.8617,'2007-07-20','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');

sb(4) = subplot(4,2,4);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070721.doy202.mat']);
bs_lst(sb(4),mpl);
set(sb(4),'XTicklabel',[],'YTicklabel',[]);
tx = text(.03,0.8617,'2007-07-21','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');

sb(6) = subplot(4,2,6);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070828.doy240.mat']);
bs_lst(sb(6),mpl);
set(sb(6),'XTicklabel',[],'YTicklabel',[]);
tx = text(.03,0.8617,'2007-08-28','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');

sb(8) = subplot(4,2,8);
set(sb(8),'YTicklabel',[]);
mpl = loadinto([stem, 'sgp_mplpol_3flynn.20070831.doy243.mat']);
bs_lst(sb(8),mpl);
set(sb(8),'YTicklabel',[]);
tx = text(.03,0.8617,'2007-08-31','units','norm','fontname','Tahoma','fontsize',8,'color','black','fontweight','demi','background','white');
xlabel('Time (CST), hour');
%%
% Set 

XY = get(sb(1),'position'); Y(1) = XY(2); old_X(1) = XY(1);
XY = get(sb(2),'position'); old_X(2) = XY(1);
XY = get(sb(3),'position'); Y(2) = XY(2);
XY = get(sb(5),'position'); Y(3) = XY(2);
XY = get(sb(7),'position'); Y(4) = XY(2);
%%
WxH = [0.44, 0.1526];
WxH_= [0.4417, 0.2186];
new_X(1) = old_X(1)./2;
new_X(2) = old_X(2) - (old_X(1)-new_X(1))./2;
set(sb(1),'position',[new_X(1),Y(1),WxH]);
set(sb(3),'position',[new_X(1), Y(2),WxH]);
set(sb(5),'position',[new_X(1), Y(3),WxH]);
set(sb(7),'position',[new_X(1), Y(4),WxH]);

set(sb(2),'position',[new_X(2),Y(1),WxH]);
set(sb(4),'position',[new_X(2), Y(2),WxH]);
set(sb(6),'position',[new_X(2), Y(3),WxH]);
set(sb(8),'position',[new_X(2), Y(4),WxH]);


%%
linkaxes(sb,'xy');
xlim([9,18]);
ylim([0,10]);
%%

return

function ax = bs_lst(ax,polavg)
if ~exist('inarg','var');
   inarg = [];
   cop_snr = 2;
   ldr_snr = 1.5;
   ldr_error_limit = .25;
   cv_log_bs = [1.5,4.5]; 
   cv_dpr = [-2,0];
   ranges = [15,5,2];
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
      vis = 'on';
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
      ranges = [10,5];
   end

%    vis = 'off';
%%
[pstr,fname,ext] = fileparts(polavg.statics.fname); fname = [fname, ext];
% in_dir = [pstr,filesep];
% if strcmp([filesep,'mat',filesep],in_dir(end-4:end))
%    in_dir(end-3:end) = [];
% end
% png_dir = [in_dir, 'png',filesep];
% fig_dir = [in_dir, 'fig',filesep];
% mat_dir = [in_dir, 'mat',filesep];
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

set(gcf,'visible',vis);
set(gcf,'position',[93,71,1089,666]);

%set(gcf,'position',[1          29        1440         805]);
% 
%Convert to local time
x = 24*(polavg.time-floor(polavg.time(1)))-6;
y = polavg.range(r.lte_20);
z1 = real(log10(mask(r.lte_20,:).*polavg.attn_bscat(r.lte_20,:)));
axes(ax); 
imagegap(x, y, z1); 
caxis(cv_log_bs); 
% cb1 = colorbar;
% set(cb1,'position',[0.858    0.5812    0.0524    0.3432]);
% set(ax(1),'position',[0.10    0.5838    0.71    0.3412]);
ax1_pos = get(ax(1),'position');
% cb1_pos = get(cb1,'position');
axis('xy'); 
% colormap(jet_rgb); 
colormap(comp_map3); 
% colormap(jet_bw)
set(ax,'TickDir','out');
set(ax,'fontname','Tahoma','fontweight','bold');
% colormap('hijet');  
ylim([0,max(ranges)]); 
% cv_bs = 10.^cv_bs;
% titlestr = ['log_1_0(attenuated backscattering ratio) for ',datestr(polavg.time(1), 'yyyy-mm-dd ')];
% title(ax(1),titlestr);

% ylabel('range (km)');

return

