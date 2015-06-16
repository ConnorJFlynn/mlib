clear; 
%%
pname = ['E:\case_studies\ABE_vert_profs\newABE\'];
aipfrh = ancload(['E:\case_studies\ABE_vert_profs\newABE\sgpaipfrhC1.c1.20060101.000000.cdf']);
aip_files = dir(['E:\case_studies\ABE_vert_profs\newABE\sgpaip1ogrenC1.*.cdf']);

for as = 1:length(aip_files)
   
   txt = textscan(aip_files(as).name,'%s', 'delimiter','.');
   txt = txt{1};
   year = txt{3};
   [infilename] = dir(['E:\case_studies\ABE_vert_profs\newABE\sgpaerosolbe1turnC1.c1.',year,'.*.cdf']);
   % [infilename] =
   % getfullname(['E:\case_studies\ABE_vert_profs\newABE\sgpaip1ogrenC1.*.cdf']);
   
   if (length(infilename)==1)&&(exist([pname,aip_files(as).name],'file'))&&(exist([pname, infilename(1).name],'file'))
      close('all')
      aip = ancload([pname,aip_files(as).name]);
      
      % [pname, fname] = fileparts(infilename);
      % pname = [pname, filesep];
      % txt = textscan(fname,'%s', 'delimiter','.');
      % txt = txt{1};
      % year = txt{3};
      % [infilename] = dir(['E:\case_studies\ABE_vert_profs\newABE\sgpaerosolbe1turnC1.c1.',year,'.*.cdf']);
      
      abe = ancload([pname, infilename(1).name]);
      
      %% RH Profiles
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      % ax1(1) = subplot(2,1,1);
      pos = abe.vars.rh.data >0 & abe.vars.rh.data <101;
      z = abe.vars.rh.data;
      z(~pos) = NaN;
      colormap(rl_prof);
      imagegap(serial2doy(abe.time), abe.vars.height.data, z);
      xl = xlim;
      ylim([0,4]);
      h_ax = gca;
      cb = colorbar;
      set(get(cb,'title'),'string',[{'RH%'}])
      % caxis([0,.5]);
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('height [km AGL]')
      title(['Relative Humidity from MergeSonde for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(cb,'units','normalized');
      set(cb,'position',[0.9245    0.23    0.0228    0.51]);
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      saveas(fig,[pname, 'abe_plots.rh_prof.',year,'.png']);
      
      %% frh plots
      [ainc, cina] = nearest(aipfrh.time, abe.time);
      %
      bad = aipfrh.vars.ratio_85by40_Bs_R_1um_2p.data>10;
      bad = bad | aipfrh.vars.ratio_85by40_Bs_G_1um_2p.data>10;
      bad = bad | aipfrh.vars.ratio_85by40_Bs_B_1um_2p.data>10;
      bad = aipfrh.vars.ratio_85by40_Bs_R_1um_2p.data<1;
      bad = bad | aipfrh.vars.ratio_85by40_Bs_G_1um_2p.data<1;
      bad = bad | aipfrh.vars.ratio_85by40_Bs_B_1um_2p.data<1;
      aipfrh.vars.ratio_85by40_Bs_R_1um_2p.data(bad) = NaN;
      aipfrh.vars.ratio_85by40_Bs_G_1um_2p.data(bad) = NaN;
      aipfrh.vars.ratio_85by40_Bs_B_1um_2p.data(bad) = NaN;
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      plot(serial2doy(aipfrh.time(ainc)), [aipfrh.vars.ratio_85by40_Bs_R_1um_2p.data(ainc),], 'rx',...
         serial2doy(aipfrh.time(ainc)), [aipfrh.vars.ratio_85by40_Bs_G_1um_2p.data(ainc),], 'go',...
         serial2doy(aipfrh.time(ainc)), [aipfrh.vars.ratio_85by40_Bs_B_1um_2p.data(ainc),], 'b+');
      legend('red','green','blue')
      h_ax = gca;
      
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('Bsp(85%)/Bsp(40%)')
      xlim(xl);
      ylim([0,1.25.*max(aipfrh.vars.ratio_85by40_Bs_R_1um_2p.data(ainc))]);
      title(['frh 85%/40% ratio at 1 um for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      
      saveas(fig,[pname, 'abe_plots.frh.',year,'.png']);
      %% g sfc plots
      [binc, cinb] = nearest(aip.time, abe.time);
      %
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      plot(serial2doy(aip.time(binc)), [aip.vars.asymmetry_parameter_R_Dry_1um.data(binc),], 'rx',...
         serial2doy(aip.time(binc)), [aip.vars.asymmetry_parameter_G_Dry_1um.data(binc),], 'go',...
         serial2doy(aip.time(binc)), [aip.vars.asymmetry_parameter_B_Dry_1um.data(binc),], 'b+');
      legend('red','green','blue')
      h_ax = gca;
      
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('g [dry sfc]')
      xlim(xl);
      title(['asymmetry parameter "g" at 1 um, low RH, sfc for ',datestr(abe.time(1),'mmm yyyy')]);
      ylim([0,1]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      
      saveas(fig,[pname, 'abe_plots.g_sfc.',year,'.png']);
      %% bsf plots
      %
%       [binc, cinb] = nearest(aip.time, abe.time);
      %
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      plot(serial2doy(aip.time(binc)), [aip.vars.bsf_R_Dry_1um.data(binc),], 'rx',...
         serial2doy(aip.time(binc)), [aip.vars.bsf_G_Dry_1um.data(binc),], 'go',...
         serial2doy(aip.time(binc)), [aip.vars.bsf_B_Dry_1um.data(binc),], 'b+');
      legend('red','green','blue')
      h_ax = gca;
      
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('bsf [dry sfc]')
      xlim(xl);
      title(['backscatter fraction at 1 um, low RH, sfc for ',datestr(abe.time(1),'mmm yyyy')]);
      ylim([0,.4]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      
      saveas(fig,[pname, 'abe_plots.bsf_sfc.',year,'.png']);
      %% Bs total scattering  plots
      %
%       [binc, cinb] = nearest(aip.time, abe.time);
      %
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      plot(serial2doy(aip.time(binc)), [aip.vars.Bs_R_Dry_1um_Neph3W_1.data(binc)], 'rx',...
         serial2doy(aip.time(binc)), [aip.vars.Bs_G_Dry_1um_Neph3W_1.data(binc)], 'go',...
         serial2doy(aip.time(binc)), [aip.vars.Bs_B_Dry_1um_Neph3W_1.data(binc)], 'b+');
      legend('red','green','blue')
      h_ax = gca;
      ylim([0,1.25.*max(aip.vars.Bs_B_Dry_1um_Neph3W_1.data(binc))])
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('Bs [1/km]')
      xlim(xl);
      title(['Total scattering coefficient at 1 um, low RH, sfc for ',datestr(abe.time(1),'mmm yyyy')]);
      
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      
      saveas(fig,[pname, 'abe_plots.Bs_sfc.',year,'.png']);
      %% Bbs hemispheric backscattering  plots
      %
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      plot(serial2doy(aip.time(binc)), [aip.vars.Bbs_R_Dry_1um_Neph3W_1.data(binc)], 'rx',...
         serial2doy(aip.time(binc)), [aip.vars.Bbs_G_Dry_1um_Neph3W_1.data(binc)], 'go',...
         serial2doy(aip.time(binc)), [aip.vars.Bbs_B_Dry_1um_Neph3W_1.data(binc)], 'b+');
      legend('red','green','blue')
      h_ax = gca;
      ylim([0,1.25.*max(aip.vars.Bbs_B_Dry_1um_Neph3W_1.data(binc))])
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('Bbs [1/km]')
      xlim(xl);
      title(['Hemispheric backscattering coefficient at 1 um, low RH, sfc for ',datestr(abe.time(1),'mmm yyyy')]);
      
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      
      saveas(fig,[pname, 'abe_plots.Bbs_sfc.',year,'.png']);
      %%
      %% Ba absorption coef  plots
      %
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      plot(serial2doy(aip.time(binc)), [aip.vars.Ba_R_Dry_1um_PSAP3W_1.data(binc)], 'rx',...
         serial2doy(aip.time(binc)), [aip.vars.Ba_G_Dry_1um_PSAP3W_1.data(binc)], 'go',...
         serial2doy(aip.time(binc)), [aip.vars.Ba_B_Dry_1um_PSAP3W_1.data(binc)], 'b+');
      legend('red','green','blue')
      h_ax = gca;
      ylim([0,1.25.*max(aip.vars.Ba_B_Dry_1um_PSAP3W_1.data(binc))])
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('Ba [1/km]')
      xlim(xl);
      title(['Absorption coefficient at 1 um, low RH, sfc for ',datestr(abe.time(1),'mmm yyyy')]);
      
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      
      saveas(fig,[pname, 'abe_plots.Ba_sfc.',year,'.png']);
      %% AOD
      
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      aod = abe.vars.be_aod_500.data;
      pos = aod>0;
      aod(~pos) = NaN;
      % ax1(2) = subplot(2,1,2);
      plot(serial2doy(abe.time), aod,'ok');
      h_ax = gca;
      
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('aod')
      xlim(xl);
      title(['Best-Estimate AOD for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %%
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      
      saveas(fig,[pname, 'abe_plots.be_aod.',year,'.png']);
      %% Extinction profiles
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      % ax1(1) = subplot(2,1,1);
      pos = abe.vars.extinction_profile.data>0;
      z = abe.vars.extinction_profile.data;
      z(~pos) = NaN;
      colormap(rl_prof)
      imagegap(serial2doy(abe.time), abe.vars.height.data, z);
      xlim(xl)
      ylim([0,4]);
      h_ax = gca;
      cb = colorbar;
      set(get(cb,'title'),'string',[{'ext','[1/km]'}])
      caxis([0,.3]);
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('height [km AGL]')
      title(['Best-Estimate Aerosol Extinction Profiles for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(cb,'units','normalized');
      set(cb,'position',[0.9245    0.23    0.0228    0.51]);
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      saveas(fig,[pname, 'abe_plots.ext_prof.',year,'.png']);
      
      %% SSA
      %
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      % ax2(1) = subplot(3,1,1);
      z1 = abe.vars.single_scattering_albedo.data;
      
      pos = z1>0 & z1<=1;
      z1(~pos) = NaN;
      imagegap(serial2doy(abe.time), abe.vars.height.data,z1) ;
      colormap(rl_prof);
      ylim([0,4]);
      xlim(xl);
      h_ax = gca;
      cb = colorbar;
      set(get(cb,'title'),'string','SSA')
      caxis([.75,1]);
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('height [km AGL]')
      title(['Single Scattering Albedo Profiles for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %%
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(cb,'units','normalized');
      set(cb,'position',[0.9245    0.23    0.0228    0.51]);
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      saveas(fig,[pname, 'abe_plots.SSA_prof.',year,'.png']);
      
      %% g
      %
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      % ax2(1) = subplot(3,1,1);
      z2 = abe.vars.asymmetry_parameter.data;
      % z1 = 1-z1;
      pos = z1>0 & z1<=1;
      z1(~pos) = NaN;
      imagegap(serial2doy(abe.time), abe.vars.height.data,z2) ;
      colormap(rl_prof);
      ylim([0,4]);
      xlim(xl);
      h_ax = gca;
      cb = colorbar;
      set(get(cb,'title'),'string','g')
      caxis([.5,1]);
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('height [km AGL]')
      title(['Asymmetry Parameter Profiles for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %%
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(cb,'units','normalized');
      set(cb,'position',[0.9245    0.23    0.0228    0.51]);
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      saveas(fig,[pname, 'abe_plots.g_prof.',year,'.png']);
      
      %% Bs profile
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      % ax2(2) = subplot(3,1,2);
      % z is ext profile
      % z1 is SSA
      imagegap(serial2doy(abe.time), abe.vars.height.data, z.*z1);
      colormap(rl_prof);
      ylim([0,4]);
      xlim(xl);
      h_ax = gca;
      cb = colorbar;
      caxis([0,.3])
      set(get(cb,'title'),'string',{'Bs','[1/km]'})
      
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('height [km AGL]')
      title(['Bs (=SSA*ext) for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(cb,'units','normalized');
      set(cb,'position',[0.9245    0.23    0.0228    0.51]);
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      saveas(fig,[pname, 'abe_plots.Bs_prof.',year,'.png']);
      
      
      %% Ba profiles
      fig = figure;
      set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
      % ax2(3) = subplot(3,1,3);
      
      imagegap(serial2doy(abe.time), abe.vars.height.data,z.*(1-z1)) ;
      colormap(rl_prof);
      ylim([0,4]);
      xlim(xl);
      h_ax = gca;
      cb = colorbar;
      caxis([0,.03])
      set(get(cb,'title'),'string',{'Ba','[1/km]'})
      
      ax1(1) = gca;
      xlabel(['day of year ',datestr(abe.time(1),'yyyy')]);
      ylabel('height [km AGL]')
      title(['Ba (=(1-SSA)*ext) for ',datestr(abe.time(1),'mmm yyyy')]);
      
      % The following settings are good for the image plots with colorbar
      % Note there are two slightly different settings for png and for emf files.
      %%
      set(h_ax,'units','normalized');
      ax_pos = [ 0.09    0.23    0.8    0.60]; set(h_ax,'position',ax_pos);
      set(h_ax,'TickDir','out');
      set(cb,'units','normalized');
      set(cb,'position',[0.9245    0.23    0.0228    0.51]);
      set(fig,'PaperPositionMode','auto');
      get(fig,'PaperPosition');
      
      saveas(fig,[pname, 'abe_plots.Ba_prof.',year,'.png']);
      %%
   end
end

% fig = figure; 
% set(fig,'units','normalized','position',[ 0.0333  0.3689 0.8833 0.4733]);
% h = figure;
% set(h,'units','normalized','Position',[0.202778 0.431111 0.734722 0.427778]);
% x = serial2doy(abe.time);
% y = abe.vars.height.data;
% z = (z1);
% w = abe.vars.extinction_profile.data;
% cmap = colormap;
% cv_z = [.5,1];
% 
% cv_w = [0,.2];
% [rgb,ssa_colorsqr] = rgb_weight_nomask(x,y,z,w,cmap,cv_z,cv_w,.05);
% %
%  ax3(1) = subplot('position',[0.100    0.1500    0.7    0.75]);
% % axx(1) = subplot(1,2,1);
% % set(ax2(1),'position',[0.0800    0.1500    0.560    0.7600])
% ax3(2) = subplot('position',[0.85    0.15    0.10    0.75]);
% % axx(2) = subplot(1,2,2);
% axes(ax3(2));
% imagegap(cv_w,cv_z,ssa_colorsqr)
% xlabel('ext')
% ylabel('ssa')
% 
% set(ax3(2),'TickDir','out','yaxisloc','right');
% %
% axes(ax3(1));
% imagegap(x,y,rgb);
% title('SSA weighted by ext');
% ylabel('height (km)')
% xlabel('day of year')
% linkaxes([ax2,ax3(1)],'xy')
% 
% %%
% h =figure;
% set(h,'units','normalized','Position',[0.202778 0.431111 0.734722 0.427778]);
% x = serial2doy(abe.time);
% y = abe.vars.height.data;
% z = (1-z1);
% w = abe.vars.extinction_profile.data;
% cmap = colormap;
% cv_z = [0,.5];
% 
% cv_w = [0,.2];
% [rgb,ssa_colorsqr] = rgb_weight_nomask(x,y,z,w,cmap,cv_z,cv_w,.05);
% %
%  ax4(1) = subplot('position',[0.100    0.1500    0.7    0.75]);
% % axx(1) = subplot(1,2,1);
% % set(ax2(1),'position',[0.0800    0.1500    0.560    0.7600])
% ax4(2) = subplot('position',[0.85    0.15    0.10    0.75]);
% % axx(2) = subplot(1,2,2);
% axes(ax4(2));
% imagegap(cv_w,cv_z,ssa_colorsqr)
% xlabel('ext')
% ylabel('ssa')
% 
% set(ax4(2),'TickDir','out','yaxisloc','right');
% %
% axes(ax4(1));
% imagegap(x,y,rgb);
% title('COA weighted by ext');
% ylabel('height (km)')
% xlabel('day of year')
% linkaxes([ax2,ax4(1)],'xy')
% %%
% figure; imagegap(serial2doy(abe.time), abe.vars.height.data, abe.vars.asymmetry_parameter.data);
% colorbar
% title('ssa')
