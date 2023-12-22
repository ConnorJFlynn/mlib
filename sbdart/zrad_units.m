function zrad_units

nfov = anc_load;
sas = anc_load;
cim = anc_load;
figure; plot(nfov.time, 1000.*nfov.vdata.radiance_870nm, '.', sas.time, sas.vdata.zenith_radiance_870nm,'.'); dynamicDateTicks; logy

figure; plot(cim.time, 10.*cim.vdata.zenith_sky_radiance_A(cim.vdata.nominal_wavelength==870,:),'*', sas.time, sas.vdata.zenith_radiance_870nm,'.');
dynamicDateTicks; logy


clear qry
qry.NF=3;
qry.idatm=2;
qry.RHAER=0.8;
qry.SAZA=180;
qry.NSTR=20;
qry.CORINT='.true.';
qry.PHI=[0];
qry.SZA=30;

qry.iout=6;
qry.isat=0; % 0 WLINF TO WLSUP WITH FILTER FUNCTION = 1
qry.wlinf=0.415;
qry.wlsup=0.415;
qry.wlbaer=0.415;
qry.IAER=3;
qry.TBAER=.4;
qry.VZEN =[qry.SZA];
      [out] = qry_sbdart(qry);
      zrad = out.rad; % (W/m2/um/sr
tau = [.1:.01:1]; tau = .41;
airmass = 1:.1:7;
SZA = [0:82]; SZA = [47, 51, 57, 68, 75];
tic
for t = length(tau):-1:1
   for z = length(SZA):-1:1
      qry.SZA = SZA(z);
      qry.TBAER=tau(t);
      qry.VZEN =[qry.SZA];
      % pause(.01);
      [out] = qry_sbdart(qry);
      zrad(t,z) = out.rads; % (W/m2/um/sr)