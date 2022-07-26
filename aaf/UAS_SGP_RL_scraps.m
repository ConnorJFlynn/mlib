rlfex = anc_load(getfullname('sgprl*.nc','rl'));
flight_time = 14.5;
rl_time_i = interp1(serial2Hh(rlfex.time), [1:length(rlfex.time)], flight_time, 'nearest')
rl_ext = rlfex.vdata.extinction_be;  miss = rl_ext<0; rl_ext(miss) = NaN;
figure; imagesc(serial2Hh(rlfex.time), rlfex.vdata.height_high, real(log10(rl_ext))); axis('xy')

this = rl_ext(:,rl_time_i);this(1) = this(2);
figure; plot(this, rlfex.vdata.height_high, '-'); logx
rl_aod = trapz(rlfex.vdata.height_high(2:end), rl_ext(2:end,:));

figure; plot(serial2Hh(rlfex.time), rl_aod,'o');

anet_aod = rd_anetaod_v3(getfullname('*.lev*','anet_aod'));
anet_time_ = anet_aod.time>min(rlfex.time)&anet_aod.time<max(rlfex.time);
aod_fig = figure_(42); plot(serial2Hh(anet_aod.time(anet_time_)), anet_aod.AOD_380nm(anet_time_),'c*'); dynamicDateTicks; title('AOD vs time');
legend('rlfex AOD','flight time', 'Aeronet 380 nm')
title({['AOD from rlproffex1thor.c0 and Aeronet'];datestr(rlfex.time(rl_time_i),'yyyy-mm-dd HH:MM')})
ylabel('height high [km]'); xlabel('time UT')
rlfex.vdata.