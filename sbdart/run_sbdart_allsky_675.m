function [zen] = run_sbdart_allsky
% [zen] = run_sbdart_allsky
% Figuring out how to run SBDART for full sky
% accept alm retrieval along with coid at retrieval wavelengths. 440, 500, 615, 870, 1020?
% Compute radiances  at MFRSR wavelengths (415, 500, 615, 675, 870, 1p6)
% Then what?

% I have successfully demonstrated that SBDART-generated ALM and PPL can be converted
% to a quantity proportional to PFN and overlay each other except in regions where
% multiple scattering increases, and have also demonstrated consistency with
% meausured sky scans (alm,ppl).
% Currently working compose total PFN from PFN_675_total + PFN_65_Ray

% Time to refactor

warning('Careful with this function.  Is in flux.  Connor 2023-12-13 AGU');
 alm = rd_anetalm_v3;
 ppl = anet_ppl_zenrad(ceil(alm.time(end)), floor(alm.time(1)));
 ppl.sky_rad(ppl.sky_rad<-100) = NaN;
 t_675 = find(alm.Nominal_Wavelength_nm_==675);
 pfn = rd_anetpfn_v3;
 asym = rd_anetaip_v3; caod = rd_anetaip_v3; ssa = rd_anetaip_v3; tod = rd_anetaod_v3;
 [ains, sina] = nearest(alm.time(t_675), ssa.time);
ains_ = t_675(ains);

anet.time = caod.time;
anet.wl = [440,675,870,1020];
anet.aod = [caod.AOD_Coincident_Input_440nm_,caod.AOD_Coincident_Input_675nm_, caod.AOD_Coincident_Input_870nm_, caod.AOD_Coincident_Input_1020nm_];
anet.ssa = [ssa.Single_Scattering_Albedo_440nm_, ssa.Single_Scattering_Albedo_675nm_, ssa.Single_Scattering_Albedo_870nm_, ssa.Single_Scattering_Albedo_1020nm_];
anet.sza = ssa.Solar_Zenith_Angle_for_Measurement_Start_Degrees_;
anet.g = [asym.Asymmetry_Factor_Total_440nm_, asym.Asymmetry_Factor_Total_675nm_, asym.Asymmetry_Factor_Total_870nm_, asym.Asymmetry_Factor_Total_1020nm_];
anet.time = anet.time(sina); anet.sza = anet.sza(sina);
anet.aod = anet.aod(sina,:);
anet.ssa = anet.ssa(sina,:);
anet.g = anet.g(sina,:);

% Did work trying to screen raw alm scans
ltz = alm.Az_deg<0; gtz = alm.Az_deg>0; 
gt5 = alm.Az_deg(gtz)>5;% subtle difference 

leg_ab = [alm.skyrad(ains_,gtz), fliplr(alm.skyrad(ains_,ltz))];
leg_dif = [alm.skyrad(ains_,gtz)-fliplr(alm.skyrad(ains_,ltz))];
leg_mn = [alm.skyrad(ains_,gtz)+fliplr(alm.skyrad(ains_,ltz))]./2;
best = all(abs(leg_dif(:,gt5)./leg_mn(:,gt5))<.5,2)& all(abs(leg_dif(:,gt5))<15,2)& all(abs(leg_mn(:,gt5))<45,2)  ; 
best_i = find(best); sum(best)
ind = 999; % from visual examination "best" includes index 999
leg_ind = [alm.skyrad(ains_(ind),gtz); fliplr(alm.skyrad(ains_(ind),ltz))];
leg_SA = [alm.SA(ains_(ind),gtz); fliplr(alm.SA(ains_(ind),ltz))];
figure; plot(alm.Az_deg, alm.skyrad(ains_(ind),:),'-');logy
figure; plot(alm.Az_deg(gtz), leg_ind,'-');logy

ppl_675 = find(ppl.Nominal_Wavelength_nm_==675);
ppl_ind = interp1(ppl.time(ppl_675), [1:length(ppl_675)], alm.time(ains_(ind)),'nearest','extrap');
ppl_ind = ppl_675(ppl_ind);
% for ppl, SA = sza - oza
oza = ppl.Solar_Zenith_Angle_Degrees_(ppl_ind)-ppl.SA;
figure; plot(ppl.SA, ppl.sky_rad(ppl_ind,:).*cosd(oza)./10,'g-',...
   leg_SA', leg_ind'.*cosd(alm.Solar_Zenith_Angle_Degrees_(ains_(ind))),'-',...
  pfn.SA, pfn.P_675nm(tot_ij(pfn_ind),:),'-' );legend('~ppl pfn', '~alm pfn', 'pfn tot'); logy

tot_t = interp1(tod.time, [1:length(tod.time)],alm.time(ains_(ind)),'nearest','extrap');
tod.AOD_675nm_Rayleigh(tot_t)  tod.AOD_675nm_AOD(tot_t)
L_675 = tod.AOD_675nm_Rayleigh(tot_t).*(3/4).*(1+cosd(pfn.SA).^2) + tod.AOD_675nm_AOD(tot_t).*pfn.P_675nm(tot_ij(pfn_ind),:);

tot_ij = find(foundstr(pfn.Phase_Function_Mode,'Total')); length(tot_ij)
fin_ij = find(foundstr(pfn.Phase_Function_Mode,'Fine')); length(fin_ij)
crs_ij = find(foundstr(pfn.Phase_Function_Mode,'Coarse')); length(crs_ij)
pfn_ind = interp1(pfn.time(tot_ij), [1:length(tot_ij)],alm.time(ains_(ind)),'nearest','extrap');
%P_ray = (3/4).*(1+cosd(SA).^2)
%
figure; plot(pfn.SA, [pfn.P_440nm(pfn_ind,:);pfn.P_675nm(pfn_ind,:);pfn.P_870nm(pfn_ind,:);pfn.P_1020nm(pfn_ind,:)],'-'); logy; legend('pfn 675')
% anet = rd_anetaip_v3;
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
qry.wlinf=.675;
qry.wlsup=qry.wlinf;

qry.IAER=5; % Oceanic==3  Probably better IAER=5 specify wlbaer, qbaer, wbaer, and gbaer. % what about tbaer?  

qry.RHAER=0.8; % RHAER has no effect when IAER=5
qry.wlbaer=anet.wl./1000;
qry.QBAER = anet.aod(ind,:);
qry.wbaer = anet.ssa(ind,:);
qry.gbaer = .9*anet.g(ind,:);
qry.SZA = anet.sza(ind);

% qry.zout = [0,0];

% PPL test
qry.PHI=[0 180]; 
qry.UZEN = [1 2.5 5:5:85 89]; 
qry.UZEN = fliplr(180-setxor(qry.UZEN,qry.SZA));
[w,s,QRY] = qry_sbdart_(qry);
pp_675 = parse_sbdart_reply(w,QRY);
figure; plot(ppl.SA, ppl.sky_rad(ppl_ind,:),'-o',pp_675.SA, pp_675.rad,'r-'); logy
% ALM test
qry.PHI = [0:10:360];
qry.UZEN = 180-qry.SZA;
[w,s,QRY] = qry_sbdart_(qry);
alm_675 = parse_sbdart_reply(w,QRY);
figure; plot(leg_SA', leg_ind','-', alm_675.SA, alm_675.rad./10,'c-'); logy

% Zen test
qry.PHI = 0;
qry.UZEN = 180;

% Hybrid or Hemisphere test

% Let's try to generate sectors at high angular resolution and then stitch them
% together. Take it piece by piece to make sure we understand the reported radiances.
% Then integrate to see if they agree with the fluxes.
qry.UZEN=fliplr(180-sort([45,5,85, 45 - logspace(log10(3),log10(44),18), 45 + logspace(log10(3),log10(44),18) ])); 

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

hemi.zend = quad1.zen; 
hemi.phid = [quad1.phi; quad2.phi; quad3.phi; quad4.phi];
hemi.rad = [quad1.rad; quad2.rad; quad3.rad; quad4.rad];
hemi.zen = pi.*hemi.zend./180; hemi.phi = pi.*hemi.phid./180;


[X,Y,Z] = sph2cart(hemi.phi*ones(size(hemi.zen)),90-ones(size(hemi.phi))*hemi.zen,hemi.rad);
% figure; plot3(X,Y,Z,'-')
figure; plot3(X',Y',Z','-')
% uncomment for Almucantar
% qry.UZEN = qry.SZA; qry = rmfield(qry,'NZEN');

      [w,s,QRY] = qry_sbdart_(qry);
      ppl = parse_sbdart_reply(w,QRY);
      alm = parse_sbdart_reply(w,QRY);
      hyb = parse_sbdart_reply(w,QRY);
      figure; plot(alm.SA, alm.rad.*cosd(alm.zen),'-x')
      figure; plot(ppl.SA, ppl.rad.*cosd(ppl.zen),'-o')


      figure; lines = plot(out.phi,out.uurs','-'); recolor(lines,out.zen);
      zrad(t,:) = out.rad; % (W/m2/um/sr)

   figure_(5); imagesc([0:3:180],tau(2:end), 100.*abs(diff(zrad))./zrad(2:end,:)); axis('xy');
   xlabel('Elevation [deg]'); ylabel('AOD'); caxis([0,2]); xlim([10,170])
   title(['SZA = ',num2str(qry.SZA)]);


figure; plot([ppl.SA(:,1);ppl.SA(:,2)], [ppl.uurs(:,1).*cosd(ppl.zen);ppl.uurs(:,2).*cosd(ppl.zen)],'o-', alm.SA_1, alm.rad.*cosd(alm.SZA),'-x')
% SZA = acosd(1./airmass);
% tic
% for t = length(tau):-1:1
%    for z = length(SZA):-1:1
%       qry.SZA = SZA(z);
%       qry.TBAER=tau(t);
%       qry.VZEN =[qry.SZA];
%       % pause(.01);
%       [out] = qry_sbdart(qry);
%       zrad(t,z) = out.rad;
%    end
%    disp(tau(t))
% end
% toc
% zen.rad_by_airmass = zrad; zen.airmass = airmass;

tau = zen.aod;
ttau = tau*ones(size(zen.sza));
sza = ones(size(tau))*zen.sza;

colr = 100.*diff2(zen.rad_by_SZA)./zen.rad_by_SZA;
zen.drad = colr;
figure; scatter(ttau(:),sza(:),64,abs(colr(:)),'filled'); cb = colorbar; 
caxis([0,3]);
xlim([.1,1]); ylim([0,80]);
set(get(cb,'title'),'string','%d(zrad)');

figure; scatter(90-sza(:),ttau(:),64,abs(colr(:)),'filled'); cb = colorbar; 
caxis([0,4]);
ylim([.05,1]); xlim([10,90]);
set(get(cb,'title'),'string','%d(zrad)');
xlabel('Solar Elevation [degrees]');
ylabel('AOD [415 nm]')
title('% Variation in zenith radiance with 0.01 OD')
saveas(gcf, ['D:\AGU_prep\zenrad_variation_by_OD_err_4pct_actual_zenith.fig'])
save(['D:\AGU_prep\sbdart_zenrad_p01.mat'],'-struct','zen')
% ttau = tau*ones(size(zen.airmass));
% airmas = ones(size(tau))*airmass;
% colr = 100.*diff2(zen.rad_by_airmass)./zen.rad_by_airmass;
% colr = zen.rad_by_airmass;
% figure; scatter(ttau(:),airmas(:),64,abs(colr(:)),'filled'); cb = colorbar; 
% caxis([0,3]);
% xlim([.1,1]); ylim([1,7]);
% set(get(cb,'title'),'string','%d(zrad)');

% zenrad_LUT = load([prep_dir, 'sbdart_zenrad.mat']);
% zenrad_LUT.sel = 90-zenrad_LUT.sza;
% zenrad_LUT.drad_pct = 100.*diff2(zenrad_LUT.rad_by_SZA)./zenrad_LUT.rad_by_SZA;
% 
% 
% sel = ones(size(zenrad_LUT.aod))*zenrad_LUT.sel;
% aod = zenrad_LUT.aod*ones(size(zenrad_LUT.sel));
% figure; scatter(sel(:), aod(:), 64, abs(zenrad_LUT.drad_pct(:)),'filled'); caxis([0,4])

end