function [zen] = run_sbdart_allsky_3
% [zen] = run_sbdart_allsky_3
% Figuring out how to run SBDART for full sky
% accept alm retrieval along with coid at retrieval wavelengths. 440, 500, 615, 870, 1020?
% Compute radiances  at MFRSR wavelengths (415, 500, 615, 675, 870, 1p6)
% Then what?

% I have successfully demonstrated that SBDART-generated ALM and PPL can be converted
% to a quantity proportional to PFN and overlay each other except in regions where
% multiple scattering increases, and have also demonstrated consistency with
% meausured sky scans (alm,ppl).

% Satifactorily compared total PFN from PFN_675_total + PFN_65_Ray to ~pfn_ppl and ~pfn_alm 
% Now re-factoring to facilitate comparing each wavelength
% This is subtle since the wavelengths are reported as different times in some files,
% and as concurrent values in others.

% Unsatisfyingly complicated.  Try again, but with more than one 675 and 870 scan.
if isafile('allsky_3.mat')
   load allsky_3.mat
else

warning('Careful with this function.  Is in flux.  Connor 2023-12-13 AGU');
 alm = rd_anetalm_v3; 
 a380 = find(alm.Nominal_Wavelength_nm_==380);
 a440 = find(alm.Nominal_Wavelength_nm_==440); 
 a675 = find(alm.Nominal_Wavelength_nm_==675); 
 a870 = find(alm.Nominal_Wavelength_nm_==870);
 a1um = find(alm.Nominal_Wavelength_nm_==1020);
 a1p6 = find(alm.Nominal_Wavelength_nm_==1640);
 ppl = anet_ppl_zenrad(ceil(alm.time(end)), floor(alm.time(1))); 
 p380 = find(ppl.Nominal_Wavelength_nm_==380);
 p440 = find(ppl.Nominal_Wavelength_nm_==440); 
 p675 = find(ppl.Nominal_Wavelength_nm_==675); 
 p870 = find(ppl.Nominal_Wavelength_nm_==870);
 p1um = find(ppl.Nominal_Wavelength_nm_==1020);
 p1p6 = find(ppl.Nominal_Wavelength_nm_==1640);

 asym = rd_anetaip_v3; caod = rd_anetaip_v3;  pfn = rd_anetpfn_v3; ssa = rd_anetaip_v3; tod = rd_anetaod_v3;
ESR = gueymard_ESR;
TOA_anet = interp1(ESR(:,1), ESR(:,3), [380,440,675,870,1020,1640],'pchip');%W/m2/nm
TOA_mfr = interp1(ESR(:,1), ESR(:,3), [415,500,615, 675,870,1625],'pchip');

 save allsky_3.mat
end


figure; plot(serial2doys(caod.time), [caod.AOD_Coincident_Input_440nm_, caod.AOD_Coincident_Input_675nm_,...
   caod.AOD_Coincident_Input_870nm_, caod.AOD_Coincident_Input_1020nm_],'o',...
  serial2doys(alm.time(a675)), zeros(size(a675)),'k*', serial2doys(ppl.time(p675)), zeros(size(p675)),'rx');
menu('Zoom to select a period','ok')
xl = xlim; xl = mean(xl);
aindx = interp1(serial2doys(alm.time(a675)), [1:length(alm.time(a675))],xl,'nearest','extrap'); aindx = a675(aindx);
pindx = interp1(serial2doys(ppl.time(p675)), [1:length(ppl.time(p675))],xl,'nearest','extrap');  pindx = p675(pindx);
cindx = interp1(serial2doys(caod.time), [1:length(caod.time)],xl,'nearest','extrap'); 
tindx = interp1(serial2doys(tod.time), [1:length(tod.time)],xl,'nearest','extrap'); 
pf_tot = find(strcmp(pfn.Phase_Function_Mode,'Total'));length(pf_tot);
pf_indx = interp1(serial2doys(pfn.time(pf_tot)), pf_tot,xl,'nearest','extrap'); serial2doys(pfn.time(pf_indx))
{datestr(pfn.time(pf_indx));datestr(alm.time(aindx)); datestr(ppl.time(pindx)); datestr(caod.time(cindx)); datestr(tod.time(tindx))}

% We have nearest instances of alm, ppl, pfn, and retrieved results (caod, asym, ssa, tod)
% Now demonstrate consistency between alm, ppl, and pfn as tau-adjusted pf
% Now account for cosd(OA)...
% for ALM, OA = SZA.
% for PPL, SA = SZA - OZA, so OZA = SZA - SA


OZA = ppl.Solar_Zenith_Angle_Degrees_(pindx) - ppl.SA;
figure_(5); ax(1) = subplot(2,2,1); plot(alm.SA(aindx,:), alm.sky_rad(aindx+ [-3, -1, 0, 1],:),'-');
logy;title('raw ALM scans'); 
subplot(2,2,3); plot(ppl.SA, ppl.sky_rad(pindx+ [-3, -1, 0, 1],:),'-'); logy; 
title('raw PPL scans'); ax(2) = gca; 
subplot(2,2,2); plot(alm.SA(aindx,:), alm.sky_rad(aindx+ [-3, -1, 0, 1],:).*cosd(alm.Solar_Zenith_Angle_Degrees_(aindx+ [-3, -1, 0, 1])),'-',...
   ppl.SA, ppl.sky_rad(pindx+ [-3, -1, 0, 1],:).*cosd(OZA),'k-'); logy; title('cos(OZA) adjusted sky scans'); legend('alm','','','','ppl')
ax(3) = gca; 

% Now demonstrate consistency with PF, adjusting for AOD and Rayleigh.
pf_Ray = (3/4).*(1+cosd(pfn.SA).^2);

pf_tau_adj(1,:) = TOA_anet(2).*((pfn.P_440nm(pf_indx,:).*caod.AOD_Coincident_Input_440nm_(cindx) + ...
   pf_Ray.*tod.AOD_440nm_Rayleigh(tindx)));
pf_tau_adj(2,:) = TOA_anet(3).*((pfn.P_675nm(pf_indx,:).*caod.AOD_Coincident_Input_675nm_(cindx) + ...
   pf_Ray.*tod.AOD_675nm_Rayleigh(tindx)));
pf_tau_adj(3,:) = TOA_anet(4).*((pfn.P_870nm(pf_indx,:).*caod.AOD_Coincident_Input_870nm_(cindx) + ...
   pf_Ray.*tod.AOD_870nm_Rayleigh(tindx)));
pf_tau_adj(4,:) = TOA_anet(5).*((pfn.P_1020nm(pf_indx,:).*caod.AOD_Coincident_Input_1020nm_(cindx) + ...
   pf_Ray.*tod.AOD_1020nm_Rayleigh(tindx)));

ax(4) = subplot(2,2,4);  plot(pfn.SA, 80.*(pf_tau_adj),'--', ...
   ppl.SA, ppl.sky_rad(pindx+ [-3, -1, 0, 1],:).*cosd(OZA),'k-'); 
logy; legend('pfn*tau*toa', '','','','ppl');
title('Scaled PFN and cos(OZA) adjusted PPL')
linkaxes(ax,'xy')

%% Maybe OK for 675?  Now try 870
aindx = interp1(serial2doys(alm.time(a870)), [1:length(alm.time(a870))],xl,'nearest','extrap'); aindx = a870(aindx);
pindx = interp1(serial2doys(ppl.time(p870)), [1:length(ppl.time(p870))],xl,'nearest','extrap');  pindx = p870(pindx);
cindx = interp1(serial2doys(caod.time), [1:length(caod.time)],xl,'nearest','extrap'); 
tindx = interp1(serial2doys(tod.time), [1:length(tod.time)],xl,'nearest','extrap'); 
pf_tot = find(strcmp(pfn.Phase_Function_Mode,'Total'));length(pf_tot)
pf_indx = interp1(serial2doys(pfn.time(pf_tot)), pf_tot,xl,'nearest','extrap'); serial2doys(pfn.time(pf_indx))
% We have nearest instances of alm, ppl, pfn, and retrieved results (caod, asym, ssa, tod)
% Need ESR to convert pf to rad


% Now demonstrate consistency between alm, ppl, and pfn as tau-adjusted pf
% Now account for cosd(OA)...
% for ALM, OA = SZA.
% for PPL, SA = SZA - OZA, so OZA = SZA - SA
OZA = ppl.Solar_Zenith_Angle_Degrees_(pindx) - ppl.SA;
figure; plot(alm.SA(aindx,:), alm.sky_rad(aindx,:).*cosd(alm.Solar_Zenith_Angle_Degrees_(aindx)),'-',...
   ppl.SA, ppl.sky_rad(pindx,:).*cosd(OZA),'m-'); logy; title('cos(OZA) adjusted sky scans 870nm'); legend('alm','ppl')

% Now demonstrate consistency with PF, adjusting for AOD and Rayleigh.
pf_Ray = (3/4).*(1+cosd(pfn.SA).^2);
pf_tau_adj = pfn.P_870nm(pf_indx,:).*caod.AOD_Coincident_Input_870nm_(cindx) + ...
   pf_Ray.*tod.AOD_870nm_Rayleigh(tindx);
hold('on'); plot(pfn.SA, 60.*TOA_anet(4).*pf_tau_adj,'g-'); logy; legend('alm','ppl','pfn*tau')

% Next, demonstrate agreement with SBDART modeled PPL and ALM.


 
anet.time = caod.time;
anet.wl = [440,675,870,1020];
anet.aod = [caod.AOD_Coincident_Input_440nm_,caod.AOD_Coincident_Input_675nm_, caod.AOD_Coincident_Input_870nm_, caod.AOD_Coincident_Input_1020nm_];
anet.ssa = [ssa.Single_Scattering_Albedo_440nm_, ssa.Single_Scattering_Albedo_675nm_, ssa.Single_Scattering_Albedo_870nm_, ssa.Single_Scattering_Albedo_1020nm_];
anet.sza = ssa.Solar_Zenith_Angle_for_Measurement_Start_Degrees_;
anet.g = [asym.Asymmetry_Factor_Total_440nm_, asym.Asymmetry_Factor_Total_675nm_, asym.Asymmetry_Factor_Total_870nm_, asym.Asymmetry_Factor_Total_1020nm_];

tot_ij = find(foundstr(pfn.Phase_Function_Mode,'Total')); length(tot_ij);
fin_ij = find(foundstr(pfn.Phase_Function_Mode,'Fine')); length(fin_ij);
crs_ij = find(foundstr(pfn.Phase_Function_Mode,'Coarse')); length(crs_ij);

clear qry
qry.SAZA=180;
qry.NSTR=6;
qry.CORINT='.true.';
qry.iout=6;
qry.NF=3;
qry.idatm=2;
% qry.pmaer= [0.80,0.70,0.60,0.50,
% 0.64,0.49,0.36,0.25,
% 0.51,0.34,0.22,0.12,
% 0.41,0.24,0.13,0.06,
% 0.33,0.17,0.08,0.03,
% 0.26,0.12,0.05,0.02]

% If output is desired at a single wavelength, set
% WLINF=WLSUP and ISAT=0. In this case, SBDART will
% set WLINC=1 (the user specified value of WLINC is ignored)
% and the output will be in units of (W/m2/um) for
% irradiance and (W/m2/um/sr) for radiance.

qry.isat=0;
qry.wlinf=.870;
qry.wlsup=qry.wlinf;

qry.IAER=5; % Oceanic==3  Probably better IAER=5 specify wlbaer, qbaer, wbaer, and gbaer. % what about tbaer?  

qry.RHAER=0.8; % RHAER has no effect when IAER=5
qry.wlbaer=anet.wl./1000;
qry.QBAER = anet.aod(cindx,:);
qry.wbaer = anet.ssa(cindx,:);
qry.gbaer = anet.g(cindx,:);
qry.SZA = anet.sza(cindx);

% qry.zout = [0,0];
figure; plot(ppl.SA, ppl.sky_rad(pindx,:),'-o')
% PPL test
qry.PHI=[0 180]; 
qry.UZEN = [1 2.5 5:5:85 89]; 
qry.UZEN = fliplr(180-setxor(qry.UZEN,qry.SZA));
[w,s,QRY] = qry_sbdart_(qry);
pp_675 = parse_sbdart_reply(w,QRY);
figure; plot(ppl.SA, ppl.sky_rad(pindx,:),'-o',pp_675.SA, pp_675.rad,'r-'); logy

% ALM test
qry.PHI = [0:10:360];
qry.UZEN = 180-qry.SZA;
[w,s,QRY] = qry_sbdart_(qry);
alm_675 = parse_sbdart_reply(w,QRY);
figure; plot(alm.SA(aindx,:), alm.sky_rad(aindx,:),'-', alm_675.SA, alm_675.rad,'c-'); logy

% Zen test
qry.PHI = 0;
qry.UZEN = 180;

% Hybrid or Hemisphere test

% Let's try to generate sectors at high angular resolution and then stitch them
% together. Take it piece by piece to make sure we understand the reported radiances.
% Then integrate to see if they agree with the fluxes.
qry.UZEN=fliplr(180-sort([45,5,85, 45 - logspace(log10(3),log10(44),18), 45 + logspace(log10(3),log10(44),18) ])); 
qry.NSTR = 20;
qry = rmfield(qry, 'CORINT');
qry.CORINT = '.true';
qry.ISAT=20; qry.isat=20;
tic

qry.PHI = linspace(0,89,40);
[w,s,QRY] = qry_sbdart_(qry);
quad1 = parse_sbdart_reply(w,QRY);

qry.PHI = 90+linspace(0,89,40);
[w,s,QRY] = qry_sbdart_(qry);
quad2 = parse_sbdart_reply(w,QRY);
% plot3(quad2.phi*ones(size(quad2.zen)),ones(size(quad2.phi))*quad2.zen, quad2.rad,'-');
 
qry.PHI = linspace(0,89,40)+180;
[w,s,QRY] = qry_sbdart_(qry);
quad3 = parse_sbdart_reply(w,QRY);
% plot3(quad3.phi*ones(size(quad3.zen)),ones(size(quad3.phi))*quad3.zen, quad3.rad,'-');
 
qry.PHI = linspace(0,89,40)+270;
[w,s,QRY] = qry_sbdart_(qry);
quad4 = parse_sbdart_reply(w,QRY);
% plot3(quad4.phi*ones(size(quad4.zen)),ones(size(quad4.phi))*quad4.zen, quad4.rad,'-');
quad4

hemi.zend = quad1.zen; 
hemi.phid = [quad1.phi; quad2.phi; quad3.phi; quad4.phi];
hemi.rad = [quad1.rad; quad2.rad; quad3.rad; quad4.rad];
hemi.zen = pi.*hemi.zend./180; hemi.phi = pi.*hemi.phid./180;
botdif = trapz(hemi.phi, trapz(cos(hemi.zen), (ones([160,1])*cos(hemi.zen).*hemi.rad)'));
disp(botdif./quad1.BOTDIF)
toc

[X,Y,Z] = sph2cart(hemi.phi*ones(size(hemi.zen)),90-ones(size(hemi.phi))*hemi.zen,hemi.rad);
% figure; plot3(X,Y,Z,'-')
figure; plot3(X',Y',Z','-')
% uncomment for Almucantar
% qry.UZEN = qry.SZA; qry = rmfield(qry,'NZEN');

end 