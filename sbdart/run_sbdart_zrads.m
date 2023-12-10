function [zen] = run_sbdart_zrads
% [zen] = run_sbdart_zrads1
% Returns look-up tables for zenith radiance vs SZA and airmass at 415 nm.
% Need to check whether surface albeda and ssa are being used
%zenith radiance only

qry.iout=6;
qry.NF=3;
qry.idatm=2;
qry.isat=0;
qry.wlinf=0.415;
qry.wlsup=0.415;
qry.wlbaer=0.415;
qry.IAER=3;

qry.RHAER=0.8;

qry.SAZA=180;

qry.NSTR=20;
qry.CORINT='.true.';
% qry.zout = [0,0];
qry.PHI=[0];
qry.SZA=30;
tau = [.01:.01:1]; % tau = .41;
airmass = 1:.1:7;
SZA = [0:82]; % SZA = [47, 51, 57, 68, 75];
tic
for t = length(tau):-1:1
   for z = length(SZA):-1:1
      qry.SZA = SZA(z);
      qry.TBAER=tau(t);
      qry.VZEN =[qry.SZA];
      % pause(.01);
      [out] = qry_sbdart(qry);
      zrad(t,z) = out.rad; % (W/m2/um/sr)
   end
   disp(tau(t))
end
toc

zen.rad_by_SZA = zrad; zen.aod = tau'; zen.sza = SZA; clear zrad
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
saveas(gcf, ['D:\AGU_prep\zenrad_variation_by_OD_err_4pct.fig'])
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