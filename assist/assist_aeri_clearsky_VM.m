
% ASSIST_AERI_VM_compare
%%
% Now, with fan
clear
AERI_ch1 = anc_load;%(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\sgpaerich1C1.b1\now_with_fan\sgpaerich1C1.b1.20150919.001256.cdf']);
AERI_ch2 = anc_load;%(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\sgpaerich1C1.b1\now_with_fan\sgpaerich2C1.b1.20150919.001256.cdf'])
asst = load(getfullname('20150919_074816.assist_down.mat','assist_wi_fan','Select assist mat file'));

asst.Sky_ii = find(asst.isSky);
ii = interp1(AERI_ch1.vdata.wnum1, [1:length(AERI_ch1.vdata.wnum1)],1145,'nearest')
wii = interp1(asst.chA.mrad.x, [1:length(asst.chA.mrad.x)],1145,'nearest');
figure; plot(serial2hs(AERI_ch1.time), AERI_ch1.vdata.mean_rad(ii,:), '.', ...
    serial2hs(asst.time(asst.isSky)), asst.chA.mrad.y(asst.isSky,wii), '.')

[ainb, bina] = nearest(asst.time(asst.Sky_ii), AERI_ch1.time);

aeri_ch1 = anc_sift(AERI_ch1, bina);
aeri_ch2 = anc_sift(AERI_ch2, bina);

cha_ = asst.chA.mrad.x>=520 & asst.chA.mrad.x <= 1900;
chb_ = asst.chB.mrad.x>=1750 & asst.chB.mrad.x <= 3500;
figure; plot(asst.chA.mrad.x(cha_), mean(asst.chA.mrad.y(asst.Sky_ii(ainb),cha_)),'b-',...
    aeri_ch1.vdata.wnum1, mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    asst.chB.mrad.x(chb_), mean(asst.chB.mrad.y(asst.Sky_ii(ainb),chb_)),'g-',...
    aeri_ch2.vdata.wnum1, mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
legend('assist chA','AERI chA','assist chB','AERI chB')
title('with fan module')

figure; plot(asst.chA.mrad.x(cha_), mean(asst.chA.mrad.y(asst.Sky_ii(ainb),cha_)),'b-',...
    asst.chB.mrad.x(chb_), mean(asst.chB.mrad.y(asst.Sky_ii(ainb),chb_)),'g-'); 
legend('assist chA','assist chB')
title('with fan module')

asst_to_aeri.chA.y = interp1(asst.chA.mrad.x(cha_), mean(asst.chA.mrad.y(asst.Sky_ii(ainb),cha_)),aeri_ch1.vdata.wnum1,'pchip');
asst_to_aeri.chB.y = interp1(asst.chB.mrad.x(chb_), mean(asst.chB.mrad.y(asst.Sky_ii(ainb),chb_)),aeri_ch2.vdata.wnum1,'pchip');
abb_to_aeri.chA.y = interp1(asst.chA.mrad.x(cha_), mean(asst.chA.mrad.y(asst.ABB_ii,cha_)),aeri_ch1.vdata.wnum1,'pchip');
abb_to_aeri.chB.y = interp1(asst.chB.mrad.x(chb_), mean(asst.chB.mrad.y(asst.ABB_ii,chb_)),aeri_ch2.vdata.wnum1,'pchip');


figure; plot(aeri_ch1.vdata.wnum1, asst_to_aeri.chA.y,'b-',...
    aeri_ch1.vdata.wnum1, mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    aeri_ch2.vdata.wnum1, asst_to_aeri.chB.y,'g-',...
    aeri_ch2.vdata.wnum1, mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
legend('assist chA on AERI wnum','AERI chA','assist chB  on AERI wnum','AERI chB')
title('with fan module')

figure; aa(1) = subplot(3,1,1);
plot(aeri_ch1.vdata.wnum1, asst_to_aeri.chA.y,'b-',...
    aeri_ch1.vdata.wnum1, mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    aeri_ch2.vdata.wnum1, asst_to_aeri.chB.y,'g-',...
    aeri_ch2.vdata.wnum1, mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
ylabel('radiance')
legend('assist chA on AERI wnum','AERI chA','assist chB  on AERI wnum','AERI chB')
title('with fan module')
aa(2) = subplot(3,1,2);
plot(aeri_ch1.vdata.wnum1, smooth(asst_to_aeri.chA.y - mean(aeri_ch1.vdata.mean_rad,2),10),'r-',...
    aeri_ch2.vdata.wnum1, smooth(asst_to_aeri.chB.y - mean(aeri_ch2.vdata.mean_rad,2),10),'k-'); 
legend('assist - aeri chA','assist -aeri chB')
ylabel('delta radiance')
aa(3) = subplot(3,1,3);
plot(aeri_ch1.vdata.wnum1, 100.*(smooth((asst_to_aeri.chA.y - mean(aeri_ch1.vdata.mean_rad,2)),10)./abb_to_aeri.chA.y),'r-',...
    aeri_ch2.vdata.wnum1, 100.*(smooth((asst_to_aeri.chB.y - mean(aeri_ch2.vdata.mean_rad,2)),10)./abb_to_aeri.chB.y),'k-'); 
legend('assist - aeri chA','assist -aeri chB')
ylabel('% diff')
title('with fan module')
linkaxes(aa,'x')


%% with no fan module 20150825
clear 
AERI_ch1 = anc_load;%(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\sgpaerich1C1.b1\now_with_fan\sgpaerich1C1.b1.20150919.001256.cdf']);
AERI_ch2 = anc_load;%(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\sgpaerich1C1.b1\now_with_fan\sgpaerich2C1.b1.20150919.001256.cdf'])
% asst = load(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\no_fan\20150825\20150825_104553.assist_down.mat'])
asst = load(getfullname('20150825_104553.assist_down.mat','assist_no_fan','Select assist mat file'));

asst.Sky_ii = find(asst.isSky);
ii = interp1(AERI_ch1.vdata.wnum1, [1:length(AERI_ch1.vdata.wnum1)],1145,'nearest')
wii = interp1(asst.chA.mrad.x, [1:length(asst.chA.mrad.x)],1145,'nearest');
figure; plot(serial2hs(AERI_ch1.time), AERI_ch1.vdata.mean_rad(ii,:), '.', ...
    serial2hs(asst.time(asst.isSky)), asst.chA.mrad.y(asst.isSky,wii), '.')

[ainb, bina] = nearest(asst.time(asst.Sky_ii), AERI_ch1.time);

aeri_ch1 = anc_sift(AERI_ch1, bina);
aeri_ch2 = anc_sift(AERI_ch2, bina);

cha_ = asst.chA.mrad.x>=520 & asst.chA.mrad.x <= 1900;
chb_ = asst.chB.mrad.x>=1750 & asst.chB.mrad.x <= 3500;
figure; plot(asst.chA.mrad.x(cha_), mean(asst.chA.mrad.y(asst.Sky_ii(ainb),cha_)),'b-',...
    aeri_ch1.vdata.wnum1, mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    asst.chB.mrad.x(chb_), mean(asst.chB.mrad.y(asst.Sky_ii(ainb),chb_)),'g-',...
    aeri_ch2.vdata.wnum1, mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
legend('assist chA','AERI chA','assist chB','AERI chB')
title('without fan module #2')

asst_to_aeri.chA.y = interp1(asst.chA.mrad.x(cha_), mean(asst.chA.mrad.y(asst.Sky_ii(ainb),cha_)),aeri_ch1.vdata.wnum1,'pchip');
asst_to_aeri.chB.y = interp1(asst.chB.mrad.x(chb_), mean(asst.chB.mrad.y(asst.Sky_ii(ainb),chb_)),aeri_ch2.vdata.wnum1,'pchip');

figure; plot(aeri_ch1.vdata.wnum1, asst_to_aeri.chA.y,'b-',...
    aeri_ch1.vdata.wnum1, mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    aeri_ch2.vdata.wnum1, asst_to_aeri.chB.y,'g-',...
    aeri_ch2.vdata.wnum1, mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
legend('assist chA on AERI wnum','AERI chA','assist chB  on AERI wnum','AERI chB')
title('with fan module')

figure; aa(1) = subplot(3,1,1);
plot(aeri_ch1.vdata.wnum1, asst_to_aeri.chA.y,'b-',...
    aeri_ch1.vdata.wnum1, mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    aeri_ch2.vdata.wnum1, asst_to_aeri.chB.y,'g-',...
    aeri_ch2.vdata.wnum1, mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
ylabel('radiance')
legend('assist chA on AERI wnum','AERI chA','assist chB  on AERI wnum','AERI chB')
title('without fan module')
aa(2) = subplot(3,1,2);
plot(aeri_ch1.vdata.wnum1, asst_to_aeri.chA.y - mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    aeri_ch2.vdata.wnum1, asst_to_aeri.chB.y - mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
legend('assist - aeri chA','assist -aeri chB')
ylabel('delta radiance')
aa(3) = subplot(3,1,3);
plot(aeri_ch1.vdata.wnum1, 100.*((asst_to_aeri.chA.y - mean(aeri_ch1.vdata.mean_rad,2))./mean(aeri_ch1.vdata.mean_rad,2)),'r-',...
    aeri_ch2.vdata.wnum1, 100.*((asst_to_aeri.chB.y - mean(aeri_ch2.vdata.mean_rad,2))./mean(aeri_ch2.vdata.mean_rad,2)),'k-'); 
legend('100*(assist chA - aeri chA)/mean','100*(assist chB - aeri chB)/mean')
ylabel('% diff')
linkaxes(aa,'x')



%%
% Now, without #1, Aug 25, 2015
% Seems like hatch is closed?
clear
AERI_ch1 = anc_load(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\sgpaerich1C1.b1\no_fan\sgpaerich1C1.b1.20150820.000436.cdf']);
AERI_ch2 = anc_load(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\sgpaerich1C1.b1\no_fan\sgpaerich2C1.b1.20150820.000436.cdf']);
asst = load(['D:\case_studies\assist\deployments\20150701_SGP_ASSIST_AERI_compare_VM\no_fan\20150820\20150820_093339.assist_down.mat'])

asst.Sky_ii = find(asst.isSky);
ii = interp1(AERI_ch1.vdata.wnum, [1:length(AERI_ch1.vdata.wnum)],1145,'nearest')
wii = interp1(asst.chA.mrad.x, [1:length(asst.chA.mrad.x)],1145,'nearest');
figure; plot(serial2doys(AERI_ch1.time), AERI_ch1.vdata.mean_rad(ii,:), '.', ...
    serial2doys(asst.time(asst.isSky)), asst.chA.mrad.y(asst.isSky,wii), '.')

[ainb, bina] = nearest(asst.time(asst.Sky_ii), AERI_ch1.time);

aeri_ch1 = anc_sift(AERI_ch1, bina);
aeri_ch2 = anc_sift(AERI_ch2, bina);

cha_ = asst.chA.mrad.x>=520 & asst.chA.mrad.x <= 1900;
chb_ = asst.chB.mrad.x>=1750 & asst.chB.mrad.x <= 3500;
figure; plot(asst.chA.mrad.x(cha_), mean(asst.chA.mrad.y(asst.Sky_ii(ainb),cha_)),'b-',...
    aeri_ch1.vdata.wnum, mean(aeri_ch1.vdata.mean_rad,2),'r-',...
    asst.chB.mrad.x(chb_), mean(asst.chB.mrad.y(asst.Sky_ii(ainb),chb_)),'g-',...
    aeri_ch2.vdata.wnum, mean(aeri_ch2.vdata.mean_rad,2),'k-'); 
legend('assist chA','AERI chA','assist chB','AERI chB')
title('assist hatch closed?')




