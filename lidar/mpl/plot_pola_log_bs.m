function polavg = plot_pola_log_bs(polavg,inarg)
% plot_pola_log_bs(polavg,inarg)
% "pola" denotes using 'alpha' for transparency instead of rgb/hsv etc.
% polavg contains averaged mplpol data
% inarg has the following optional elements 
% .mat_dir
% .png_dir 
% .fig_dir
% .cop_snr = 4;
% .ldr_snr = 5;
% .ldr_error_limit = 1;
% .cv_log_bs = [2,4];
% .cv_dpr = [-2.25,0];%    
% Now plotting attenuated backscatter ratio (using std atm for Rayleigh)
if ~exist('polavg','var')
   polavg_file = getfullname('*.mat','polavg');
   polavg = loadinto(polavg_file);
   polavg.statics.fname = polavg_file;
end
% [pname, fname, ext] = fileparts(polavg_file); pname = [pname, filesep];
if ~exist('inarg','var');
   inarg = [];
end

   if isfield(inarg,'cv_log_bs')
      cv_log_bs = inarg.cv_log_bs;
   else
      cv_log_bs = [2,6];
   end
   if isfield(inarg,'cop_snr')
      cop_snr = inarg.cop_snr;
   else
      cop_snr = 2;
   end
   if isfield(inarg,'cv_dpr')
      cv_dpr = inarg.cv_dpr;
   else
      cv_dpr = [-1.5,0];
   end
   if isfield(inarg,'ldr_snr')
      ldr_snr = inarg.ldr_snr;
   else
      ldr_snr = 1.5;
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
   if isfield(inarg,'fig')&&isgraphics(inarg.fig)
      fig = inarg.fig;
   else
      fig = 54;
   end
   if isfield(inarg,'plot_ranges')
      ranges = inarg.plot_ranges;
   else
      ranges = [15,5,2];
   end
% end
   vis = 'on';
%%
[pstr,fname,ext] = fileparts(polavg.statics.fname); fname = [fname, ext];
in_dir = [pstr,filesep]; [~,ds] = fileparts(fname);  [ds_,ds] = strtok(ds,'.');ds_ = [ds_,'.',strtok(ds,'.')];
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

if ~isfield(polavg.r, 'lte_25')
    polavg.r.lte_25 = polavg.range>0 & polavg.range<=25;
end
r.lte_25 = polavg.r.lte_25;
if isfield(polavg,'std_attn_prof')
   std_attn_prof = polavg.std_attn_prof(polavg.r.lte_25);
else
   [std_attn_prof,tau, ray_tod] = std_ray_atten(polavg.range(polavg.r.lte_25));
end

end_time = floor(polavg.time(end));

if isstruct(fig)
    figure_(fig.Number);
else
    figure_(fig);
end;
set(gcf,'visible',vis);

loop = true;
while loop
   if isfield(inarg,'manual_limits')&&inarg.manual_limits
      set(gcf,'visible','on');
      loop = true;
   else
      loop = false;
   end
   aloop = loop;
   mask = ones(size(polavg.cop));

%    mask(polavg.r.lte_25,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
   mask(polavg.r.lte_25,:) = 1;

   mask(polavg.cop_snr<cop_snr) = NaN;
   set(gcf,'position',[18    72   819   708]);
   x = 24*(polavg.time-floor(polavg.time(1)));
   y = polavg.range(r.lte_25);

%    z1 = real(log10(mask(r.lte_25,:).*polavg.attn_bscat(r.lte_25,:)));
   z1 = mask(r.lte_25,:).*polavg.attn_bscat(r.lte_25,:);
   z1 = z1./(std_attn_prof*ones([1,length(polavg.time)]));
   z1 = real(log10(z1));
   ax(1) = subplot(2,1,1); set(ax(1),'position',[0.10    0.5838    0.71    0.3412]); 

   imagegap(x, y, z1);
   cb1 = colorbar;
      caxis(cv_log_bs);
   set(cb1,'position',[0.858    0.5812    0.0524    0.3432]);
   set(ax(1),'position',[0.10    0.5838    0.71    0.3412]);
   ax1_pos = get(ax(1),'position');
   cb1_pos = get(cb1,'position');
   axis('xy');
%    colormap(jet_rgb);
%    colormap(comp_map3);
   % colormap(jet_bw)
   set(ax(1),'TickDir','out');
   colormap('hijet');
   ylim([0,max(ranges)]);
   % cv_bs = 10.^cv_bs;
   hold('on');
   plot(0, 0,'w.'); legend(['log_1_0(attenuated backscattering ratio)'],'location','northwest');
   hold('off')
   titlestr = {[ds_, datestr(polavg.time(1), ', yyyy-mm-dd ')]};
   tl = title(ax(1),titlestr); set(tl,'units','normalized');
   pos = get(tl,'position');pos(2) = 1; set(tl,'position', pos);
   ylabel('range (km)');
   
   mask = ones(size(polavg.cop));
   ldr_error = abs(polavg.ldr)./polavg.ldr_snr;
   mask(polavg.ldr_snr<ldr_snr | ldr_error>ldr_error_limit) = NaN;
   z2 = real(log10(mask(r.lte_25,:).*polavg.ldr(r.lte_25,:)));
   ax(2) = subplot(2,1,2);
   imagegap(x, y, z2);
   axis('xy');
   xlabel('time (UTC)');
   ylabel('range (km)');   
   % colormap('jet_rgb');
   % colormap('hijet');
   % colormap(comp_map3);
   % colormap(jet_bw)
   titlestr = {[ds_, datestr(polavg.time(1), ', yyyy-mm-dd ')]};
   hold('on');
   plot(0, 0,'w.'); legend(['log_1_0(linear depolarization ratio)'],'location','northwest');
   hold('off')
   tl = title(ax(2),titlestr); set(tl,'units','normalized');
   
  cb2 = colorbar;
   caxis(cv_dpr); 
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
   
   if loop
      loop = logical(menu('Are the caxis settings OK?','Yes, they''re good.','No, let''s adjust them')-1);
      if loop
         % cv_log_bs
         c_log_bs = input(sprintf('Enter lower limit for log(bs): <%g> ',cv_log_bs(1)));
         if ~isempty(c_log_bs)&&isnumeric(c_log_bs)&&c_log_bs<cv_log_bs(2)
            cv_log_bs(1) = c_log_bs;
         end
         c_log_bs = input(sprintf('Enter upper limit for log(bs): <%g> ',cv_log_bs(2)));
         if ~isempty(c_log_bs)&&isnumeric(c_log_bs)&&c_log_bs>cv_log_bs(1)
            cv_log_bs(2) = c_log_bs;
         end
         % cop_snr 
         cop_sn = input(sprintf('Enter cop snr min limit: <%g> ',cop_snr));
         if ~isempty(cop_sn)&&isnumeric(cop_sn)
            cop_snr = cop_sn;
         end
         
         c_dpr = input(sprintf('Enter lower limit for dpr: <%g> ',cv_dpr(1)));
         if ~isempty(c_dpr)&&isnumeric(c_dpr)&&c_dpr<cv_dpr(2)
            cv_dpr(1) = c_dpr;
         end
         c_dpr = input(sprintf('Enter upper limit for dpr: <%g> ',cv_dpr(2)));
         if ~isempty(c_dpr)&&isnumeric(c_dpr)&&c_dpr>cv_dpr(1)
            cv_dpr(2) = c_dpr;
         end
         % ldr_snr | ldr_error_limit
         ldr_sn = input(sprintf('Enter ldr snr min limit: <%g> ',ldr_snr));
         if ~isempty(ldr_sn)&&isnumeric(ldr_sn)
            ldr_snr = ldr_sn;
         end
         ldr_error_lim = input(sprintf('Enter ldr error max limit: <%g> ',ldr_error_limit));
         if ~isempty(ldr_error_lim)&&isnumeric(ldr_error_lim)
            ldr_error_limit = ldr_error_lim;
         end
      else
         inarg.cv_log_bs = cv_log_bs;
         inarg.cop_snr = cop_snr;
         inarg.cv_dpr = cv_dpr;
         inarg.ldr_snr = ldr_snr;
         inarg.ldr_error_limit = ldr_error_limit;
         polavg.inarg = inarg;
      end
      
   end
end


% The following lines are used in debug mode to manually adjust the color
% scales and to capture the settings for use throughout the rest of the
% function
caxis(ax(1),cv_log_bs);
caxis(ax(2),cv_dpr);
% cv_log_bs = caxis(ax(1));
% cv_dpr = caxis(ax(2));

cmap = colormap;

 comp = comp_image(x,y,z2, z1,cv_dpr,cv_log_bs, mask(r.lte_25,:));
  %  %Brightens set(img99, 'alphadata',get(img99, 'alphadata').^(.75));
 titlestr = {[ds_, datestr(polavg.time(1), ', yyyy-mm-dd ')]};
 ax2 = comp.axs;
tl = title(ax2(1),titlestr)
linkaxes([ax,ax2(1)],'xy');

xlim(xl);

% colormap(comp_map3);
cmap = colormap;

% fig_comp = figure_(double(gcf)+1); 
% ax2(1) = subplot(1,2,1);
% ax2(2) = subplot(1,2,2); 
% cv_z = cv_dpr; cv_a = cv_log_bs;
% col_sqr = (ones([length(colormap),1])*linspace(cv_z(1), cv_z(2), length(colormap)))'; 
% alpha_sqr =(ones([length(colormap),1])*linspace(0, 1, length(colormap)));
% img = imagesc(cv_a, cv_z,col_sqr); caxis(cv_z); 
% axis(ax2(2),'square','xy');
% axes(ax2(1)); 
% set(ax2(2),'YAxisLocation','right');
% s1_pos = get(ax2(1), 'position'); 
% s2_pos = get(ax2(2),'position');
% s1_pos_ = s1_pos; s2_pos_ = s2_pos; 
% s2_pos_(1) = s2_pos_(1) + s2_pos(3)./2; s2_pos_(3) = s2_pos(3)./2 ;
% set(ax2(2),'position',s2_pos_); 
%  xt = xlabel(ax2(2),'Log_1_0(bscat)');set(xt,'interp','Tex') ;
%  yt = ylabel(ax2(2),'Log_1_0(ldr)'); set(yt, 'interp','Tex');
% %  tl = title('color square')
% 
% set(img,'alphadata',alpha_sqr);set(ax2(2),'color','k')
% 
% dx = (s2_pos(1) - s1_pos(1)-s1_pos(3));
% s1_pos_(3) = s2_pos_(1) - dx -.05;
% s1_pos_(1) = s1_pos(1).*(.75); s1_pos_(2) = s1_pos(2)+.05;s1_pos_(4) = s1_pos(4)-.05;
% set(ax2(1), 'position',s1_pos_);
% axes(ax2(1));
% 
%  [comp2] = comp_image(x,y,z2, z1, cv_dpr,cv_log_bs, mask(r.lte_25,:));
%  xlabel('time [UTC]'); ylabel('range [km]');
%  caxis(cv_dpr);
%   tx = text(.5, .5, ['Composite of backscatter & dpr']); 
%  set(tx,'color','w')
% set(tx,'units','normalized');set(tx,'position',[.02,.95,0])
 titlestr = {[ds_, datestr(polavg.time(1), ', yyyy-mm-dd ')]};
tl = title(titlestr)
 %  %Brightens set(img99, 'alphadata',get(img99, 'alphadata').^(.75));
set(comp.fig,'InvertHardcopy','off');
% linkaxes([ax,ax2(1)],'xy');
% colormap(comp_map3);
% xlim(xl);
% set(fig,'InvertHardcopy','off');
% 

set(fig,'visible','on');
   fname1 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_2panel.',];
   saveas(fig, [fig_dir,filesep,fname1,'fig']);
%    set(fig,'visible',vis);

axes(ax2(1));
set(double(fig)+1,'visible','on');
   fname2 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_composite.'];
   saveas(double(fig)+1, [fig_dir,filesep,fname2,'fig']);
%    set(double(fig)+1,'visible',vis);
   
for rr = fliplr(ranges)
% figure(1);set(gcf,'visible',vis)
   ylim([0,rr]);
   fname1 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_2panel.',num2str(rr),'km.'];
   fname2 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_composite.',num2str(rr),'km.'];
   if ~isempty(png_dir)
%       saveas(fig,[png_dir, filesep, fname1, 'emf']);
      saveas(fig,[png_dir, filesep, fname1, 'png']);
      set(double(fig)+1, 'PaperPositionMode','auto');
%       saveas(double(fig)+1,[png_dir, filesep, fname2, 'emf']);   
      saveas(double(fig)+1,[png_dir, filesep, fname2, 'png']);
%        saveas(double(fig)+1, [fig_dir,filesep,fname2,'fig']);
%       print(gcf, '-dpng', [png_dir, filesep, fname, 'png']) ;
   end   
end

return
% This text won't run because it is after RETURN but you can put a
% stop above and then run it by hand to examine collimation.

i = 0;
clear hr_ avg_
all_done = false;
while ~all_done
   mn_0 = menu('Select one or more periods to assess collimation?','Yes','No, skip'); sleep(.1)
   if mn_0 ==1
      i = i+1;       hr_(i,:) = false(size(polavg.time));
      done_looping = false;
      while ~done_looping
         mn = menu({'Zoom in to a period of time with clear air.';...
            'Select "Ready" to add the displayed times to the current average';...
            'Or "Done" to complete this average.'},'Ready','Done');
         if mn==1
            xl = xlim; hr_(i,:) = hr_(i,:) | serial2hs(polavg.time)>xl(1)&serial2hs(polavg.time)<xl(2);sum(hr_(i,:))
            avg_(i,:) = mean(polavg.attn_bscat(:,hr_(i,:)),2);
            cal_r = polavg.range>8 & polavg.range<10;
            cal_mean = mean(mean(avg_(:,cal_r)))./mean(polavg.std_attn_prof(cal_r));
            figure(9);plot(polavg.range,avg_ ,'-',polavg.range,cal_mean.*polavg.std_attn_prof,'--');logy
         else
            done_looping = true;
         end
      end
   elseif mn_0 ==2
      all_done = true;
   end
end
cal_means = mean(avg_(:,cal_r)./(ones([size(avg_,1),1])*(polavg.std_attn_prof(cal_r)')),2);
figure(9);plot(polavg.range,avg_ ,'-',polavg.range,cal_means*polavg.std_attn_prof','--');logy;
title({['Collimation and overlap assessment for ',upper(inarg.tla(1:3)), ' ',upper(inarg.tla(4:end))];...
   datestr(polavg.time(1),'yyyy-mm-dd')});
ylabel('NRB [MHz]'); xlabel('range [km]');
saveas(gcf,[inarg.tla,'_mplpol_3flynn.collimation.',datestr(polavg.time(1),'yyyy_mm_dd'),'.fig'])