%%
clap = ancload(getfullname_('*.cdf','aos_abs'));
pass = ancload(getfullname_('*.cdf','aos_abs'));
%%
zeds = pass.vars.sample_measurement_flag.data>0;
figure; 
s(1) = subplot(2,1,1);
plot(serial2doy(pass.time), [pass.vars.absorption_coefficient_405nm.data;...
    pass.vars.absorption_coefficient_532nm.data; pass.vars.absorption_coefficient_781nm.data],'o-');
legend('405 nm','532 nm','781 nm')
s(2) = subplot(2,1,2);
plot(serial2doy(pass.time), pass.vars.sample_measurement_flag.data,'o-')
linkaxes(s,'x');
%%
[pass_zed, pass_nonzed] = ancsift(pass,pass.dims.time,zeds);
pass_nonzed.vars = rmfield(pass_nonzed.vars, 'sample_measurement_flag');
pass_nonzed.vars = rmfield(pass_nonzed.vars, 'running_average');
%%
pass_nonzed_60s = ancdownsample(pass_nonzed,30);
good_clap = clap.vars.Ba_B_Dry_10um_CLAP3W_1.data>-9000 & clap.vars.Ba_G_Dry_10um_CLAP3W_1.data>-9000 ...
    & clap.vars.Ba_R_Dry_10um_CLAP3W_1.data>-9000;
figure; 
s(1) = subplot(2,1,1);
plot(serial2doy(pass_nonzed_60s.time), [pass_nonzed_60s.vars.absorption_coefficient_405nm.data;...
    pass_nonzed_60s.vars.absorption_coefficient_532nm.data; pass_nonzed_60s.vars.absorption_coefficient_781nm.data],'o-');
legend('405 nm','532 nm','781 nm')
s(2) = subplot(2,1,2);
plot(serial2doy(clap.time(good_clap)), [clap.vars.Ba_B_Dry_10um_CLAP3W_1.data(good_clap);...
    clap.vars.Ba_G_Dry_10um_CLAP3W_1.data(good_clap);clap.vars.Ba_R_Dry_10um_CLAP3W_1.data(good_clap)],'o-');
legend('B','G','R')

linkaxes(s,'xy');
