
% ASSIST_AERI_VM_compare
% with fan module 20150919

AERI_ch1 = anc_load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\sgpaerich1C1.b1\sgpaerich1C1.b1.20150919.001256.cdf']);
AERI_ch2 = anc_load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\sgpaerich1C1.b1\sgpaerich2C1.b1.20150919.001256.cdf']);
asst = load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\Now_with_fan_module\2015_09_19_08_12_26_RAW\20150919_074816.assist_down.mat'])

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

%%
% Now, without #1, Aug 20, 2015
AERI_ch1 = anc_load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\sgpaerich1C1.b1\sgpaerich1C1.b1.20150820.000436.cdf']);
AERI_ch2 = anc_load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\sgpaerich1C1.b1\sgpaerich2C1.b1.20150820.000436.cdf']);
asst = load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\No_fan_module\20150820\20150820_093339.assist_down.mat'])

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

%%
% Now, without #1, Aug 25, 2015
AERI_ch1 = anc_load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\sgpaerich1C1.b1\sgpaerich1C1.b1.20150825.000452.cdf']);
AERI_ch2 = anc_load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\sgpaerich1C1.b1\sgpaerich2C1.b1.20150825.000452.cdf']);
asst = load(['C:\xfer\ASSIST_all\ASSIST_VM_at_SGP_20150821\No_fan_module\20150825\20150825_104553.assist_down.mat'])

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





