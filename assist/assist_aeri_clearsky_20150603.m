aeri_ch2 = anc_load('sgpaerich2*.cdf','aeri');
aeri_ch2.vdata.Tb = BrightnessTemperature(aeri_ch2.vdata.wnum, aeri_ch2.vdata.mean_rad);

figure; plot(aeri_ch2.vdata.wnum,aeri_ch2.vdata.mean_rad(:,1000),'-')
figure; plot(aeri_ch2.vdata.wnum,aeri_ch2.vdata.Tb(:,1000),'-')
interp1(aeri_ch2.vdata.wnum, [1:length(aeri_ch2.vdata.wnum)],2500)
figure; plot(serial2hs(aeri_ch2.time),aeri_ch2.vdata.Tb(1453,:),'-')
figure; plot(serial2hs(aeri_ch2.time),aeri_ch2.vdata.Tb(1450:1455,:),'-')
figure; plot(serial2hs(aeri_ch2.time),mean(aeri_ch2.vdata.Tb(1450:1455,:),1),'-')

assist_3rd_BBtest_pc_avg_nlc
Tb_ii = assist.chA.mrad.x > 1093 & assist.chA.mrad.x < 1098.5;
figure; plot(assist.time(assist.isSky), min( assist.chA.T_bt(assist.isSky,Tb_ii)')-273.15,'b.')
figure; plot(assist.chA.mrad.x, assist.chA.mrad.y(assist.isSky,:),'-')
aeri_ch1 = anc_load('sgpaerich1*.cdf','aeri');
[ainb, bina] = nearest(assist.time, aeri_ch1.time);


figure; plot(aeri_ch1.vdata.wnum, mean(aeri_ch1.vdata.mean_rad(:,bina),2), 'r-')
figure; plot(assist.chA.mrad.x, mean(assist.chA.mrad.y(assist.isSky,:),1),'b-')
mean_aeri =  mean(aeri_ch1.vdata.mean_rad(:,bina),2);
mean_asst =  mean(assist.chA.mrad.y(assist.isSky,:),1);

assist_2_aeri = interp1(assist.chA.mrad.x,mean_asst, aeri_ch1.vdata.wnum,'linear');
figure; plot( downsample(aeri_ch1.vdata.wnum,10), (downsample(mean_aeri,10)-downsample(assist_2_aeri,10))./downsample(mean_aeri,10),'r.')
mean_asst_ABB =  mean(assist.chA.mrad.y(assist.isABB,:),1);
assist_ABB = interp1(assist.chA.mrad.x,mean_asst_ABB, aeri_ch1.vdata.wnum,'linear');
figure; plot( downsample(aeri_ch1.vdata.wnum,10), 100.*(downsample(mean_aeri,10)-downsample(assist_2_aeri,10))./downsample(assist_ABB,10),'r.');

figure; aa(1) = subplot(2,1,1);
plot( downsample(aeri_ch1.vdata.wnum,10), downsample(mean_aeri,10), 'b',...
   downsample(aeri_ch1.vdata.wnum, 10),downsample(assist_2_aeri,10), 'r-');  legend('AERI','ASSIST');
ylabel('mW/(m^2 sr cm^-1)');
title(['AERI - ASSIST clear sky radiance at SGP:',...
   datestr(aeri_ch1.time(bina(1)),'yyyy-mm-dd HH:MM'),'-',datestr(aeri_ch1.time(bina(end)),'HH:MM')]);
aa(2) = subplot(2,1,2);
plot( downsample(aeri_ch1.vdata.wnum,10), 100.*(downsample(mean_aeri,10)-downsample(assist_2_aeri,10))./downsample(assist_ABB,10),'r.');
legend('AERI - ASSIST');
ylabel('% diff');
xlabel('wavenumber [1/cm]');
linkaxes(aa,'x');

