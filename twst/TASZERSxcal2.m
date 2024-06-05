function TASZERSxcal2
twst11 = twst4_to_struct; 
twst11a = twst4_to_struct;twst11b = twst4_to_struct;twst11c = twst4_to_struct;twst11d = twst4_to_struct;
twst10 = twst4_to_struct;

Ze1_vis = rd_SAS_raw(getfullname('*vis_1s*','Ze1')); Ze1_nir = rd_SAS_raw(getfullname('*nir_1s*','Ze1'));
Ze2_vis = rd_SAS_raw(getfullname('*vis_1s*','Ze2')); Ze2_nir = rd_SAS_raw(getfullname('*nir_1s*','Ze2'));
lite1 = Ze1_vis.Shutter_open_TF==1;
lite2 = Ze2_vis.Shutter_open_TF==1;

nm1_500 = interp1(Ze1_vis.wl, [1:length(Ze1_vis.wl)],500,'nearest');
nm2_500 = interp1(Ze2_vis.wl, [1:length(Ze2_vis.wl)],500,'nearest');
nm10_500 = interp1(twst10.wl_A , [1:length(twst10.wl_A)],500,'nearest');
nm11_500 = interp1(twst11.wl_A , [1:length(twst11.wl_A)],500,'nearest');

figure; subplot(2,1,1); 
plot(twst11d.wl_A, mean(twst11d.rate_A,2),'.',...
   twst10.wl_A, mean(twst10.rate_A,2),'.', ...
  Ze1_vis.wl, 1e3.*mean(Ze1_vis.rate(lite1,:),1),'.',...
  Ze2_vis.wl, 1e3.*mean(Ze2_vis.rate(lite2,:),1),'.'); 
legend('TWST-11','TWST-10', 'Ze-1','Ze-2'); 
title('TWST and ZE count rates for Sphere');
ylabel('cps');
xlabel('wavelength [nm]');
subplot(2,1,2); 
plot(twst11d.wl_B, mean(twst11d.rate_B,2),'.',...
   twst10.wl_B, mean(twst10.rate_B,2),'.', ...
  Ze1_nir.wl, 1e3.*mean(Ze1_nir.rate(lite1,:),1),'.',...
  Ze2_nir.wl, 1e3.*mean(Ze2_nir.rate(lite2,:),1),'.'); 
legend('TWST-11','TWST-10', 'Ze-1','Ze-2'); 
ylabel('cps');
xlabel('wavelength [nm]');

% These are the counts as reported by the spectrometer but also incorporate gain
% Need to examine Kiedron plots to determine gain?  That would allow us to confirm
% whether noise is following photon-counting statistics.
% Alternatively, what if I just divide each of these curves by the relevant std as
% relating to signal to noise?

figure; subplot(2,1,1); 
plot(twst11.wl_A, mean(twst11d.rate_A,2)./std(twst11d.rate_A,0,2),'.',...
   twst10.wl_A, mean(twst10.rate_A,2)./std(twst10.rate_A,0,2),'.', ...
  Ze1_vis.wl, mean(Ze1_vis.rate(lite1,:),1)./std(Ze1_vis.rate(lite1,:),0,1),'.',...
  Ze2_vis.wl, mean(Ze2_vis.rate(lite2,:),1)./std(Ze2_vis.rate(lite2,:),0,1),'.'); 
legend('TWST-11','TWST-10', 'Ze-1','Ze-2'); 
title('TWST and ZE count rates for Sphere');
ylabel('snr');
xlabel('wavelength [nm]');
subplot(2,1,2); 
plot(twst11.wl_B, mean(twst11d.rate_B,2)./std(twst11d.rate_B,0,2),'.',...
   twst10.wl_B, mean(twst10.rate_B,2)./std(twst10.rate_B,0,2),'.', ...
  Ze1_nir.wl, mean(Ze1_nir.rate(lite1,:),1)./std(Ze1_nir.rate(lite1,:),0,1),'.',...
  Ze2_nir.wl, mean(Ze2_nir.rate(lite2,:),1)./ std(Ze2_nir.rate(lite2,:),0,1),'.'); 
legend('TWST-11','TWST-10', 'Ze-1','Ze-2'); 
ylabel('snr');
xlabel('wavelength [nm]');

% Counter-intuitive result was due to taking std over twst 11 a,b,c,d traces
%Very counter-intuitive.  Let's see what's up with the std traces.
figure; subplot(2,1,1); 
plot(twst11.wl_A, std(twst11a.rate_A,0,2),'.',...
   twst10.wl_A, std(twst10.rate_A,0,2),'.', ...
  Ze1_vis.wl, 1e3.*std(Ze1_vis.rate(lite1,:),0,1),'.',...
  Ze2_vis.wl, 1e3.*std(Ze2_vis.rate(lite2,:),0,1),'.'); 
legend('TWST-11','TWST-10', 'Ze-1','Ze-2'); 
title('TWST and ZE count rates for Sphere');
ylabel('snr');
xlabel('wavelength [nm]');
subplot(2,1,2); 
plot(twst11.wl_B, mean(twst11.rate_B,2)./std(twst11.rate_B,0,2),'.',...
   twst10.wl_B, mean(twst10.rate_B,2)./std(twst10.rate_B,0,2),'.', ...
  Ze1_nir.wl, mean(Ze1_nir.rate(lite1,:),1)./std(Ze1_nir.rate(lite1,:),0,1),'.',...
  Ze2_nir.wl, mean(Ze2_nir.rate(lite2,:),1)./ std(Ze2_nir.rate(lite2,:),0,1),'.'); 
legend('TWST-11','TWST-10', 'Ze-1','Ze-2'); 
ylabel('snr');
xlabel('wavelength [nm]');

[fullname_sphere] = getfullname('sphere_xcal_*.mat','sphere_xcal');
[pname_sphere, fname_sphere] = fileparts(fullname_sphere);
sphere_xcal = load(fullname_sphere);

figure; plot(twst11.wl_A, mean(twst11.zenrad_A,2),'b.', twst11.wl_B, mean(twst11.zenrad_B,2),'b.',...
 twst10.wl_A, mean(twst10.zenrad_A,2),'r.', twst10.wl_B, mean(twst10.zenrad_B,2),'r.',...
 sphere_xcal.nm, 1e-3*sphere_xcal.rad_patched,'k-');
xlabel('wl'); ylabel('radiance'); title('sphere xref 2024-04-26')
legend('twst11', '', 'twst10', '','sphere patched')
sphere_factor = ((0.7693+0.7652)./2)./.5223;

% Here's what I _think_ we want to do.
% Scale sphere radiance to match the mean of TWST 10&11 in the NIR where they are very similar; 
% Then compute new responsivities from rate for all 4 systems both VIS and NIR.  
% By definition, these should all yield pretty good agreement.
% Interesting to look at shape or responsivities.
% [fullname_sphere] = getfullname('sphere_xcal_*.mat','sphere_xcal');
% [pname_sphere, fname_sphere] = fileparts(fullname_sphere);
% sphere_xcal = load(fullname_sphere);
% sphere_xcal.sphere_factor = sphere_factor;
% sphere_xcal.units = 'W/m2/nm/sr';
% sphere_xcal.factor = '2024-04-26';
% save([pname_sphere,filesep,'sphere_xcal_20240426.mat'],'-struct','sphere_xcal')
% forgot to scale
twst11_resp.A = mean(twst11.rate_A,2)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, twst11.wl_A,'linear');
twst11_resp.B = mean(twst11.rate_B,2)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, twst11.wl_B,'linear');
twst10_resp.A = mean(twst10.rate_A,2)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, twst10.wl_A,'linear');
twst10_resp.B = mean(twst10.rate_B,2)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, twst10.wl_B,'linear');
Ze1_resp_vis = mean(Ze1_vis.rate(lite1,:),1)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, Ze1_vis.wl,'linear');
Ze1_resp_nir = mean(Ze1_nir.rate(lite1,:),1)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, Ze1_nir.wl,'linear');
Ze2_resp_vis = mean(Ze2_vis.rate(lite1,:),1)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, Ze2_vis.wl,'linear');
Ze2_resp_nir = mean(Ze2_nir.rate(lite1,:),1)./interp1(sphere_xcal.nm, sphere_factor.*sphere_xcal.rad_patched, Ze2_nir.wl,'linear');
twst10_resp.wl_A = twst10.wl_A; twst10_resp.wl_B = twst10.wl_B;
twst11_resp.wl_A = twst11.wl_A; twst11_resp.wl_B = twst11.wl_B;

taszers_xcal.Ze1_vis_wl = Ze1_vis.wl; taszers_xcal.Ze1_nir_wl = Ze1_nir.wl;
taszers_xcal.Ze2_vis_wl = Ze2_vis.wl; taszers_xcal.Ze2_nir_wl = Ze2_nir.wl;


taszers_xcal.Ze1_resp_vis = Ze1_resp_vis;  
   taszers_xcal.Ze1_resp_vis(taszers_xcal.Ze1_vis_wl<350) = NaN; 
   taszers_xcal.Ze1_resp_vis(taszers_xcal.Ze1_vis_wl>1020) = NaN;
taszers_xcal.Ze1_resp_nir = Ze1_resp_nir; 
   taszers_xcal.Ze1_resp_nir(taszers_xcal.Ze1_nir_wl>1670)=NaN;
taszers_xcal.Ze2_resp_vis = Ze2_resp_vis;
   taszers_xcal.Ze2_resp_vis(taszers_xcal.Ze2_vis_wl<350) = NaN;
   taszers_xcal.Ze2_resp_vis(taszers_xcal.Ze2_vis_wl>1020) = NaN;
taszers_xcal.Ze2_resp_nir = Ze2_resp_nir; 
   taszers_xcal.Ze2_resp_nir(taszers_xcal.Ze2_nir_wl>1670)=NaN;


taszers_xcal.twst10_resp.A =twst10_resp.A; 
   taszers_xcal.twst10_resp.A(twst10.wl_A<350)=NaN; 
   taszers_xcal.twst10_resp.A(twst10.wl_A>920)=NaN;
taszers_xcal.twst10_resp.B =twst10_resp.B;
   taszers_xcal.twst10_resp.B(twst10.wl_B>1670) = NaN;
taszers_xcal.twst11_resp.A =twst11_resp.A; 
   taszers_xcal.twst11_resp.A(twst11.wl_A<350)=NaN; 
   taszers_xcal.twst11_resp.A(twst11.wl_A>920)=NaN;
taszers_xcal.twst11_resp.B =twst11_resp.B;
   taszers_xcal.twst11_resp.B(twst11.wl_B>1670) = NaN;
taszers_xcal.twst10_wl.A =twst10.wl_A; taszers_xcal.twst10_wl.B =twst10.wl_B;
taszers_xcal.twst11_wl.A =twst11.wl_A; taszers_xcal.twst11_wl.B =twst11.wl_B;
save([pname_sphere,filesep,'taszers_xcal_resp_20240426.mat'],'-struct','taszers_xcal')

% Then apply these new responsivities to current data from SGP along with Aeronet

% All good.  Next, we read in sky data and do the same.
% We'll try 2024-04-23 for mix of clear and cloudy
Ze1_vis = rd_SAS_dualtint_raw(getfullname('sgpsaszeC1*vis*','Ze1_vis','Select Ze1 vis files'));
Ze1_nir = rd_SAS_dualtint_raw(getfullname('sgpsaszeC1*nir*','Ze1_nir','Select Ze1 nir files'));
Ze2_vis = rd_SAS_dualtint_raw(getfullname('sgpsaszeE13*vis*','Ze2_vis','Select Ze2 vis files'));
Ze2_nir = rd_SAS_dualtint_raw(getfullname('sgpsaszeE13*nir*','Ze2_nir','Select Ze2 nir files'));
TWST10= twst4_to_struct(getfullname('sgptwstC1*','TWST10','Select TWST-10 files'));
TWST11= twst4_to_struct(getfullname('sgptwstE13*','TWST11','Select TWST-11 files'));


Ze1_vis_rad = (Ze1_vis.rate)./taszers_xcal.Ze1_resp_vis; Ze1_nir_rad = (Ze1_nir.rate)./taszers_xcal.Ze1_resp_nir;
Ze2_vis_rad = (Ze2_vis.rate)./taszers_xcal.Ze2_resp_vis; Ze2_nir_rad = (Ze2_nir.rate)./taszers_xcal.Ze2_resp_nir;

TWST10_radA =(TWST10.rate_A)./taszers_xcal.twst10_resp.A; TWST10_radB =(TWST10.rate_B)./taszers_xcal.twst10_resp.B;
TWST11_radA =(TWST11.rate_A)./taszers_xcal.twst11_resp.A; TWST11_radB =(TWST11.rate_B)./taszers_xcal.twst11_resp.B;

pos1 = Ze1_vis.Shutter_open_TF==1; pos2 = Ze2_vis.Shutter_open_TF==1;
figure; plot(Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'.',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'.',...
   TWST10.time, TWST10_radA(nm10_500,:),'.',TWST11.time, TWST11_radA(nm11_500,:),'.');dynamicDateTicks;
ylabel('radiance'); 
legend('SASZe1','SASZe2','TWST-10','TWST-11')

anet_zrad = aeronet_zenith_radiance(getfullname('*ppl','anet_ppl','Select Aeronet PPL file'));

% Read anet cloudmode file
% anet_zrad = aeronet_zenith_radiance(getfullname('*ppl','anet_ppl','Select Aeronet PPL file'));
cim_cld = read_cimel_cloudrad_v3;




figure; plot(Ze1_vis.time(pos1), Ze1_vis_rad(pos1,nm1_500),'.',Ze2_vis.time(pos2), Ze2_vis_rad(pos2,nm2_500),'.',...
   TWST10.time, TWST10_radA(nm10_500,:),'.',TWST11.time, TWST11_radA(nm11_500,:),'.', ...
   cim_cld.time, cim_cld.K500nm,'ko','markersize',6);dynamicDateTicks;
ylabel('Radiance [W/m^2/nm/sr]'); 
legend('SASZe1','SASZe2','TWST-10','TWST-11', 'Cimel K Rad')
title({'Zenith Radiances at 500 nm during TASZERS';datestr(floor(mean(Ze1_vis.time(xl_1_v))),'yyyy-mm-dd')});

figure; plot(cim_cld.time, cim_cld.A500nm,'k+',cim_cld.time, cim_cld.K500nm,'kx'); dynamicDateTicks;
legend('Cld A500nm', 'Cld K500nm')
ylabel(cim_cld.zenrad_units)

xl = xlim;
xl_1_v = Ze1_vis.time>xl(1)&Ze1_vis.time<xl(2);xl_1_n = Ze1_nir.time>xl(1)&Ze1_nir.time<xl(2);
xl_2_v = Ze2_vis.time>xl(1)&Ze2_vis.time<xl(2);xl_2_n = Ze2_nir.time>xl(1)&Ze2_nir.time<xl(2);
xl_10 = TWST10.time>xl(1)&TWST10.time<xl(2);
xl_11 = TWST11.time>xl(1)&TWST11.time<xl(2);
cim_cl = cim_cld.time>xl(1) & cim_cld.time<xl(2);
wl_K = [380, 440, 500, 675, 870, 1020, 1640]; 
rad_A = [cim_cld.A380nm(cim_cl),cim_cld.A440nm(cim_cl),cim_cld.A500nm(cim_cl),cim_cld.A675nm(cim_cl),...
   cim_cld.A870nm(cim_cl),cim_cld.A1020nm(cim_cl),cim_cld.A1640nm(cim_cl)]; 
rad_A = mean(rad_A,1);
rad_K = [cim_cld.K380nm(cim_cl),cim_cld.K440nm(cim_cl),cim_cld.K500nm(cim_cl),cim_cld.K675nm(cim_cl),...
   cim_cld.K870nm(cim_cl),cim_cld.K1020nm(cim_cl),cim_cld.K1640nm(cim_cl)]; 
rad_K = mean(rad_K,1);

figure; plot( [Ze1_vis.wl,Ze1_nir.wl], [mean(Ze1_vis_rad(pos1&xl_1_v,:),1),mean(Ze1_nir_rad(pos1&xl_1_v,:),1)],'-',...
   [Ze2_vis.wl,Ze2_nir.wl], [mean(Ze2_vis_rad(pos2&xl_2_v,:),1),mean(Ze2_nir_rad(pos2&xl_2_v,:),1)],'-',...
   [TWST10.wl_A;TWST10.wl_B], [mean(TWST10_radA(:,xl_10),2);mean(TWST10_radB(:,xl_10),2)], '-',...
   [TWST11.wl_A;TWST11.wl_B], [mean(TWST11_radA(:,xl_11),2);mean(TWST11_radB(:,xl_11),2)],'-',...
   wl_K, mean(rad_K,'ko','markersize',12,'MarkerFaceColor',[.6,.6,.6]);logy
title({'Zenith Radiances measured at SGP during TASZERS';datestr(mean(Ze1_vis.time(xl_1_v)),'yyyy-mm-dd HH:MM')});
ylabel('Radiance [W/m^2/nm/sr]');
xlabel('Wavelength [nm]');
legend('SASZe1','SASZe2','TWST-10','TWST-11', 'Cimel K Rad')

rad_A = [cim_cld.A380nm,cim_cld.A440nm,cim_cld.A500nm,cim_cld.A675nm,...
   cim_cld.A870nm,cim_cld.A1020nm,cim_cld.A1640nm]; 
rad_K = [cim_cld.K380nm,cim_cld.K440nm,cim_cld.K500nm,cim_cld.K675nm,...
   cim_cld.K870nm,cim_cld.K1020nm,cim_cld.K1640nm]; 

[cinz1, z1inc] = nearest(cim_cld.time, Ze1_vis.time);
[cinz2, z2inc] = nearest(cim_cld.time, Ze2_vis.time);
[cint10, t10inc] = nearest(cim_cld.time, TWST10.time);
[cint11, t11inc] = nearest(cim_cld.time, TWST11.time);
wl_K = [380, 440, 500, 675, 870, 1020, 1640]; 
z1_vij = [interp1(Ze1_vis.wl, [1:length(Ze1_vis.wl)],wl_K,'nearest')];
z2_vij = [interp1(Ze2_vis.wl, [1:length(Ze2_vis.wl)],wl_K,'nearest')];
z1_nij = [interp1(Ze1_nir.wl, [1:length(Ze1_nir.wl)],wl_K,'nearest')];
z2_nij = [interp1(Ze2_nir.wl, [1:length(Ze2_nir.wl)],wl_K,'nearest')];
t10_Aij = [interp1(TWST10.wl_A, [1:length(TWST10.wl_A)],wl_K,'nearest')];
t10_Bij = [interp1(TWST10.wl_B, [1:length(TWST10.wl_B)],wl_K,'nearest')];
t11_Aij = [interp1(TWST11.wl_A, [1:length(TWST11.wl_A)],wl_K,'nearest')];
t11_Bij = [interp1(TWST11.wl_B, [1:length(TWST11.wl_B)],wl_K,'nearest')];

% figure; ax = plot(rad_K(cinz1,3),Ze1_vis_rad 

return