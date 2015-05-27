mfr = ancload;
%%
%figure; plot(mfr.time(el<-15), mfr.vars.head_temp.data(el<-15),'.'); datetick('keeplimits')
[nighttime_head_temp, ind] = sort(mfr.vars.head_temp.data(el<-15));
temp = mfr.vars.alltime_hemisp_broadband.data(el<-15);
nighttime_broadband = temp(ind);
temp = mfr.vars.alltime_hemisp_narrowband_filter1.data(el<-15);
nighttime_filter1 = temp(ind);
temp = mfr.vars.alltime_hemisp_narrowband_filter2.data(el<-15);
nighttime_filter2 = temp(ind);
temp = mfr.vars.alltime_hemisp_narrowband_filter3.data(el<-15);
nighttime_filter3 = temp(ind);
temp = mfr.vars.alltime_hemisp_narrowband_filter4.data(el<-15);
nighttime_filter4 = temp(ind);
temp = mfr.vars.alltime_hemisp_narrowband_filter5.data(el<-15);
nighttime_filter5 = temp(ind);
temp = mfr.vars.alltime_hemisp_narrowband_filter6.data(el<-15);
nighttime_filter6 = temp(ind);
%%
[P0,S0] = polyfit(nighttime_head_temp, nighttime_broadband,1);
[P1,S1] = polyfit(nighttime_head_temp, nighttime_filter1,1);
[P2,S2] = polyfit(nighttime_head_temp, nighttime_filter2,1);
[P3,S3] = polyfit(nighttime_head_temp, nighttime_filter3,1);
[P4,S4] = polyfit(nighttime_head_temp, nighttime_filter4,1);
[P5,S5] = polyfit(nighttime_head_temp, nighttime_filter5,1);
[P6,S6] = polyfit(nighttime_head_temp, nighttime_filter6,1);
%%
figure; plot(nighttime_head_temp,nighttime_broadband, 'r.', nighttime_head_temp, polyval(P0,nighttime_head_temp),'g');
title(['broadband offset vs head temp, slope = ',num2str(P0(1))])
figure; plot(nighttime_head_temp,nighttime_filter1, 'r.', nighttime_head_temp, polyval(P1,nighttime_head_temp),'g')
title(['filter1 offset vs head temp, slope = ',num2str(P1(1))])
figure; plot(nighttime_head_temp,nighttime_filter2, 'r.', nighttime_head_temp, polyval(P2,nighttime_head_temp),'g')
title(['filter2 offset vs head temp, slope = ',num2str(P2(1))])
figure; plot(nighttime_head_temp,nighttime_filter3, 'r.', nighttime_head_temp, polyval(P3,nighttime_head_temp),'g')
title(['filter3 offset vs head temp, slope = ',num2str(P3(1))])
figure; plot(nighttime_head_temp,nighttime_filter4, 'r.', nighttime_head_temp, polyval(P4,nighttime_head_temp),'g')
title(['filter4 offset vs head temp, slope = ',num2str(P4(1))])
figure; plot(nighttime_head_temp,nighttime_filter5, 'r.', nighttime_head_temp, polyval(P5,nighttime_head_temp),'g')
title(['filter5 offset vs head temp, slope = ',num2str(P5(1))])
figure; plot(nighttime_head_temp,nighttime_filter6, 'r.', nighttime_head_temp, polyval(P6,nighttime_head_temp),'g')
title(['filter6 offset vs head temp, slope = ',num2str(P6(1))])
%%
close('all')
