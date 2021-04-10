vis =anc_bundle_files(getfullname('enaswsvis*.nc','swsvis'));
nir = anc_bundle_files(getfullname('enaswsnir*.nc','swsnir'));
swsdark = anc_bundle_files(getfullname('enaswsdark*.nc','swsdark'));
swsrad = anc_bundle_files(getfullname('enaswsrad*.nc','swsrad'));
guey = load('guey'); TOA.nm = guey.guey(:,1); TOA.irad = guey.guey(:,3);
vistoa = interp1(TOA.nm, TOA.irad, vis.vdata.wavelength,'pchip');
nirtoa = interp1(TOA.nm, TOA.irad, nir.vdata.wavelength,'pchip');
cimtoa = interp1(TOA.nm, TOA.irad, [440,500,675,870,1020,1640],'pchip');

ol_lims = [965 985];
wl_vis1 = [ol_lims(1); vis.vdata.wavelength(vis.vdata.wavelength>ol_lims(1) & vis.vdata.wavelength<ol_lims(2));ol_lims(2)];
wl_nir1 = [ol_lims(1); nir.vdata.wavelength(nir.vdata.wavelength>ol_lims(1) & nir.vdata.wavelength<ol_lims(2));ol_lims(2)];


ol_vis = vis.vdata.wavelength>ol_lims(1) & vis.vdata.wavelength<ol_lims(2);
ol_nir = nir.vdata.wavelength>ol_lims(1) & nir.vdata.wavelength<ol_lims(2);
ol_wls = unique([vis.vdata.wavelength(ol_vis);nir.vdata.wavelength(ol_nir)]);


LW1 = NaN(size(vis.time));
visrad = NaN(size(vis.vdata.spectra));
nirrad = NaN(size(nir.vdata.spectra));
for in_time = length(vis.time):-1:1

dark_ii = interp1(swsdark.time, [1:length(swsdark.time)],vis.time(in_time),'nearest','extrap');
visrate = (vis.vdata.spectra(:,in_time)./vis.vdata.integration_time(in_time)-swsdark.vdata.dark_count_rate_SW(:,dark_ii));
visrad(:,in_time) = visrate./swsrad.vdata.responsivity_SW;
nirrate = (nir.vdata.spectra(:,in_time)./nir.vdata.integration_time(in_time)-swsdark.vdata.dark_count_rate_LW(:,dark_ii));
nirrad(:,in_time) = nirrate./swsrad.vdata.responsivity_LW;
rad_vis1 = interp1(vis.vdata.wavelength, visrad(:,in_time), wl_vis1,'linear');
rad_nir1 = interp1(nir.vdata.wavelength, nirrad(:,in_time), wl_nir1,'linear');
LW1(in_time) = trapz(wl_vis1, rad_vis1)./trapz(wl_nir1, rad_nir1);

if mod(in_time,100)==0
    disp(in_time)
end
end
LW1(vis.vdata.shutter_state==0) = [];

xl_ = swsrad.vdata.solar_zenith_angle<70;
sm_rat = smooth(swsrad.vdata.SW_LW_ratio,600); 
sm_LW1 = smooth(LW1,600);
figure; plot(swsrad.time(xl_), sm_rat(xl_),'o', swsrad.time(xl_), sm_LW1(xl_),'-'); dynamicDateTicks; 
lg = legend('SW_LW_ratio','LW1'); set(lg,'interp','none')

rat_bounds = [.9:.005:1.33]; rat_lims = [min(rat_bounds), max(rat_bounds)];
figure; hist(sm_LW1(xl_),rat_bounds);xlim(rat_lims);
[Nr,Xr] = hist(sm_LW1(xl_),rat_bounds);
Nr = Nr(Xr>rat_lims(1)&Xr<rat_lims(2)); Xr = Xr((Xr>rat_lims(1)&Xr<rat_lims(2)));
[~,indr] = max(Nr); facr = Xr(indr); facrN1 = Xr(indr-1); facrP1 = Xr(indr+1);
title(['WL[',num2str(ol_lims(1)),',',num2str(ol_lims(2)),']', ' LW_factor=',sprintf('%1.2f ',facr),sprintf('%1.3f ',trapz(Xr, Nr.*Xr)./trapz(Xr, Nr))]);

figure; hist(sm_rat(xl_),rat_bounds);xlim(rat_lims);
[Nr,Xr] = hist(sm_rat(xl_),rat_bounds);
Nr = Nr(Xr>rat_lims(1)&Xr<rat_lims(2)); Xr = Xr((Xr>rat_lims(1)&Xr<rat_lims(2)));
[~,indr] = max(Nr); facr = Xr(indr); facrN1 = Xr(indr-1); facrP1 = Xr(indr+1);
title(['WL[',num2str(ol_lims(1)),',',num2str(ol_lims(2)),']', ' rat_factor=',sprintf('%1.2f ',facr),sprintf('%1.3f ',trapz(Xr, Nr.*Xr)./trapz(Xr, Nr))]);

%%
swsrad = anc_bundle_files(getfullname('enaswsrad*.nc','swsrad'));
xl_ = swsrad.vdata.solar_zenith<70 & swsrad.vdata.solar_zenith>10;
ol_lims = [swsrad.vatts.SW_LW_ratio.wavelength_lower_limit,swsrad.vatts.SW_LW_ratio.wavelength_upper_limit];
sm_rat = smooth(swsrad.vdata.SW_LW_ratio,600); 
figure; plot(swsrad.time(xl_), sm_rat(xl_),'o-'); dynamicDateTicks; 
lg = legend('SW_LW_ratio'); set(lg,'interp','none')

rat_bounds = [.9:.005:1.33]; rat_lims = [min(rat_bounds), max(rat_bounds)];
figure; hist(sm_rat(xl_),rat_bounds);xlim(rat_lims);
[Nr,Xr] = hist(sm_rat(xl_),rat_bounds);
Nr = Nr(Xr>rat_lims(1)&Xr<rat_lims(2)); Xr = Xr((Xr>rat_lims(1)&Xr<rat_lims(2)));
[~,indr] = max(Nr); facr = Xr(indr); facrN1 = Xr(indr-1); facrP1 = Xr(indr+1);
title(['WL[',num2str(ol_lims(1)),',',num2str(ol_lims(2)),']', ' rat_factor=',sprintf('%1.3f ',facr),sprintf('%1.3f ',trapz(Xr, Nr.*Xr)./trapz(Xr, Nr))]);
mean(sm_rat(xl_))
%%



figure; plot(find(vis.vdata.shutter_state~=0), vis.vdata.spectra(37,vis.vdata.shutter_state~=0),'.');

anet_crad = read_cimel_cloudrad;
anet_ppl = anet_ppl_SA_and_radiance;
cim_nm = [440,500,675,870,1020,1640];

nm_440 = find(anet_ppl.Nominal_Wavelength_nm_==440);
nm_500 = find(anet_ppl.Nominal_Wavelength_nm_==500);
nm_675 = find(anet_ppl.Nominal_Wavelength_nm_==675);
nm_870 = find(anet_ppl.Nominal_Wavelength_nm_==870);
nm_1020 = find(anet_ppl.Nominal_Wavelength_nm_==1020); 
nm_1640 = find(anet_ppl.Nominal_Wavelength_nm_==1640);
v_nm = interp1(vis.vdata.wavelength,[1:length(vis.vdata.wavelength)],[440,500,675,870,1020,1640],'nearest');
n_nm = interp1(nir.vdata.wavelength, [1:length(nir.vdata.wavelength)],[440,500,675,870,1020,1640],'nearest');
op = vis.vdata.shutter_state~=0;
% anet_crad AK440,500,675,870,1020,1640 (380 are all 0)
figure; 
plot(vis.time(op), [visrad(v_nm(1:4),op);nirrad(n_nm(5:6),op)],'*','markersize',3); 
legend('SWS 440','SWS 500','SWS 675','SWS 870','SWS 1020','SWS 1640');
dynamicDateTicks;
figure;
plot(anet_crad.time, 10.*[anet_crad.A440nm,anet_crad.A500nm,anet_crad.A675nm,anet_crad.A870nm,anet_crad.A1020nm,anet_crad.A1640nm],'x'); 
dynamicDateTicks; 
legend('440','500','675','870','1020','1640');

figure; 
plot(vis.time(op), 1e-3.*[visrad(v_nm(1:4),op);nirrad(n_nm(5:6),op)]./([vistoa(v_nm(1:4));nirtoa(n_nm(5:6))]*ones([1,sum(op)])),'*','markersize',3); 
legend('SWS 440','SWS 500','SWS 675','SWS 870','SWS 1020','SWS 1640');
ylabel('normalized rad')
dynamicDateTicks;
figure;
plot(anet_crad.time, 1e-2.*[anet_crad.A440nm,anet_crad.A500nm,anet_crad.A675nm,anet_crad.A870nm,anet_crad.A1020nm,anet_crad.A1640nm]./...
 (ones(size(anet_crad.time))*cimtoa)  ,'x'); 
dynamicDateTicks; 
legend('440','500','675','870','1020','1640');


figure; plot(vis.time(op), visrad(v_nm(1),op),'b.',anet_ppl.time(nm_440), 10.*anet_ppl.zen_rad(nm_440),'bo',...
vis.time(op), visrad(v_nm(2),op),'g.',anet_ppl.time(nm_500), 10.*anet_ppl.zen_rad(nm_500),'go',...
vis.time(op), visrad(v_nm(3),op),'m.',anet_ppl.time(nm_675), 10.*anet_ppl.zen_rad(nm_675),'mo',...
vis.time(op), visrad(v_nm(4),op),'r.',anet_ppl.time(nm_870), 10.*anet_ppl.zen_rad(nm_870),'ro'); dynamicDateTicks

figure; plot(nir.time(op), nirrad(n_nm(5),op),'b.',anet_ppl.time(nm_1020), 10.*anet_ppl.zen_rad(nm_1020),'bo',...
nir.time(op), nirrad(n_nm(6),op),'k.',anet_ppl.time(nm_1640), 10.*anet_ppl.zen_rad(nm_1640),'ko'); dynamicDateTicks

figure; plot(anet_ppl.time(nm_440), 1e-2.*anet_ppl.zen_rad(nm_440)./cimtoa(1),'o',...
anet_ppl.time(nm_500), 1e-2.*anet_ppl.zen_rad(nm_500)./cimtoa(2),'o',...
anet_ppl.time(nm_675), 1e-2.*anet_ppl.zen_rad(nm_675)./cimtoa(3),'o',...
anet_ppl.time(nm_870), 1e-2.*anet_ppl.zen_rad(nm_870)./cimtoa(4),'o', ...
anet_ppl.time(nm_1020), 1e-2.*anet_ppl.zen_rad(nm_1020)./cimtoa(5),'o',...
anet_ppl.time(nm_1640), 1e-2.*anet_ppl.zen_rad(nm_1640)./cimtoa(6),'o'); dynamicDateTicks

% AT 16:00 UT on 2019-07-15, clear sky 
cim_sky_Tr = [0.04146, 0.030, 0.0155 0.0103, 0.008690 0.00652]; 
sws_sky_Tr = [0.0384,0.0288, 0.01515, 0.0106, 1.05.*0.0079,  1.05.*0.00608];
figure; plot(cim_nm, -log(cim_sky_Tr), '-o', cim_nm, -log(sws_sky_Tr), '-x'); title('Clear sky normalized radiances')
logx
logy
2.*(cim_sky_Tr-sws_sky_Tr)./ (cim_sky_Tr+sws_sky_Tr)

figure; plot([440,500,675,870],[77,63,26.5,12.2],'-o',[440,500,675,870],[84.9,64.9,26.6,10.9],'-x'); logx; logy
figure;sb(1) = subplot(2,1,1); plot(vis.vdata.wavelength, visrad(:,ainb(20000)), 'o', swsrad.vdata.wavelength_SW, swsrad.vdata.zenith_radiance_SW(:,bina(20000)),'x');
 sb(2) = subplot(2,1,2); plot(vis.vdata.wavelength, visrad(:,ainb(20000))-swsrad.vdata.zenith_radiance_SW(:,bina(20000)),'x');
 xlim([400,900]); linkaxes(sb,'x'); xlim([400,900]);

 figure; plot(nirrad(20,nir.vdata.shutter_state~=0), LW3(vis.vdata.shutter_state~=0),'.')
[ainb, bina] = nearest(vis.time, swsrad.time);
 
 figure;sa(1) = subplot(2,1,1); 
 plot(vis.vdata.wavelength, visrad(:,ainb(24500)), 'o',swsrad.vdata.wavelength_SW, swsrad.vdata.zenith_radiance_SW(:,bina(24500)),'x',...
 nir.vdata.wavelength, nirrad(:,ainb(24500)), 'o', swsrad.vdata.wavelength_LW, swsrad.vdata.zenith_radiance_LW(:,bina(24500)),'x');
logy;
 sa(2) = subplot(2,1,2); 
 plot(vis.vdata.wavelength, visrad(:,ainb(24500))-swsrad.vdata.zenith_radiance_SW(:,bina(24500)),'o',...
     nir.vdata.wavelength, nirrad(:,ainb(24500))-swsrad.vdata.zenith_radiance_LW(:,bina(24500)),'x');
 logy;
 linkaxes(sa,'x');

 figure;sa(1) = subplot(2,1,1); 
 plot(vis.vdata.wavelength, visrad(:,ainb(60000)), 'o',swsrad.vdata.wavelength_SW, swsrad.vdata.zenith_radiance_SW(:,bina(60000)),'x',...
 nir.vdata.wavelength, nirrad(:,ainb(60000)), 'o', swsrad.vdata.wavelength_LW, swsrad.vdata.zenith_radiance_LW(:,bina(60000)),'x');
logy 
sa(2) = subplot(2,1,2); 
 plot(vis.vdata.wavelength, visrad(:,ainb(60000))-swsrad.vdata.zenith_radiance_SW(:,bina(60000)),'o',...
     nir.vdata.wavelength, nirrad(:,ainb(60000))-swsrad.vdata.zenith_radiance_LW(:,bina(60000)),'x');
 linkaxes(sa,'x');
 
 figure; 
 plot(vis.vdata.wavelength, visrad(:,ainb(75000)), 'o', nir.vdata.wavelength, nirrad(:,ainb(75000)), 'o');
 logy
 
 figure; plot(vis.vdata.wavelength, mean(vis.vdata.spectra(:,2:5),2),'-x',swsdark.vdata.wavelength_SW, swsdark.vdata.dark_count_rate_SW(:,1).*swsdark.vdata.integration_time_SW(1),'o') 

figure; plot(vis.time(vis.vdata.shutter_state==1), LW1,'-x'); dynamicDateTicks; legend('My LW scale factor')

figure; plot(swsrad.time, swsrad.vdata.LW_scale_factor,'kx');legend('LW scale factor from swsrad'); dynamicDateTicks


figure; plot(vis.vdata.wavelength, visrad(:, ainb(20000)),'-',nir.vdata.wavelength,nirrad(:,ainb(20000)).*LW_scale_factor(ainb(20000)),'-')
title('My SWS zen radiances'); legend('SW (VIS)', 'LW (NIR)');

figure; plot(swsrad.vdata.wavelength_SW, swsrad.vdata.zenith_radiance_SW(:,bina(20000)), '-',...
    swsrad.vdata.wavelength_LW, swsrad.vdata.zenith_radiance_LW(:,bina(20000)),'-');


figure; plot(swsrad.vdata.wavelength_SW, swsrad.vdata.zenith_radiance_SW(:,bina(20000)), '-',...
    nir.vdata.wavelength,nirrad(:,ainb(20000)).*LW_scale_factor2(ainb(20000)),'r-');

[aind, dina] = nearest(vis.time, swsdark.time);
figure; plot(vis.vdata.wavelength, vis.vdata.spectra(:,ainb(20000))./vis.vdata.integration_time(ainb(20000))-swsdark.vdata.dark_count_rate_SW(:,365),'-', nir.vdata.wavelength, nir.vdata.spectra(:,ainb(20000))./nir.vdata.integration_time(ainb(20000))-swsdark.vdata.dark_count_rate_LW(:,365),'-');


