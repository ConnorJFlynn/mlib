

% BB = Blackbody(Wavenumber, Temperature); % Assist
% y=planck_in_wn(nu,T); %
%%
um = [.25:.001:25];
wn_ = um2wn(um);
wn = [400:40000];
um_ = wn2um(wn);
long_bump = um2wn([1.7,2.5]);
short_bump = um2wn([.25,.35]);
%%
T_sun = 5700;
T_earth = 273;
rad_sun = planck_in_wn(wn,T_sun); flux_sun = trapz(wn,rad_sun); %[mw/(m^2.sr.cm^-1)]
rad_earth = planck_in_wn(wn,T_earth);flux_earth = trapz(wn,rad_earth);
rad_sun_nm = planck_in_wl(um.*1e-6,T_sun);flux_sun_nm = trapz(um,rad_sun_nm);
rad_earth_nm =planck_in_wl(um.*1e-6,T_earth);flux_earth_nm = trapz(um,rad_earth_nm);
%%
% load Charts data
charts_irad = read_charts_irradiance;
%%
SAS_nm = [325,1700];
SAS_nm_lim = charts_irad.nm>min(SAS_nm)&charts_irad.nm<max(SAS_nm);
SAS_wn = um2wn(SAS_nm./1000);
SAS_wn_lim = charts_irad.wn>min(SAS_wn)&charts_irad.wn<max(SAS_wn);

SWS_nm = [350,2200];
SWS_nm_lim = charts_irad.nm>min(SWS_nm)&charts_irad.nm<max(SWS_nm);
SWS_wn = um2wn(SWS_nm./1000);
SWS_wn_lim = charts_irad.wn>min(SWS_wn)&charts_irad.wn<max(SWS_wn);
%%
a=1; % fraction of direct in numer
b = 1; % fraction of diffuse in numer and denom
%%
a = a.*.5;
b = b.*.5;
 plot(charts_irad.nm, (a.*charts_irad.dir_irrad_nm+(1-b).*charts_irad.dif_irrad_nm)./(b.*charts_irad.dif_irrad_nm+(1-a).*charts_irad.dir_irrad_nm),'-');
xlim([350,1050])
title({['Direct error:',num2str(1-a)];['Diffuse error:',num2str(1-b)]});

%%
% Load ASSIST data, put in plots below
assist_dir = ['E:\case_studies\sbsassist_proc\2011_03_24_06_01_15_PROCESSED\'];
assist_file = ['20110324_053829_chA_SKY.coad.mrad.coad.merged.truncated.mat'];
   edgar_mat = loadinto([assist_dir, assist_file]);
   flynn_mat = repack_edgar(edgar_mat);
assist_file = ['20110324_053829_chB_SKY.coad.mrad.coad.merged.truncated.mat'];
   edgar_matB = loadinto([assist_dir, assist_file]);
   flynn_matB = repack_edgar(edgar_matB);
%%
figure; plot(flynn_mat.x, flynn_mat.y(1,:), 'k-',flynn_matB.x, flynn_matB.y(1,:),'g-')
%%
plots_ppt;
figure; s(1) = subplot(2,1,1);
plot(flynn_mat.x, flynn_mat.y(1,:)./2,'m-',...
   flynn_matB.x, flynn_matB.y(1,:)./2,'g-',...
   wn,[rad_sun./1.9e4],'k--',charts_rad.wn, 3e3.*(charts_rad.dir_irrad_wn+charts_rad.dif_irrad_wn), 'k-',...
   charts_rad.wn(SWS_wn_lim), 3e3.*(charts_rad.dir_irrad_wn(SWS_wn_lim)+charts_rad.dif_irrad_wn(SWS_wn_lim)), 'b-',...
   charts_rad.wn(SAS_wn_lim), 3e3.*(charts_rad.dir_irrad_wn(SAS_wn_lim)+charts_rad.dif_irrad_wn(SAS_wn_lim)), 'r--');
xlabel('wavenumbers [1/cm]');
ylabel({'Arbitrary';'Units'});
title('ARM spectral coverage');
yl = ylim;ylim([0,yl(2)]);
grid('on');
set(gca,'yticklabel',[]);
legend('MCT','InSb','5700 K','charts','sws','sas');
s(2) = subplot(2,1,2);

plot(um,rad_earth_nm,'k:', wn2um(flynn_mat.x), flynn_mat.y(1,:).*flynn_mat.x.^2,'m-',...
   wn2um(flynn_matB.x), flynn_matB.y(1,:).*flynn_matB.x.^2,'g-',...
   um,rad_sun_nm./3.8e6,'k--',...
   charts_rad.nm/1000, 1.5e8.*(charts_rad.dir_irrad_nm+charts_rad.dif_irrad_nm),'k-',...
   charts_rad.nm(SWS_nm_lim)/1000, 1.5e8.*(charts_rad.dir_irrad_nm(SWS_nm_lim)+charts_rad.dif_irrad_nm(SWS_nm_lim)),'b.',...
   charts_rad.nm(SAS_nm_lim)/1000, 1.5e8.*(charts_rad.dir_irrad_nm(SAS_nm_lim)+charts_rad.dif_irrad_nm(SAS_nm_lim)),'r-');
xlabel('wavelength [microns]');
ylabel({'Arbitrary';'Units'});
yl = ylim;ylim([0,yl(2)]);
grid('on');

legend('273 K')
set(gca,'yticklabel',[]);

%%
plots_default
figure; 
wn_low = [100:2000];
T_earth = 273;
rad_low = planck_in_wn(wn_low,T_earth);
plot(wn_low,rad_low,'k-', flynn_mat.x, flynn_mat.y(1,:),'m-',...
   flynn_matB.x, flynn_matB.y(1,:),'g-');
xlabel('wavenumbers [1/cm]');
ylabel({'Arbitrary';'Units'});
title('ARM spectral coverage');
yl = ylim;ylim([0,yl(2)]);
grid('on');
set(gca,'yticklabel',[]);
legend('273 K','MCT','InSb');
%%
lg = legend('(mW/m2/ster/cm)');
set(lg,'interp','none')
%%
nu = HBB.x;
y_2=Blackbody(nu, 5700);
figure; plot(nu, [y_2],'go')

%%

%%
% Load ASSIST data, put in plots below
assist_dir = ['E:\case_studies\sbsassist_proc\2011_03_24_06_01_15_PROCESSED\'];
assist_file = ['20110324_053829_chA_BTemp_SKY.coad.mrad.coad.merged.truncated.mat'];
   edgar_mat_BT = loadinto([assist_dir, assist_file]);
   flynn_mat_BT = repack_edgar(edgar_mat_BT);
assist_file = ['20110324_053829_chB_BTemp_SKY.coad.mrad.coad.merged.truncated.mat'];
   edgar_matB_BT = loadinto([assist_dir, assist_file]);
   flynn_matB_BT = repack_edgar(edgar_matB_BT);
   figure; plot(flynn_mat_BT.x, flynn_mat_BT.y(1,:), 'k-',flynn_matB_BT.x, flynn_matB_BT.y(1,:), 'r-')
%%
% Load ASSIST data, put in plots below
assist_dir = ['E:\case_studies\sbsassist_proc\2011_03_24_06_01_15_PROCESSED\'];
assist_file = ['20110324_053829_chA_SKY.coad.mrad.coad.merged.truncated.mat'];
   edgar_mat_BT = loadinto([assist_dir, assist_file]);
   flynn_mat_BT = repack_edgar(edgar_mat_BT);
assist_file = ['20110324_053829_chB_SKY.coad.mrad.coad.merged.truncated.mat'];
   edgar_matB_BT = loadinto([assist_dir, assist_file]);
   flynn_matB_BT = repack_edgar(edgar_matB_BT);
   figure; plot(flynn_mat_BT.x, flynn_mat_BT.y(1,:), 'k-',flynn_matB_BT.x, flynn_matB_BT.y(1,:), 'r-')
%%
% dir = 1
% dif = 2
% zen = 3
% sky = 4

% direct irrad 1
mfrsr.nm = [415,500,615,673,870,940];
mfrsr.dir = ones(size(mfrsr.nm));
cimel_irad.nm = [1640,1020,870,675,500,440,380,340];
cimel_irad.dir = 1.*ones(size(cimel_irad.nm));
rss.nm = [360:1050];
rss.dir = 1.25.*ones(size(rss.nm));
sas.nm = [330:1700];
sas.dir = 1.5.*ones(size(sas.nm));

% diffuse irrad 2
mfrsr.dif = 2.*ones(size(mfrsr.nm));
rss.dif = 2.25.*ones(size(rss.nm));
sas.dif = 2.5.*ones(size(sas.nm));

% zen radiance 3
cimel_rad.nm = [1020,870,675,440];
cimel_rad.zen = 3*ones(size(cimel_rad.nm));
sws.nm = [350:2200];
sws.zen = 3.5 .* ones(size(sws.nm));
sas.zen = 3.25.*ones(size(sas.nm));

% sky radiance 4
cimel_rad.nm = [1020,870,675,440];
cimel_rad.sky = 4*ones(size(cimel_rad.nm));

mfrsr.up = -1.*ones(size(mfrsr.nm));
plots_ppt;
figure; plot(mfrsr.nm,mfrsr.dir,'m*',cimel_irad.nm, cimel_irad.dir,'co',rss.nm, rss.dir,'rx',sas.nm, sas.dir,'b+',...
mfrsr.nm,mfrsr.dif,'m*',rss.nm, rss.dif,'rx',sas.nm, sas.dif,'b+',...  
cimel_rad.nm, cimel_rad.zen, 'co',sws.nm, sws.zen,'gx',sas.nm, sas.zen,'b+',...
cimel_rad.nm, cimel_rad.sky, 'co',...
mfrsr.nm, mfrsr.up,'m*');
set(gca,'YGrid','on');
set(gca,'Ytick',[0,1.75,2.75,3.75,4.75],'Yticklabel',[]);
ylim([-2,5]);
xlabel('Wavelength [nm]')
ylabel([]);
%%

figure; 
plot(mfrsr.nm,mfrsr.dir,'m*',cimel_irad.nm, cimel_irad.dir,'co',rss.nm, rss.dir,'rx',sas.nm, sas.dir,'b+',...
   sws.nm, sws.zen,'gx');
legend('MFRSR','Cimel','RSS','SAS','SWS');





%%
cimel = rd_cim