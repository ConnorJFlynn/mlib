function sas = procsas_a0tob1_fsb(a0, b1); 

if ~isavar('a0')
   a0= anc_bundle_files;
end
if ~isavar('b1');
   b1 = anc_load;
end

%     4.  Get Darks
%     5.  Get TH1
%     6.  Move to SB1
%     7.  Get SB1
%     8.  Move to BK
%     9.  Get BK
%     10.  Move to SB2
%     11.  Get SB2

[sza, saz, AU, ha, dec, sel, oam] = sunae(a0.vdata.lat, a0.vdata.lon, a0.time);

nm_500 = 381;
sig = a0.vdata.spectra(nm_500,:);
darks = interp1(a0.time(a0.vdata.tag==4), sig(a0.vdata.tag==4),a0.time,'linear');
sig  = sig-darks;
SB1 = interp1(a0.time(a0.vdata.tag==7), sig(a0.vdata.tag==7),a0.time,'linear');
SB2 = interp1(a0.time(a0.vdata.tag==9), sig(a0.vdata.tag==9),a0.time,'linear');
SB3 = interp1(a0.time(a0.vdata.tag==11), sig(a0.vdata.tag==11),a0.time,'linear');
[bands, ijk] = sort([SB1;SB2;SB3]); ii = ijk(1,:); jj = ijk(2,:); kk = ijk(3,:);
banding = bands(3,:) > (bands(2,:) - sqrt(bands(2,:)));

sig = a0.vdata.spectra';
darks = interp1(a0.time(a0.vdata.tag==4), sig(a0.vdata.tag==4,:),a0.time,'linear');
sig  = sig-darks;
TH_raw = interp1(a0.time(a0.vdata.tag==5), sig(a0.vdata.tag==5,:),a0.time,'linear');
SB1 = interp1(a0.time(a0.vdata.tag==7), sig(a0.vdata.tag==7,:),a0.time,'linear');
SB2 = interp1(a0.time(a0.vdata.tag==9), sig(a0.vdata.tag==9,:),a0.time,'linear');
SB3 = interp1(a0.time(a0.vdata.tag==11), sig(a0.vdata.tag==11,:),a0.time,'linear');

clear bands BK SB SB_
for ti = length(a0.time):-1:1
   bands = [SB1(ti,:); SB2(ti,:); SB3(ti,:)];
   BK(ti,:) = bands(ii(ti),:);
   SB(ti,:) = bands(kk(ti),:);
   SB_(ti,:) = bands(jj(ti),:);
end
   
SB(banding,:) = (SB(banding,:) + SB_(banding,:) )./2;

cos_corr_comp = interp1(b1.vdata.test_incident_angle, b1.vdata.cosine_correction_hisun, sza, 'linear');
% figure; plot(b1.time, b1.vdata.cosine_correction_computed,'o',a0.time, cos_corr_comp,'.'); dynamicDateTicks;

dirh_raw = SB-BK;
difh_raw = TH_raw - dirh_raw;
dirh = dirh_raw' .* (ones(size(a0.vdata.wavelength))*cos_corr_comp);
difh = difh_raw' .* b1.vdata.diffuse_correction;
TH = dirh + difh;
dirn = dirh ./ (ones(size(a0.vdata.wavelength))*cosd(sza));

% figure; plot(a0.time, dirh_raw(:,nm_500-1)./difh_raw(:,nm_500-1), '.', a0.time, dirh(nm_500-1,:)./difh(nm_500-1,:),'.'); dynamicDateTicks


sas.time = a0.time;
sas.AU = AU;
sas.oam = oam;
sas.lat = a0.vdata.lat;
sas.lon = a0.vdata.lon;
sas.sza = sza; 
sas.difh = difh;
sas.dirh = dirh;
sas.tag = 'sashea0';
sas.resp = b1.vdata.responsivity_vis;
end
