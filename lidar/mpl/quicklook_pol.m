function quicklook_pol(polavg,inarg)
% quicklook_pol(polavg,inarg)
% polavg contains averaged mplpol data
% inarg has the following optional elements 
% .matdir
% .pngdir 
% .figdir
% .Nsamples
% .ldr_snr

% Now plotting attenuated backscatter ratio (using std atm for Rayleigh)

if ~exist('inarg','var');
   inarg = [];
   Nsamples = 8;
   ldr_snr = .5;
   ldr_error_limit = .15;
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
      fstem = 'sgp_mplpol_1flynn.';
   end
end

%%
[pstr,fname,ext] = fileparts(polavg.statics.fname); fname = [fname, ext];
in_dir = pstr;
pngdir = [in_dir,filesep, 'png',filesep];
figdir = [in_dir,filesep, 'fig',filesep];
matdir = [in_dir,filesep, 'mat',filesep];
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

cv_bs = [3,7];
cv_dpr = [-2,0];
%% Determine if we are plotting 0-12 or 12-24
if mod(mean(polavg.time),1)>.5
   am_pm = [12,24];
   am_pm_str1 = '12-24 UTC';
   am_pm_str2 = '.12_24UTC';
else
   am_pm = [0,12];
   am_pm_str1 = '00-12 UTC';
   am_pm_str2 = '.00_12UTC';
end
max_hr = 24*(polavg.time(end)-polavg.time(1));
hours = [12,3,1];
ranges = [15,10,5,2,1,0.5];


r.lte_15 = polavg.range>0 & polavg.range<=15;

[std_attn_prof,tau, ray_tod] = std_ray_atten(polavg.range(polavg.r.lte_15));

mask = ones(size(polavg.cop));
mask(polavg.r.lte_15,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
% mask(polavg.cop_lin_snr>.05) = NaN;
end_time = floor(polavg.time(end));

figure(1); 
set(gcf,'visible','on')
ax(1) = subplot(2,1,1); imagegap(24*(polavg.time-end_time), polavg.range(r.lte_15), real(log10(mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:)))); axis('xy'); colormap('jet'); 
colormap('hijet');  ylim([0,max(ranges)]); 
caxis(cv_bs); colorbar;

ylabel('range (km)')
mask = ones(size(polavg.cop));
ldr_error = abs(polavg.ldr)./polavg.ldr_snr;
mask(polavg.ldr_snr<ldr_snr | ldr_error>ldr_error_limit) = NaN;
ax(2) = subplot(2,1,2); imagegap(24*(polavg.time-end_time), polavg.range(r.lte_15), real(log10(mask(r.lte_15,:).*polavg.ldr(r.lte_15,:)))); axis('xy'); colormap('jet'); 
ylim([0,max(ranges)]); 

% xl = xlim; xl = round(xl);
% if xl(1)==xl(2) 
%    xl(2) = xl(1)+max_hr;
% end
% xlim(xl);
colormap('hijet');  caxis(cv_dpr); colorbar;
title(['log_1_0(volume linear depolarization ratio) with ldr snr > ',num2str(ldr_snr)])
ylabel('range (km)');
xlabel('time (UTC)')
linkaxes(ax,'xy');
 xl = xlim; 
% xl = round(xl);
% if xl(1)==xl(2) 
%    xl(2) = xl(1)+max_hr;
% end
xlim(xl);

for rr = ranges
   for hh = hours
      ylim([0,rr]);
      xl2 = [xl(2)-hh,xl(2)];
      xlim(xl2);
      titlestr = ['Attenuated backscatter:  ',datestr(polavg.time(end)-hh/24, 'yyyy-mm-dd HH:MM'), ' to ', datestr(polavg.time(end), 'yyyy-mm-dd HH:MM')];
      title(ax(1),titlestr, 'interpreter','none');
      fname = [fstem,num2str(hh),'hr.',num2str(rr),'km.'];
      if ~isempty(figdir)
         saveas(gcf,  [figdir, filesep, fname, 'fig'],'fig') ;
      end
      if ~isempty(pngdir)
         print(gcf, '-dpng', [pngdir, filesep, fname, 'png']) ;
      end
   end

   xlim(am_pm);
   titlestr = ['Attenuated backscatter:  ',datestr(polavg.time(end), 'yyyy-mm-dd '),am_pm_str1];
   title(ax(1),titlestr, 'interpreter','none');
   fname = [fstem,datestr(polavg.time(end), 'yyyy-mm-dd'),am_pm_str2,'.',num2str(rr),'km.'];
   if ~isempty(pngdir)
      print(gcf, '-dpng', [pngdir, filesep, fname, 'png']) ;
   end
end


