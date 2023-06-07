function sas = chkprocsas_a0tob1_fsb(a0, b1); 

if ~isavar('a0')
   a0= anc_load(getfullname('*sashe*hisun*.nc','sasa0')); % a0.gatts.operation_mode
end

if ~isavar('b1');
   b1 = anc_load(getfullname(['*sashe*',datestr(a0.time(1),'yyyymmdd'),'*.nc'],'sasb1'));
end

% a0 = anc_sift(a0, a0.vdata.integration_time==300);
opmode = a0.gatts.operation_mode; 
tag = [];
while ~isempty(opmode)
   [str, opmode] = getl(opmode);
   if foundstr(str,'Get')
      tag = [tag,sscanf(str,'%*s %f')];
   end
end

     %     7.  Get Darks
     %     8.  Get TH1
     %     9.  Move to SB1
     %     10.  Get SB1
     %     11.  Move to BK
     %     12.  Get BK
     %     13.  Move to SB2
     %     14.  Get SB2

[sza, saz, AU, ha, dec, sel, oam] = sunae(a0.vdata.lat, a0.vdata.lon, a0.time(a0.vdata.tag==tag(4)));

if length(a0.vdata.wavelength<300)
   nm_500 = 100;
else
   nm_500 = 381;
end
sig = a0.vdata.spectra(nm_500,:);
darks = interp1(a0.time(a0.vdata.tag==tag(1)), sig(a0.vdata.tag==tag(1)),a0.time,'linear');
sig  = sig-darks;
SB1 = interp1(a0.time(a0.vdata.tag==tag(3)), sig(a0.vdata.tag==tag(3)),a0.time(a0.vdata.tag==tag(4)),'linear');
SB2 = interp1(a0.time(a0.vdata.tag==tag(4)), sig(a0.vdata.tag==tag(4)),a0.time(a0.vdata.tag==tag(4)),'linear');
SB3 = interp1(a0.time(a0.vdata.tag==tag(5)), sig(a0.vdata.tag==tag(5)),a0.time(a0.vdata.tag==tag(4)),'linear');
[bands, ijk] = sort([SB1;SB2;SB3]); ii = ijk(1,:); jj = ijk(2,:); kk = ijk(3,:);
banding = bands(3,:) > (bands(2,:) - sqrt(bands(2,:)));

sig = a0.vdata.spectra';
darks = interp1(a0.time(a0.vdata.tag==tag(1)), sig(a0.vdata.tag==tag(1),:),a0.time,'linear');
sig  = sig-darks; 
sig = sig./unique(a0.vdata.integration_time)./(ones(size(sig,1),1)*b1.vdata.responsivity_vis');
TH_raw = interp1(a0.time(a0.vdata.tag==tag(2)), sig(a0.vdata.tag==tag(2),:),a0.time(a0.vdata.tag==tag(4)),'linear');
SB1 = interp1(a0.time(a0.vdata.tag==tag(3)), sig(a0.vdata.tag==tag(3),:),a0.time(a0.vdata.tag==tag(4)),'linear');
SB2 = interp1(a0.time(a0.vdata.tag==tag(4)), sig(a0.vdata.tag==tag(4),:),a0.time(a0.vdata.tag==tag(4)),'linear');
SB3 = interp1(a0.time(a0.vdata.tag==tag(5)), sig(a0.vdata.tag==tag(5),:),a0.time(a0.vdata.tag==tag(4)),'linear');

clear sig darks bands BK SB SB_
for ti = length(a0.time(a0.vdata.tag==tag(4))):-1:1
   bands = [SB1(ti,:); SB2(ti,:); SB3(ti,:)];
   BK(ti,:) = bands(ii(ti),:);
   SB(ti,:) = bands(kk(ti),:);
   SB_(ti,:) = bands(jj(ti),:);
end
   
SB(banding,:) = (SB(banding,:) + SB_(banding,:) )./2;

cos_corr_comp = interp1(b1.vdata.test_incident_angle, b1.vdata.cosine_correction_hisun, sza, 'linear');
% figure; plot(b1.time, b1.vdata.cosine_correction_computed,'o',a0.time, cos_corr_comp,'.'); dynamicDateTicks;

dirh_raw = SB-BK;
diff_raw = TH_raw - dirh_raw;
dirh = dirh_raw'.* (ones(size(a0.vdata.wavelength))*cos_corr_comp);
dirn = dirh ./ (ones(size(a0.vdata.wavelength))*cosd(sza));
diff = diff_raw' .* b1.vdata.diffuse_correction;

TH = dirh + diff;

% figure; plot(b1.time, b1.vdata.cosine_correction_computed, '.')
% figure; plot(a0.time(a0.vdata.tag==10), dirh_raw(:,nm_500-1)./difh_raw(:,nm_500-1), '.', a0.time(a0.vdata.tag==10), dirh(nm_500-1,:)./difh(nm_500-1,:),'.'); dynamicDateTicks
tint = unique(b1.vdata.integration_time_vis); tint = 1;

figure_; plot(b1.time, b1.vdata.direct_horizontal_vis(nm_500,:),'r-', a0.time(a0.vdata.tag==tag(4)), dirh(nm_500,:).*tint,'k--')
logy; legend('from b1','from a0'); title('dirh'); dynamicDateTicks

figure_; plot(b1.time, b1.vdata.direct_normal_vis(nm_500,:),'r-', a0.time(a0.vdata.tag==tag(4)), dirn(nm_500,:).*tint,'k--')
logy; legend('from b1','from a0'); title('dirn'); dynamicDateTicks

figure_; plot(b1.time, b1.vdata.diffuse_hemisp_vis(nm_500,:),'r-', a0.time(a0.vdata.tag==tag(4)), diff(nm_500,:).*tint,'k--')
logy;  legend('from b1','from a0'); title('diff'); dynamicDateTicks

figure_; plot(b1.time, b1.vdata.direct_normal_vis(nm_500,:)./b1.vdata.diffuse_hemisp_vis(nm_500,:),'r-', a0.time(a0.vdata.tag==tag(4)), dirn(nm_500,:)./diff(nm_500,:),'k--')
logy;

a0.gatts.process_version
b1.gatts.process_version


sas.time = a0.time(a0.vdata.tag==10);
sas.AU = AU;
sas.oam = oam;
sas.lat = a0.vdata.lat;
sas.lon = a0.vdata.lon;
sas.sza = sza; 
sas.difh = difh;
sas.dirh = dirh;
sas.tag = 'sashea0';
sas.wl = a0.vdata.wavelength;
sas.resp = b1.vdata.responsivity_vis;
bad = sas.wl<320 | sas.wl > 1040; 
sas.difh(bad,:) = [];
sas.dirh(bad,:) = [];
sas.wl(bad) = [];
sas.resp(bad) = [];
% sas.difh = sas.difh./(sas.resp*ones(size(sas.time)));
% sas.dirh = sas.dirh./(sas.resp*ones(size(sas.time)));
save('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\sgp_2022\sasa0_corr_tint5_difh.mat','-struct','sas')

end
