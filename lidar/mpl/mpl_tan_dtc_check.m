function mpl_tan_dtc_check
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
MPL_cals = load([getnamedpath('miniMPLcal'),'calibration_uc.lid_on_ray_ol.mat']);
mmpl = load(getfullname('*.mat','mmpl_daily','Select MPL daily mat file.'));
ap_cop = MPL_cals.cjf.ap_cop * double(mmpl.vdata.energy_monitor)./1000;
ap_crs = MPL_cals.cjf.ap_crs * double(mmpl.vdata.energy_monitor)./1000;
cop = mmpl.vdata.channel_2-ap_cop;
crs = mmpl.vdata.channel_1-ap_crs;
rng = MPL_cals.cjf.rng;
r.bg = rng >27.5 & rng < 30;
cop = cop - ones(size(rng))*mean(cop(r.bg,:));
crs = crs - ones(size(rng))*mean(crs(r.bg,:));

dpr_raw = crs./cop;

cop = cop.*dtc_34184(cop);
crs = crs.*dtc_34184(crs);
dpr_dtc = crs./cop;

figure_(33); imagegap(serial2doy(mmpl.time), MPL_cals.ap(:,1), real(log10(dpr_raw))); caxis([-3,0]); ax(1) = gca;
figure_(34); imagegap(serial2doy(mmpl.time), MPL_cals.ap(:,1), real(log10(dpr_dtc))); caxis([-3,0]); ax(2) = gca;
figure_(35); imagegap(serial2doy(mmpl.time), MPL_cals.ap(:,1), real(log10(cop.*(rng.^2)))); caxis([0,3.5]);ax(3) = gca; 
linkaxes(ax,'xy'); zoom('on');


return