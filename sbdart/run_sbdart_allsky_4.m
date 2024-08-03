function [zen] = run_sbdart_allsky_4
% [zen] = run_sbdart_allsky_4
% accept alm retrieval along with coid at retrieval wavelengths. 440, 500, 615, 870, 1020?
% Compute radiances  at MFRSR wavelengths (415, 500, 615, 675, 870, 1p6)
% Then what?

% I have demonstrated consistency between meausured sky scans (alm,ppl) when
% adjusted for cos(OZA) which is constant for ALM but varies for PPL>
% I have not been able to demonstrate agreement between the shape of sky scans and PFN after
% "reasonable" adjustments for tau, TOA, cos(OZA), etc.  
%
% So now, following Kaufman's lead I will use PPL (instead of PFN) to estimate sky
% radiance over full hemisphere.  Then compute the ratio between the direct normal
% (from TOD) and this hemispheric diffuse flux to compare to MFRSR interpolated to Cimel WLs. 

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


figure; plot(caod.time, [caod.AOD_Coincident_Input_440nm_, caod.AOD_Coincident_Input_675nm_,...
   caod.AOD_Coincident_Input_870nm_, caod.AOD_Coincident_Input_1020nm_],'o',...
  alm.time(a675), zeros(size(a675)),'k*', ppl.time(p675), zeros(size(p675)),'rx');dynamicDateTicks;
menu('Zoom to select a period','ok')
xl = xlim; xl = mean(xl);
aindx = interp1((alm.time(a675)), [1:length(alm.time(a675))],xl,'nearest','extrap'); aindx = a675(aindx);
pindx = interp1((ppl.time(p675)), [1:length(ppl.time(p675))],xl,'nearest','extrap');  pindx = p675(pindx);
ains = aindx+ fliplr([-3, -1, 0, 1]); 
pins = pindx+ fliplr([-3, -1, 0, 1]);
cindx = interp1((caod.time), [1:length(caod.time)],xl,'nearest','extrap'); 
tindx = interp1((tod.time), [1:length(tod.time)],xl,'nearest','extrap'); 
pf_tot = find(strcmp(pfn.Phase_Function_Mode,'Total'));length(pf_tot);
pf_indx = interp1((pfn.time(pf_tot)), pf_tot,xl,'nearest','extrap'); 
{datestr(pfn.time(pf_indx));datestr(alm.time(aindx)); datestr(ppl.time(pindx)); datestr(caod.time(cindx)); datestr(tod.time(tindx))}



% We have nearest instances of alm, ppl, pfn, and retrieved results (caod, asym, ssa, tod)
% Now demonstrate consistency between alm, ppl, and pfn as tau-adjusted pf
% Now account for cosd(OA)...
% for ALM, OA = SZA.
% for PPL, SA = SZA - OZA, so OZA = SZA - SA

OZA = ppl.Solar_Zenith_Angle_Degrees_(pindx) - ppl.SA;
figure_(6); ax(1) = subplot(2,2,1); plot(alm.SA(aindx,:), alm.sky_rad(ains,:),'-'); logy;
title(['ALM scans, SZA=',sprintf('%2.1f',mean(ppl.Solar_Zenith_Angle_Degrees_(pindx)))]); xlabel('Scattering Angle [deg]');
ylabel('sky radiance [W/m2/um/sr]'); legend('440 nm','675 nm','870 nm', '1020 nm');

ax(2) =subplot(2,2,2); plot(abs(ppl.SA), ppl.sky_rad(pins,:),'-'); logy; 
title(['PPL scans, SZA=',sprintf('%2.1f',mean(ppl.Solar_Zenith_Angle_Degrees_(pindx)))]); xlabel('Scattering Angle [deg]');
ylabel('sky radiance [W/m2/um/sr]'); 

ax(3) =subplot(2,2,3); plot(alm.SA(aindx,:), alm.sky_rad(ains,:)./...
   cosd(alm.Solar_Zenith_Angle_Degrees_(ains)),'-',...
   abs(ppl.SA), ppl.sky_rad(pins,:)./cosd(OZA),'k-'); logy; 
title('sky scans divided by cos(theta)'); xlabel('Scattering Angle [deg]'); ylabel('sky radiance [W/m2/um/sr]'); 
legend('alm/cos(sza)','','','','ppl/cos(oza)')

ax(4) =subplot(2,2,4); plot(alm.SA(aindx,:), alm.sky_rad(ains,:).*...
   cosd(alm.Solar_Zenith_Angle_Degrees_(ains)),'-',...
   abs(ppl.SA), ppl.sky_rad(pins,:).*cosd(OZA),'k-'); logy; 
title('sky scans multiplied by cos(theta)'); xlabel('Scattering Angle [deg]'); ylabel('sky radiance [W/m2/um/sr]'); 
legend('alm*cos(sza)','','','','ppl*cos(oza)')

% Now demonstrate lack of consistency with PF, adjusting for AOD and Rayleigh.
pf_Ray = (3/4).*(1+cosd(pfn.SA).^2);

pf_tau_adj(1,:) = TOA_anet(2).*((pfn.P_440nm(pf_indx,:).*caod.AOD_Coincident_Input_440nm_(cindx) + ...
   pf_Ray.*tod.AOD_440nm_Rayleigh(tindx))); 
pf_tau_adj(2,:) = TOA_anet(3).*((pfn.P_675nm(pf_indx,:).*caod.AOD_Coincident_Input_675nm_(cindx) + ...
   pf_Ray.*tod.AOD_675nm_Rayleigh(tindx)));
pf_tau_adj(3,:) = TOA_anet(4).*((pfn.P_870nm(pf_indx,:).*caod.AOD_Coincident_Input_870nm_(cindx) + ...
   pf_Ray.*tod.AOD_870nm_Rayleigh(tindx)));
pf_tau_adj(4,:) = TOA_anet(5).*((pfn.P_1020nm(pf_indx,:).*caod.AOD_Coincident_Input_1020nm_(cindx) + ...
   pf_Ray.*tod.AOD_1020nm_Rayleigh(tindx)));
figure_(7)
ss(1) = subplot(1,2,1);
above = pfn.SA<pfn.Solar_Zenith_Angle_for_Measurement_Start_Degrees_(pf_indx)+80;
  plot(pfn.SA(above),80.*(pf_tau_adj(:,above)),'--', ...
   abs(ppl.SA), ppl.sky_rad(pins,:).*cosd(OZA),'k-'); 
logy; legend('pfn*tau*toa', '','','','ppl * cos(OZA)');
title('Scaled PFN and cos(OZA) adjusted PPL')


ss(2) = subplot(1,2,2);
  plot(pfn.SA(above),80.*(pf_tau_adj(:,above)),'--', ...
   abs(ppl.SA), ppl.sky_rad(pins,:)./cosd(OZA),'k-'); 
title('cos(OZA) adjusted sky scans'); xlabel('Scattering Angle [deg]'); ylabel('sky radiance [W/m2/um/sr]'); 
legend('pfn*tau*toa','','','','ppl / cos(oza)'); logy

figure_(9)

  plot(alm.SA(ains(1),:), alm.sky_rad(ains(1),:),'-',...
  pfn.SA,1500.*pf_tau_adj(1,:).*cosd(alm.Solar_Zenith_Angle_Degrees_(ains(1)))./4,'--'); 
logy; legend('almucantar','pfn*toa*tau/(4*cos(SZA))');
title('Scaled PFN and Almucantar Scan')
hold('off')

pp(2) = subplot(1,2,2);
  plot(alm.SA(ains(1),:), alm.sky_rad(ains(1),:),'-');
  hold('on'); set(gca,'ColorOrderIndex',1)
  plot(pfn.SA,200.*pf_tau_adj(1,:)./(4.*cosd(alm.Solar_Zenith_Angle_Degrees_(ains(1)))),'--'); 
logy; legend('almucantar', '','','','pfn*toa*(tau/4)*cos(SZA))');
title('Scaled PFN and Almucantar Scan')
hold('off')

%% So now somehow construct a hemispheric field from the PPL radiances.

% AT the most basic this is a double loop over Az and Zen (or El) to compute SA and
% interpolate to the measured PPL 
% What do we need? Need SZA, then loop over 0-180 (in phi / Az) and 0-90 (in El / Ze)
% What about wavelength?  Do we need Angstrom interpolation (probably) and does the
% same angstrom dependence hold over SA or compute it for each angle?
% Or do we save the WL adjustment for the MFRSR-derived DDR?  Maybe yes.
% Starting at the most basic level, we compute sky radiance over hemisphere for each measured (or retrieved) sky scan WL.

% scratch from above: ppl.SA, ppl.sky_rad(pindx+ [-3, -1, 0, 1],:).*cosd(OZA),'k-')
seq = [-3:3];
SZA = ppl.Solar_Zenith_Angle_Degrees_(pindx + seq); % mean over what SZA measurements?
[wl, ij] = sort(ppl.Nominal_Wavelength_nm_(pindx +seq));
sza = mean(ppl.Solar_Zenith_Angle_Degrees_(pindx + seq));
% % ppl.sky_rad(pindx+ [-3, -1, 0, 1],:).*cosd(OZA)
scan.cosa_rad = ppl.sky_rad(pindx + seq,:).*cosd(OZA); 
scan.cosa_rad = scan.cosa_rad(ij,:);
scan.wl = wl; 
scan.SZA = SZA;
scan.SA = ppl.SA;
% SA = NaN([180,90]);
 
%These aren't very large streams so we'll feed "scat_ang_degs" with MxN matrices of
%the appropriate ZexAz size
%then we'll interpolate the PPL for each WL
Az = [0:180]';
Ze = [0.1:1:.9 1:89 89.1:.1:89.9];
Ze = [0:86];
cZA = cosd(Ze);
figure; plot(scan.SA, scan.cosa_rad,'-');legend('380','440','500','675','870','1020','1640'); logy;
% SA = scat_ang_degs(SZA, 0, ones(size(Az))*Ze, Az* ones(size(Ze))); % using new implementation of SA from Kaufman
tic   
for wl_ij = length(wl):-1:1   
   SA = scat_ang_degs(SZA(wl_ij), 0, ones(size(Az))*Ze, Az* ones(size(Ze))); % using new implementation of SA from Kaufman
   for ze = length(Ze):-1:1
      % SA_ze = scat_ang_degs(sza, 0, ones(size(Az))*Ze(ze), Az); % using new implementation of SA from Kaufman
      notnan = ~isnan(scan.cosa_rad(wl_ij,:));
      all_rad_(:,ze) = interp1(scan.SA(notnan), scan.cosa_rad(wl_ij,notnan), SA(:,ze),'linear', 'extrap')./cZA(ze); %This is supposed to divide cos_oza back out
      all_rad(:,ze,wl_ij) = all_rad_(:,ze);
   end
end
toc
above = pfn.SA<pfn.Solar_Zenith_Angle_for_Measurement_Start_Degrees_(pf_indx)+80;
figure; plot(SA(1,:), squeeze(all_rad(1,:,[2,4,5,6])),'-',SA(end,:), squeeze(all_rad(end,:,[2,4,5,6])),'-'); logy; legend('ppl est')

% tic
% for az = length(Az):-1:1
%    % SA_ze = scat_ang_degs(sza, 0, ones(size(Az))*Ze(ze), Az); % using new implementation of SA from Kaufman
%    for wl_ij = length(wl):-1:1
%       all_rad_(az,:,wl_ij) =interp1(scan.SA, scan.cosa_rad(wl_ij,:), SA(az,:),'linear', 'extrap')./cZA; %This is supposed to divide cos_oza back out
%    end
% end
% toc
% any(abs(all_rad-all_rad_)>.0001)

Ze_i = interp1(Ze, [1:length(Ze)],sza,'nearest')
% figure; plot(SA(:,Ze_i), squeeze(all_rad(:,Ze_i,:)).*cosd(SZA),'-x',SA(:,Ze_i), squeeze(all_rad_(:,Ze_i,:)).*cosd(SZA),'k.'); logy; legend('alm est') 
figure; plot(SA(:,Ze_i), squeeze(all_rad(:,Ze_i,[2,4,5,6])).*cosd(SZA([2,4,5,6]))','-'); logy; legend('est alm cosa')
figure; plot(SA(1,:), squeeze(all_rad(1,:,[2,4,5,6])).*cZA','-x',SA(end,:), squeeze(all_rad(end,:,[2,4,5,6])).*cZA','r.'); logy; legend('est ppl cosa')

figure; plot(SA(:,Ze_i), squeeze(all_rad(:,Ze_i,[2,4,5,6])),'-'); logy; legend('alm est')

% Confirm these match alm and ppl scans
% They match.  
% Now sort out integration over the half-hemisphere:
% Perhaps test this by integrating over "ones" to yield the surface area of a quarter
% sphere, so pi
all_ones = ones([length(Az),length(Ze)]);
phi = Az.*pi./180;
theta = Ze.*pi./180;
for wl_ij = length(wl):-1:1
   all_rad_ =squeeze(all_rad(:,:,wl_ij)); all_rad_(isnan(all_rad_)) = 0;
   dif_flux(wl_ij) = trapz(phi, trapz(theta, all_rad_.*sin(theta),2));
end
% compute direct normal from ESR and tod
[~, ~, soldst] = sunae(caod.Latitude_Degrees_(cindx),caod.Longitude_Degrees_(cindx), caod.time(cindx));
% TOA_anet = interp1(ESR(:,1), ESR(:,3), [380,440,675,870,1020,1640],'pchip');%W/m2/nm
tod_anet = [tod.AOD_380nm_Total(tindx), tod.AOD_440nm_Total(tindx), tod.AOD_675nm_Total(tindx), ...
   tod.AOD_870nm_Total(tindx), tod.AOD_1020nm_Total(tindx), tod.AOD_1640nm_Total(tindx)];

dirn = (1000./soldst.^2).*TOA_anet.*exp(-tod_anet.*tod.Optical_Air_Mass(tindx));
dirn_by_diff = dirn./dif_flux([1 2 4:end]);
figure; plot([380,440,675,870,1020,1640], dirn_by_diff,'o-'); legend('Cimel');
% Compute OZA

mfrC1 = anc_bundle_files; C1_i = interp1(mfrC1.time, [1:length(mfrC1.time)],tod.time(tindx), 'nearest');
mfrE13 = anc_bundle_files; E13_i = interp1(mfrE13.time, [1:length(mfrE13.time)],tod.time(tindx), 'nearest');
mfraodE13 = anc_bundle_files; E13_j  = interp1(mfraodE13.time, [1:length(mfraodE13.time)],tod.time(tindx), 'nearest');

ddr_mfrC1.vdata.direct_diffuse_ratio_filter1(C1_i)
mfr_wl = [415, 500, 615, 676, 870, 1625];
mfrC1_ddr = [mfrC1.vdata.direct_diffuse_ratio_filter1(C1_i), mfrC1.vdata.direct_diffuse_ratio_filter2(C1_i),...
   mfrC1.vdata.direct_diffuse_ratio_filter3(C1_i), mfrC1.vdata.direct_diffuse_ratio_filter4(C1_i),...
   mfrC1.vdata.direct_diffuse_ratio_filter5(C1_i), mfrC1.vdata.direct_diffuse_ratio_filter7(C1_i)];
mfrE13_ddr = [mfrE13.vdata.direct_diffuse_ratio_filter1(E13_i), mfrE13.vdata.direct_diffuse_ratio_filter2(E13_i),...
   mfrE13.vdata.direct_diffuse_ratio_filter3(E13_i), mfrE13.vdata.direct_diffuse_ratio_filter4(E13_i),...
   mfrE13.vdata.direct_diffuse_ratio_filter5(E13_i), mfrE13.vdata.direct_diffuse_ratio_filter7(E13_i)];
hold('on'); plot(mfr_wl, mfrC1_ddr,'o-'); legend('Cimel','MFRSR C1')
plot(mfr_wl, mfrE13_ddr,'x-'); legend('Cimel','MFRSR C1','MFRSR E13')
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