% SAS He shadowband processing test

% Open nir_1s, vis_1s, vis_ms.
vis_1s = SAS_read_ava(getfullname_('sashe_vis_1s*.csv','vis_1s','Select vis 1s file.'));
%%
[~,tok] = strtok(vis_1s.fname,'.');
vis_nm = read_avantes_trt(getfullname_('*.trt','sashe','Select CCD file for pixel map.')); 
vis_1s.nm = vis_nm.nm;
%%
proc_sashe_1s(vis_1s);
%%
nir_1s = SAS_read_ava(getfullname_(['sashe_nir_1s*',tok{1}],'nir_1s','Select NIR 1s file.'));
nir_nm = read_avantes_trt(getfullname_('*.trt','sashe','Select NIR file for pixel map.')); % Read in a file from nir SN 69 to use as the wavelength scale
nir_1s.nm = nir_nm.nm;
%%
vis_ms = SAS_read_ava(getfullname_(['sashe_vis_ms*',tok{1}],'vis_ms','Select vis ms file.'));
vis_ms.nm = vis_1s.nm;
%%
clear vis_nm
clear nir_nm
%%
ms.time = unique(vis_ms.time);
wl = [500:20:800];
[nm_ind,tmp_] = nearest(vis_ms.nm,wl);
mark = find(diff(vis_ms.Spectrometer_clock_ticks)>50000,1,'first');


%%
figure; plot([1:mark], [vis_ms.Inner_band_angle_deg(1:mark), vis_ms.Outer_band_angle_deg(1:mark)],'o-');
legend('inner','outer');
xlabel('record number');
ylabel('band angle [deg]');
tl = title({'Band angles in vis ms scan';vis_ms.fname{:}}); set(tl,'interp','none')
%%
subms.nm = downsample(vis_ms.nm,4);
subms.spec = downsample(vis_ms.spec(1:mark,:),4,2);
subms.nm_ind = nearest(subms.nm,wl);
%%
figure; these = plot(vis_ms.Inner_band_angle_raw_deg(1:mark), ...
   ones([length(vis_ms.Inner_band_angle_deg(1:mark)),1])*subms.spec(1,subms.nm_ind)-subms.spec(:,subms.nm_ind), '.-'); 
these=recolor(these,[500:20:800]);colorbar
%%
ms_traces = ones([length(vis_ms.Inner_band_angle_deg(1:mark)),1])*vis_ms.spec(1,nm_ind)-vis_ms.spec(1:mark,nm_ind);
ms_traces = ones([length(vis_ms.Inner_band_angle_deg(1:mark)),1])*subms.spec(1,subms.nm_ind)-subms.spec(:,subms.nm_ind);
%%
figure; these = plot(vis_ms.Inner_band_angle_raw_deg(1:mark), ...
  ms_traces ./ (ones(size(vis_ms.time(1:mark)))*max(ms_traces,[],1)) , '.-'); 
these=recolor(these,[500:20:800]);colorbar
%%
figure; plot([1:length(vis_ms.time)],[0;diff(vis_ms.Spectrometer_clock_ticks)],'o-')

%%
vis_1s.darks = mean(vis_1s.spec(vis_1s.Shutter_open_TF==0&(vis_1s.nth<7),:),1);
vis_1s.hemisp_raw = mean(vis_1s.spec((vis_1s.Shutter_open_TF==1)&(abs(vis_1s.Inner_band_angle_deg)>70)...
   &(vis_1s.nth<7),:),1);
vis_1s.hemisp = vis_1s.hemisp_raw - vis_1s.darks;
vis_1s.blocked = mean(vis_1s.spec((vis_1s.Shutter_open_TF==1)&(abs(vis_1s.Inner_band_angle_deg)<1)...
   &(vis_1s.nth<7),:),1);
vis_1s.bands = mean(vis_1s.spec((vis_1s.Shutter_open_TF==1)&(abs(vis_1s.Inner_band_angle_deg)>1)...
   &(abs(vis_1s.Inner_band_angle_deg)<20)&(vis_1s.nth<7),:),1);
vis_1s.direct_raw = vis_1s.bands - vis_1s.blocked ;
vis_1s.diffuse = vis_1s.hemisp - vis_1s.direct_raw;
%%
vis_1s.good_pix = ones(size(vis_1s.darks));
vis_1s.good_ii = find(vis_1s.good_pix);

vis_1s.good_pix = vis_1s.good_pix & vis_1s.good_ii>50 & vis_1s.good_ii<1476;
vis_1s.good_ii = find(vis_1s.good_pix);
%%


figure; plot(vis_1s.good_ii,[vis_1s.direct_raw(vis_1s.good_pix); ...
   vis_1s.diffuse(vis_1s.good_pix); ...
   vis_1s.hemisp(vis_1s.good_pix); ...
   vis_1s.darks(vis_1s.good_pix)],'-');
lg =legend('direct','diffuse','hemisp','darks');set(lg,'interp','none')
%%

figure; plot(vis_1s.good_ii,[vis_1s.direct_raw(vis_1s.good_pix)./vis_1s.hemisp(vis_1s.good_pix); ...
   vis_1s.diffuse(vis_1s.good_pix)./vis_1s.hemisp(vis_1s.good_pix);...
   vis_1s.diffuse(vis_1s.good_pix)./vis_1s.direct_raw(vis_1s.good_pix)],'-');
lg = legend('T_dir','T_dif','dif/dir'); set(lg,'interp','none')

%%
vis_ms.good_pix = ones(size(vis_ms.nm));
vis_ms.good_ii = find(vis_ms.good_pix);

vis_ms.good_pix = vis_ms.good_pix & vis_ms.good_ii>50 & vis_ms.good_ii<1476;
vis_ms.good_ii = find(vis_ms.good_pix);
%%
figure;
lines = plot([1:length(vis_ms.time)], [vis_ms.Inner_band_angle_deg, vis_ms.Outer_band_angle_deg],'-');
legend('inner','outer');

%%
figure; plot(vis_ms.good_ii,[vis_ms.direct_raw(vis_ms.good_pix)./vis_ms.hemisp(vis_ms.good_pix); ...
   vis_ms.diffuse(vis_ms.good_pix)./vis_ms.hemisp(vis_ms.good_pix);...
   vis_ms.diffuse(vis_ms.good_pix)./vis_ms.direct_raw(vis_ms.good_pix)],'-');
lg = legend('T_dir','T_dif','dif/dir'); set(lg,'interp','none')

%%
% vis_sky = SAS_read_ava;
% %%
% figure; plot(vis_sky.nm, vis_sky.spec(vis_sky.Shuttered_0==1,:),'-')
%%
