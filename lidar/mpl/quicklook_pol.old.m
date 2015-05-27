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
   ldr_snr = .125;
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
      ldr_snr = .125;
   end
end
%%

% figure(2);
r.lte_15 = polavg.range>0 & polavg.range<=15;
% figure(9); 
% end_time = floor(polavg.time(end));
[std_attn_prof,tau, ray_tod] = std_ray_atten(polavg.range(polavg.r.lte_15));
% imagegap((polavg.time-end_time)*24, polavg.range(polavg.r.lte_15), real((polavg.attn_bscat(polavg.r.lte_15,:)))./(std_attn_prof*ones([1,length(polavg.time)]))); axis('xy'); colormap('jet'); 
% colormap('hijet');  ylim([0,15]); 
% caxis([100,3000]); colorbar;

mask = ones(size(polavg.cop));
mask(polavg.r.lte_15,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
% mask(polavg.cop_lin_snr>.05) = NaN;
end_time = floor(polavg.time(end));
figure(1); ax(1) = subplot(2,1,1); imagegap((polavg.time-end_time)*24, polavg.range(r.lte_15), real(log10(mask(r.lte_15,:).*polavg.attn_bscat(r.lte_15,:)))); axis('xy'); colormap('jet'); 
colormap('hijet');  ylim([0,15]); 
caxis([2,6]); colorbar;
[pstr,fname,ext] = fileparts(polavg.statics.fname); fname = [fname, ext];
titlestr = ['Attenuated backscatter:  ',datestr(polavg.time(end), 'yyyy-mm-dd HH:MM'), ' to ', datestr(polavg.time(end), 'yyyy-mm-dd HH:MM')];
title(titlestr, 'interpreter','none')
ylabel('range (km)')
mask = ones(size(polavg.cop));
mask(polavg.ldr_snr<ldr_snr) = NaN;
ax(2) = subplot(2,1,2); imagegap((polavg.time-end_time)*24, polavg.range(r.lte_15), real(log10(mask(r.lte_15,:).*polavg.ldr(r.lte_15,:)))); axis('xy'); colormap('jet'); 
ylim([0,15]); xl = xlim; xlim(round(xl));
colormap('hijet');  caxis([-2,0]); colorbar;
title(['log_1_0(volume linear depolarization ratio) with ldr snr > ',num2str(ldr_snr)])
ylabel('range (km)');
xlabel('time (UTC)')
linkaxes(ax,'xy');

scp_str = ['C:\progra~1\putty\pscp.exe'];
% scp_str = [' c:\cygwin\bin\scp.exe '];
% key_str = [' -i c:\ISDAC\nsamplpolC1.00\nsampl.key '];
key_str = [' -i C:\progra~1\putty\science_ssh\isdac_science.ppk '];
sci_key = [' cflynn@science.arm.gov:/home/cflynn/science_html/ISDAC/MPL_images/'];
% png_str = [' /cygdrive/c/ISDAC/nsamplpolC1.00/processed/png/'];
% png_str = [' C:\ISDAC\192.148.94.8\processed\png\'];

fname = 'nsamplps.15km.8hr';
fname = [fname,datestr(polavg.time(end), '.yyyymmdd_HH')];
if ~isempty(matdir)
%     save([matdir, filesep, fname, '.mat'],'polavg')
end
if ~isempty(figdir)
    saveas(gcf,  [figdir, filesep, fname, '.fig'],'fig') ;
end
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     pause(.1)
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

fname = 'recent.15km.8hr';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end


ylim([0,10]);
fname = 'nsamplps.10km.8hr';
fname = [fname,datestr(polavg.time(end), '.yyyymmdd_HH'),];
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end
fname = 'recent.10km.8hr';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

ylim([0,2]);
fname = 'nsamplps.2km.8hr';
fname = [fname,datestr(polavg.time(end), '.yyyymmdd_HH'),];
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end
fname = 'recent.2km.8hr';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

ylim([0,4]);
fname = 'nsamplps.4km.8hr';
fname = [fname,datestr(polavg.time(end), '.yyyymmdd_HH'),];
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end
fname = 'recent.4km.8hr';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

%Reduce range of x-axis
xl = xlim;
xl2 = [xl(2)-3,xl(2)];
xlim(xl2);

fname = 'recent.15km';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

ylim([0,10]);
fname = 'nsamplps.10km';
fname = [fname,datestr(polavg.time(end), '.yyyymmdd_HH'),];
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end
fname = 'recent.10km';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

ylim([0,2]);
fname = 'nsamplps.2km';
fsfname = [fname,datestr(polavg.time(end), '.yyyymmdd_HH'),];
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end
fname = 'recent.2km';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

ylim([0,4]);
fname = 'nsamplps.4km';
fname = [fname,datestr(polavg.time(end), '.yyyymmdd_HH'),];
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end
fname = 'recent.4km';
if ~isempty(pngdir)
    print(gcf, '-dpng', [pngdir, filesep, fname, '.png']) ;
%     [s,w] =system([scp_str, key_str, pngdir, fname,'.png ', sci_key, fname,'.png ']);
end

%%

% figure; semilogy(range, cop_snr(:,10),'g',range, cross_snr(:,10),'r',range, dpr_snr(:,10),'k')
disp('done saving images')
