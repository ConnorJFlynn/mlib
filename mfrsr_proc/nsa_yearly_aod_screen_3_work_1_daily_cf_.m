function nc = nsa_yearly_aod_screen_3c

nc = ancload;
% Clean up existing QC error with isolated variability flags at 00:00 UTC
% These tests are in AOD QC bits 3 and 7
% Clean this up for filter2
qc = nc.vars.qc_aerosol_optical_depth_filter2;
vari = bitget(uint32(qc.data),3);  %Test "3" for questionable variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);

vari = bitget(uint32(qc.data),7); %Test "7" for 'bad' variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);
nc.vars.qc_aerosol_optical_depth_filter2 = qc;


% Clean this up for filter5
qc = nc.vars.qc_aerosol_optical_depth_filter5;
vari = bitget(uint32(qc.data),3);  %Test "3" for questionable variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);

vari = bitget(uint32(qc.data),7); %Test "7" for 'bad' variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);
nc.vars.qc_aerosol_optical_depth_filter5 = qc;

% Clean this up for Angstrom Exponent
qc = nc.vars.qc_angstrom_exponent;
vari = bitget(uint32(qc.data),2);  %Test "2" for questionable variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);

vari = bitget(uint32(qc.data),5); %Test "5" for 'bad' variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);
nc.vars.qc_angstrom_exponent = qc;
%%
filter2_qc = nc.vars.qc_aerosol_optical_depth_filter2.data >0; % good when ~filter_qc
filter5_qc = nc.vars.qc_aerosol_optical_depth_filter5.data >0;
ang_qc = nc.vars.qc_angstrom_exponent.data > 0; % good when ~ang_qc
Tr_test = real(log10(nc.vars.Tr_filter2.data))<log10(.01);  % good when ~Tr_test
Tr_test = nc.vars.Tr_filter2.data<0.04;  % good when ~Tr_test
% for d = floor(datenum(2006,1,1)):ceil(datenum(2006,12,31))
bad_qc = qc_impacts(nc.vars.qc_aerosol_optical_depth_filter2)>0;
nc.vars.aerosol_optical_depth_filter2.data(bad_qc) = NaN;
bad_qc = qc_impacts(nc.vars.qc_aerosol_optical_depth_filter5)>0;
nc.vars.aerosol_optical_depth_filter5.data(bad_qc) = NaN;
bad_qc = qc_impacts(nc.vars.qc_angstrom_exponent)>0;
nc.vars.angstrom_exponent.data(bad_qc) = NaN;
doy = serial2doy(nc.time);
first_day = floor(min(doy));
last_day = floor(max(doy));
days = last_day - first_day + 1;


nc_.vars.qc_aerosol_optical_depth_filter2 = nc.vars.qc_aerosol_optical_depth_filter2;
nc_.vars.qc_aerosol_optical_depth_filter5 = nc.vars.qc_aerosol_optical_depth_filter5;
nc_.vars.qc_angstrom_exponent = nc.vars.qc_angstrom_exponent;
nc_.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc_.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
bad_qc = qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter2)>0;
nc_.vars.aerosol_optical_depth_filter2.data = nc.vars.aerosol_optical_depth_filter2.data;
nc_.vars.aerosol_optical_depth_filter2.data(bad_qc) = NaN;
bad_qc = qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter5)>0;
nc_.vars.aerosol_optical_depth_filter5.data =nc.vars.aerosol_optical_depth_filter5.data;
nc_.vars.aerosol_optical_depth_filter5.data(bad_qc) = NaN;
bad_qc = (qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter2)>0)|(qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter5)>0);
nc_.vars.angstrom_exponent.data =nc.vars.angstrom_exponent.data;
nc_.vars.angstrom_exponent.data(bad_qc) = NaN;

figure; 
ax(1) = subplot(3,1,1);
aa = plot(serial2doy(nc.time(~filter2_qc)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc), 'ro',...
    serial2doy(nc.time(~filter2_qc & ~Tr_test)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc& ~Tr_test), 'go');
title(['20-s,  hourly, daily averaged AOD: ',datestr(mean(nc.time),'yyyy')]);
ylabel('AOD');
set(aa(1),'markersize',4,'markerfaceColor','r');
set(aa(2),'markersize',4,'markerfaceColor','g');
N_screened = sum(~filter2_qc)-sum(~filter2_qc & ~Tr_test);
Fraction_screened = N_screened ./ sum(~filter2_qc);

for d = days:-1:1;
   day = (doy >= (first_day -1 + d)) & (doy < (first_day +d));
   orig.time(d) = mean(doy(day));
   orig.aod_500(d) = meannonan(nc.vars.aerosol_optical_depth_filter2.data(day));   
   orig.aod_870(d) = meannonan(nc.vars.aerosol_optical_depth_filter5.data(day));
   orig.ang(d) = meannonan(nc.vars.angstrom_exponent.data(day));
   
   scrn.time(d) = mean(doy(day));
   scrn.aod_500(d) = meannonan(nc_.vars.aerosol_optical_depth_filter2.data(day));   
   scrn.aod_870(d) = meannonan(nc_.vars.aerosol_optical_depth_filter5.data(day));
   scrn.ang(d) = meannonan(nc_.vars.angstrom_exponent.data(day));

   orig.N(d) = sum(~isNaN(nc.vars.aerosol_optical_depth_filter2.data(day)));
   scrn.N(d) = sum(~isNaN(nc_.vars.aerosol_optical_depth_filter2.data(day)));
   orig.frac_good(d) = scrn.N(d)./orig.N(d);   
end
N_daily_screened = sum(orig.aod_500>0) - sum(~isNaN(scrn.aod_500));
Fraction_daily_screened = N_daily_screened ./ sum(orig.aod_500>0);
ax(3) = subplot(3,1,3);
cc = plot(serial2doy(orig.time), orig.aod_500,'ro',serial2doy(scrn.time), scrn.aod_500,'go');
ylabel('daily AOD');
xlabel('time [day of year]');
set(cc(1),'markersize',4,'markerfaceColor','r');
set(cc(2),'markersize',4,'markerfaceColor','g');
xlabel('time [day of year]');

%%
for d = 24.*days:-1:1;
   day = (doy >= (first_day -1 + d./24)) & (doy < (first_day +d./24));
   horig.time(d) = mean(doy(day));
   horig.aod_500(d) = meannonan(nc.vars.aerosol_optical_depth_filter2.data(day));
   horig.aod_870(d) = meannonan(nc.vars.aerosol_optical_depth_filter5.data(day));
   horig.ang(d) = meannonan(nc.vars.angstrom_exponent.data(day));
   hscrn.time(d) = mean(doy(day));
   hscrn.aod_500(d) = meannonan(nc_.vars.aerosol_optical_depth_filter2.data(day));
   hscrn.aod_870(d) = meannonan(nc_.vars.aerosol_optical_depth_filter5.data(day));
   hscrn.ang(d) = meannonan(nc_.vars.angstrom_exponent.data(day));

   horig.N(d) = sum(~isNaN(nc.vars.aerosol_optical_depth_filter2.data(day)));
   hscrn.N(d) = sum(~isNaN(nc_.vars.aerosol_optical_depth_filter2.data(day)));
   horig.frac_good(d) = horig.N(d)./hscrn.N(d);
   horig.frac_good(d) = hscrn.N(d)./horig.N(d);   
end
N_hourly_screened = sum(horig.aod_500>0) - sum(~isNaN(hscrn.aod_500));
Fraction_hourly_screened = N_hourly_screened ./ sum(horig.aod_500>0);
ax(2) = subplot(3,1,2);
bb = plot(serial2doy(horig.time), horig.aod_500,'ro',serial2doy(hscrn.time), hscrn.aod_500,'go');
ylabel('hourly AOD');
set(bb(1),'markersize',4,'markerfaceColor','r');
set(bb(2),'markersize',4,'markerfaceColor','g');

%%

return


