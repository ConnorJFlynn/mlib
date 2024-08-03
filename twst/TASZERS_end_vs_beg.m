function TASZER_end_vs_beg
% Apply new responsivities and WL corrections to end data at SGP June 2

% All good.  Next, we read in sky data and do the same.
% We'll try 2024-04-23 for mix of clear and cloudy
taszers_xcal = load(getfullname('taszers_xcal_resp_20240426.mat','taszers_xcal', 'Select the taszers_xcal mat file.'));
% Use uncapitalized for beginning xcal.
twst11 = twst4_to_struct; 
twst11a = twst4_to_struct;twst11b = twst4_to_struct;twst11c = twst4_to_struct;twst11d = twst4_to_struct;
twst10 = twst4_to_struct;

ze1_vis = rd_SAS_raw(getfullname('*vis_1s*','Ze1')); ze1_nir = rd_SAS_raw(getfullname('*nir_1s*','Ze1'));
ze2_vis = rd_SAS_raw(getfullname('*vis_1s*','Ze2')); ze2_nir = rd_SAS_raw(getfullname('*nir_1s*','Ze2'));
lite1 = ze1_vis.Shutter_open_TF==1;
lite2 = ze2_vis.Shutter_open_TF==1;

% Use capitalized for ending xcal
TWST11 = twst4_to_struct; 
TWST11A = twst4_to_struct; TWST11B = twst4_to_struct; TWST11C = twst4_to_struct;
TWST10 = twst4_to_struct;

Ze1_vis = rd_SAS_raw(getfullname('*vis_1s*','Ze1')); Ze1_nir = rd_SAS_raw(getfullname('*nir_1s*','Ze1'));
Ze2_vis = rd_SAS_raw(getfullname('*vis_1s*','Ze2')); Ze2_nir = rd_SAS_raw(getfullname('*nir_1s*','Ze2'));
Lite1 = Ze1_vis.Shutter_open_TF==1;
Lite2 = Ze2_vis.Shutter_open_TF==1;


Ze2_new_wls = load(['D:\TASZERS\Ze2\HgAr\SASZe1_new_wls.mat']);
ze2_vis.wl = Ze2_new_wls.new_wl_A; ze2_nir.wl = Ze2_new_wls.new_wl_B;
Ze2_vis.wl = Ze2_new_wls.new_wl_A; Ze2_nir.wl = Ze2_new_wls.new_wl_B;

TWST10_new_wls = load(['D:\TASZERS\TWST_10\HgAr\TWST10_new_wls.mat']);
twst10.wl_A = TWST10_new_wls.new_wl_A; twst10.wl_B = TWST10_new_wls.new_wl_B; 
TWST10.wl_A = TWST10_new_wls.new_wl_A; TWST10.wl_B = TWST10_new_wls.new_wl_B; 

TWST11_new_wls = load(['D:\TASZERS\TWST_11\HgAr\TWST11_new_wls.mat']);
twst11.wl_A = TWST11_new_wls.new_wl_A; twst11.wl_B = TWST11_new_wls.new_wl_B; 
TWST11.wl_A = TWST11_new_wls.new_wl_A; TWST11.wl_B = TWST11_new_wls.new_wl_B; 


nm1_600 = interp1(Ze1_vis.wl, [1:length(Ze1_vis.wl)],600,'nearest');
nm2_600 = interp1(Ze2_vis.wl, [1:length(Ze2_vis.wl)],600,'nearest');
nm10_600 = interp1(TWST10.wl_A , [1:length(TWST10.wl_A)],600,'nearest');
nm11_600 = interp1(TWST11.wl_A , [1:length(TWST11.wl_A)],600,'nearest');

pos1 = Ze1_vis.Shutter_open_TF==1; pos2 = Ze2_vis.Shutter_open_TF==1;
pos1n = Ze1_nir.Shutter_open_TF==1; pos2n = Ze2_nir.Shutter_open_TF==1;

Ze1_1020 = find(Ze1_vis.wl>1019.6, 1, 'first'); 
taszers_xcal.Ze1_resp_vis(Ze1_1020) = taszers_xcal.Ze1_resp_vis(Ze1_1020-2); % To avoid NaN at Ze 1020
ze1_vis_rad = (ze1_vis.rate)./taszers_xcal.Ze1_resp_vis; ze1_nir_rad = (ze1_nir.rate)./taszers_xcal.Ze1_resp_nir;
ze2_vis_rad = (ze2_vis.rate)./taszers_xcal.Ze2_resp_vis; ze2_nir_rad = (ze2_nir.rate)./taszers_xcal.Ze2_resp_nir;
Ze1_vis_rad = (Ze1_vis.rate)./taszers_xcal.Ze1_resp_vis; Ze1_nir_rad = (Ze1_nir.rate)./taszers_xcal.Ze1_resp_nir;
Ze2_vis_rad = (Ze2_vis.rate)./taszers_xcal.Ze2_resp_vis; Ze2_nir_rad = (Ze2_nir.rate)./taszers_xcal.Ze2_resp_nir;

TWST10_radA =(TWST10.rate_A)./taszers_xcal.twst10_resp.A; TWST10_radB =(TWST10.rate_B)./taszers_xcal.twst10_resp.B;
twst10_radA =(twst10.rate_A)./taszers_xcal.twst10_resp.A; twst10_radB =(twst10.rate_B)./taszers_xcal.twst10_resp.B;
TWST11_radA =(TWST11.rate_A)./taszers_xcal.twst11_resp.A; TWST11_radB =(TWST11.rate_B)./taszers_xcal.twst11_resp.B;
twst11_radA =(twst11.rate_A)./taszers_xcal.twst11_resp.A; twst11_radB =(twst11.rate_B)./taszers_xcal.twst11_resp.B;

TWST11A_radA =(TWST11A.rate_A)./taszers_xcal.twst11_resp.A; TWST11A_radB =(TWST11A.rate_B)./taszers_xcal.twst11_resp.B;
TWST11B_radA =(TWST11B.rate_A)./taszers_xcal.twst11_resp.A; TWST11B_radB =(TWST11B.rate_B)./taszers_xcal.twst11_resp.B;
TWST11C_radA =(TWST11C.rate_A)./taszers_xcal.twst11_resp.A; TWST11C_radB =(TWST11C.rate_B)./taszers_xcal.twst11_resp.B;

twst11a_radA =(twst11a.rate_A)./taszers_xcal.twst11_resp.A; twst11a_radB =(twst11a.rate_B)./taszers_xcal.twst11_resp.B;
twst11b_radA =(twst11b.rate_A)./taszers_xcal.twst11_resp.A; twst11b_radB =(twst11b.rate_B)./taszers_xcal.twst11_resp.B;
twst11c_radA =(twst11c.rate_A)./taszers_xcal.twst11_resp.A; twst11c_radB =(twst11c.rate_B)./taszers_xcal.twst11_resp.B;
twst11d_radA =(twst11d.rate_A)./taszers_xcal.twst11_resp.A; twst11d_radB =(twst11d.rate_B)./taszers_xcal.twst11_resp.B;

figure; plot([ze1_vis.wl, ze1_nir.wl], [mean(ze1_vis_rad(lite1,:)), mean(ze1_nir_rad(lite1,:))],'-',...
   [ze1_vis.wl, ze1_nir.wl], [mean(Ze1_vis_rad(Lite1,:)), mean(Ze1_nir_rad(Lite1,:))],'-'); legend('ze1', 'Ze1')
figure; plot([ze2_vis.wl, ze2_nir.wl], [mean(ze2_vis_rad(lite2,:)), mean(ze2_nir_rad(lite2,:))],'-',...
   [ze2_vis.wl, ze2_nir.wl], [mean(Ze2_vis_rad(Lite2,:)), mean(Ze2_nir_rad(Lite2,:))],'-'); legend('ze2', 'Ze2')
figure; plot([TWST10.wl_A; TWST10.wl_B], [mean(TWST10_radA,2);mean(TWST10_radB,2)],'-',...
   [TWST10.wl_A; TWST10.wl_B], [mean(twst10_radA,2);mean(twst10_radB,2)],'-'); legend('TWST10','twst10')
figure; plot([TWST11B.wl_A; TWST11B.wl_B], [mean(TWST11B_radA,2);mean(TWST11B_radB,2)],'-',...
   [TWST11B.wl_A; TWST11B.wl_B], [mean(twst11b_radA,2);mean(twst11b_radB,2)],'-'); legend('TWST11 B','twst11 b')

Ze1_vis_pmd = 100.*(mean(Ze1_vis_rad(Lite1,:)) - mean(ze1_vis_rad(lite1,:)))./mean(ze1_vis_rad(lite1,:));
Ze1_nir_pmd = 100.*(mean(Ze1_nir_rad(Lite1,:)) - mean(ze1_nir_rad(lite1,:)))./mean(ze1_nir_rad(lite1,:));
Ze2_vis_pmd = 100.*(mean(Ze2_vis_rad(Lite2,:)) - mean(ze2_vis_rad(lite2,:)))./mean(ze2_vis_rad(lite2,:));
Ze2_nir_pmd = 100.*(mean(Ze2_nir_rad(Lite2,:)) - mean(ze2_nir_rad(lite2,:)))./mean(ze2_nir_rad(lite2,:));
twst10_A_pmd =  100.*(nanmean(TWST10_radA,2)-nanmean(twst10_radA,2))./nanmean(twst10_radA,2);
twst10_B_pmd =  100.*(nanmean(TWST10_radB,2)-nanmean(twst10_radB,2))./nanmean(twst10_radB,2);
twst11b_A_pmd =  100.*(nanmean(TWST11B_radA,2)-nanmean(twst11b_radA,2))./nanmean(twst11b_radA,2);
twst11b_B_pmd =  100.*(nanmean(TWST11B_radB,2)-nanmean(twst11b_radB,2))./nanmean(twst11b_radB,2);

figure; plot([ze1_vis.wl, ze1_nir.wl],[Ze1_vis_pmd,Ze1_nir_pmd],'-',...
   [ze2_vis.wl, ze2_nir.wl],[Ze2_vis_pmd,Ze2_nir_pmd],'-',...
   [TWST10.wl_A; TWST10.wl_B], [twst10_A_pmd; twst10_B_pmd],'-',...
   [TWST11.wl_A; TWST11.wl_B], [twst11b_A_pmd; twst11b_B_pmd],'-');
legend('Ze1','Ze2','TWST-10','TWST-11')

figure; plot([ze1_vis.wl, ze1_nir.wl],[Ze1_vis_pmd,Ze1_nir_pmd],'-',...
   [TWST10.wl_A; TWST10.wl_B], [twst10_A_pmd; twst10_B_pmd],'-',...
   [TWST11.wl_A; TWST11.wl_B], [twst11b_A_pmd; twst11b_B_pmd],'-');
legend('Ze1','TWST-10','TWST-11');
xlabel('wavelength [nm]'); ylabel('Calibration drift [%]')


figure; plot(...
   [TWST10.wl_A; TWST10.wl_B], ([twst10_A_pmd; twst10_B_pmd] + [twst11b_A_pmd; twst11b_B_pmd])./2,'-');
legend('(TWST10 + TWST11)/2');
xlabel('wavelength [nm]'); ylabel('Calibration drift [%]')

figure; plot([TWST11B.wl_A; TWST11B.wl_B], [(TWST11A_radA);(TWST11A_radB)],'-'); legend('TWST11 A')
% figure; plot(Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'.',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'.',...
%    TWST10.time, TWST10_radA(nm10_500,:),'.',TWST11.time, TWST11_radA(nm11_500,:),'.');dynamicDateTicks;
% ylabel('radiance'); 
% legend('SASZe1','SASZe2','TWST-10','TWST-11')
try
   anet_zrad = anet_ppl_zenrad(ceil(Ze1_vis.time(end))+1, ceil(Ze1_vis.time(1)-1));
catch
   if ~isavar('anet_zrad')||isempty(anet_zrad)
      anet_zrad.time = NaN;
      anet_zrad.zenrad_380_nm=NaN;anet_zrad.zenrad_440_nm=NaN;anet_zrad.zenrad_500_nm=NaN;
      anet_zrad.zenrad_675_nm=NaN; anet_zrad.zenrad_870_nm=NaN;anet_zrad.zenrad_1020_nm=NaN;
      anet_zrad.zenrad_1640_nm=NaN;
   end
end
% Read anet cloudmode file
% anet_zrad = aeronet_zenith_radiance(getfullname('*ppl','anet_ppl','Select Aeronet PPL file'));
try
   cim_cld = rd_cimel_cloudrad_v3(ceil(Ze1_vis.time(end))+1, ceil(Ze1_vis.time(1)));
catch
   if ~isavar('cim_cld')||isempty(cim_cld)
      cim_cld.time = NaN;
      cim_cld.A380nm=NaN;cim_cld.A440nm=NaN;cim_cld.A500nm=NaN;cim_cld.A675nm=NaN;
      cim_cld.A870nm=NaN;cim_cld.A1020nm=NaN;cim_cld.A1640nm=NaN;
      cim_cld.K380nm=NaN;cim_cld.K440nm=NaN;cim_cld.K500nm=NaN;cim_cld.K675nm=NaN;
      cim_cld.K870nm=NaN;cim_cld.K1020nm=NaN;cim_cld.K1640nm=NaN;
   end
end
   if ~isavar('anet_zrad')||isempty(anet_zrad)
      anet_zrad.time = NaN;
      anet_zrad.zenrad_380_nm=NaN;anet_zrad.zenrad_440_nm=NaN;anet_zrad.zenrad_500_nm=NaN;
      anet_zrad.zenrad_675_nm=NaN; anet_zrad.zenrad_870_nm=NaN;anet_zrad.zenrad_1020_nm=NaN;
      anet_zrad.zenrad_1640_nm=NaN;
   end
   if ~isavar('cim_cld')||isempty(cim_cld)
      cim_cld.time = NaN;
      cim_cld.A380nm=NaN;cim_cld.A440nm=NaN;cim_cld.A500nm=NaN;cim_cld.A675nm=NaN;
      cim_cld.A870nm=NaN;cim_cld.A1020nm=NaN;cim_cld.A1640nm=NaN;
      cim_cld.K380nm=NaN;cim_cld.K440nm=NaN;cim_cld.K500nm=NaN;cim_cld.K675nm=NaN;
      cim_cld.K870nm=NaN;cim_cld.K1020nm=NaN;cim_cld.K1640nm=NaN;
   end
figure; plot(Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'.',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'.',...
   TWST10.time, TWST10_radA(nm10_500,:),'.',TWST11.time, TWST11_radA(nm11_500,:),'.');dynamicDateTicks;
ylabel('Radiance [W/m^2/nm/sr]'); 
legend('SASZe1','SASZe2','TWST-10','TWST-11')
title({'Zenith Radiances at 500 nm during TASZERS end cal';datestr(floor(mean(Ze1_vis.time)),'yyyy-mm-dd')});

% inserting anet merge here
wl_K = [380, 440, 500, 675, 870, 1020, 1640]; 
zen_ppl = [anet_zrad.zenrad_380_nm,anet_zrad.zenrad_440_nm,anet_zrad.zenrad_500_nm,anet_zrad.zenrad_675_nm,...
   anet_zrad.zenrad_870_nm,anet_zrad.zenrad_1020_nm,anet_zrad.zenrad_1640_nm];
rad_A = [cim_cld.A380nm,cim_cld.A440nm,cim_cld.A500nm,cim_cld.A675nm,...
   cim_cld.A870nm,cim_cld.A1020nm,cim_cld.A1640nm]; 
% rad_A = nanmean(rad_A,1);
rad_K = [cim_cld.K380nm,cim_cld.K440nm,cim_cld.K500nm,cim_cld.K675nm,...
   cim_cld.K870nm,cim_cld.K1020nm,cim_cld.K1640nm]; 
% rad_K = nanmean(rad_K,1);

[cim.time, cind] = sort([cim_cld.time;cim_cld.time;anet_zrad.time]);
cim.wl = wl_K;
ctmp = [rad_A; rad_K; zen_ppl;];
cim.rad = ctmp(cind,:);





% figure; plot(cim_cld.time, cim_cld.A500nm,'o',cim_cld.time, cim_cld.K500nm,'x'); dynamicDateTicks;
% legend('Cld A500nm', 'Cld K500nm')
% ylabel(cim_cld.zenrad_units)

% I could put a loop with a menu here to select limited times for spectral averages
% allowing user to save, skip, or done.
done = false; zoom('on');
while ~done
   mn = menu('Zoom in to select a limited time range over which to compute for a spectral average?', 'Yes, ready.', 'Nah, skip it')
   if mn ==2
      done = true;
   end
   if ~done
      xl = xlim;
      xl_1_v = Ze1_vis.time>xl(1)&Ze1_vis.time<xl(2);xl_1_n = Ze1_nir.time>xl(1)&Ze1_nir.time<xl(2);
      xl_2_v = Ze2_vis.time>xl(1)&Ze2_vis.time<xl(2);xl_2_n = Ze2_nir.time>xl(1)&Ze2_nir.time<xl(2);
      xl_10 = TWST10.time>xl(1)&TWST10.time<xl(2);
      xl_11 = TWST11.time>xl(1)&TWST11.time<xl(2);
      xl_cim = cim.time>xl(1)&cim.time<xl(2);

      figure; plot( [Ze1_vis.wl,Ze1_nir.wl], [mean(Ze1_vis_rad(pos1&xl_1_v,:),1),mean(Ze1_nir_rad(pos1n&xl_1_n,:),1)],'-',...
         [Ze2_vis.wl,Ze2_nir.wl], [mean(Ze2_vis_rad(pos2&xl_2_v,:),1),mean(Ze2_nir_rad(pos2n&xl_2_n,:),1)],'-',...
         [TWST10.wl_A;TWST10.wl_B], [mean(TWST10_radA(:,xl_10),2);mean(TWST10_radB(:,xl_10),2)], '-',...
         [TWST11.wl_A;TWST11.wl_B], [mean(TWST11_radA(:,xl_11),2);mean(TWST11_radB(:,xl_11),2)],'-',...
         cim.wl, nanmean(cim.rad(xl_cim,:),1),'ko','markersize',12,'MarkerFaceColor',[.6,.6,.6]);logy
      title({'Zenith Radiances measured at SGP during TASZERS';datestr(mean(Ze1_vis.time(xl_1_v)),'yyyy-mm-dd HH:MM')});
      ylabel('Radiance [W/m^2/nm/sr]');
      xlabel('Wavelength [nm]');
      legend('SASZe1','SASZe2','TWST-10','TWST-11', 'Cimel');
    


      wl_Z1 = unique([Ze1_vis.wl,Ze1_nir.wl]);
      wl_Z2 = unique([Ze2_vis.wl,Ze2_nir.wl]);
      wl_T10 = unique([TWST10.wl_A;TWST10.wl_B]);
      wl_T11 = unique([TWST11.wl_A;TWST11.wl_B]);
      wl_all = unique([wl_Z1, wl_Z2, wl_T10', wl_T11']);
      rads.wl_all = wl_all;

      %First, Ze1
      Ze1_v = interp1(Ze1_vis.wl, nanmean(Ze1_vis_rad(pos1&xl_1_v,:),1), wl_all, 'linear');
      Ze1_n = interp1(Ze1_nir.wl, nanmean(Ze1_nir_rad(pos1n&xl_1_n,:),1), wl_all, 'linear');
      %  Scale Ze1_n to mean(Ze1_v) between 1000:1020nm. 
      wl_1000_1020 = wl_all>=1000&wl_all<=1020;
      Ze1_n = (nanmean(Ze1_v(wl_1000_1020))./nanmean(Ze1_n(wl_1000_1020))).*Ze1_n;
      %Then seam from 980-1020. 
      Ze1 = Ze1_v; 
      wl_seam = wl_all>=980 & wl_all<=1020;
      Ze1(wl_seam) = seam_ab(wl_all(wl_seam), Ze1_v(wl_seam), Ze1_n(wl_seam));
      Ze1(wl_all>=1020) = Ze1_n(wl_all>=1020);
      Ze1 = interp1(wl_all(~isnan(Ze1)), Ze1(~isnan(Ze1)), wl_all,'linear');

      % Now Ze2
      Ze2_v = interp1(Ze2_vis.wl, nanmean(Ze2_vis_rad(pos2&xl_2_v,:),1), wl_all, 'linear');
      Ze2_n = interp1(Ze2_nir.wl, nanmean(Ze2_nir_rad(pos2n&xl_2_n,:),1), wl_all, 'linear');
      wl_1010_1020 = wl_all>=1010&wl_all<=1020;
      Ze2_n = (nanmean(Ze2_v(wl_1010_1020))./nanmean(Ze2_n(wl_1010_1020))).*Ze2_n;
      Ze2 = Ze2_v; 
      wl_seam = wl_all>=1000 & wl_all<=1020;
      Ze2(wl_seam) = seam_ab(wl_all(wl_seam), Ze2_v(wl_seam), Ze2_n(wl_seam));
      Ze2(wl_all>=1020) = Ze2_n(wl_all>=1020);
      Ze2 = interp1(wl_all(~isnan(Ze2)), Ze2(~isnan(Ze2)), wl_all,'linear');
      % figure_(111);plot(wl_all, Ze2_v,'k-'); hold('on'); plot(wl_all,Ze2_n,'x','color',[.5,.5,.5]); 
      % plot(wl_all, Ze2,'r.');hold('off')

      % Now TWST10
      T10_A = interp1(TWST10.wl_A, nanmean(TWST10_radA(:,xl_10),2), wl_all, 'linear');
      T10_B = interp1(TWST10.wl_B, nanmean(TWST10_radB(:,xl_10),2), wl_all, 'linear');
      T10 = T10_A;
      T10(~isnan(T10_B)) = T10_B(~isnan(T10_B));

      % Now TWST11
      T11_A = interp1(TWST11.wl_A, nanmean(TWST11_radA(:,xl_11),2), wl_all, 'linear');
      T11_B = interp1(TWST11.wl_B, nanmean(TWST11_radB(:,xl_11),2), wl_all, 'linear');
      T11 = T11_A;
      T11(~isnan(T11_B)) = T11_B(~isnan(T11_B));
% figure; plot(wl_all, T10_A, '-', wl_all, T10_B,'-')
      rads.wl_all = wl_all;
      rads.Ze1 = Ze1; rads.Ze2=Ze2; rads.T10 = T10; rads.T11 = T11;
      rads.mean_rad = nanmean([Ze1; Ze2; T10; T11],1);
      rads.std_rad = nanstd([Ze1; Ze2; T10; T11]);
      rads.rad_cwl = interp1(rads.wl_all, rads.mean_rad, cim.wl,'linear');

      figure; plot( wl_all, [Ze1; Ze2; T10; T11]-rads.mean_rad,'-',...
         wl_K, nanmean(cim.rad(xl_cim,:),1)-rads.rad_cwl,'ko','markersize',12,'MarkerFaceColor',[.6,.6,.6]);%logy
      title({'Zenith Radiances measured at SGP during TASZERS';datestr(mean(Ze1_vis.time(xl_1_v)),'yyyy-mm-dd HH:MM')});
      ylabel('Radiance [W/m^2/nm/sr]');
      xlabel('Wavelength [nm]');
      legend('SASZe1','SASZe2','TWST-10','TWST-11', 'Cimel Rad');

      figure; plot( wl_all, 100.*([Ze1; Ze2; T10; T11]-rads.mean_rad)./rads.mean_rad,'-',...
         cim.wl, 100.*(nanmean(cim.rad(xl_cim,:),1)-rads.rad_cwl)./rads.rad_cwl,'ko','markersize',12,'MarkerFaceColor',[.6,.6,.6]);%logy
      title({'Zenith Radiances measured at SGP during TASZERS';datestr(mean(Ze1_vis.time(xl_1_v)),'yyyy-mm-dd HH:MM')});
      ylabel('% difference from mean');
      xlabel('Wavelength [nm]');
      legend('SASZe1','SASZe2','TWST-10','TWST-11', 'Cimel Rad');


      mn = menu('Save the visible figure?','Yes','No')
      if mn==1
         [~,enamp] = strtok(fliplr(TWST10.pname(1:end-1)),filesep);[~,enamp] = strtok(enamp(2:end),filesep);
         pname = [fliplr(enamp),datestr(mean(TWST10.time),'yyyymmdd')];
         if ~isadir(pname)
            mkdir(pname);
            pname = [pname, filesep];
         end
         figname = ['TASZERS_spectra_',datestr(mean(TWST10.time(xl_10)),'yyyymmdd_HHMMUT')];
         saveas(gcf,[pname, figname,'.png']); saveas(gcf,[pname, figname,'.fig']); 


      end
   end
end

menu('Move on with X-Y regression fits vs Cimel after zooming to desired period','OK')
xl = xlim;
xl_1_v = Ze1_vis.time>xl(1)&Ze1_vis.time<xl(2);xl_1_n = Ze1_nir.time>xl(1)&Ze1_nir.time<xl(2);
xl_2_v = Ze2_vis.time>xl(1)&Ze2_vis.time<xl(2);xl_2_n = Ze2_nir.time>xl(1)&Ze2_nir.time<xl(2);
xl_10 = TWST10.time>xl(1)&TWST10.time<xl(2);
xl_11 = TWST11.time>xl(1)&TWST11.time<xl(2);
xl_cim = cim.time>xl(1) & cim.time<xl(2);

xl_1_vi = find(xl_1_v&pos1); xl_1_ni = find(xl_1_n&pos1n);
xl_2_vi = find(xl_2_v&pos2); xl_2_ni = find(xl_2_n&pos2);
xl_10i = find(xl_10);
xl_11i = find(xl_11);
xl_ci =  find(xl_cim);

z1inc = interp1(  Ze1_vis.time(xl_1_vi),[1:length(Ze1_vis.time(xl_1_vi))], cim.time(xl_ci),'nearest');
z1inc(isnan(z1inc)) = [];
% [cinz1, z1inc] = nearest(cim.time(xl_ci), Ze1_vis.time(xl_1_vi));
z2inc = interp1(Ze2_vis.time(xl_2_vi),[1:length(Ze2_vis.time(xl_2_vi))],   cim.time(xl_ci),'nearest');
z2inc(isnan(z2inc)) = [];
% [cinz2, z2inc] = nearest(cim.time(xl_ci), Ze2_vis.time(xl_2_vi));
t10inc = interp1(TWST10.time(xl_10i), [1:length(TWST10.time(xl_10i))],cim.time(xl_ci),'nearest');
t10inc(isnan(t10inc)) = [];
% [cint10, t10inc] = nearest(cim.time(xl_ci), TWST10.time(xl_10i));
t11inc = interp1(TWST11.time(xl_11i),[1:length(TWST11.time(xl_11i))], cim.time(xl_ci),'nearest');
t11inc(isnan(t11inc)) = [];
% [cint11, t11inc] = nearest(cim.time(xl_ci), TWST11.time(xl_11i));
  
wl_K = [380, 440, 500, 675, 870, 1020, 1640]; 
z1_vij = [interp1(Ze1_vis.wl, [1:length(Ze1_vis.wl)],wl_K,'nearest')];
z2_vij = [interp1(Ze2_vis.wl, [1:length(Ze2_vis.wl)],wl_K,'nearest')];
z1_nij = [interp1(Ze1_nir.wl, [1:length(Ze1_nir.wl)],wl_K,'nearest')];
z2_nij = [interp1(Ze2_nir.wl, [1:length(Ze2_nir.wl)],wl_K,'nearest')];
t10_Aij = [interp1(TWST10.wl_A, [1:length(TWST10.wl_A)],wl_K,'nearest')];
t10_Bij = [interp1(TWST10.wl_B, [1:length(TWST10.wl_B)],wl_K,'nearest')];
t11_Aij = [interp1(TWST11.wl_A, [1:length(TWST11.wl_A)],wl_K,'nearest')];
t11_Bij = [interp1(TWST11.wl_B, [1:length(TWST11.wl_B)],wl_K,'nearest')];

 wl_ind = 2;
 figure; ax = plot(cim.rad(xl_ci(~isnan(z1inc)),wl_ind),Ze1_vis_rad(xl_1_vi(z1inc(~isnan(z1inc))),z1_vij(wl_ind)), '+',...
    cim.rad(xl_ci(~isnan(z2inc)),wl_ind),Ze2_vis_rad(xl_2_vi(z2inc(~isnan(z2inc))),z2_vij(wl_ind)), 'x',...
    cim.rad(xl_ci(~isnan(t10inc)),wl_ind),TWST10_radA(t10_Aij(wl_ind),xl_10i(t10inc(~isnan(t10inc)))), 'o',...
    cim.rad(xl_ci(~isnan(t11inc)),wl_ind),TWST11_radA(t11_Aij(wl_ind),xl_11i(t11inc(~isnan(t11inc)))), '*');
 yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
  hold('on'); plot(vl, vl, 'k-.','linewidth',5);
 ylim(vl); xlim(vl); axis('square');
 xlabel('Cimel radiance');
 legend('Ze1','Ze2', 'TWST-10','TWST-11','location','northwest');
ylabel([' radiance [mW/m^2/nm/sr]'], 'interp','tex');
if ~isempty(z1inc)
   title({sprintf('SGP TASZER from %s-%s',datestr(Ze1_vis.time(xl_1_vi(z1inc(1))),'yyyy-mm-dd HH:MM'),...
      datestr(Ze1_vis.time(xl_1_vi(z1inc(end))),'HH:MM'));sprintf('Radiance at %d nm',wl_K(wl_ind))})
else
   close(gcf)
end

slope_m = nan([4,7]);
figure_(88);
for wl_ind = 1:6
   spec_str = 'SASZe1 vis'; 
   good_i = find(~isnan(z1inc));
   XX = cim.rad(xl_ci(good_i),wl_ind);
   YY = Ze1_vis_rad(xl_1_vi(z1inc(good_i)),z1_vij(wl_ind));
   ax = plot(XX,YY, '+');
   yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
   ylim(vl); xlim(vl); axis('square');
   [P1] = polyfit(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)),1); 
   slope_m(1,wl_ind) = polyder(P1,1);
   hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P1,vl),'-'); hold('off');
   xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
   title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
      sprintf('SGP TASZER from %s-%s',datestr(Ze1_vis.time(xl_1_vi(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(Ze1_vis.time(xl_1_vi(good_i(end))),'HH:MM'))})
   [txt, stats] = txt_stat(XX, YY,P1); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
   pause(2);close(88); figure_(88);

   spec_str = 'SASZe2 vis'; 
   good_i = find(~isnan(z2inc));
   XX = cim.rad(xl_ci(good_i),wl_ind);
   YY = Ze2_vis_rad(xl_2_vi(z2inc(good_i)),z2_vij(wl_ind));
   ax = plot(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)), '+');
   yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
   ylim(vl); xlim(vl); axis('square');
   [P2] = polyfit(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)),1); 
   slope_m(2,wl_ind) = polyder(P2,1);
   hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P2,vl),'-'); hold('off');
   xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
   title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
      sprintf('SGP TASZER from %s-%s',datestr(Ze2_vis.time(xl_2_vi(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(Ze2_vis.time(xl_2_vi(good_i(end))),'HH:MM'))})
 [txt, stats] = txt_stat(XX, YY,P2); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
    pause(2);close(88); figure_(88);

    if ~isnan(wl_ind) && ~isnan(t10_Aij(wl_ind))
       spec_str = 'TWST-10 A'; %XX = cim.rad(cimt10,wl_ind);YY = TWST10_radA(t10_Aij(wl_ind),xl_10i(t10inc))';
       good_i = find(~isnan(t10inc));
       XX = cim.rad(xl_ci(good_i),wl_ind);
       YY = TWST10_radA(t10_Aij(wl_ind),xl_10i(t10inc(good_i)))';

       ax = plot(XX,YY, '+');
       yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
       ylim(vl); xlim(vl); axis('square');
       [P3] = polyfit(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)),1); 
       slope_m(3,wl_ind) = polyder(P3,1);
       hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P3,vl),'-'); hold('off');
       xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
       title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
          sprintf('SGP TASZER from %s-%s',datestr(TWST10.time(xl_10i(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(TWST10.time(xl_10i(good_i(end))),'HH:MM'))})
       [txt, stats] = txt_stat(XX, YY,P3); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
       pause(2);close(88); figure_(88);
    end

    if ~isnan(wl_ind) && ~isnan(t11_Aij(wl_ind))
       spec_str = 'TWST-11 A'; %XX = cim.rad(cimt11,wl_ind);YY = TWST11_radA(t11_Aij(wl_ind),xl_11i(t11inc))';
       good_i = find(~isnan(t11inc));
       XX = cim.rad(xl_ci(good_i),wl_ind);
       YY = TWST11_radA(t11_Aij(wl_ind),xl_11i(t11inc(good_i)))';
       ax = plot(XX,YY, '+');
       yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
       ylim(vl); xlim(vl); axis('square');
       [P4] = polyfit(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)),1); 
       slope_m(4,wl_ind) = polyder(P4,1);
       hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P4,vl),'-'); hold('off');
       xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
       title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
          sprintf('SGP TASZER from %s-%s',datestr(TWST11.time(xl_11i(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(TWST11.time(xl_11i(good_i(end))),'HH:MM'))})
       [txt, stats] = txt_stat(XX, YY,P4); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
       pause(2);close(88); figure_(88);
    end
end
wl_ind = 6;
    if ~isnan(wl_ind) && ~isnan(t10_Bij(wl_ind))
       spec_str = 'TWST-10 B'; %XX = cim.rad(cimt10,wl_ind);YY = TWST10_radA(t10_Aij(wl_ind),xl_10i(t10inc))';
       good_i = find(~isnan(t10inc));
       XX = cim.rad(xl_ci(good_i),wl_ind);
       YY = TWST10_radB(t10_Bij(wl_ind),xl_10i(t10inc(good_i)))';

       ax = plot(XX,YY, '+');
       yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
       ylim(vl); xlim(vl); axis('square');
       [P3] = polyfit(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)),1); 
       slope_m(3,wl_ind) = polyder(P3,1);
       hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P3,vl),'-'); hold('off');
       xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
       title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
          sprintf('SGP TASZER from %s-%s',datestr(TWST10.time(xl_10i(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(TWST10.time(xl_10i(good_i(end))),'HH:MM'))})
       [txt, stats] = txt_stat(XX, YY,P3); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
       pause(2);close(88); figure_(88);
    end

    if ~isnan(wl_ind) && ~isnan(t11_Bij(wl_ind))
       spec_str = 'TWST-11 B'; %XX = cim.rad(cimt11,wl_ind);YY = TWST11_radA(t11_Aij(wl_ind),xl_11i(t11inc))';
       good_i = find(~isnan(t11inc));
       XX = cim.rad(xl_ci(good_i),wl_ind);
       YY = TWST11_radB(t11_Bij(wl_ind),xl_11i(t11inc(good_i)))';
       ax = plot(XX,YY, '+');
       yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
       ylim(vl); xlim(vl); axis('square');
       [P4] = polyfit(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)),1); 
       slope_m(4,wl_ind) = polyder(P4,1);
       hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P4,vl),'-'); hold('off');
       xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
       title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
          sprintf('SGP TASZER from %s-%s',datestr(TWST11.time(xl_11i(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(TWST11.time(xl_11i(good_i(end))),'HH:MM'))})
       [txt, stats] = txt_stat(XX, YY,P4); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
       pause(2);close(88); figure_(88);
    end






wl_ind = 7;
good_i = find(~isnan(z1inc));
XX = cim.rad(xl_ci(good_i),wl_ind);
YY = Ze1_nir_rad(xl_1_ni(z1inc(good_i)),z1_nij(wl_ind)); good_i = ~isnan(XX)&~isnan(YY);
XX = XX(good_i); YY = YY(good_i);
 spec_str = 'SASZe1 nir';
ax = plot(XX,YY, '+');
yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
ylim(vl); xlim(vl); axis('square');
[P1] = polyfit(XX,YY,1); 
slope_m(1,wl_ind) = polyder(P1,1);
hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P1,vl),'-'); hold('off');
xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
   sprintf('SGP TASZER from %s-%s',datestr(Ze1_vis.time(xl_1_vi(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(Ze1_vis.time(xl_1_vi(good_i(end))),'HH:MM'))})
 [txt, stats] = txt_stat(XX, YY,P1); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
    pause(2);close(88); figure_(88);
    
spec_str = 'SASZ2 nir';  
good_i = find(~isnan(z2inc));
XX = cim.rad(xl_ci(good_i),wl_ind);
YY = Ze2_nir_rad(xl_2_ni(z2inc(good_i)),z2_nij(wl_ind)); 
good_i = ~isnan(XX)&~isnan(YY); XX = XX(good_i); YY = YY(good_i);
ax = plot(XX,YY, '+');
yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
ylim(vl); xlim(vl); axis('square');
[P2] = polyfit(XX,YY,1); 
slope_m(2,wl_ind) = polyder(P2,1);
hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P2,vl),'-'); hold('off');
xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
   sprintf('SGP TASZER from %s-%s',datestr(Ze2_nir.time(xl_2_ni(good_i(1))),'yyyy-mm-dd HH:MM'),datestr(Ze2_nir.time(xl_2_ni(good_i(end))),'HH:MM'))})
 [txt, stats] = txt_stat(XX, YY,P2); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
    pause(2);close(88); figure_(88);
    
spec_str = 'TWST-10 B'; 
good_i = find(~isnan(t10inc));
XX = cim.rad(xl_ci(good_i),wl_ind);
YY = TWST10_radB(t10_Bij(wl_ind),xl_10i(t10inc(good_i)))';
good_i = ~isnan(XX)&~isnan(YY); XX = XX(good_i); YY = YY(good_i);
ax = plot(XX,YY, '+');
yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
ylim(vl); xlim(vl); axis('square');
[P3] = polyfit(XX,YY,1); 
slope_m(3,wl_ind) = polyder(P3,1);
hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P3,vl),'-'); hold('off');
xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
   sprintf('SGP TASZER from %s-%s',datestr(Ze1_vis.time(xl_1_vi(z1inc(1))),'yyyy-mm-dd HH:MM'),datestr(Ze1_vis.time(xl_1_vi(z1inc(end))),'HH:MM'))})
 [txt, stats] = txt_stat(XX, YY,P3); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
    pause(2);close(88); figure_(88);
    
spec_str = 'TWST-11 B'; 
good_i = find(~isnan(t11inc));
XX = cim.rad(xl_ci(good_i),wl_ind);
YY = TWST11_radB(t11_Bij(wl_ind),xl_11i(t11inc(good_i)))';
good_i = ~isnan(XX)&~isnan(YY); XX = XX(good_i); YY = YY(good_i);
ax = plot(XX,YY, '+');
yll = ylim; xll = xlim;  vl = [0,max([yll(2),xll(2)])];
ylim(vl); xlim(vl); axis('square');
[P4] = polyfit(XX(~isnan(XX)&~isnan(YY)),YY(~isnan(XX)&~isnan(YY)),1); 
slope_m(4,wl_ind) = polyder(P4,1);
hold('on'); plot(vl, vl, 'k-.','linewidth',5); plot(vl, polyval(P4,vl),'-'); hold('off');
xlabel('Cimel radiance'); ylabel([spec_str,' radiance [mW/m^2/nm/sr]'], 'interp','tex');
title({sprintf('%s vs Cimel, %d nm Radiance',spec_str, wl_K(wl_ind));...
   sprintf('SGP TASZER from %s-%s',datestr(Ze1_vis.time(xl_1_vi(z1inc(1))),'yyyy-mm-dd HH:MM'),datestr(Ze1_vis.time(xl_1_vi(z1inc(end))),'HH:MM'))})
 [txt, stats] = txt_stat(XX, YY,P4); txt(2:end-1) = []; an = annotation('textbox',[0.21   0.8    0.165    0.085], 'string',txt);
    pause(2);close(88); figure_(88);

    slope_m(slope_m==0) = NaN;
figure; plot(wl_K,slope_m,'o-')
legend('Ze1','Ze2','T10','T11');
xlabel('wavelength [nm]');
ylabel('Slope vs Cimel by Wavelength')


% Consider adding density plots below
% For example, between Ze and TWST cloud and clear sky measurements.

% if size(X,1)==size(Y,2); Y = Y'; end
% bad = X<=-1 | Y<=-1; X(bad) =[]; Y(bad) = [];
% D = den2plot(X,Y);
% figure; scatter(X, Y,6,log10(D)); colormap(comp_map_w_jet);
% xlabel(x_str); ylabel(y_str); title(t_str)
%  xl = xlim; yl = ylim; xlim([0,round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
% hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
% 
% [good, P_bar] = rbifit(X,Y,3,0); hold('on');  plot(xl,polyval(P_bar,xl),'b-', 'linewidth',3); hold('off')
% 
% [gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
% gt.Units = 'Normalized'; gt.Position = round(gt.Position.*10)./10;

 
return