%%
visl = ancload;
% visa = ancload;
% % visl= ancload;
% nira = ancload(strrep(visa.fname,'vis','nir'));
%%
[tmp,noon_ii] = max(visl.vars.cosine_solar_zenith_angle.data)
PM = serial2doys(visl.time)>serial2doys(visl.time(noon_ii));
nm_500 = interp1(visl.vars.wavelength.data, [1:length(visl.vars.wavelength.data)],500,'nearest');
mask = visl.vars.direct_normal_irradiance_mask.data(nm_500,:);
[P,S] = polyfit(visl.vars.airmass.data(PM&mask>0), log((mean(visl.vars.earth_sun_distance.data).^2).*visl.vars.direct_normal_irradiance.data(nm_500,PM&mask>0)),1);

figure; 

plot(visl.vars.airmass.data(PM), log((mean(visl.vars.earth_sun_distance.data).^2).*visl.vars.direct_normal_irradiance.data(nm_500,PM)),'ro',...
     visl.vars.airmass.data(PM&mask>0), log((mean(visl.vars.earth_sun_distance.data).^2).*visl.vars.direct_normal_irradiance.data(nm_500,PM&mask>0)),'bo',...
     [0,3],polyval(P,[0,3]),'k-');
 xlabel('airmass'); legend('rejected points','used for regression');
 ylabel('ln|I| [counts]')
% %%
% T_ray = exp(-m_ray(~PM).*visa.vars.rayleigh_optical_depth.data(nm_500));
% figure; plot(visl.vars.airmass.data(~PM), T_ray,'-')
V = (mean(visl.vars.earth_sun_distance.data).^2).*visl.vars.direct_normal_irradiance.data(nm_500,~PM);
[Vo,tau,Vo_, tau_, good] = dbl_lang(visl.vars.airmass.data(~PM), ...
  V ,2.5,1,1);
 %%
V = (mean(visl.vars.earth_sun_distance.data).^2).*visl.vars.direct_normal_irradiance.data(nm_500,PM);
[Vo,tau,Vo_, tau_, good] = dbl_lang(visl.vars.airmass.data(PM), ...
  V ,2.5,1,1);
 %%

% %%
% sza= visl.vars.solar_zenith_angle.data;
% m_ray=1./(cos(sza*pi/180)+0.50572*(96.07995-sza).^(-1.6364)); %Kasten and Young (1989)
% m_H2O=1./(cos(sza*pi/180)+0.0548*(92.65-sza).^(-1.452));   %Kasten (1965)
%%
% nirl = ancload;

vis_nm = visa.vars.wavelength.data>=325 & visa.vars.wavelength.data<=1040;
nir_nm = nira.vars.wavelength.data>=920 & nira.vars.wavelength.data<=1740;
figure; plot(visa.vars.wavelength.data(vis_nm), visa.vars.smoothed_Io_values.data(vis_nm), 'b-'); 
xlabel('wavelength [nm]');
ylabel('digital counts');
title('Smoothed Io spectrum for SASHe at PVC (Cape Cod)')
legend('VIS CCD Spectrometer');

figure; plot(nira.vars.wavelength.data(nir_nm), nira.vars.smoothed_Io_values.data(nir_nm), 'r-'); 
xlabel('wavelength [nm]');
ylabel('digital counts');
title('Smoothed Io spectrum for SASHe at PVC (Cape Cod)')
legend('NIR CCD Spectrometer');


%%


vis_nm = visa.vars.wavelength.data>=325 & visa.vars.wavelength.data<=1040;
nir_nm = nira.vars.wavelength.data>=920 & nira.vars.wavelength.data<=1740;
[~,sort_ii] = sort(visa.vars.Io_values.data(464,:));
vIo_stdiq = std(visa.vars.Io_values.data(:,sort_ii(13:33))')';
vIo_miq = mean(visa.vars.Io_values.data(:,sort_ii(13:33)),2);
nIo_stdiq = std(nira.vars.Io_values.data(:,sort_ii(13:33))')';
nIo_miq = mean(nira.vars.Io_values.data(:,sort_ii(13:33)),2);
vnm = visa.vars.wavelength.data;
nnm = nira.vars.wavelength.data;
nm_500 = interp1(visa.vars.wavelength.data, [1:length(visa.vars.wavelength.data)],500,'nearest');
xl = [21.5,22.5];
t_ = serial2Hh(visa.time)>xl(1)&serial2Hh(visa.time)<xl(2);
%%
v.stray = vnm<450;
n.stray = nnm<450;
% Bit 1: description: “stray light affects calibration”
% Bit 1: assessment “indeterminate”
% Bit 1: “true” for WL < 400 

v_.stray = vnm<370;
n_.stray = nnm<370;
% Bit 2: description: “stray light severely affects calibration”
% Bit 2: assessment “bad”
% Bit 2: “true” for WL < 370

v.ozone = (vnm>566&vnm<582)|(vnm>621&vnm<636);
n.ozone = (nnm>566&nnm<582)|(nnm>621&nnm<636);
% Bit 3: description: “uncorrected ozone affects calibration”
% Bit 3: assessment “indeterminate”
% Bit 3: “true” for wavelength WL>566 & WL< 582 | WL>621 & WL< 636 |
% 
v_.ozone = (vnm<350);
n_.ozone = (nnm<350);

% Bit 4: description: “uncorrected ozone severely affects calibration”
% Bit 4: assessment “bad”
% Bit 4: “true” for WL < 350
WL = vnm;
v.pwv = (WL>586 & WL< 600) | (WL>643 & WL< 660) | (WL> 684 & WL<740) | (WL>785 & WL<840) ...
    | (WL>880 & WL<992) | (WL>1020 & WL<1229) | (WL>1243 & WL<1282) | (WL>1292 & WL<1548)| (WL > 1683);
WL = nnm;
n.pwv = (WL>586 & WL< 600) | (WL>643 & WL< 660) | (WL> 684 & WL<740) | (WL>785 & WL<840) ...
    | (WL>880 & WL<992) | (WL>1020 & WL<1229) | (WL>1243 & WL<1282) | (WL>1292 & WL<1548)| (WL > 1683);
 
% Bit 5: description: “uncorrected water vapor affects calibration”
% Bit 5: assessment “indeterminate”
% Bit 5: “true” for wavelength (WL>586 & WL< 600) | (WL>643 & WL< 660) | (WL> 684 & WL<740) | (WL>712 & WL<714.5) | (WL>785 & WL<840) | (WL>880 & WL<992) | (WL>1050 & WL<1229) | (WL>1243 & WL<1282) | (WL>1292 & WL<1548) (WL > 1683)
WL = vnm;
v_.pwv = (WL>714 & WL< 735) | (WL>811 & WL<834) | (WL>890 & WL<988) | (WL>1040 & WL<1232) ...
    | (WL>1242 & WL<1282) | (WL>1294 & WL<1546) |(WL > 1686);
WL = nnm;
n_.pwv = (WL>714 & WL< 735) | (WL>811 & WL<834) | (WL>890 & WL<988) | (WL>1040 & WL<1232) ...
    | (WL>1242 & WL<1282) | (WL>1294 & WL<1546) |(WL > 1686);

% Bit 6: description: “uncorrected water vapor severely affects calibration”
% Bit 6: assessment “bad”
% Bit 6: “true” for wavelength  (WL>714 & WL< 735) | (WL>811 & WL<834) | (WL>890 & WL<988) | (WL>1040 & WL<1232) | (WL>1242 & WL<1282) | (WL>1294 & WL<1546) (WL > 1686)

WL = vnm;
v.O2 = (WL>684 & WL< 708)  | (WL>756 & WL < 770);
WL = nnm;
n.O2 = (WL>684 & WL< 708)  | (WL>756 & WL < 770);

WL = vnm;
v_.O2 = (WL>684 & WL< 708)  | (WL>756 & WL < 770);
WL = nnm;
n_.O2 = (WL>684 & WL< 708)  | (WL>756 & WL < 770);
% Bit 7: description: “uncorrected oxygen severely affects calibration”
% Bit 7: assessment “bad”
% Bit 7: “true” for wavelength (WL>684 & WL< 708)  | (WL>756 & WL < 770)
% 
WL = vnm;
v.CO2 = (WL>1562 & WL<1584) | (WL>1594 & WL<1616);
WL = nnm;
n.CO2 = (WL>1562 & WL<1584) | (WL>1594 & WL<1616);
% Bit 8: description: “uncorrected CO2 affects calibration”
% Bit 8: assessment “indeterminate”
% Bit 8: “true” for wavelength (WL>1562 & WL<1584) | (WL>1594 & WL<1616)
% 
WL = vnm;
v.CH4 = (WL>1630 & WL<1669);
WL = nnm;
n.CH4 = (WL>1630 & WL<1669);
% Bit 9: description: “uncorrected CH4 affects calibration”
% Bit 9: assessment “indeterminate”
% Bit 9: “true” for wavelength  (WL>1630 & WL<1669)
% 
% And two new tests for diffuse_transmittance, direct_normal_transmittance, and aerosol_optical_depth:
% Bit_(n): description: “smoothed_Io_values failed one or more qc tests”
% Bit_(n): assessment: “indeterminate”
% Bit_(n): “true” if any of the qc_smoothed_Io_values tests fail.
% 
% Bit_(n): description: “smoothed_Io_values failed one or more critical qc tests”
% Bit_(n): assessment: “bad”
% Bit_(n): “true” if any of the qc_smoothed_Io_values tests with “bad” assessment fail.
v.ind = v.stray|v.ozone|v.pwv|v.O2|v.CO2|v.CH4;
v_.ind = v_.stray|v_.ozone|v_.O2|v_.pwv;
n.ind = n.stray|n.ozone|n.pwv|n.O2|n.CO2|n.CH4;
n_.ind = n_.stray|n_.ozone|n_.O2|n_.pwv;
%%
vtau = visa.vars.aerosol_optical_depth.data;
vtau(vtau<=0) = NaN;
ntau = nira.vars.aerosol_optical_depth.data;
ntau(ntau<=0) = NaN;
figure;
%


plot([vnm(vis_nm&~v.ind);nnm(nir_nm&~n.ind)],[meannonan(vtau(vis_nm&~v.ind,t_),2);meannonan(ntau(nir_nm&~n.ind,t_),2)],'.g',...
[vnm(vis_nm&v.stray);nnm(nir_nm&n.stray)],[meannonan(vtau(vis_nm&v.stray,t_),2);meannonan(ntau(nir_nm&n.stray,t_),2)],'.',...
[vnm(vis_nm&v.ozone);nnm(nir_nm&n.ozone)],[meannonan(vtau(vis_nm&v.ozone,t_),2);meannonan(ntau(nir_nm&n.ozone,t_),2)],'.',...
[vnm(vis_nm&v.O2);nnm(nir_nm&n.O2)],[meannonan(vtau(vis_nm&v.O2,t_),2);meannonan(ntau(nir_nm&n.O2,t_),2)],'.',...
[vnm(vis_nm&v.pwv);nnm(nir_nm&n.pwv)],[meannonan(vtau(vis_nm&v.pwv,t_),2);meannonan(ntau(nir_nm&n.pwv,t_),2)],'.',...
[vnm(vis_nm&v.CO2);nnm(nir_nm&n.CO2)],[meannonan(vtau(vis_nm&v.CO2,t_),2);meannonan(ntau(nir_nm&n.CO2,t_),2)],'.',...
[vnm(vis_nm&v.CH4);nnm(nir_nm&n.CH4)],[meannonan(vtau(vis_nm&v.CH4,t_),2);meannonan(ntau(nir_nm&n.CH4,t_),2)],'.');
legend('aerosol','stray light','O3','O2-O2 O4','PWV','CO2','CH4');
hold('on');
plot([vnm(vis_nm&~v.ind);nnm(nir_nm&~n.ind)],[meannonan(vtau(vis_nm&~v.ind,t_),2);meannonan(ntau(nir_nm&~n.ind,t_),2)],'.g',...
[vnm(vis_nm&v_.stray);nnm(nir_nm&n_.stray)],[meannonan(vtau(vis_nm&v_.stray,t_),2);meannonan(ntau(nir_nm&n_.stray,t_),2)],'x',...
[vnm(vis_nm&v_.ozone);nnm(nir_nm&n_.ozone)],[meannonan(vtau(vis_nm&v_.ozone,t_),2);meannonan(ntau(nir_nm&n_.ozone,t_),2)],'x',...
[vnm(vis_nm&v_.O2);nnm(nir_nm&n_.O2)],[meannonan(vtau(vis_nm&v_.O2,t_),2);meannonan(ntau(nir_nm&n_.O2,t_),2)],'x',...
[vnm(vis_nm&v_.pwv);nnm(nir_nm&n_.pwv)],[meannonan(vtau(vis_nm&v_.pwv,t_),2);meannonan(ntau(nir_nm&n_.pwv,t_),2)],'x');
% a1(1) = subplot(2,1,2);
xlabel('wavelength [nm]');
a1(1) = gca;

% a1(2) = subplot(2,1,1);
figure;
plot(vnm(vis_nm), meannonan(vtau(vis_nm,t_),2),'.g',...
    vnm(vis_nm&v.ind),meannonan(vtau(vis_nm&v.ind,t_),2),'y.',...
    vnm(vis_nm&v_.ind),meannonan(vtau(vis_nm&v_.ind,t_),2),'r.',...
    nnm(nir_nm), meannonan(ntau(nir_nm,t_),2),'.g',...
    nnm(nir_nm&n.ind),meannonan(ntau(nir_nm&n.ind,t_),2),'y.',...
    nnm(nir_nm&n_.ind),meannonan(ntau(nir_nm&n_.ind,t_),2),'r.')
title('Rayleigh-subtracted, Ozone subtracted OD and uncorrected components');
xlabel('wavelength [nm]');
legend('good','suspect','bad')
a1(2) = gca;
linkaxes(a1,'x');
%%
vpct = 100.*vIo_stdiq./vIo_miq;
npct = 100.*nIo_stdiq./nIo_miq;
figure;
% a2(1) = subplot(2,1,2);

plot([vnm(vis_nm&~v.ind);nnm(nir_nm&~n.ind)],[vpct(vis_nm&~v.ind);npct(nir_nm&~n.ind)],'.g',...
[vnm(vis_nm&v.stray);nnm(nir_nm&n.stray)],[vpct(vis_nm&v.stray);npct(nir_nm&n.stray)],'.',...
[vnm(vis_nm&v.ozone);nnm(nir_nm&n.ozone)],[vpct(vis_nm&v.ozone);npct(nir_nm&n.ozone)],'.',...
[vnm(vis_nm&v.O2);nnm(nir_nm&n.O2)],[vpct(vis_nm&v.O2);npct(nir_nm&n.O2)],'.',...
[vnm(vis_nm&v.pwv);nnm(nir_nm&n.pwv)],[vpct(vis_nm&v.pwv);npct(nir_nm&n.pwv)],'.',...
[vnm(vis_nm&v.CO2);nnm(nir_nm&n.CO2)],[vpct(vis_nm&v.CO2);npct(nir_nm&n.CO2)],'.',...
[vnm(vis_nm&v.CH4);nnm(nir_nm&n.CH4)],[vpct(vis_nm&v.CH4);npct(nir_nm&n.CH4)],'.');
legend('aerosol','stray light','O3','O2-O2 O4','PWV','CO2','CH4');
hold('on');
plot([vnm(vis_nm&~v.ind);nnm(nir_nm&~n.ind)],[vpct(vis_nm&~v.ind);npct(nir_nm&~n.ind)],'.g',...
[vnm(vis_nm&v_.stray);nnm(nir_nm&n_.stray)],[vpct(vis_nm&v_.stray);npct(nir_nm&n_.stray)],'x',...
[vnm(vis_nm&v_.ozone);nnm(nir_nm&n_.ozone)],[vpct(vis_nm&v_.ozone);npct(nir_nm&n_.ozone)],'x',...
[vnm(vis_nm&v_.O2);nnm(nir_nm&n_.O2)],[vpct(vis_nm&v_.O2);npct(nir_nm&n_.O2)],'x',...
[vnm(vis_nm&v_.pwv);nnm(nir_nm&n_.pwv)],[vpct(vis_nm&v_.pwv);npct(nir_nm&n_.pwv)],'x');
a2(1) = gca;
% a2(2) = subplot(2,1,1);
figure;
plot(vnm(vis_nm), vpct(vis_nm),'.g',...
    vnm(vis_nm&v.ind),vpct(vis_nm&v.ind),'y.',...
    vnm(vis_nm&v_.ind),vpct(vis_nm&v_.ind),'r.',...
    nnm(nir_nm), npct(nir_nm),'.g',...
    nnm(nir_nm&n.ind),npct(nir_nm&n.ind),'y.',...
    nnm(nir_nm&n_.ind),npct(nir_nm&n_.ind),'r.')
title('Calibration variability and atmospheric components');
xlabel('wavelength [nm]');
legend('good','suspect','bad');
a2(2) = gca;
linkaxes([a1,a2],'x');
% a2(1) = subplot(2,2,2);
% plot(nnm(nir_nm),100.*nIo_stdiq(nir_nm)./nIo_miq(nir_nm),'-g')
% 
% a2(2) = subplot(2,2,4);
% plot()
% linkaxes(a2,'x');
% 

