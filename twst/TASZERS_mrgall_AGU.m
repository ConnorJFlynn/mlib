function TZR = TASZERS_mrgall_AGU
try
   anet_zrad = anet_ppl_zenrad(datenum(2024,06,01), datenum(2024,05,1));
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
   cim_cld = rd_cimel_cloudrad_v3(datenum(2024,06,01), datenum(2024,05,1));
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
figure; plot(cim_cld.time, cim_cld.K500nm,'o',anet_zrad.time, anet_zrad.zenrad_500_nm,'+','markersize',6);dynamicDateTicks;
ylabel('Radiance [W/m^2/nm/sr]');
legend('Cimel K Rad','Cimel PPL')
title({'Zenith Radiances at 500 nm during TASZERS'});

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
% xlim([tt, tt+1]);tl = xlim;
         % tl = cim.time>Ze1_vis.time(1) & cim.time<Ze1_vis.time(end);
         % TASZERS.cim.time = cim.time(tl); TASZERS.cim.wl = cim.wl; TASZERS.cim.rad = cim.rad(tl,:);
taszers_xcal = load(getfullname('taszers_xcal_resp_20240426.mat','taszers_xcal', 'Select the taszers_xcal mat file.'));
for tt = datenum(2024,5,1):datenum(2024,5,31)

   dstr = datestr(tt,'yyyymmdd'); dstr2 = datestr(tt+1,'yyyymmdd');
   if isafile([getnamedpath('TASZERS'),filesep,'TASZERS_',dstr,'.mat'])
      tic;
      disp(['Loading ','TASZERS_',dstr,'.mat'])
      TASZERS = load([getnamedpath('TASZERS'),filesep,'TASZERS_',dstr,'.mat']);
      toc
      pause(.5)
      Ze1_vis = TASZERS.Ze1_vis; 
      Ze2_vis=TASZERS.Ze2_vis; 
      Ze1_nir=TASZERS.Ze1_nir; 
      if isfield(TASZERS,'Ze12nir')
         Ze2_nir=TASZERS.Ze12nir;
      else
         Ze2_nir=TASZERS.Ze2_nir;
      end
      TWST10=TASZERS.TWST10;
      TWST11=TASZERS.TWST11;
      clear TASZERS
      if (isfield(Ze1_vis,'rate')&&isfield(Ze2_vis,'rate'))&&(isa(Ze1_vis.rate,'double')&&isa(Ze2_vis.rate,'double'))
         if isfield(Ze1_vis,'rate')
            rate = single(Ze1_vis.rate); 
            Ze1_vis = rmfield(Ze1_vis,'rate');
            Ze1_vis.rate =rate;
            rate = single(Ze1_nir.rate); 
            Ze1_nir = rmfield(Ze1_nir,'rate');
            Ze1_nir.rate =rate;
         end
         if isfield(Ze2_vis,'rate')
            rate = single(Ze2_vis.rate);
            Ze2_vis = rmfield(Ze2_vis,'rate');
            Ze2_vis.rate =rate;
            rate = single(Ze2_nir.rate);
            Ze2_nir = rmfield(Ze2_nir,'rate');
            Ze2_nir.rate =rate;
         end
         TASZERS.Ze1_vis = Ze1_vis;
         TASZERS.Ze2_vis = Ze2_vis;
         TASZERS.Ze1_nir = Ze1_nir;
         TASZERS.Ze2_nir = Ze2_nir;
         TASZERS.TWST10=TWST10;
         TASZERS.TWST11=TWST11;
         tic; save([getnamedpath('TASZERS'),filesep,'TASZERS_',dstr,'.mat'],'-struct','TASZERS');toc
         clear TASZERS
         pause(.5)
      end
      Ze1_1020 = find(Ze1_vis.wl>1019.6, 1, 'first'); taszers_xcal.Ze1_resp_vis(Ze1_1020) = taszers_xcal.Ze1_resp_vis(Ze1_1020-2);
      Ze1_vis_rad = (Ze1_vis.rate)./taszers_xcal.Ze1_resp_vis; Ze1_nir_rad = (Ze1_nir.rate)./taszers_xcal.Ze1_resp_nir;
      Ze2_vis_rad = (Ze2_vis.rate)./taszers_xcal.Ze2_resp_vis; Ze2_nir_rad = (Ze2_nir.rate)./taszers_xcal.Ze2_resp_nir;
      TWST10_radA =(TWST10.rate_A)./taszers_xcal.twst10_resp.A; TWST10_radB =(TWST10.rate_B)./taszers_xcal.twst10_resp.B;
      TWST11_radA =(TWST11.rate_A)./taszers_xcal.twst11_resp.A; TWST11_radB =(TWST11.rate_B)./taszers_xcal.twst11_resp.B;

      pos1 = Ze1_vis.Shutter_open_TF==1; pos2 = Ze2_vis.Shutter_open_TF==1;
      pos1n = Ze1_nir.Shutter_open_TF==1; pos2n = Ze2_nir.Shutter_open_TF==1;
      pos1_i = find(pos1); pos1n_i = find(pos1n);
      pos2_i = find(pos2); pos2n_i = find(pos2n);

      %sync
      % first sync Ze1 vis to Ze1 nir, Ze2vis to Ze2nir, then Ze1 to Ze2
      [ainb, bina] = nearest(Ze1_vis.time(pos1_i), Ze1_nir.time(pos1n_i),2/(24*60*60));
      Ze1.time = Ze1_vis.time(pos1_i(ainb));Ze1.rad_vis = Ze1_vis_rad(pos1_i(ainb),:); Ze1.rad_nir = Ze1_nir_rad(pos1n_i(bina),:);
      [ainb, bina] = nearest(Ze2_vis.time(pos2_i), Ze2_nir.time(pos2n_i),2/(24*60*60));
      Ze2.time = Ze2_vis.time(pos2_i(ainb));Ze2.rad_vis = Ze2_vis_rad(pos2_i(ainb),:); Ze2.rad_nir = Ze2_nir_rad(pos2n_i(bina),:);

      [ainb, bina] = nearest(Ze1.time, Ze2.time,2/(24*60*60) );
      Ze.time = Ze1.time(ainb);
      Ze.rad1_vis = Ze1.rad_vis(ainb,:); Ze.rad1_nir = Ze1.rad_nir(ainb,:);
      Ze.rad2_vis = Ze2.rad_vis(bina,:); Ze.rad2_nir = Ze2.rad_nir(bina,:);

      [ainb, bina] = nearest(TWST10.time, TWST11.time,2/(24*60*60));
      TWST.time = TWST10.time(ainb);
      TWST.radA_10 = TWST10_radA(:,ainb);TWST.radB_10 = TWST10_radB(:,ainb);
      TWST.radA_11 = TWST11_radA(:,bina);TWST.radB_11 = TWST11_radB(:,bina);
      TWST.cod_10 = TWST10.cod(ainb); TWST.cod_11 = TWST11.cod(bina);
      TWST.sza = TWST10.sza(ainb);
      [ainb, bina] = nearest(Ze.time, TWST.time, 2/(24*60*60));
      TZR.time = Ze.time(ainb);
      TZR.Lat = unique(Ze1_nir.Lat_N_deg);
      TZR.Lon = unique(Ze1_nir.Lon_E_deg);
      TZR.wl.vis1 = Ze1_vis.wl; TZR.wl.nir1 = Ze1_nir.wl;
      TZR.wl.vis2 = Ze2_vis.wl; TZR.wl.nir2 = Ze2_nir.wl;
      TZR.wl.A10 = TWST10.wl_A';TZR.wl.B10 = TWST10.wl_B';
      TZR.wl.A11 = TWST11.wl_A';TZR.wl.B11 = TWST11.wl_B';

      TZR.rad1_vis = Ze.rad1_vis(ainb,:);TZR.rad2_vis = Ze.rad2_vis(ainb,:);
      TZR.rad1_nir = Ze.rad1_nir(ainb,:);TZR.rad2_nir = Ze.rad2_nir(ainb,:);
      TZR.rad10_A = TWST.radA_10(:,bina)';TZR.rad10_B = TWST.radB_10(:,bina)';
      TZR.rad11_A = TWST.radA_11(:,bina)';TZR.rad11_B = TWST.radB_11(:,bina)';
      TZR.cod10 = TWST.cod_10(bina)'; TZR.cod11 = TWST.cod_11(bina)';
      TZR.sza = TWST.sza(bina)';

      figure_(7); plot(TWST10.time, TWST10.cod,'.',TWST11.time, TWST11.cod,'.'); dynamicDateTicks;
      [ainb, bina] = nearest(TWST10.time, TWST11.time);
      figure_(4); plot( TWST10.cod(ainb),TWST11.cod(bina),'.'); axis('square'); 
      xx = xlim; yy = ylim; xy = min([xx(2),yy(2)]); xlim([0,xy]); ylim(xlim)
      % figure; plot( TZR.cod10,TZR.cod11,'.'); axis('square'); 
      save([getnamedpath('TASZERS'),filesep,'TZR.',dstr,'.mat'],'-struct','TZR');
      TZR_cld.time = TZR.time;TZR_cld.sza = TZR.sza; TZR_cld.cod10 = TZR.cod10; TZR_cld.cod11 = TZR.cod11;
      save([getnamedpath('TASZERS'),filesep,'TZR_cld.',dstr,'.mat'],'-struct','TZR_cld');
      % if ~isavar('TZR_cod')
      %    TZR_cod = TZR_cld;
      % else
      %    tmp = [TZR_cod.time; TZR_cld.time];
      %    [TZR_cod.time,ij] = unique(tmp);
      %    tmp = [TZR_cod.cod10; TZR_cld.cod10];
      %    TZR_cod.cod10 = tmp(ij);
      %    tmp =  [TZR_cod.cod11; TZR_cld.cod11];
      %    TZR_cod.cod11 = tmp(ij);         
      % end
   end
   clear TASZERS
end

nm1_500 = interp1(Ze1_vis.wl, [1:length(Ze1_vis.wl)],500,'nearest');
nm2_500 = interp1(Ze2_vis.wl, [1:length(Ze2_vis.wl)],500,'nearest');
nm10_500 = interp1(TWST10.wl_A , [1:length(TWST10.wl_A)],500,'nearest');
nm11_500 = interp1(TWST11.wl_A , [1:length(TWST11.wl_A)],500,'nearest');

figure; plot(TZR.time, [TZR.rad1_vis(:,nm1_500), TZR.rad2_vis(:,nm2_500), TZR.rad10_A(:,nm10_500),TZR.rad11_A(:,nm11_500)],'.'); dynamicDateTicks
legend('Ze1','Ze2','TWST10','TWST11');
figure; plot(TZR.time, [TZR.rad1_nir(:,50), TZR.rad2_nir(:,50), TZR.rad10_B(:,50),TZR.rad11_B(:,50)],'.'); dynamicDateTicks
legend('Ze1','Ze2','TWST10','TWST11');
% figure; plot(Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'.',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'.',...
%    TWST10.time, TWST10_radA(nm10_500,:),'.',TWST11.time, TWST11_radA(nm11_500,:),'.');dynamicDateTicks;
% ylabel('radiance'); 
% legend('SASZe1','SASZe2','TWST-10','TWST-11')

% figure; plot(Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'.',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'.',...
%    TWST10.time, TWST10_radA(nm10_500,:),'.',TWST11.time, TWST11_radA(nm11_500,:),'.', ...
%    anet_zrad.time, anet_zrad.zenrad_500_nm,'k+', cim_cld.time, cim_cld.K500nm,'ko','markersize',6);dynamicDateTicks;
% ylabel('Radiance [W/m^2/nm/sr]'); 
% legend('SASZe1','SASZe2','TWST-10','TWST-11', 'Cimel PPL','Cimel K Rad')
% title({'Zenith Radiances at 500 nm during TASZERS';datestr(floor(mean(Ze1_vis.time)),'yyyy-mm-dd')});

figure; plot(anet_zrad.time, anet_zrad.zenrad_500_nm,'k+', cim_cld.time, cim_cld.K500nm,'ko',...
   Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'.',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'.',...
   TWST10.time, TWST10_radA(nm10_500,:),'.',TWST11.time, TWST11_radA(nm11_500,:),'.', ...
   'markersize',6);dynamicDateTicks;
ylabel('Radiance [W/m^2/nm/sr]'); 
legend('Cimel PPL','Cimel K Rad','SASZe1','SASZe2','TWST-10','TWST-11')
title({'Zenith Radiances at 500 nm during TASZERS';datestr(floor(mean(Ze1_vis.time)),'yyyy-mm-dd')});


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