function TASZERSxcal

% have already generated resp files in radcal_Ze2_TASZERS_Oriel_20240326.m
oriel_cal_vis = rd_sasze_resp_file; 
oriel_cal_nir = rd_sasze_resp_file;
oriel_cal_vis.resp(oriel_cal_vis.lambda_nm>1020) = NaN;

% Now load sasze integrating sphere measurements to establish transfer calibration

visfile = getfullname('*_vis_*.csv','sasze');
[pname, vis_stem,ext] = fileparts(visfile);
pname = strrep([pname, filesep], [filesep filesep], filesep);
vis_stem = 'sgpsaszevisE13';nir_stem = 'sgpsaszenirE13';
vis = rd_SAS_raw(visfile); nir = rd_SAS_raw([vis.pname{:},strrep(vis.fname{:},'vis','nir')]);
if iscell(vis.pname)&&isadir(vis.pname)&&iscell(nir.pname)&&isadir(nir.pname)
    vis.pname = vis.pname{:}; nir.pname = nir.pname{:};
end
pat = 'System SN = '; i = 1;p = [];

while (i < length(vis.header))&&isempty(p); i = i +1; p = strfind(vis.header{i},pat) + length(pat); end

SAS_unit = vis.header{i}(p:end);
vrec = cumsum(uint16(vis.time>0));
nrec = cumsum(uint16(nir.time>0));
figure; plot(double(vrec), vis.rate(:,500),'o'); zoom('on'); xlabel('record #'); ylabel('spec') % Use to identify desired ranges
xl = xlim;
xl_ = vrec>xl(1)&vrec<xl(2);

vis_rate = mean(vis.rate(xl_,:)); nir_rate = mean(nir.rate(xl_,:));


vis_rad = vis_rate./oriel_cal_vis.resp'; %sphere radiance
nir_rad = nir_rate./oriel_cal_nir.resp'; %sphere radiance

figure; plot(vis.wl, vis_rate./oriel_cal_vis.resp', '-',nir.wl, nir_rate./oriel_cal_nir.resp','-',...
   oriel_cal_vis.lambda_nm, oriel_cal_vis.src_radiance,'r-',oriel_cal_nir.lambda_nm, oriel_cal_nir.src_radiance,'r-' );  logy
legend('Sphere VIS','Sphere NIR','Oriel Lamp')
ylabel('mW/m2/nm/sr')

%Define the overlap region

last_v = oriel_cal_vis.lambda_nm(find(~isnan(vis_rad),1,'last'))
first_n = oriel_cal_nir.lambda_nm(find(~isnan(nir_rad),1,'first'))
nwl = nir.wl>first_n & nir.wl<last_v;
vwl = vis.wl>first_n & vis.wl<last_v;
nmean = mean(nir_rad(nwl));
vmean =  mean(vis_rad(vwl));
mmean = (nmean + vmean)./2;
npin = mean(vis_rad(vwl))./mean(nir_rad(nwl)); %currently unused, pin to mmean
vpin = mean(nir_rad(nwl))./mean(vis_rad(vwl)); %currently unused, pin to mmean
figure; plot(vis.wl, (mmean./vmean).*vis_rad, '-', nir.wl, (mmean./nmean).* nir_rad,'-')
figure; plot(vis.wl, vpin.*vis_rad, '-', nir.wl, nir_rad,'-')
% figure; plot(vis.wl, oriel_cal_vis.resp', 'r-',nir.wl, oriel_cal_nir.resp','r-');  logy

% Now, take a sliding linear weighted average of vis and nir rad for overlap region.
ol_nm = unique([vis.wl(vwl), nir.wl(nwl)]);
dwl = last_v - first_n;
ol_vis = interp1(vis.wl, (mmean./vmean).*vis_rad, ol_nm,'linear');
vis_w = (last_v-ol_nm)./dwl;
ol_nir = interp1(nir.wl, (mmean./nmean).*nir_rad, ol_nm,'linear');
nir_w = (ol_nm-first_n)./dwl;
ol_rad = ol_vis.*vis_w + ol_nir.*nir_w;
figure; plot(vis.wl, (mmean./vmean).*vis_rad, '-', nir.wl, (mmean./nmean).* nir_rad,'-',ol_nm, ol_rad,'k-' )
sphere_xcal.date = datestr(min(vis.time));
sphere_xcal.units = ['mW/m2/nm/sr'];
sphere_xcal.nm = [vis.wl(vis.wl<first_n), ol_nm, nir.wl(nir.wl>last_v)];
sphere_xcal.rad = [(mmean./vmean).*vis_rad(vis.wl<first_n),ol_rad, (mmean./nmean).*nir_rad(nir.wl>last_v)];
% Now patch the peak with the Oriel nir radiance
% Zoom in so that y-fiber artifact is encompassed in limits.
wv_ = xlim;
bad_wl = sphere_xcal.nm>=wv_(1) & sphere_xcal.nm<=wv_(2);
bad_rad = sphere_xcal.rad; bad_rad(bad_wl) = NaN;
b_wl =  oriel_cal_nir.lambda_nm>=wv_(1) &  oriel_cal_nir.lambda_nm<=wv_(2);
sphere_xcal.rad_patched = patch_ab(sphere_xcal.nm, bad_rad, oriel_cal_nir.lambda_nm, oriel_cal_nir.src_radiance);
save([vis.pname,'sphere_xcal_20240405.mat'],'-struct','sphere_xcal');


twst_long1 =twst4_to_struct; twst_long2 = rd_twst_nc4; twst_long3 = rd_twst_nc4;
twst_med1 =twst4_to_struct; twst_med2 =twst4_to_struct; twst_med3 =twst4_to_struct;
twst_short1 =twst4_to_struct;twst_short2 =twst4_to_struct;twst_short3 =twst4_to_struct;
figure; plot(twst_long1.wl_A, 1e3.*[mean(twst_long1.zenrad_A,2),mean(twst_long2.zenrad_A,2),mean(twst_long3.zenrad_A,2)],'b-', ...
   twst_long1.wl_B, 1e3.*[mean(twst_long1.zenrad_B,2),mean(twst_long2.zenrad_B,2),mean(twst_long3.zenrad_B,2)],'b-', ...
     twst_med1.wl_A, 1e3.*[mean(twst_med1.zenrad_A,2),mean(twst_med2.zenrad_A,2),mean(twst_med3.zenrad_A,2),],'g-',...
     twst_med1.wl_B, 1e3.*[mean(twst_med1.zenrad_B,2),mean(twst_med2.zenrad_B,2),mean(twst_med3.zenrad_B,2),],'g-',...
  twst_short1.wl_A, 1e3.*[mean(twst_short1.zenrad_A,2),mean(twst_short2.zenrad_A,2),mean(twst_short3.zenrad_A,2)],'r-', ...
  twst_short1.wl_B, 1e3.*[mean(twst_short1.zenrad_B,2),mean(twst_short2.zenrad_B,2),mean(twst_short3.zenrad_B,2)],'r-' );
ylabel('rad [mW/nm/m2]');
title('TWST-EN')
legend('long','','','','','','med','','','','','','short','','','','','')

twst_10 = twst4_to_struct;

twst_10.xrad_A = interp1(sphere_xcal.nm, 1e-3.*sphere_xcal.rad_patched, twst_10.wl_A,'linear');
twst_10.resp_A  = nanmean(twst_10.rate_A,2)./twst_10.xrad_A;
twst_10.resp_A = interp1(twst_10.wl_A(~isnan(twst_10.resp_A)),twst_10.resp_A(~isnan(twst_10.resp_A)), twst_10.wl_A,'linear');
twst_10.resp_A = interp1(twst_10.wl_A(~isnan(twst_10.resp_A)),twst_10.resp_A(~isnan(twst_10.resp_A)), twst_10.wl_A,'nearest','extrap');
twst_10.xrad_B = interp1(sphere_xcal.nm, 1e-3.*sphere_xcal.rad_patched, twst_10.wl_B,'linear');
twst_10.resp_B = nanmean(twst_10.rate_B,2)./twst_10.xrad_B;
twst_10.resp_B = interp1(twst_10.wl_B(~isnan(twst_10.resp_B)),twst_10.resp_B(~isnan(twst_10.resp_B)), twst_10.wl_B,'linear');
twst_10.resp_B = interp1(twst_10.wl_B(~isnan(twst_10.resp_B)),twst_10.resp_B(~isnan(twst_10.resp_B)), twst_10.wl_B,'nearest','extrap');

xcal_10.date = datestr(floor(min(twst_10.time)));
xcal_10.twst = 'TWST10';
xcal_10.wl_A = twst_10.wl_A;
xcal_10.resp_A = twst_10.resp_A;
xcal_10.wl_B = twst_10.wl_B;
xcal_10.resp_B = twst_10.resp_B;
save([twst_10.pname,'TWST10_xcal_20240328.mat'],'-struct','xcal_10');

twst_11 = twst4_to_struct;
twst_11.xrad_A = interp1(sphere_xcal.nm, 1e-3.*sphere_xcal.rad_patched, twst_10.wl_A,'linear');
twst_11.resp_A  = nanmean(twst_11.rate_A,2)./twst_11.xrad_A;
twst_11.resp_A = interp1(twst_11.wl_A(~isnan(twst_11.resp_A)),twst_11.resp_A(~isnan(twst_11.resp_A)), twst_11.wl_A,'linear');
twst_11.resp_A = interp1(twst_11.wl_A(~isnan(twst_11.resp_A)),twst_11.resp_A(~isnan(twst_11.resp_A)), twst_11.wl_A,'nearest','extrap');
twst_11.xrad_B = interp1(sphere_xcal.nm, 1e-3.*sphere_xcal.rad_patched, twst_10.wl_B,'linear');
twst_11.resp_B = nanmean(twst_10.rate_B,2)./twst_10.xrad_B;
twst_11.resp_B = interp1(twst_11.wl_B(~isnan(twst_11.resp_B)),twst_11.resp_B(~isnan(twst_11.resp_B)), twst_11.wl_B,'linear');
twst_11.resp_B = interp1(twst_11.wl_B(~isnan(twst_11.resp_B)),twst_11.resp_B(~isnan(twst_11.resp_B)), twst_11.wl_B,'nearest','extrap');

xcal_11.date = datestr(floor(min(twst_11.time)),'yyyy-mm-dd');
xcal_11.twst = 'TWST11';
xcal_11.wl_A = twst_11.wl_A;
xcal_11.resp_A = twst_11.resp_A;
xcal_11.wl_B = twst_11.wl_B;
xcal_11.resp_B = twst_11.resp_B;
save([twst_11.pname,'TWST10_xcal_20240406.mat'],'-struct','xcal_11');

% Now xcal for Ze1
vis = rd_SAS_raw;
v_tint = unique(vis.t_int_ms);
dark.time = vis.time(vis.t_int_ms==v_tint(end)&vis.Shutter_open_TF==0);
dark.rate = mean(vis.spec(vis.t_int_ms==v_tint(end)&vis.Shutter_open_TF==0,:)./v_tint(end));
lite.time = vis.time(vis.t_int_ms==v_tint(end)&vis.Shutter_open_TF==1);
lite.rate = mean(vis.spec(vis.t_int_ms==v_tint(end)&vis.Shutter_open_TF==1,:)./v_tint(end) - ones(size(lite.time))*dark.rate);
Ze1_xcal_vis.date = datestr(floor(min(vis.time)),'yyyy-mm-dd');
Ze1_xcal_vis.Ze = 'Ze1';
Ze1_xcal_vis.wl = vis.wl;
Ze1_xcal_vis.xrad = interp1(sphere_xcal.nm, sphere_xcal.rad_patched, vis.wl,'linear');
Ze1_xcal_vis.rate = lite.rate;
Ze1_xcal_vis.esp = Ze1_xcal_vis.rate ./  Ze1_xcal_vis.xrad;
save([vis.pname{:},'Ze1_vis_xcal_20240419.mat'],'-struct','Ze1_xcal_vis');

nir = rd_SAS_raw;
n_tint = unique(nir.t_int_ms);
dark.time = nir.time(nir.t_int_ms==n_tint(end)&nir.Shutter_open_TF==0);
dark.rate = mean(nir.spec(nir.t_int_ms==n_tint(end)&nir.Shutter_open_TF==0,:)./n_tint(end));
lite.time = nir.time(nir.t_int_ms==n_tint(end)&nir.Shutter_open_TF==1);
lite.rate = mean(nir.spec(nir.t_int_ms==n_tint(end)&nir.Shutter_open_TF==1,:)./n_tint(end) - ones(size(lite.time))*dark.rate);
Ze1_xcal_nir.date = datestr(floor(min(nir.time)),'yyyy-mm-dd');
Ze1_xcal_nir.Ze = 'Ze1';
Ze1_xcal_nir.wl = nir.wl;
Ze1_xcal_nir.xrad = interp1(sphere_xcal.nm, sphere_xcal.rad_patched, nir.wl,'linear');
Ze1_xcal_nir.rate = lite.rate;
Ze1_xcal_nir.esp = Ze1_xcal_nir.rate ./  Ze1_xcal_nir.xrad;
save([nir.pname{:},'Ze1_nir_xcal_20240419.mat'],'-struct','Ze1_xcal_nir');


% Test the generated responsivities by loading the SphereCal data for each system,
% apply existing resp, and overlay radiances
Ze2_vis_resp =  rd_sasze_resp_file; Ze2_nir_resp =  rd_sasze_resp_file;
Ze1_vis_resp = load(getfullname('*.mat')); Ze1_nir_resp = load(getfullname('*.mat'));
TWST10_resp = load(getfullname('*.mat'));
TWST11_resp  = load(getfullname('*.mat'));
Ze2_vis = rd_SAS_raw; Ze2_nir = rd_SAS_raw;
Ze1_vis = rd_SAS_raw; Ze1_nir = rd_SAS_raw;
TWST10 = twst4_to_struct;
TWST11 = twst4_to_struct;

Ze2_vis_rad = mean(Ze2_vis.rate)./Ze2_vis_resp.resp'; 
Ze2_nir_rad = mean(Ze2_nir.rate)./Ze2_nir_resp.resp';

tint = unique(Ze1_vis.t_int_ms); tint_ = Ze1_vis.t_int_ms==tint(end); shut = Ze1_vis.Shutter_open_TF==0;
dark = mean(Ze1_vis.spec(tint_&shut,:)); lite = mean(Ze1_vis.spec(tint_&~shut,:));
sig = lite - dark; rate = sig./tint(end); 
Ze1_vis.rad = rate./Ze1_vis_resp.esp;
tint = unique(Ze1_nir.t_int_ms); tint_ = Ze1_nir.t_int_ms==tint(end); shut = Ze1_nir.Shutter_open_TF==0;
dark = mean(Ze1_nir.spec(tint_&shut,:)); lite = mean(Ze1_nir.spec(tint_&~shut,:));
sig = lite - dark; rate = sig./tint(end); 
Ze1_nir.rad = rate./Ze1_nir_resp.esp;

TWST10_radA = nanmean(TWST10.rate_A,2)./TWST10_resp.resp_A;
TWST10_radB = nanmean(TWST10.rate_B,2)./TWST10_resp.resp_B;
TWST11_radA = nanmean(TWST11.rate_A,2)./TWST11_resp.resp_A;
TWST11_radB = nanmean(TWST11.rate_B,2)./TWST11_resp.resp_B;

figure; plot(Ze2_vis.wl, Ze2_vis_rad,'-',Ze2_nir.wl, Ze2_nir_rad,'-', Ze1_vis.wl, Ze1_vis.rad,'-',Ze1_nir.wl, Ze1_nir.rad,'-',...
   TWST10.wl_A, 1e3.*TWST10_radA, 'k-',TWST10.wl_B, 1e3.*TWST10_radB, 'k-',...
   TWST10.wl_A, 1e3.*TWST10_radA, 'm-',TWST10.wl_B, 1e3.*TWST10_radB, 'm-')

% All good.  Next, we read in sky data and do the same.
% We'll try 2024-04-23 for mix of clear and cloudy
Ze2_vis = rd_SAS_dualtint_raw; Ze2_nir = rd_SAS_dualtint_raw;
Ze1_vis = rd_SAS_dualtint_raw; Ze1_nir = rd_SAS_dualtint_raw;
TWST10 = twst4_to_struct;
TWST11 = twst4_to_struct;

Ze2_vis_rad = (Ze2_vis.rate)./Ze2_vis_resp.resp'; Ze2_nir_rad = (Ze2_nir.rate)./Ze2_nir_resp.resp';
Ze1_vis_rad = (Ze1_vis.rate)./Ze1_vis_resp.esp; Ze1_nir_rad = (Ze1_nir.rate)./Ze1_nir_resp.esp;
TWST10_radA =(TWST10.rate_A)./TWST10_resp.resp_A;
TWST10_radB =(TWST10.rate_B)./TWST10_resp.resp_B;
TWST11_radA = (TWST11.rate_A)./TWST11_resp.resp_A;
TWST11_radB = (TWST11.rate_B)./TWST11_resp.resp_B;

nm1_500 = interp1(Ze1_vis.wl, [1:length(Ze1_vis.wl)],500,'nearest');
nm2_500 = interp1(Ze2_vis.wl, [1:length(Ze2_vis.wl)],500,'nearest');
nm10_500 = interp1(TWST10.wl_A , [1:length(TWST10.wl_A)],500,'nearest');
nm11_500 = interp1(TWST11.wl_A , [1:length(TWST11.wl_A)],500,'nearest');

anet_zrad = aeronet_zenith_radiance(getfullname('*ppl','anet_ppl','Select Aeronet PPL file'));

% Read anet cloudmode file
cim_cld = read_cimel_cloudrad_v3;

figure; plot(Ze1_vis.time(Ze1_vis.Shutter_open_TF==1), Ze1_vis_rad(Ze1_vis.Shutter_open_TF==1,nm1_500),'.',...
   Ze2_vis.time(Ze2_vis.Shutter_open_TF==1), Ze2_vis_rad(Ze2_vis.Shutter_open_TF==1,nm2_500),'.',...
   TWST10.time, 1e3.*TWST10_radA(nm10_500,:),'.',...
   TWST11.time, 1e3.*TWST11_radA(nm11_500,:),'.', ...
   anet_zrad.time, anet_zrad.zenrad_500_nm,'o',cim_cld.time, cim_cld.A500nm,'+',cim_cld.time, cim_cld.K500nm,'x'); dynamicDateTicks;
legend('Ze1','Ze2','TWST-10','TWST-11', 'PPL 500nm', 'Cld A500nm', 'Cld K500nm')
ylabel(cim_cld.zenrad_units)


return