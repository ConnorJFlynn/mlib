% Compare Amice_B nearest

air_neph = rd_in102_raw; % air_neph.time = air_neph.time + 1;
tsi_neph = rd_bnl_tsv4;
caps = rd_capsdaq;
time_offset = floor(mean(air_neph.time))-floor(mean(caps.time));
air_neph.time = air_neph.time - time_offset;
% air_neph.time = air_neph.time-datenum(2000,08,14)+datenum(2024,08,14);
air_neph.Bs = [air_neph.TOTAL_SCATT_BLUE, air_neph.TOTAL_SCATT_GREEN, air_neph.TOTAL_SCATT_RED];
figure; plot(air_neph.time , [air_neph.Bs],'-'); 
dynamicDateTicks; legend('AP Bs_B','AP Bs_G','AP Bs_R')


tsi_neph.Bs = [tsi_neph.Blue_T, tsi_neph.Green_T, tsi_neph.Red_T]*1e6;
figure; plot(tsi_neph.time, tsi_neph.Bs,'-'); 
dynamicDateTicks; legend('TSI Bs_B','TSI Bs_G','TSI Bs_R');


caps.Be = [caps.Extinction_Blue, caps.Extinction_Green, caps.Extinction_Red];
figure; plot(caps.time(caps.Status_Blue==10024), caps.Be(caps.Status_Blue==10024,:),'-'); 
dynamicDateTicks; legend('Be_B','Be_G', 'Be_R');

figure; plot(caps.time(caps.Status_Blue==10024), ...
   [smooth(caps.Be(caps.Status_Blue==10024,1),180),smooth(caps.Be(caps.Status_Blue==10024,2),75),...
   smooth(caps.Be(caps.Status_Blue==10024,3),180)],'-'); 
dynamicDateTicks; legend('Be_B','Be_G', 'Be_R');

[aint, tina] = nearest(air_neph.time, tsi_neph.time);
[ainc, cina] = nearest(air_neph.time, caps.time);
[tinc, cint] = nearest(tsi_neph.time, caps.time);

figure; plot(caps.Extinction_Green(cina), air_neph.TOTAL_SCATT_GREEN(ainc),'gx');

figure; plot(caps.Extinction_Green(cint), tsi_neph.Green_T(tinc)*1e6,'go');

figure; plot(tsi_neph.Green_T(tina)*1e6, air_neph.TOTAL_SCATT_GREEN(aint), 'g*');