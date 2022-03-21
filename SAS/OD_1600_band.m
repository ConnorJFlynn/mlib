% OD_1600_band

% % Gaussian
% [P,sigma] = gaussian_fwhm(w, mu, FWHM);
% Gaussian profile with unit height centered on mu with full-width half-max of FWHM
% Convert to unit area by dividing by (sigma(SS).*sqrt(2*pi))

h2o_5cm_rod = load(getfullname(['lbl_od*h2o*.nadir']));
co2_410ppm_rod = load(getfullname(['lbl_od*co2*.nadir']));
ch4_1860ppb_rod = load(getfullname(['lbl_od*ch4*.nadir']));
OD_1600_band.nm = 1e7./h2o_5cm_rod(:,1);
nm = OD_1600_band.nm;

[A, filt2] = IntorFilters;
mfrsr_ch7 = interp1(filt2.nm, filt2.Tr, nm, 'linear');
mfrsr_ch7(isnan(mfrsr_ch7)) = interp1(filt2.nm, filt2.Tr, nm(isnan(mfrsr_ch7)), 'nearest','extrap');
mfrsr_ch(mfrsr_ch7<0) = 0; mfrsr_ch7 = mfrsr_ch7./trapz(flipud(nm), flipud(mfrsr_ch7));
figure; plot(nm, mfrsr_ch7,'-');

OD_1600_band.ray = rayleigh_ht(nm./1000,1013.25);

fprintf('%s %e \n','Rayleigh: ',trapz(flipud(nm), flipud(mfrsr_ch7.*OD_1600_band.ray))); 
fprintf('%s %e \n','H2O[5cm]: ',trapz(flipud(nm), flipud(mfrsr_ch7.*h2o_5cm_rod(:,2))));
fprintf('%s %e \n','CH4[1860ppb]: ',trapz(flipud(nm), flipud(mfrsr_ch7.*ch4_1860ppb_rod(:,2))));
fprintf('%s %e \n','CO2[1860ppb]: ',trapz(flipud(nm), flipud(mfrsr_ch7.*co2_410ppm_rod(:,2))));

OD_1600_band.h20_5cm = h2o_5cm_rod(:,2)-OD_1600_band.ray ;
OD_1600_band.co2_410ppm = co2_410ppm_rod(:,2)-OD_1600_band.ray ;
OD_1600_band.ch4_1860ppb = ch4_1860ppb_rod(:,2)-OD_1600_band.ray ;


fprintf('%s %e \n','H2O[5cm]: ',trapz(flipud(nm), flipud(mfrsr_ch7.*OD_1600_band.h20_5cm)))
fprintf('%s %e \n','CH4[1860ppb]: ',trapz(flipud(nm), flipud(mfrsr_ch7.*OD_1600_band.ch4_1860ppb)))
fprintf('%s %e \n','CO2[1860ppb]: ',trapz(flipud(nm), flipud(mfrsr_ch7.*OD_1600_band.co2_410ppm)))


cim1640 = cim1640filtfun;
OD_1600_band.mfrsr_1625nm = mfrsr_ch7;
OD_1600_band.cimel_1640nm = interp1(cim1640.nm, cim1640.Tr, nm,'linear');
OD_1600_band.cimel_1640nm(isnan(OD_1600_band.cimel_1640nm)) = interp1(cim1640.nm, cim1640.Tr, nm(isnan(OD_1600_band.cimel_1640nm)),'nearest','extrap');
OD_1600_band.cimel_1640nm(OD_1600_band.cimel_1640nm<0) = 0; 
OD_1600_band.cimel_1640nm = OD_1600_band.cimel_1640nm./trapz(flipud(nm),flipud(OD_1600_band.cimel_1640nm));

figure_(6); 
xx(1) = subplot(3,1,1);
plot(OD_1600_band.nm, [OD_1600_band.h20_5cm,OD_1600_band.ch4_1860ppb, OD_1600_band.co2_410ppm, OD_1600_band.cimel_1640nm, OD_1600_band.mfrsr_1625nm],'-')
tl = title('OD Spectra for H_2O, CH_4, and CO_2 and Unity-Area Filter Functions for MFRSR and Cimel'); set(tl,'interp','tex')
ylabel('OD and Tr')
lg = legend('H_2O','CH_4','CO_2','Cimel','MFRSR'); set(lg,'interp','tex');
xx(2) = subplot(3,1,2);
plot(OD_1600_band.nm, [OD_1600_band.h20_5cm,OD_1600_band.ch4_1860ppb, OD_1600_band.co2_410ppm].*(OD_1600_band.mfrsr_1625nm*ones([1,3])),'-');
title( 'OD spectra multiplied by MFRSR Intor Filter Function CWL = 1625 nm')
lg = legend('H_2O','CH_4','CO_2'); set(lg,'interp','tex');
xx(3) = subplot(3,1,3);
plot(OD_1600_band.nm, [OD_1600_band.h20_5cm,OD_1600_band.ch4_1860ppb, OD_1600_band.co2_410ppm].*(OD_1600_band.cimel_1640nm*ones([1,3])),'-'); 
title( 'OD spectra multiplied by Cimel Filter Function CWL = 1640 nm')
lg = legend('H_2O','CH_4','CO_2'); set(lg,'interp','tex');
xlabel('wavelength [nm]'); ylabel('OD')
linkaxes(xx,'x'); linkaxes(xx(2:3),'y')

mfr_H2O_avg_od = -trapz(OD_1600_band.nm, OD_1600_band.h20_5cm.*OD_1600_band.mfrsr_1625nm);
mfr_CH4_avg_od = -trapz(OD_1600_band.nm, OD_1600_band.ch4_1860ppb.*OD_1600_band.mfrsr_1625nm);
mfr_CO2_avg_od = -trapz(OD_1600_band.nm, OD_1600_band.co2_410ppm.*OD_1600_band.mfrsr_1625nm);
sum([mfr_H2O_avg_od,mfr_CH4_avg_od, mfr_CO2_avg_od])

cim_H2O_avg_od = -trapz(OD_1600_band.nm, OD_1600_band.h20_5cm.*OD_1600_band.cimel_1640nm);
cim_CH4_avg_od = -trapz(OD_1600_band.nm, OD_1600_band.ch4_1860ppb.*OD_1600_band.cimel_1640nm);
cim_CO2_avg_od = -trapz(OD_1600_band.nm, OD_1600_band.co2_410ppm.*OD_1600_band.cimel_1640nm);
sum([cim_H2O_avg_od,cim_CH4_avg_od, cim_CO2_avg_od])

airmass = 1;
Tr_H2O = exp(-OD_1600_band.h20_5cm.*airmass);
OD_H2O_mfr = -log(-trapz(nm,Tr_H2O.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_H2O_cim = -log(-trapz(nm,Tr_H2O.*OD_1600_band.cimel_1640nm))./airmass;

Tr_CH4 = exp(-OD_1600_band.ch4_1860ppb.*airmass);
OD_CH4_mfr = -log(-trapz(nm,Tr_CH4.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_CH4_cim = -log(-trapz(nm,Tr_CH4.*OD_1600_band.cimel_1640nm))./airmass;

Tr_CO2 = exp(-OD_1600_band.co2_410ppm.*airmass);
OD_CO2_mfr = -log(-trapz(nm,Tr_CO2.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_CO2_cim = -log(-trapz(nm,Tr_CO2.*OD_1600_band.cimel_1640nm))./airmass;
sum([OD_H2O_mfr,OD_CH4_mfr,OD_CO2_mfr])
sum([OD_H2O_cim,OD_CH4_cim,OD_CO2_cim])

airmass = 3;
Tr_H2O = exp(-OD_1600_band.h20_5cm.*airmass);
OD_H2O_mfr = -log(-trapz(nm,Tr_H2O.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_H2O_cim = -log(-trapz(nm,Tr_H2O.*OD_1600_band.cimel_1640nm))./airmass;

Tr_CH4 = exp(-OD_1600_band.ch4_1860ppb.*airmass);
OD_CH4_mfr = -log(-trapz(nm,Tr_CH4.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_CH4_cim = -log(-trapz(nm,Tr_CH4.*OD_1600_band.cimel_1640nm))./airmass;

Tr_CO2 = exp(-OD_1600_band.co2_410ppm.*airmass);
OD_CO2_mfr = -log(-trapz(nm,Tr_CO2.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_CO2_cim = -log(-trapz(nm,Tr_CO2.*OD_1600_band.cimel_1640nm))./airmass;
sum([OD_H2O_mfr,OD_CH4_mfr,OD_CO2_mfr])
sum([OD_H2O_cim,OD_CH4_cim,OD_CO2_cim])

airmass = 5;
Tr_H2O = exp(-OD_1600_band.h20_5cm.*airmass);
OD_H2O_mfr = -log(-trapz(nm,Tr_H2O.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_H2O_cim = -log(-trapz(nm,Tr_H2O.*OD_1600_band.cimel_1640nm))./airmass;

Tr_CH4 = exp(-OD_1600_band.ch4_1860ppb.*airmass);
OD_CH4_mfr = -log(-trapz(nm,Tr_CH4.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_CH4_cim = -log(-trapz(nm,Tr_CH4.*OD_1600_band.cimel_1640nm))./airmass;

Tr_CO2 = exp(-OD_1600_band.co2_410ppm.*airmass);
OD_CO2_mfr = -log(-trapz(nm,Tr_CO2.*OD_1600_band.mfrsr_1625nm))./airmass;
OD_CO2_cim = -log(-trapz(nm,Tr_CO2.*OD_1600_band.cimel_1640nm))./airmass;
sum([OD_H2O_mfr,OD_CH4_mfr,OD_CO2_mfr])
sum([OD_H2O_cim,OD_CH4_cim,OD_CO2_cim])

% % At GSFC yesterday we had (at 1640 nm) OD_CH4=0.0086; OD_CO2=0.004651 and OD_H20=0.001 (for wvc~0.55 cm).
% tau_co2 = 0.0047 * exp(-0.0001215 * elevation); elevation is in meters (if I am not mistaken) -Giles et al. 2019, p.173
% tau_ch4 = 0.0087 * exp(-0.0001225 * elevation);
% 1020 :  tau_wv = water_vapor * 0.002259 + 0.000426;
% 1640 :  tau_wv = water_vapor * 0.001925 - 0.000033;
anet_gas_subt = 0.0086+0.004651+0.001
lbl_cim_avg_od = sum([cim_H2O_avg_od,cim_CH4_avg_od, cim_CO2_avg_od])
lbl_cim_gas_subt = sum([OD_H2O_cim,OD_CH4_cim,OD_CO2_cim])




CO2 = load('CO2.mat');
CH4 = load('CH4.mat');
H2O = load('H2O.mat');
He = load('He');

% So for pixels in He.wl that are within the OD wavelength limits compute a
% gaussian in OD.wl centered on the pixel in question from He.wl. 
% Convolve with each OD spectrum to yield the OD in He for that specie.

wl_ = He.wl>=min(CO2.nm) & He.wl<=max(CO2.nm);
wl_ii =find(wl_);
od.wl = He.wl(wl_);
for w = length(wl_ii):-1:1
    wl = He.wl(wl_ii(w));
    gaus = gaussian_fwhm(CO2.nm, wl, 6);
    area = trapz(CO2.nm, gaus);
    od.CO2(w) = trapz(CO2.nm, gaus.*CO2.block(:,2))./area;
    od.CH4(w) = trapz(CH4.nm, gaus.*CH4.block(:,2))./area;
    od.H2O_5cm(w) = trapz(CH4.nm, gaus.*H2O.block(:,2))./area;
end
figure; plot(He.wl(wl_),od.CO2,'-',He.wl(wl_),od.CH4,'-',He.wl(wl_),od.H2O_5cm,'-',...
   He.wl(wl_),od.CO2+od.CH4+od.H2O_5cm,'k-' ); legend('CO_2','CH_4','H_2O','all');

