function plot_AM_PM_pol(polavg,inarg)
% plot_AM_PM_pol(polavg,inarg)
% polavg contains averaged mplpol data
% inarg has the following optional elements 
% .matdir
% .pngdir 
% .figdir
% .Nsamples
% .ldr_snr

% Now plotting attenuated backscatter ratio (using std atm for Rayleigh)
if ~exist('polavg','var')
   polavg_file = getfullname('*.mat','polavg');
   polavg = loadinto(polavg_file);
end
if ~exist('inarg','var');
   inarg = [];
   Nsamples = 8;
   ldr_snr = 1;
   ldr_error_limit = .25;
   fstem = 'sgpmplpol_3flynn.';
else
   if isfield(inarg,'matdir')
      matdir = inarg.matdir;
   else
      matdir = [];
   end
   if isfield(inarg,'figdir')
      figdir = inarg.figdir;
   else
      figdir = [];
   end
   if isfield(inarg,'pngdir')
      pngdir = inarg.pngdir;
   else
      pngdir = [];
   end
   if isfield(inarg,'Nsamples')
      Nsamples = inarg.Nsamples;
   else
      Nsamples = 8;
   end
   if isfield(inarg,'ldr_snr')
      ldr_snr = inarg.ldr_snr;
   else
      ldr_snr = .5;
      ldr_error_limit = .15;
   end
   if isfield(inarg,'ldr_error_limit')
      ldr_error_limit = inarg.ldr_error_limit;
   else
         ldr_error_limit = .15;
   end
   if isfield(inarg,'fstem')
      fstem = inarg.fstem;
   else
      fstem = 'taihu_mplpol_1flynn.';
   end
end

%%
[pstr,fname,ext] = fileparts(polavg.statics.fname); fname = [fname, ext];
in_dir = [pstr,filesep];
pngdir = [in_dir, 'png',filesep];
figdir = [in_dir, 'fig',filesep];
matdir = [in_dir, 'mat',filesep];
% in_dir = ['C:\case_studies\ISDAC\MPL\MPL_raw\'];
if ~exist(pngdir, 'dir')
   mkdir(in_dir, 'png');
end
if ~exist(figdir, 'dir')
   mkdir(in_dir, 'fig');
end
if ~exist(matdir, 'dir')
   mkdir(in_dir, 'mat');
end

cv_bs = [2,5];
% cv_bs = [2,5]; % for ISDAC due to weaker signal compared to NIM.
cv_dpr = [-3,0];
%% Determine if we are plotting 0-12 or 12-24
if serial2Hh(polavg.time(1))>=12
   am_pm = [12,24];
   am_pm_str1 = '12-24 UTC';
   am_pm_str2 = '.12_24UTC';
else
   am_pm = [0,12];
   am_pm_str1 = '00-12 UTC';
   am_pm_str2 = '.00_12UTC';
end
max_hr = 24*(polavg.time(end)-polavg.time(1));
ranges = [15,10,5,2];

r.lte_15 = polavg.range>0 & polavg.range<=15;
if isfield(polavg,'std_attn_prof')
   std_attn_prof = polavg.std_attn_prof(polavg.r.lte_15);
else
   [std_attn_prof,tau, ray_tod] = std_ray_atten(polavg.range(polavg.r.lte_15));
end
mask = ones(size(polavg.cop));
mask(polavg.r.lte_15,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
% mask(polavg.cop_lin_snr>.05) = NaN;
end_time = floor(polavg.time(end));

figure(1); 
set(gcf,'visible','on');
set(gcf,'position',[18    72   658   708]);
x = 24*(polavg.time-floor(polavg.time(1)));
y = polavg.range(r.lte_15);
z1 = real(log10(mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:)));
ax(1) = subplot(2,1,1); imagegap(x, y, z1); 
axis('xy'); colormap('jet'); 
set(ax(1),'TickDir','out');
% colormap('hijet');  
ylim([0,max(ranges)]); 
caxis(cv_bs); colorbar;
titlestr = ['Attenuated backscatter:  ',datestr(polavg.time(1), 'yyyy-mm-dd '),am_pm_str1];
title(ax(1),titlestr, 'interpreter','none');


ylabel('range (km)')
mask = ones(size(polavg.cop));
ldr_error = abs(polavg.ldr)./polavg.ldr_snr;
mask(polavg.ldr_snr<ldr_snr | ldr_error>ldr_error_limit) = NaN;
% z2 = real(log10(mask(r.lte_15,:).*polavg.d(r.lte_15,:)));
z2 = real(log10(mask(r.lte_15,:).*polavg.ldr(r.lte_15,:)));
ax(2) = subplot(2,1,2); 
imagegap(x, y, z2); 
axis('xy'); colormap('jet'); 
set(ax(2),'TickDir','out');
ylim([0,max(ranges)]); 

xl = xlim; xl = round(xl);
if xl(1)==xl(2) 
   xl(2) = xl(1)+1;
end
xlim(xl);
% colormap('hijet');  
caxis(cv_dpr); cb_d = colorbar;
tick_label = get(cb_d,'YTickLabel');
ytick = get(cb_d,'YTick');
% title(['log_1_0(volume linear depolarization ratio) with ldr snr > ',num2str(ldr_snr)])
% ylabel('range (km)');
% xlabel('time (UTC)')


%  cmap = colormap(comp_map);
cmap = colormap;
[rgb] = rgb_weight(x,y,z2,z1,cmap,cv_dpr,cv_bs,0.2,mask(r.lte_15,:));
% ax(3) = subplot(3,1,3); 
figure(2); 
ax2(2) = subplot(1,2,2);
ax2(1) = subplot(1,2,1);
imagegap(x,y,rgb); 
xlabel('time (UTC)')
ylabel('range (km)')
title('composite backscatter/ldr')
set(ax2(1),'units','normalized');
axv = get(ax2(1),'position');
set(ax2(1),'position',[axv(1), axv(2), .8,.8]);


% csqr = colorsquare(cv_dpr, cv_bs,cmap);
% imagegap(cb_1,cb_2,y,csqr);

cb_1 = linspace(cv_dpr(1), cv_dpr(2),length(cmap));
cb_2 = linspace(cv_bs(1),cv_bs(2),length(cmap))';
zz1 = ones(size(cb_2))*cb_1;
zz2 = cb_2*ones(size(cb_1));
rgb_2 = rgb_weight(cb_1,cb_2,zz1',zz2',cmap,cv_dpr,cv_bs);
ylabel('range (km)');
xlabel('time (UTC)')
% titlestr = {'Composite image: backscatter (brightness), depolarization (color) ',[datestr(polavg.time(1), 'yyyy-mm-dd '),am_pm_str1]};
titlestr = ['Composite image: backscatter (brightness), depolarization (color) '];
title(ax2(1),titlestr, 'interpreter','none');

axes(ax2(2));
imagegap(cb_2',cb_1',rgb_2);
axis('square')
xlabel('backscatter','color','red')
ylabel('log_1_0(dpr)','color','red')
set(gca,'YAxisLoc','right')
set(ax2(2),'position',[0.15    0.2    0.1567    0.2359])
set(ax2(2),'xcolor','red','ycolor','red','color','red')


% set(gcf,'visible','off') 
% axes(ax2(1))
% set(ax(3),'TickDir','out');
% ax2 = gca;


linkaxes([ax,ax2(1)],'xy');
xl = xlim; xl = round(xl);
if xl(1)==xl(2) 
   xl(2) = xl(1)+1;
end
xlim(xl);
xlim(am_pm);
% set(cb,'YTickLabel',tick_label);
% set(cb,'YTick',ytick);
axes(ax2(2))
for rr = ranges
% figure(1);set(gcf,'visible','off')
   ylim([0,rr]);
   fname = [fstem,'bs_comp.',datestr(polavg.time(1), 'yyyy-mm-dd'),am_pm_str2,'.',num2str(rr),'km.'];
   if ~isempty(pngdir)
      print(gcf, '-dpng', [pngdir, filesep, fname, 'png']) ;
   end
% figure(12);set(gcf,'visible','off')
%    ylim([0,rr]);
%    fname = [fstem,'composite.',datestr(polavg.time(1), 'yyyy-mm-dd'),am_pm_str2,'.',num2str(rr),'km.'];
%    if ~isempty(pngdir)
%       print(gcf, '-dpng', [pngdir, filesep, fname, 'png']) ;
%    end      
end


