function swspect_v_ssfr_head

sws = rd_SAS_raw;
sws = catsas(sws,rd_SAS_raw);

figure(1000); plot(sws.lambda, mean(sws.spec(sws.Shutter_open_TF==1,:))-mean(sws.spec(sws.Shutter_open_TF==0,:)),'-');

ssfr = rd_SAS_raw;

figure(1001); plot(ssfr.lambda, mean(ssfr.spec(ssfr.Shutter_open_TF==1,:))-mean(ssfr.spec(ssfr.Shutter_open_TF==0,:)),'-');

figure(1003); plot(ssfr.lambda, (mean(sws.spec(sws.Shutter_open_TF==1,:))-mean(sws.spec(sws.Shutter_open_TF==0,:)))./...
    (mean(ssfr.spec(ssfr.Shutter_open_TF==1,:))-mean(ssfr.spec(ssfr.Shutter_open_TF==0,:))),'r-');legend('nir')

title('sws / ssfr')


swsv = rd_SAS_raw;
swsv = catsas(swsv,rd_SAS_raw);

figure(1000); plot(swsv.lambda, mean(swsv.spec(swsv.Shutter_open_TF==1,:))-mean(swsv.spec(swsv.Shutter_open_TF==0,:)),'-');

ssfrv = rd_SAS_raw;
good= ssfrv.spec(:,100) >1.5e4;
figure(1001); plot(ssfrv.lambda, mean(ssfrv.spec(good&ssfrv.Shutter_open_TF==1,:))-mean(ssfrv.spec(ssfr.Shutter_open_TF==0,:)),'-');

figure(1004); plot(swsv.lambda, (mean(swsv.spec(swsv.Shutter_open_TF==1,:))-mean(swsv.spec(swsv.Shutter_open_TF==0,:)))./...
    (mean(ssfrv.spec(ssfrv.Shutter_open_TF==1,:))-mean(ssfrv.spec(ssfrv.Shutter_open_TF==0,:))),'b-');legend('uv/vis')
title('sws vis / ssfr vis')





return