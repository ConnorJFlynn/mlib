function mpl_er_dtc_check
% Four excellent cases with low clouds at different ceilings
% < 350-400m cbh, Jan 18, 30-deg min El
% similar CBH,  Feb 27, finer el angle spacing
% ~800 m CBH, Feb 25, fine El angles
% 1.5 km CBH, Mar 02, find El angles

% Load MPL file
% Subtract AP from cop and crs
% Compute and subtract BG
% Compute ratio crs/cop. 
% setnamedpath('miniMPLcal','*.mat','Select mini-MPL cal file');
% setnamedpath('mmpl_daily','*.mat','Select mini-MPL daily file.')
MPL_cals = load([getnamedpath('mMPL_er_cal'),'calibration_uc.lid_on_ray_ol.mat']);
mmpl = load(getfullname('*.mat','mmpl_daily','Select MPL daily mat file.'));
ap_cop = MPL_cals.vdata.ap_copol * double(mmpl.vdata.energy_monitor)./1000;
ap_crs = MPL_cals.vdata.ap_crosspol	* double(mmpl.vdata.energy_monitor)./1000;
full_ol = 10.^interp1(log10(MPL_cals.vdata.ol_range(2:end)), log10(MPL_cals.vdata.ol_overlap(2:end)), log10(MPL_cals.vdata.ap_range),'linear','extrap');
cop = mmpl.vdata.channel_2-ap_cop;
crs = mmpl.vdata.channel_1-ap_crs;
rng = MPL_cals.vdata.ap_range;
r.bg = rng >27.5 & rng < 30;
cop = cop - ones(size(rng))*mean(cop(r.bg,:));
crs = crs - ones(size(rng))*mean(crs(r.bg,:));

dpr_raw = crs./cop;

cop_dtc = cop.*dtc_34184(cop); 
% figure; imagesc(serial2doy(mmpl.time), rng,real(log10(cop_dtc./cop)));axis('xy'); axis(v);

crs_dtc = crs.*dtc_34184(crs);
% figure; imagesc(serial2doy(mmpl.time), rng,real(log10(crs_dtc./crs)));axis('xy'); axis(v);
dpr_dtc = crs_dtc./cop_dtc;

figure_(33); imagegap(serial2doy(mmpl.time), rng, real((dpr_raw))); caxis([0,0.15]); ax(1) = gca;
figure_(34); imagegap(serial2doy(mmpl.time), rng, real((dpr_dtc))); caxis([0,0.15]); ax(2) = gca;
figure_(35); imagegap(serial2doy(mmpl.time), rng, real(log10(cop_dtc.*(rng.^2)./full_ol))); caxis([0,3.5]);ax(3) = gca; 
linkaxes(ax,'xy'); zoom('on'); 
if isavar('v') axis(v); end


return