function ARM_sashe_ddr_plots_Kassianov_shared % Current situation with HOU comparisons:
% There seemed to be a notable difference in AOD agrreement between 
% MFR and SAS about some date.  
% ARM-processed sas aod look _decent_ AFTER doys(500) (whenever that is)
% Was this an accident to call it "early"?  Did I accidentally select LATE?
% Regardless, there is a distinct difference between the two periods.
% This may be related to banding issues that could be improved using the MFR 
% direct/diffuse approach.  
% What I'll attempt to do today is apply fix_sas_ddr to the ARM processed AOD files
% To do so, I'll read in the sas_filtered mat file and a corresponding data set for
% MFR and run fix_sas_ddr.  Then what?

cim = rd_anetaod_v3;
if foundstr(cim.site,'High')
   mfr = load('D:\aodfit_be\pvc\pvcmfrsraod1michM1.c1.ddr_filt.20120709_20130404.mat');
   sasv = load('D:\aodfit_be\pvc\pvcsashevisaodM1.c1.ddr_filt.20120629_20130621.mat');
   sasn = load('D:\aodfit_be\pvc\pvcsasheniraodM1.c1.ddr_filt.20120629_20130614.mat');
   ddr_corr = load('D:\aodfit_be\pvc\pvc_ddrcorr_v3.mat');
elseif foundstr(cim.site,'Jolla')
   mfr = load('D:\epc\epcmfrsr7nchM1.b1.ddr_filt.20230505_20230923.mat');
   sasv = load('D:\epc\epcsashevisaodM1.c1.ddr_filt.20230113_20230810.mat');
   sasn = load('D:\epc\epcsasheniraodM1.c1.ddr_filt.20230113_20230810.mat');
   ddr_corr = load(['D:\aodfit_be\hou\hou_ddrcorr_v3.mat']);
   ddr_nir_corr = load(['D:\epc\epc_nirddrcorr_v3.mat']);
else
   mfr = load('D:\aodfit_be\hou\houmfrsr7nchaod1michM1.c1.ddr_filt.20210915_20221001.mat');
   sasv = load('D:\aodfit_be\hou\housashevisaodM1.c1.ddr_filt.20210921_20221001.mat');
   sasn = load('D:\aodfit_be\hou\housasheniraodM1.c1.ddr_filt.20210921_20221001.mat');
   ddr_corr = load('D:\aodfit_be\hou\hou_ddrcorr_v3.mat');
   ddr_nir_corr = load(['D:\epc\epc_nirddrcorr_v3.mat']);
end
   ddr_corr = load(['D:\aodfit_be\hou\hou_ddrcorr_v3.mat']);
   ddr_nir_corr = load(['D:\epc\epc_nirddrcorr_v3.mat']);
vers = 'v5'; % Correct computation of ddr_corr
% ddr_corr_epc = load(['D:\epc\epc_ddrcorr_v3.mat']);
% ddr_corr_hou = load('D:\aodfit_be\hou\hou_ddrcorr_v3.mat');
% ddr_corr_hou.fac_epc = interp1(ddr_corr_epc.ddr,ddr_corr_epc.fac, ddr_corr_hou.ddr,'linear','extrap');
% ddr_corr.ddr = ddr_corr_hou.ddr;
% ddr_corr.fac = mean([ddr_corr_hou.fac;ddr_corr_hou.fac_epc]);
% vers = 'v4'; % Composed as mean to test statistics
% sasv = cat_sasvis_wl;
% sasn = cat_sasnir_wl;
% vers = 'v5'; % Uses ddr_corr from one site for another, eg ddr_corr from EPC applied to HOU

% sasv = anc_sift(sasv, ~any(sasv.vdata.aerosol_optical_depth<=0)&...
%    all(anc_qc_impacts(sasv.vdata.qc_aerosol_optical_depth, sasv.vatts.qc_aerosol_optical_depth)<2));
% sasv = anc_sift(sasv, sasv.vdata.airmass>=1&sasv.vdata.airmass<=6);  
% sasn = anc_sift(sasn, sasn.vdata.airmass>=1&sasn.vdata.airmass<=6);

%These will be overwritten by lines 42-43 with an intersecting subset
% but we may want to SAS and MFR comparisons even without matching aeronet
[mins, sinm] = nearest(mfr.time, sasv.time);
[minns, sinnm] = nearest(mfr.time, sasn.time); % for sasnir

fig_path = [fileparts(cim.pname), filesep,'figs',filesep];
if ~isadir(fig_path)
   mkdir(fig_path)
end

[mins, sinm] = nearest(mfr.time, sasv.time);
[minns, sinnm] = nearest(mfr.time, sasn.time); % for sasnir
% Plot sas vs cim and mfrsr to see if there are periods we should exclude as below
% figure; scatter(sas.vdata.aerosol_optical_depth(4,sinc), cim.AOD_500nm_AOD(cins),6,serial2doys(sas.time(sinc)));
% figure; scatter(mfr.vdata.aerosol_optical_depth    (mins),sasv.vdata.aerosol_optical_depth(4,sinm), ...
%    6,serial2doys(sasv.time(sinm)));
% xlabel('Aeronet 500 nm AOD'); ylabel('SASHe 500 nm AOD'); xlim([0,1]); ylim([0,1]);
% figure; scatter(sasn.vdata.aerosol_optical_depth(3,sinnc), cim.AOD_1640nm_AOD(cinns),6,serial2doys(sasn.time(sinnc)));
% xlabel('Aeronet 1640 nm AOD'); ylabel('SASHe 1640 nm AOD'); xlim([0,.3]); ylim([0,.3]);
if foundstr(cim.site,'Port')   
   ij = find(serial2doys(sasv.time(sinm))>300 & serial2doys(sasv.time(sinm))<600);
   mins = mins(ij); sinm = sinm(ij);
   [minns, sinnm] = nearest(mfr.time, sasn.time);
   ij = find(serial2doys(sasn.time(sinnm))>300 & serial2doys(sasn.time(sinnm))<600);
   minns = minns(ij); sinnm = sinnm(ij);
   site_str = ['HOU TRACER: ', datestr(sasv.time(sinm(1)),'mmm yyyy - '),datestr(sasv.time(sinm(end)),'mmm yyyy')];
% Look for good time series for TRACER, 
elseif foundstr(cim.site,'Jolla');
     site_str = ['EPC EPCAPE: ', datestr(sasv.time(sinm(1)),'mmm yyyy - '),datestr(sasv.time(sinm(end)),'mmm yyyy')];
else
   site_str = ['PVC TCAP: ', datestr(sasv.time(sinm(1)),'mmm yyyy - '),datestr(sasv.time(sinm(end)),'mmm yyyy')];
end

% Time series for Aug 30, 380, 500, 1020, 1640.



% MFRSR and SASvis 

X = mfr.vdata.direct_diffuse_ratio_filter1(mins);
Y = sasv.vdata.direct_normal_transmittance(2,sinm)./sasv.vdata.diffuse_transmittance(2,sinm);
Y = max([Y; zeros(size(Y))]);
yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
Y = Y.*(yf);
x_str = 'MFRSR DDR'; y_str = 'SASHe DDR'; nm_str = [' 415 nm'];
plot_ddr(X,Y,x_str, y_str, site_str, nm_str, fig_path);

X = mfr.vdata.direct_diffuse_ratio_filter2(mins); 
Y = sasv.vdata.direct_normal_transmittance(4,sinm)./sasv.vdata.diffuse_transmittance(4,sinm);
Y = max([Y; zeros(size(Y))]);
yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
Y = Y.*(yf);
x_str = 'MFRSR DDR'; y_str = 'SASHe DDR'; nm_str = [' 500 nm'];
plot_ddr(X,Y,x_str, y_str, site_str, nm_str, fig_path);

X = mfr.vdata.direct_diffuse_ratio_filter3(mins); 
Y = sasv.vdata.direct_normal_transmittance(5,sinm)./sasv.vdata.diffuse_transmittance(5,sinm);
Y = max([Y; zeros(size(Y))]);
yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
Y = Y.*(yf);
x_str = 'MFRSR DDR'; y_str = 'SASHe DDR'; nm_str = [' 615 nm'];
plot_ddr(X,Y,x_str, y_str, site_str, nm_str, fig_path);

X = mfr.vdata.direct_diffuse_ratio_filter4(mins); 
Y = sasv.vdata.direct_normal_transmittance(6,sinm)./sasv.vdata.diffuse_transmittance(6,sinm);
Y = max([Y; zeros(size(Y))]);
yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
Y = Y.*(yf);
x_str = 'MFRSR DDR'; y_str = 'SASHe DDR'; nm_str = [' 675 nm'];
plot_ddr(X,Y,x_str, y_str, site_str, nm_str, fig_path);

X = mfr.vdata.direct_diffuse_ratio_filter5(mins); 
Y = sasv.vdata.direct_normal_transmittance(7,sinm)./sasv.vdata.diffuse_transmittance(7,sinm);
Y = max([Y; zeros(size(Y))]);
yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
Y = Y.*(yf);
x_str = 'MFRSR DDR'; y_str = 'SASHe DDR'; nm_str = [' 870 nm'];
plot_ddr(X,Y,x_str, y_str, site_str, nm_str, fig_path);

if isfield(mfr.vdata,'direct_diffuse_ratio_filter7')
   X = mfr.vdata.direct_diffuse_ratio_filter7(minns);
   Y = sasn.vdata.direct_normal_transmittance(5,sinnm)./sasn.vdata.diffuse_transmittance(5,sinnm);
   Y = max([Y; zeros(size(Y))]);
   yf = interp1(ddr_nir_corr.ddr, ddr_nir_corr.fac, Y,'linear','extrap');
   Y = Y.*(yf);
   x_str = 'MFRSR DDR'; y_str = 'SASHe DDR'; nm_str = [' 1625 nm'];
   plot_ddr(X,Y,x_str, y_str, site_str, nm_str, fig_path);
end

% Put plots of diffuse hemispheric below here...


   X = mfr.vdata.diffuse_hemisp_narrowband_filter1(mins);
   Z = sasv.vdata.wavelength;
   Y = sasv.vdata.diffuse_transmittance(2,sinm).*sasv.vdata.solar_spectrum(2);
   keep = X>0 & Y>0 & ...
      sasv.vdata.direct_normal_transmittance(2,sinm)>0 & sasv.vdata.diffuse_transmittance(2,sinm)>0 & ...
      mfr.vdata.direct_normal_narrowband_filter1(mins)>0 & mfr.vdata.diffuse_hemisp_narrowband_filter1(mins)>0;
   X = X(keep); Y = Y(keep);
   Y = max([Y; zeros(size(Y))]);
   yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
   Y = Y./yf;
   x_str = 'MFRSR dif [W/m^2/nm]'; y_str = 'SASHe dif [W/m^2/nm]'; nm_str = [' 415 nm'];
   plot_difh(X,Y,x_str, y_str, site_str, nm_str, fig_path);


   X = mfr.vdata.diffuse_hemisp_narrowband_filter2(mins);
   Z = sasv.vdata.wavelength;
   Y = sasv.vdata.diffuse_transmittance(4,sinm).*sasv.vdata.solar_spectrum(4);
   % keep = X>0 & Y>0 & ...
   %    sasv.vdata.direct_normal_transmittance(4,sinm)>0 & sasv.vdata.diffuse_transmittance(4,sinm)>0 & ...
   %    mfr.vdata.direct_normal_narrowband_filter2(mins)>0 & mfr.vdata.diffuse_hemisp_narrowband_filter2(mins)>0;
   % X = X(keep); Y = Y(keep);
   Y = max([Y; zeros(size(Y))]);
   yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
   Y = Y./yf;
   x_str = 'MFRSR dif [W/m^2/nm]'; y_str = 'SASHe dif [W/m^2/nm]'; nm_str = [' 500 nm'];
   plot_difh(X,Y,x_str, y_str, site_str, nm_str, fig_path);

   X = mfr.vdata.diffuse_hemisp_narrowband_filter3(mins);
   Z = sasv.vdata.wavelength;
   Y = sasv.vdata.diffuse_transmittance(5,sinm).*sasv.vdata.solar_spectrum(5);
   % keep = X>0 & Y>0 & ...
   %    sasv.vdata.direct_normal_transmittance(5,sinm)>0 & sasv.vdata.diffuse_transmittance(5,sinm)>0 & ...
   %    mfr.vdata.direct_normal_narrowband_filter3(mins)>0 & mfr.vdata.diffuse_hemisp_narrowband_filter3(mins)>0;
   % X = X(keep); Y = Y(keep);
   Y = max([Y; zeros(size(Y))]);
   yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
   Y = Y./yf;
   x_str = 'MFRSR dif [W/m^2/nm]'; y_str = 'SASHe dif [W/m^2/nm]'; nm_str = [' 615 nm'];
   plot_difh(X,Y,x_str, y_str, site_str, nm_str, fig_path);

   X = mfr.vdata.diffuse_hemisp_narrowband_filter4(mins);
   Z = sasv.vdata.wavelength;
   Y = sasv.vdata.diffuse_transmittance(6,sinm).*sasv.vdata.solar_spectrum(6);
   % keep = X>0 & Y>0 & ...
   %    sasv.vdata.direct_normal_transmittance(6,sinm)>0 & sasv.vdata.diffuse_transmittance(6,sinm)>0 & ...
   %    mfr.vdata.direct_normal_narrowband_filter4(mins)>0 & mfr.vdata.diffuse_hemisp_narrowband_filter4(mins)>0;
   % X = X(keep); Y = Y(keep);
   Y = max([Y; zeros(size(Y))]);
   yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
   Y = Y./yf;
   x_str = 'MFRSR dif [W/m^2/nm]'; y_str = 'SASHe dif [W/m^2/nm]'; nm_str = [' 675 nm'];
   plot_difh(X,Y,x_str, y_str, site_str, nm_str, fig_path);

   X = mfr.vdata.diffuse_hemisp_narrowband_filter5(mins);
   Z = sasv.vdata.wavelength;
   Y = sasv.vdata.diffuse_transmittance(7,sinm).*sasv.vdata.solar_spectrum(7);
   % keep = X>0 & Y>0 & ...
   %    sasv.vdata.direct_normal_transmittance(7,sinm)>0 & sasv.vdata.diffuse_transmittance(7,sinm)>0 & ...
   %    mfr.vdata.direct_normal_narrowband_filter5(mins)>0 & mfr.vdata.diffuse_hemisp_narrowband_filter5(mins)>0;
   % X = X(keep); Y = Y(keep);
   % Y = max([Y; zeros(size(Y))]);
   yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
   Y = Y./yf;
   x_str = 'MFRSR dif [W/m^2/nm]'; y_str = 'SASHe dif [W/m^2/nm]'; nm_str = [' 870 nm'];
   plot_difh(X,Y,x_str, y_str, site_str, nm_str, fig_path);

   if isfield(mfr.vdata,'diffuse_hemisp_narrowband_filter7')
   X = mfr.vdata.diffuse_hemisp_narrowband_filter7(minns);
   Z = sasn.vdata.wavelength;
   Y = sasn.vdata.diffuse_transmittance(5,sinnm).*sasn.vdata.solar_spectrum(5);
   % keep = X>0 & Y>0 & ...
   %    sasn.vdata.direct_normal_transmittance(5,sinnm)>0 & sasn.vdata.diffuse_transmittance(5,sinnm)>0 & ...
   %    mfr.vdata.direct_normal_narrowband_filter7(minns)>0 & mfr.vdata.diffuse_hemisp_narrowband_filter7(minns)>0;
   % X = X(keep); Y = Y(keep);
   Y = max([Y; zeros(size(Y))]);
   yf = interp1(ddr_corr.ddr, ddr_corr.fac, Y,'linear','extrap');
   Y = Y./yf;
   x_str = 'MFRSR dif [W/m^2/nm]'; y_str = 'SASHe dif [W/m^2/nm]'; nm_str = [' 1625 nm'];
   plot_difh(X./1,Y,x_str, y_str, site_str, nm_str, fig_path);
   end


% Plots of diffuse hemispheric above here...

% X = cim.AOD_500nm_AOD(cinm);
% Y = mfr.vdata.aerosol_optical_depth_filter2(minc);
% y_str = 'MFRSR AOD'; x_str = 'Aeronet AOD'; nm_str = '500 nm';
% plot_aod(X,Y,x_str, y_str, site_str, nm_str,fig_path);
% 
% Y = mfr.vdata.aerosol_optical_depth_filter4(minc);
% X = cim.AOD_675nm_AOD(cinm);
% y_str = 'MFRSR AOD'; x_str = 'Aeronet AOD'; nm_str = '675 nm';
% plot_aod(X,Y,x_str, y_str, site_str, nm_str,fig_path);
% 
% Y = mfr.vdata.aerosol_optical_depth_filter5(minc);
% X = cim.AOD_870nm_AOD(cinm);
% y_str = 'MFRSR AOD'; x_str = 'Aeronet AOD'; nm_str = '870 nm';
% plot_aod(X,Y,x_str, y_str, site_str, nm_str,fig_path);

function plot_ddr(X,Y,x_str, y_str, site_str, nm_str, pname);
% try
      t_str = ['Direct Normal to Diffuse Ratio ',nm_str];
      % Evaluate from here...
      if size(X,1)==size(Y,2); Y = Y'; end
      bad = X<=0.025 | Y<=0.025; X(bad) =[]; Y(bad) = [];
      tic;D = ptdens(X,Y, 16./sqrt(length(X)));toc
      figure_(112); scatter(X, Y,6,log10(D)); colormap(comp_map_w_jet);
      xlabel(x_str); ylabel(y_str); title({site_str; t_str})
      xl = xlim; yl = ylim; xlim([floor(min([xl, yl])),round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
      hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off');
      [good, P_bar] = rbifit(X,Y,3,0); hold('on');  plot(xl,polyval(P_bar,xl),'b-', 'linewidth',3); hold('off');
      [gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
      gt.Units = 'Normalized'; gt.Position = round(gt.Position.*20)./20; gt.BackgroundColor = [.975,.975,.975]; 
      zoom('on');
      if isavar('pname')&&isadir(pname)
         menu('Zoom as desired then click OK','OK');
         xl = xlim; yl = ylim; xlim([min([xl, yl]),round(50.*min([xl(2),yl(2)]))./50]);ylim(xlim); axis('square');
         tla = [strtok(site_str), ' ']; xtok = [strtok(x_str), ' ']; ytok = [strtok(y_str), ' ']; nm = strrep(nm_str,' ','_');
         saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_DDR.png'],' ','_'));
         saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_DDR.fig'],' ','_'));
      end
% catch
%    plot_ddr(X(1:2:end),Y(1:2:end),x_str, y_str, site_str, nm_str, pname);
% end
return

function plot_difh(X,Y,x_str, y_str, site_str, nm_str, pname);
% try
      t_str = ['Diffuse Hemispheric Irradiance ',nm_str];
      % Evaluate from here...
      if size(X,1)==size(Y,2); Y = Y'; end
      bad = X<=0 | Y<=0; X(bad) =[]; Y(bad) = [];
      D = ptdens(X,Y, 2./sqrt(length(X)));
      figure_(111); scatter(X, Y,6,log10(D)); colormap(comp_map_w_jet);
      xlabel(x_str,'interp','tex'); ylabel(y_str,'interp','tex'); title({site_str; t_str})
      xl = xlim; yl = ylim; xlim([floor(min([xl, yl])),round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
      hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
      [good, P_bar] = rbifit(X,Y,3,0); hold('on');  plot(xl,polyval(P_bar,xl),'b-', 'linewidth',3); hold('off')
      [gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b'); gt.BackgroundColor = [.975,.975,.975]; 
      gt.Units = 'Normalized'; gt.Position = round(gt.Position.*10)./10;
      zoom('on');
      if isavar('pname')&&isadir(pname)
         menu('Zoom as desired then click OK','OK')
         xl = xlim; yl = ylim; xlim([0,round(50.*min([xl(2),yl(2)]))./50]);ylim(xlim); axis('square');
         tla = [strtok(site_str), ' ']; xtok = [strtok(x_str), ' ']; ytok = [strtok(y_str), ' ']; nm = strrep(nm_str,' ','_');
         saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_difh.png'],' ','_'));
         saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_difh.fig'],' ','_'));
      end
% catch
%    plot_difh(X(1:2:end),Y(1:2:end),x_str, y_str, site_str, nm_str, pname);
% end
return

% [gt,txt, stats] = txt_stat(X, Y,P_bar); set(gt,'color','b');
figure; plot(sasv.time, sasv.vdata.aerosol_optical_depth([1 4],:), '.',cim.time, [cim.AOD_380nm_AOD, cim.AOD_500nm_AOD],'*' ); dynamicDateTicks; axis(v)
legend('SASHe 380 nm','SASHe 500 nm','Aeronet 380 nm','Aeronet 500 nm')

AOD_1020nm = cim.AOD_1020nm_AOD + cim.AOD_1020nm_WaterVapor;
AOD_1640nm =  cim.AOD_1640nm_AOD +  cim.AOD_1640nm_CH4 +  cim.AOD_1640nm_CO2 + cim.AOD_1640nm_WaterVapor;
% figure; plot(sasn.time, sasn.vdata.aerosol_optical_depth([1 3],:), '.',cim.time, [AOD_1020nm, AOD_1640nm],'*' ); dynamicDateTicks; axis(v)
% legend('SASHe 1020 nm','SASHe 1640 nm','Aeronet 1020 nm - Rayleigh','Aeronet 1640 nm - Rayleigh')
% axis(v)
hisun = sasv.vdata.solar_zenith_angle<65;
hisunn = sasn.vdata.solar_zenith_angle<65;
figure; plot(sasv.time, sasv.vdata.aerosol_optical_depth([1 4],:).*(ones(2,1)*hisun), '.',cim.time, [cim.AOD_380nm_AOD, cim.AOD_500nm_AOD],'*' ); dynamicDateTicks; axis(v)
legend('SASHe 380 nm','SASHe 500 nm','Aeronet 380 nm','Aeronet 500 nm')

figure; plot(sasn.time, sasn.vdata.aerosol_optical_depth([1 3],:).*(ones(2,1)*hisunn), '.',cim.time, [AOD_1020nm, AOD_1640nm],'*' ); dynamicDateTicks; axis(v)
legend('SASHe 1020 nm','SASHe 1640 nm','Aeronet 1020 nm - Rayleigh','Aeronet 1640 nm - Rayleigh')
axis(v)

% We could:
% A. Show agreement between Csphot and Anet at 500, 675, and 870
% B. Show corresponding agreement between CSPHOT and SAS at 

return