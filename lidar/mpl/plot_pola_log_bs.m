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
% As of 2022-10-29 This is a draft version replacing the dpr panel with the
% transparency plot thus saving only one fig.
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



   if isfield(inarg,'manual_plot_settings')&&inarg.manual_plot_settings
      set(gcf,'visible','on');
      loop = true;
   else
      loop = false;
   end
   cv_loop = loop;
   mask_loop = loop;
   mask = ones(size(polavg.cop));

   %    mask(polavg.r.lte_25,:) = 1./(std_attn_prof*ones([1,length(polavg.time)]));
   mask(polavg.r.lte_25,:) = 1;

   mask(polavg.cop_snr<cop_snr) = NaN;
   %    set(gcf,'position',[18    72   819   708]);
   x = 24*(polavg.time-floor(polavg.time(1)));
   y = polavg.range(r.lte_25);

   %    z1 = real(log10(mask(r.lte_25,:).*polavg.attn_bscat(r.lte_25,:)));
   z1 = polavg.attn_bscat(r.lte_25,:);
   z1 = z1./(std_attn_prof*ones([1,length(polavg.time)]));
   z1 = real(log10(z1));
   ax(1) = subplot(2,1,1); %set(ax(1),'position',[0.10    0.5838    0.71    0.3412]);

   imagegap(x, y, mask(r.lte_25,:).*z1);
   cb1 = colorbar;
   caxis(cv_log_bs);
%    set(cb1,'position',[0.858    0.5812    0.0524    0.3432]);
   %set(ax(1),'position',[0.10    0.5838    0.71    0.3412]);
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
   mask(polavg.ldr_snr<ldr_snr) = NaN;
   z2 = real(log10(polavg.ldr(r.lte_25,:)));
   ax(2) = subplot(2,1,2);
   [~,img] = imagegap(x, y, mask(r.lte_25,:).*z2);
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
 

   cb2 = colorbar;
   caxis(cv_dpr);
   cb2_pos = get(cb2,'position');
%    set(cb2,'position',[cb1_pos(1),cb2_pos(2),cb1_pos(3),cb2_pos(4)]);
%    ax2_pos = get(ax(2),'position');
%    set(ax(2),'position',[ax1_pos(1)    ax2_pos(2)    ax1_pos(3)    ax2_pos(4)]);
   set(ax(2),'TickDir','out');
   ylim([0,max(ranges)]);
   tick_label = get(cb2,'YTickLabel');
   ytick = get(cb2,'YTick');

   xl = xlim; xl = round(xl);
   if xl(1)==xl(2)
      xl(2) = xl(1)+1;
   end
   xlim(xl);


   %trim to bounds of z1 caxis limits
   op_ = max(cv_log_bs(1),min(cv_log_bs(2),z1));
   mino = .35;
   % scale from mina:1
   op_ = interp1(cv_log_bs,[mino,1],op_);
   % op_ = op_-(min(min(op_)))+mino; op_ = op_./(max(max(op_)));
   op_ = (op_.*mask(r.lte_25,:));
   opa_=fill_img(op_, x);
   alpha_exp = 1;
   set(img, 'alphadata',opa_.^alpha_exp);   set(gca,'color','k')

   if loop
      while mask_loop
         switch(menu('Adjust mask settings?', ...
               'cop_snr +.25','cop_snr -.25',['cop_snr [?] <',num2str(cop_snr),'>'],...
               'DPR snr +.25','DPR snr -.25',['DPR snr [?] <',num2str(ldr_snr),'>'],...
               'They are good, exit'));
            case 1
               cop_snr = cop_snr + .25;
            case 2
               cop_snr = max([.25, cop_snr - .25]);
            case 3
               cp_snr = input(sprintf('Mask COP with SNR < [%g] ',cop_snr));
               if ~isempty(cp_snr)&&isnumeric(cp_snr)&&cp_snr>0
                  cop_snr = cp_snr;
               end
            case 4
               ldr_snr = ldr_snr + .25;
            case 5
               ldr_snr = max([.25,ldr_snr - .25]);
            case 6
               ld_snr = input(sprintf('Mask DPR with SNR < [%g] ',ldr_snr));
               if ~isempty(ld_snr)&&isnumeric(ld_snr)&& ld_snr>0
                  ldr_snr = ld_snr;
               end                               
            case 7
               inarg.cop_snr = cop_snr;
               inarg.ldr_snr = ldr_snr;
               inarg.ldr_error_limit = ldr_error_limit;
               mask_loop = false;
         end
         axes(ax(1)); v = axis;
         mask = ones(size(polavg.cop));
         mask(polavg.r.lte_25,:) = 1;
         mask(polavg.cop_snr<cop_snr) = NaN;
         imagegap(x, y, mask(r.lte_25,:).*z1);
         caxis(cv_log_bs); colorbar

         axes(ax(2));
         alph = get(img,'AlphaData');
         mask = ones(size(polavg.cop));
         mask(polavg.ldr_snr<ldr_snr | ldr_error>ldr_error_limit) = NaN;
         [~,img] = imagegap(x, y, mask(r.lte_25,:).*z2);
         caxis(cv_dpr); set(img,'AlphaData',alph);set(gca,'color','k'); colorbar
         linkaxes(ax,'xy'); axis(v)

      end
      while cv_loop

         switch(menu('Adjust caxis setttings?',...
               'Bs max +.1','Bs max -.1',['Bs max [?] <',num2str(cv_log_bs(2)),'>'],...
               'Bs min +.1','Bs min -.1',['Bs min <',num2str(cv_log_bs(1)),'>'],...
               'DPR max +.1','DPR max -.1',['DPR max <',num2str(cv_dpr(2)),'>'],...
               'DPR min +.1','DPR min -.1',['DPR min <',num2str(cv_dpr(1)),'>'],...
               'Alpha brighter', 'Alpha dimmer',...
               'They are good, Exit'));
            case 1
               % cv_log_bs(2)
               cv_log_bs(2) = cv_log_bs(2) +.1;
            case 2
               cv_log_bs(2) = cv_log_bs(2) -(.1.*double(cv_log_bs(2)>(cv_log_bs(1)+.1)));               
            case 3
               c_log_bs = input(sprintf('Enter upper limit for log(bs): <%g> ',cv_log_bs(2)));
               if ~isempty(c_log_bs)&&isnumeric(c_log_bs)&&c_log_bs>cv_log_bs(1)
                  cv_log_bs(2) = c_log_bs;
               end
            case 4
               % cv_log_bs(1)
               cv_log_bs(1) = cv_log_bs(1) + (.1 .* double(cv_log_bs(2)>(cv_log_bs(1)+.1)));
            case 5
               cv_log_bs(1) = cv_log_bs(1) -.1;               
            case 6
               c_log_bs = input(sprintf('Enter lower limit for log(bs): <%g> ',cv_log_bs(1)));
               if ~isempty(c_log_bs)&&isnumeric(c_log_bs)&&c_log_bs<cv_log_bs(2)
                  cv_log_bs(1) = c_log_bs;
               end
            case 7
               cv_dpr(2) = cv_dpr(2) +.1;
            case 8
               cv_dpr(2) = cv_dpr(2) - (.1.*double(cv_dpr(2)>(cv_dpr(1)+.1)));               
            case 9
               c_dpr = input(sprintf('Enter upper limit for log_1_0(dpr): <%g> ',cv_dpr(2)));
               if ~isempty(c_dpr)&&isnumeric(c_dpr)&&c_dpr>cv_dpr(1)
                  cv_dpr(2) = c_dpr;
               end
            case 10
               cv_dpr(1) = cv_dpr(1) + (.1.*double(cv_dpr(2)>(cv_dpr(1)+.1)));
            case 11
               cv_dpr(1) = cv_dpr(1) -.1;               
            case 12
               c_dpr = input(sprintf('Enter lower limit for log_1_0(dpr): <%g> ',cv_dpr(1)));
               if ~isempty(c_dpr)&&isnumeric(c_dpr)&&c_dpr<cv_dpr(2)
                  cv_dpr(1) = c_dpr;
               end
            case 13
               alpha_exp = alpha_exp .* 3./4;
               set(img, 'alphadata',opa_.^(alpha_exp));
            case 14
               alpha_exp = alpha_exp .* 4./3;
               set(img, 'alphadata',opa_.^(alpha_exp));
            case 15
               inarg.cv_log_bs = cv_log_bs;
               inarg.cop_snr = cop_snr;
               inarg.cv_dpr = cv_dpr;
               inarg.ldr_snr = ldr_snr;
               inarg.ldr_error_limit = ldr_error_limit;
               polavg.inarg = inarg;
               cv_loop = false;
         end
         axes(ax(1));
         caxis(cv_log_bs);
         axes(ax(2));
         caxis(cv_dpr); 
         linkaxes(ax,'xy');
      end
   end

   titlestr = {[ds_, datestr(polavg.time(1), ', yyyy-mm-dd ')]};
   axes(ax(1));
   set(ax(1),'TickDir','out'); colorbar(ax(1));
   set(ax(2),'TickDir','out'); colorbar(ax(2));
   tl = title(titlestr); set(tl,'units','norm'); pos = get(tl,'position'); pos(2) = 1.05; set(tl,'position',pos);
   %  %Brightens set(img99, 'alphadata',get(img99, 'alphadata').^(.75));

   set(fig,'visible','on');
   fname1 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_2panel.',];
   set(gcf,'InvertHardcopy','off'); set(gcf, 'PaperPositionMode','auto');
   saveas(fig, [fig_dir,filesep,fname1,'fig']);
   %    set(fig,'visible',vis);

linkaxes(ax,'xy');
   for rr = fliplr(ranges)
      % figure(1);set(gcf,'visible',vis)
      ylim([0,rr]);
      fname1 = [fstem,datestr(polavg.time(1), 'yyyy-mm-dd'),hh_HH_str2,'.doy',num2str(serial2doy(floor(polavg.time(1)))),'.bs_ldr_2panel.',num2str(rr),'km.'];     
      if ~isempty(png_dir)
       saveas(fig,[png_dir, filesep, fname1, 'png']);
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