% Jan 29, 2015

a0 = anc_load;
b1 = anc_load;

darks = interp1(a0.time(a0.vdata.shutter_state==0), a0.vdata.spectra(:,a0.vdata.shutter_state==0)', a0.time)';
TH2 = interp1(a0.time(a0.vdata.tag==5), a0.vdata.spectra(:,a0.vdata.tag==5)', a0.time)'- darks;
S_a= interp1(a0.time(a0.vdata.tag==7), a0.vdata.spectra(:,a0.vdata.tag==7)', a0.time)' - darks;
S_b= interp1(a0.time(a0.vdata.tag==9), a0.vdata.spectra(:,a0.vdata.tag==9)', a0.time)' - darks;
S_c= interp1(a0.time(a0.vdata.tag==11), a0.vdata.spectra(:,a0.vdata.tag==11)', a0.time)' - darks;

SUN = (S_a+S_c)./2 - S_b;
DIFH = TH2 - SUN; 
good = SUN(381,:)>0 & DIFH(381,:)>0;
figure; plot(a0.time, SUN(381,:)./DIFH(381,:),'.',b1.time, b1.vdata.direct_horizontal_vis(381,:)./b1.vdata.diffuse_hemisp_vis(381,:),'.'); dynamicDateTicks; 
title(['DDR ',datestr(mean(a0.time),'yyyy-mm-dd')]); 

%March 15, 2022 (first)
a0 = anc_load;
b1 = anc_load;
darks = interp1(a0.time(a0.vdata.shutter_state==0), a0.vdata.spectra(:,a0.vdata.shutter_state==0)', a0.time)';
TH2 = interp1(a0.time(a0.vdata.tag==4), a0.vdata.spectra(:,a0.vdata.tag==4)', a0.time)'- darks;
S_a= interp1(a0.time(a0.vdata.tag==6), a0.vdata.spectra(:,a0.vdata.tag==6)', a0.time)' - darks;
S_b= interp1(a0.time(a0.vdata.tag==8), a0.vdata.spectra(:,a0.vdata.tag==8)', a0.time)' - darks;
S_c= interp1(a0.time(a0.vdata.tag==10), a0.vdata.spectra(:,a0.vdata.tag==10)', a0.time)' - darks;

SUN = (S_a+S_c)./2 - S_b;
DIFH = TH2 - SUN; 
good = SUN(381,:)>0 & DIFH(381,:)>0;
figure; plot(a0.time, SUN(381,:)./DIFH(381,:),'.',b1.time, b1.vdata.direct_horizontal_vis(381,:)./b1.vdata.diffuse_hemisp_vis(381,:),'.'); dynamicDateTicks; 
title(['DDR ',datestr(mean(a0.time),'yyyy-mm-dd')]); 

%March 15, 2022 (second)
a0 = anc_load;
b1 = anc_load; a0.gatts.operation_mode
darks = interp1(a0.time(a0.vdata.shutter_state==0), a0.vdata.spectra(:,a0.vdata.shutter_state==0)', a0.time)';
TH2 = interp1(a0.time(a0.vdata.tag==4), a0.vdata.spectra(:,a0.vdata.tag==4)', a0.time)'- darks;
S_a= interp1(a0.time(a0.vdata.tag==6), a0.vdata.spectra(:,a0.vdata.tag==6)', a0.time)' - darks;
S_b= interp1(a0.time(a0.vdata.tag==8), a0.vdata.spectra(:,a0.vdata.tag==8)', a0.time)' - darks;
S_c= interp1(a0.time(a0.vdata.tag==10), a0.vdata.spectra(:,a0.vdata.tag==10)', a0.time)' - darks;

SUN = (S_a+S_c)./2 - S_b;
DIFH = TH2 - SUN; 
good = SUN(381,:)>0 & DIFH(381,:)>0;
figure; plot(a0.time, SUN(381,:)./DIFH(381,:),'.',b1.time, b1.vdata.direct_horizontal_vis(381,:)./b1.vdata.diffuse_hemisp_vis(381,:),'.'); dynamicDateTicks; 
title(['DDR ',datestr(mean(a0.time),'yyyy-mm-dd')]); 


%Apr 1, 2022 (second)
a0 = anc_load;
b1 = anc_load; a0.gatts.operation_mode
darks = interp1(a0.time(a0.vdata.shutter_state==0), a0.vdata.spectra(:,a0.vdata.shutter_state==0)', a0.time)';
TH2 = interp1(a0.time(a0.vdata.tag==4), a0.vdata.spectra(:,a0.vdata.tag==4)', a0.time)'- darks;
S_a= interp1(a0.time(a0.vdata.tag==6), a0.vdata.spectra(:,a0.vdata.tag==6)', a0.time)' - darks;
S_b= interp1(a0.time(a0.vdata.tag==8), a0.vdata.spectra(:,a0.vdata.tag==8)', a0.time)' - darks;
S_c= interp1(a0.time(a0.vdata.tag==10), a0.vdata.spectra(:,a0.vdata.tag==10)', a0.time)' - darks;

SUN = (S_a+S_c)./2 - S_b;
DIFH = TH2 - SUN; 
good = SUN(381,:)>0 & DIFH(381,:)>0;
figure; plot(a0.time, SUN(381,:)./DIFH(381,:),'.',b1.time, b1.vdata.direct_horizontal_vis(381,:)./b1.vdata.diffuse_hemisp_vis(381,:),'.'); dynamicDateTicks; 
title(['DDR ',datestr(mean(a0.time),'yyyy-mm-dd')]); 

%Apr 6, 2022 (second)
a0 = anc_load;
b1 = anc_load; a0.gatts.operation_mode
darks = interp1(a0.time(a0.vdata.shutter_state==0), a0.vdata.spectra(:,a0.vdata.shutter_state==0)', a0.time)';
TH2 = interp1(a0.time(a0.vdata.tag==5), a0.vdata.spectra(:,a0.vdata.tag==5)', a0.time)'- darks;
S_a= interp1(a0.time(a0.vdata.tag==7), a0.vdata.spectra(:,a0.vdata.tag==7)', a0.time)' - darks;
S_b= interp1(a0.time(a0.vdata.tag==9), a0.vdata.spectra(:,a0.vdata.tag==9)', a0.time)' - darks;
S_c= interp1(a0.time(a0.vdata.tag==11), a0.vdata.spectra(:,a0.vdata.tag==11)', a0.time)' - darks;

SUN = (S_a+S_c)./2 - S_b;
DIFH = TH2 - SUN; 
good = SUN(381,:)>0 & DIFH(381,:)>0;
figure; plot(a0.time, SUN(381,:)./DIFH(381,:),'.',b1.time, b1.vdata.direct_horizontal_vis(381,:)./b1.vdata.diffuse_hemisp_vis(381,:),'.'); dynamicDateTicks; 
title(['DDR ',datestr(mean(a0.time),'yyyy-mm-dd')]); 

%This showed that SGP data is OK until 2022-04-06

% Now HOU, work backwards
a0 = anc_load;a0.gatts.operation_mode
b1 = anc_load; 
darks = interp1(a0.time(a0.vdata.shutter_state==0), a0.vdata.spectra(:,a0.vdata.shutter_state==0)', a0.time)';
TH2 = interp1(a0.time(a0.vdata.tag==8), a0.vdata.spectra(:,a0.vdata.tag==8)', a0.time)'- darks;
S_a= interp1(a0.time(a0.vdata.tag==10), a0.vdata.spectra(:,a0.vdata.tag==10)', a0.time)' - darks;
S_b= interp1(a0.time(a0.vdata.tag==12), a0.vdata.spectra(:,a0.vdata.tag==12)', a0.time)' - darks;
S_c= interp1(a0.time(a0.vdata.tag==14), a0.vdata.spectra(:,a0.vdata.tag==14)', a0.time)' - darks;

SUN = (S_a+S_c)./2 - S_b;
DIFH = TH2 - SUN; 
good = SUN(381,:)>0 & DIFH(381,:)>0;
figure; plot(a0.time, SUN(381,:)./DIFH(381,:),'.',b1.time, b1.vdata.direct_horizontal_vis(381,:)./b1.vdata.diffuse_hemisp_vis(381,:),'.'); dynamicDateTicks; 
title(['DDR ',datestr(mean(a0.time),'yyyy-mm-dd')]); 



