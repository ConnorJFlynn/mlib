function Kass
% Reproducing/replacing placeholder plots in Kassianov SASHe paper with real plots

% Switching to July,  July 19th PM looks nice

vis = anc_bundle_files;
nm = [380, 415, 440, 500, 615, 675, 870];
% nm = [415, 440, 500, 615, 675, 870];

nm_i = interp1(vis.vdata.wavelength, [1:length(vis.vdata.wavelength)],nm,'nearest');

am_ = vis.vdata.airmass>1.5 & vis.vdata.airmass < 6.5;

figure_(2); plot(vis.time(am_), vis.vdata.direct_normal_transmittance(nm_i(4),am_),'.'); dynamicDateTicks
xl = xlim;
tl_ = vis.time>xl(1) & vis.time<xl(2);
dirn = vis.vdata.direct_normal_transmittance(nm_i,am_&tl_);
figure_(3); plot(vis.vdata.airmass(am_&tl_), dirn,'x'); logy
xlabel('airmass');
ylabel('log_1_0(Tr)');
for n = length(nm_i):-1:1
P = polyfit(vis.vdata.airmass(am_&tl_), real(log10(dirn(n,:))),1);
Ps(n,:) = P;
end
dirn2 = dirn./(10.^Ps(:,2)*ones(size(dirn(1,:))));
for n = length(nm_i):-1:1
P2 = polyfit(vis.vdata.airmass(am_&tl_), real(log10(dirn2(n,:))),1);
Ps2(n,:) = P2;
end

figure_(3); cla; plot(vis.vdata.airmass(am_&tl_), dirn2,'+'); logy
hold('on');set(gca,'ColorOrderIndex',1)
ams = [0,ceil(max(vis.vdata.airmass(am_&tl_)))];
for n = 1:length(nm_i)
plot(ams, 10.^polyval(Ps2(n,:),ams),'-');
leg_str(n) = {sprintf('%1.0f',nm(n))};
end
for n = 1:length(nm_i)
leg_str(n) = {sprintf('%1.0f nm',nm(n))};
end
lg = legend(leg_str); lg.Location = 'SouthWest';
xlabel('airmass');
ylabel('log_1_0(Tr)', 'interp','tex');
xlim([0,6.02]); ylim([.01, 1.15]);
title(['Langley for ',datestr(mean(vis.time(tl_)),'yyyy-mm-dd HH')]); 
% Now plot the "good" smoothed Io values over the top of a line plot of responsivity


% Now responsivity plots
hou_vis2 = rd_sashe_resp_file('housashevisM1.cal.20220910_0000.50ms.dat');
gtz = hou_vis2.resp>0;
good_Io = anc_qc_impacts(vis.vdata.qc_smoothed_Io_values, vis.vatts.qc_smoothed_Io_values);
vis_lang_resp = vis.vdata.smoothed_Io_values./vis.vdata.solar_spectrum;
[max_Ro, maxr] = max(vis_lang_resp);
maxrb = interp1(hou_vis2.lambda_nm, [1:length(hou_vis2.lambda_nm)],vis.vdata.wavelength(maxr),'nearest');
resp_max = hou_vis2.resp(maxrb);
ax = vis.vdata.wavelength; ay =vis_lang_resp; ay(good_Io~=0) = NaN;
bx = hou_vis2.lambda_nm(gtz); by = hou_vis2.resp(gtz);
ab = patch_ab(ax,ay,bx,by);% ay(1) = 0; ay(end) = 0;
figure_(4); plot(vis.vdata.wavelength, vis_lang_resp,'r*', ...
   vis.vdata.wavelength(good_Io==0), vis_lang_resp(good_Io==0),'g*',...
   hou_vis2.lambda_nm(gtz), hou_vis2.resp(gtz).*max_Ro./resp_max,'k-','markersize',8);
lg = legend('Langley (all)','Langley (robust)', 'Lamp'); lg.Location = 'NorthWest';
xlabel('wavelength [nm]'); ylabel('Si CCD responsivity');
xlim([325,1040]); xlv = xlim;


figure_(5); plot(vis.vdata.wavelength, vis_lang_resp,'r*', ...
   vis.vdata.wavelength(good_Io==0), vis_lang_resp(good_Io==0),'g*',...
   vis.vdata.wavelength, ab,'k-','markersize',8);
lg = legend('Langley (all)','Langley (good)', 'Langley & Lamp'); lg.Location = 'NorthWest';
xlabel('wavelength [nm]'); ylabel('Si CCD responsivity');
xlim(xlv);

nir1 = anc_load;% Load a NIR AOD file in order to get Io and TOA values for NIR
hou_nir2 = rd_sashe_resp_file('housashenirM1.cal.20220910_0000.900ms.dat');
gtz = hou_nir2.resp>0;
good_Io = anc_qc_impacts(nir1.vdata.qc_smoothed_Io_values, nir1.vatts.qc_smoothed_Io_values);
nir_lang_resp = nir1.vdata.smoothed_Io_values./nir1.vdata.solar_spectrum;
nir_lang_resp(nir1.vdata.smoothed_Io_values<0) = NaN;
[max_Ro, maxr] = max(nir_lang_resp);
maxrb = interp1(hou_nir2.lambda_nm, [1:length(hou_nir2.lambda_nm)],nir1.vdata.wavelength(maxr),'nearest');
resp_max = hou_nir2.resp(maxrb);

gtz = nir_lang_resp>0;
nax = nir1.vdata.wavelength; nay =nir_lang_resp; nay(good_Io==2) = NaN;
nbx = hou_nir2.lambda_nm(gtz); nby = hou_nir2.resp(gtz);
nab = patch_ab(nax,nay,nbx,nby); 
nab(isnan(nab)) = nir_lang_resp(isnan(nab)); % Is this an attempt to handle edge cases?

figure_(6); plot(nir1.vdata.wavelength, nir_lang_resp,'r*', ...
   nir1.vdata.wavelength(good_Io==0), nir_lang_resp(good_Io==0),'g*',...
   hou_nir2.lambda_nm(gtz), hou_nir2.resp(gtz).*max_Ro./resp_max,'k-','markersize',8);
xlim([965,1750]); xln = xlim;
lg = legend('Langley (all)','Langley (good)', 'Scaled Lamp'); lg.Location = 'NorthWest';
xlabel('wavelength [nm]'); ylabel('InGaAs Array responsivity');

figure_(7); plot(nir1.vdata.wavelength, nir_lang_resp,'r*', ...
   nir1.vdata.wavelength(good_Io==0), nir_lang_resp(good_Io==0),'g*',...
   nir1.vdata.wavelength, nab,'k-','markersize',8);
xlim([965,1694]); xln = xlim;
lg = legend('Langley (all)','Langley (good)', 'Langley + Lamp'); lg.Location = 'NorthWest';
xlabel('wavelength [nm]'); ylabel('InGaAs Array res1ponsivity');

% ARM_display_beta(skyrad); plot down_short_normal
% I can't remember what I was after here. Maybe looking for heavy AOD by looking 
% at time series of down_short_normal.  Possibly when I was struggling to find 
% a good "aerosol day" without realizing that the 4STAR day had very large y-limits
sky_lim = xlim;
sl_ = skyrad.time>sky_lim(1) & skyrad.time<sky_lim(2); sum(sl_)
vt = vis.time>sky_lim(1) & vis.time<sky_lim(2); sum(vt)
nt = nir.time>sky_lim(1) & nir.time<sky_lim(2); sum(nt)

wl_v = vis.vdata.wavelength>370 & vis.vdata.wavelength<1000; 
wl_n = nir.vdata.wavelength>1000 & nir.vdata.wavelength<1710;
dirn_v = vis.vdata.direct_normal_transmittance(wl_v,vt).*(vis.vdata.solar_spectrum(wl_v)*ones(size(vis.time(vt))));
dirn_n = nir.vdata.direct_normal_transmittance(wl_n,nt).*(nir.vdata.solar_spectrum(wl_n)*ones(size(nir.time(nt))));

difh_v = vis.vdata.diffuse_transmittance(wl_v,vt).*(vis.vdata.solar_spectrum(wl_v)*ones(size(vis.time(vt))));
difh_n = nir.vdata.diffuse_transmittance(wl_n,nt).*(nir.vdata.solar_spectrum(wl_n)*ones(size(nir.time(nt))));


% figure; plot(vis.vdata.wavelength(wl_v), dirn_v, '-',nir.vdata.wavelength(wl_n), dirn_n,'-');
gtz_v = any(dirn_v>0,2); gtz_n = any(dirn_n > 0,2);
dirn_bb = trapz(vis.vdata.wavelength(gtz_v), dirn_v(gtz_v,:)) + ...
   trapz(nir.vdata.wavelength(gtz_n), dirn_n(gtz_n,:));
figure; plot(skyrad.time(sl_), skyrad.vdata.short_direct_normal(sl_),'.',  vis.time(vt), dirn_bb,'.');
legend('BB dirn','SASHe dirn');

gtz_v = any(difh_v>0,2); gtz_n = any(difh_n > 0,2);
difh_bb = trapz(vis.vdata.wavelength(gtz_v), difh_v(gtz_v,:)) + ...
   trapz(nir.vdata.wavelength(gtz_n), difh_n(gtz_n,:));
figure; plot(skyrad.time(sl_), skyrad.vdata.down_short_diffuse_hemisp(sl_),'.',  vis.time(vt), difh_bb,'k.');
legend('BB difh','SASHe difh');

%show plot with dirn vs time

vis = anc_bundle_files; nir = anc_bundle_files;
xl = xlim;
vis_xl = vis.time>xl(1) & vis.time<xl(2);
nir_xl = nir.time>xl(1) & nir.time<xl(2);
v_aod = anc_qc_impacts(vis.vdata.qc_aerosol_optical_depth(:,vis_xl), vis.vatts.qc_aerosol_optical_depth);
v_aod = v_aod<2; v_aod = all(v_aod,2);
v_aod = (anc_qc_impacts(vis.vdata.qc_smoothed_Io_values, vis.vatts.qc_smoothed_Io_values)'==0);
v_aod(1:end-1) = v_aod(1:end-1)&v_aod(2:end); v_aod(1:end-1) = v_aod(1:end-1)&v_aod(2:end);
n_aod = anc_qc_impacts(nir.vdata.qc_aerosol_optical_depth(:,nir_xl), nir.vatts.qc_aerosol_optical_depth);
n_aod = n_aod<1; n_aod = all(n_aod,2);
n_aod = anc_qc_impacts(nir.vdata.qc_smoothed_Io_values, nir.vatts.qc_smoothed_Io_values)'==0;
n_bad = zeros(size(n_aod));
% n_bad(nir.vdata.wavelength>1000 & nir.vdata.wavelength<1009) = NaN;
n_bad(nir.vdata.wavelength>1342 & nir.vdata.wavelength<1443) = NaN;
n_bad_dot = zeros(size(n_aod));
n_bad_dot(nir.vdata.wavelength>1000 & nir.vdata.wavelength<1009) = NaN;
n_aod(1:end-1) = n_aod(1:end-1)&n_aod(2:end);
n_aod(1:end-1) = n_aod(1:end-1)&n_aod(2:end);
n_aod(1:end-1) = n_aod(1:end-1)&n_aod(2:end);
figure; plot([vis.vdata.wavelength(wl_v); nir.vdata.wavelength(wl_n)],...
   [mean(vis.vdata.aerosol_optical_depth(wl_v,vis_xl),2); n_bad(wl_n)+mean(nir.vdata.aerosol_optical_depth(wl_n,nir_xl),2)],'r-',...
   [vis.vdata.wavelength(v_aod&wl_v); nir.vdata.wavelength(n_aod&wl_n)],...
   [mean(vis.vdata.aerosol_optical_depth(v_aod&wl_v,vis_xl),2); n_bad_dot(n_aod&wl_n)+mean(nir.vdata.aerosol_optical_depth(n_aod&wl_n,nir_xl),2)],'k.')
logy; logx; ylim([.1, 1.2]);
legend('gas absorption', 'Good AOD');
ylabel('OD (Rayleigh and O_3 removed)','interp','tex')
xlabel('wavelength [nm]');


return
