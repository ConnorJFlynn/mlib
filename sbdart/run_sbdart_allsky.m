function [zen] = run_sbdart_allsky
% [zen] = run_sbdart_allsky
% Figuring out how to run SBDART for full sky
% accept alm retrieval along with coid at retrieval wavelengths. 440, 500, 615, 870, 1020?
% Compute radiances  at MFRSR wavelengths (415, 500, 615, 675, 870, 1p6)
% Then what?
warning('Careful with this function.  Is in flux.  Connor 2023-12-13 AGU');
 alm = rd_anetalm_v3;  asym = rd_anetaip_v3; caod = rd_anetaip_v3; ssa = rd_anetaip_v3; 
 [ains, sina] = nearest(alm.time, ssa.time);

anet.time = caod.time(sina);
anet.wl = [440,675,870,1020];
anet.aod = [caod.AOD_Coincident_Input_440nm_,caod.AOD_Coincident_Input_675nm_, caod.AOD_Coincident_Input_870nm_, caod.AOD_Coincident_Input_1020nm_];
anet.ssa = [ssa.Single_Scattering_Albedo_440nm_, ssa.Single_Scattering_Albedo_675nm_, ssa.Single_Scattering_Albedo_870nm_, ssa.Single_Scattering_Albedo_1020nm_];
anet.sza = ssa.Solar_Zenith_Angle_for_Measurement_Start_Degrees_;
anet.g = [asym.Asymmetry_Factor_Total_440nm_, asym.Asymmetry_Factor_Total_675nm_, asym.Asymmetry_Factor_Total_870nm_, asym.Asymmetry_Factor_Total_1020nm_];

% anet = rd_anetaip_v3;
clear qry
qry.SAZA=180;
qry.NSTR=20;
qry.CORINT='.true.';
qry.iout=6;
qry.NF=3;
qry.idatm=2;

% If output is desired at a single wavelength, set
% WLINF=WLSUP and ISAT=0. In this case, SBDART will
% set WLINC=1 (the user specified value of WLINC is ignored)
% and the output will be in units of (W/m2/um) for
% irradiance and (W/m2/um/sr) for radiance.

qry.isat=0;
qry.wlinf=.5;
qry.wlsup=qry.wlinf;

qry.IAER=5; % Oceanic==3  Probably better IAER=5 specify wlbaer, qbaer, wbaer, and gbaer. % what about tbaer?  

qry.RHAER=0.8; % RHAER has no effect when IAER=5
qry.wlbaer=anet.wl./1000;
qry.QBAER = anet.aod(755,:);
qry.wbaer = anet.ssa(755,:);
qry.gbaer = anet.g(755,:);
qry.SZA = anet.sza(755);

% qry.zout = [0,0];

% PPL test
qry.PHI=[0 180]; 
qry.UZEN = [1 2.5 5:5:85 89]; 
qry.UZEN = fliplr(180-setxor(qry.UZEN,qry.SZA));

% ALM test
qry.PHI = [0:10:360];
qry.UZEN = 180-qry.SZA;

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