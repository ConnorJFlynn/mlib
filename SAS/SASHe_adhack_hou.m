% Set SASHe VIS and NIR to agree with MFRSR7nch irradiances at HOU
% 2022_03_09

% Load b1 files. 
% match times near noon.
sasvis2 = anc_load(getfullname('housashevis*.nc','sashevis'));
sasnir2 = anc_load(getfullname('housashenir*.nc','sashenir'));
mfr = anc_load(getfullname('houmfrsr7nchm1.b1.*.nc','mfr'));

nm_500 = interp1(sasvis.vdata.wavelength_vis,[1:length(sasvis.vdata.wavelength_vis)],500,'nearest'); 
dndh_500 = sasvis.vdata.direct_normal_vis(nm_500,:)./sasvis.vdata.diffuse_hemisp_vis(nm_500,:);
bad = sasvis.vdata.direct_normal_vis(nm_500,:)<0 | sasvis.vdata.diffuse_hemisp_vis(nm_500,:)<0;
dndh_500(bad) = NaN;
bad = double(mfr.vdata.direct_diffuse_ratio_filter2<0);
bad(bad==1) = NaN;

figure; plot(serial2doys(sasvis.time), dndh_500, '.', serial2doys(mfr.time), bad+mfr.vdata.direct_diffuse_ratio_filter2,'.');

figure; plot(sasvis.vdata.wavelength_vis, sasvis.vdata.responsivity_vis,'-')

sas_noon = interp1(serial2doys(sasvis.time), [1:length(sasvis.time)],29.75,'nearest');
mfr_noon = interp1(serial2doys(mfr.time), [1:length(mfr.time)],29.75,'nearest');

mfr_dirh = [mfr.vdata.direct_horizontal_narrowband_filter1;mfr.vdata.direct_horizontal_narrowband_filter2;...
   mfr.vdata.direct_horizontal_narrowband_filter3; mfr.vdata.direct_horizontal_narrowband_filter4; ...
   mfr.vdata.direct_horizontal_narrowband_filter5; mfr.vdata.direct_horizontal_narrowband_filter6; ...
   mfr.vdata.direct_horizontal_narrowband_filter7];

figure; plot(sasvis.vdata.wavelength_vis, sasvis.vdata.direct_horizontal_vis(:,sas_noon).*vscale,'-',...
   sasnir.vdata.wavelength_nir, sasnir.vdata.direct_horizontal_nir(:,sas_noon).*(10./7),'-',...
   [415,500,615,676,870,940,1625], mfr_dirh(1:7,mfr_noon),'mo'); logy;

sas_vpix = interp1(sasvis.vdata.wavelength_vis, [1:length(sasvis.vdata.wavelength_vis)], [415,500,615,676,870,940],'nearest')
vpins = mfr_dirh(1:6,mfr_noon)./sasvis.vdata.direct_horizontal_vis(sas_vpix,sas_noon);
vscale = interp1([415,500,615,676,870,940],vpins, sasvis.vdata.wavelength_vis,'linear');
vscale(isnan(vscale)) = interp1([415,500,615,676,870,940],vpins, sasvis.vdata.wavelength_vis(isnan(vscale)),'nearest','extrap');
figure; plot(sasvis.vdata.wavelength_vis, vscale, 'k-x',[415,500,615,676,870,940],vpins,'mo' )
vscale(sasvis.vdata.wavelength_vis<325 | sasvis.vdata.wavelength_vis> 1001.5) = NaN;

figure; plot(sasnir.vdata.wavelength_nir, sasnir.vdata.responsivity_nir,'r');
% Based on irradiances in the NIR we should mask out WL>1340 and WL<1450
Io_vis = importdata(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\dev\hou\housashevisM1.20180401.Io_calib']);
Iovis.nm = Io_vis(:,2); Iovis.resp = Io_vis(:,3); Iovis.ESR = Io_vis(:,4);
figure; plot(Iovis.nm, Iovis.resp, 'r.',sasvis.vdata.wavelength_vis, sasvis.vdata.responsivity_vis, 'bo');
Io_vis(:,3) = Io_vis(:,3)./vscale;
fid = fopen(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\dev\hou\housashevisM1.20210803.Io_calib'], 'w+');
fprintf(fid, '%d  %f  %f  %f \n',Io_vis' ); 
fclose(fid);

nscale = ones(size(sasnir.vdata.responsivity_nir)).*(10./7);
nscale(sasnir.vdata.wavelength_nir<960 | (sasnir.vdata.wavelength_nir>1340 & sasnir.vdata.wavelength_nir<1450)) = NaN;
Io_nir = importdata(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\dev\hou\housashenirM1.20180401.Io_calib']);
Io_nir(:,3) = Io_nir(:,3)./nscale;
fid = fopen(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\dev\hou\housashenirM1.20210803.Io_calib'], 'w+');
fprintf(fid, '%d  %f  %f  %f \n',Io_nir' ); 
fclose(fid);

figure; plot(sasvis2.vdata.wavelength_vis, sasvis2.vdata.direct_horizontal_vis(:,sas_noon),'-',...
   sasnir2.vdata.wavelength_nir, sasnir2.vdata.direct_horizontal_nir(:,sas_noon),'-',...
   [415,500,615,676,870,940,1625], mfr_dirh(1:7,mfr_noon),'mo'); logy;
title('SASHe vIS NIR and MFRSR');
xlabel('wavelength [nm]'); ylabel('W/(m2 nm)')
legend('SASHe VIS','SASHe NIR','MFRSR')
figure; plot(sasvis2.vdata.wavelength_vis, sasvis2.vdata.responsivity_vis,'r-')
