function langs = get_robust_Vo(langs)
% langs = get_robust_Io(langs);
% I think this algorithm is critically flawed in that the
% interquartile is taken over the entire series instead of just over a
% subset. This will potentially truncate one end of a series having a
% systematic trend.
%
% Provided with a long time series of Langley regressions, this function
% applies a Forgan interquartile filter and lowess smoothing to yield
% robust Io values for filters 1-6 (415nm, 500nm, 615nm, 673nm, 870nm, 940nm)

%filter1 415nm
mgood = find(~(langs.vars.michalsky_solar_constant_sdist_filter1.data<.1));
mbad = find(~(langs.vars.michalsky_solar_constant_sdist_filter1.data>=.1));
[Io, mind] = sort(langs.vars.michalsky_solar_constant_sdist_filter1.data(mgood));
lenIo=length(Io); quartet = floor(lenIo/4);
mbad = unique([mbad, mgood(mind(1:(quartet-1))), mgood(mind(end-quartet+1:end))]);
mgood = unique(mgood(mind(quartet:end-quartet)));
y = smooth(serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter1.data(mgood),.25, 'lowess');
yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'linear', 'extrap');
yi = smooth(serial2doy0(langs.time),yi,.25, 'lowess')';
% yi = polyval(polyfit(serial2doy0(langs.time(mgood)), y',1), ... 
%    serial2doy0(langs.time));
figure; plot(serial2doy0(langs.time),langs.vars.michalsky_solar_constant_sdist_filter1.data, 'r.', serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter1.data(mgood), 'g.', serial2doy0(langs.time), yi, 'k')
title('filter 1');
langs.vars.michalsky_smoothed_Io_415nm = langs.vars.michalsky_solar_constant_sdist_filter1;
langs.vars.michalsky_smoothed_Io_415nm.data = yi;
langs.vars.michalsky_smoothed_Io_415nm.atts.long_name.data = 'smoothed Io';
langs.vars.michalsky_smoothed_Io_415nm.atts = rmfield(langs.vars.michalsky_smoothed_Io_415nm.atts, 'actual_wavelength');
langs.vars.michalsky_smoothed_Io_415nm.id = length(fieldnames(langs.vars))+1;

%filter2 500nm
mgood = find(~(langs.vars.michalsky_solar_constant_sdist_filter2.data<.1));
mbad = find(~(langs.vars.michalsky_solar_constant_sdist_filter2.data>=.1));
[Io, mind] = sort(langs.vars.michalsky_solar_constant_sdist_filter2.data(mgood));
lenIo=length(Io); quartet = floor(lenIo/4);
mbad = unique([mbad, mgood(mind(1:(quartet-1))), mgood(mind(end-quartet+1:end))]);
mgood = unique(mgood(mind(quartet:end-quartet)));
y = smooth(serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter2.data(mgood),.25, 'lowess');
yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
yi = smooth(serial2doy0(langs.time),yi,.25, 'lowess')';
% yi = polyval(polyfit(serial2doy0(langs.time(mgood)), y',1), ... 
%     serial2doy0(langs.time));
figure; plot(serial2doy0(langs.time),langs.vars.michalsky_solar_constant_sdist_filter2.data, 'r.', serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter2.data(mgood), 'g.', serial2doy0(langs.time), yi, 'k')
title('filter 2');
langs.vars.michalsky_smoothed_Io_500nm = langs.vars.michalsky_solar_constant_sdist_filter2;
langs.vars.michalsky_smoothed_Io_500nm.data = yi;
langs.vars.michalsky_smoothed_Io_500nm.atts.long_name.data = 'smoothed Io';
langs.vars.michalsky_smoothed_Io_500nm.atts = rmfield(langs.vars.michalsky_smoothed_Io_500nm.atts, 'actual_wavelength');
langs.vars.michalsky_smoothed_Io_500nm.id = length(fieldnames(langs.vars))+1;

%filter3 615nm
mgood = find(~(langs.vars.michalsky_solar_constant_sdist_filter3.data<.1));
mbad = find(~(langs.vars.michalsky_solar_constant_sdist_filter3.data>=.1));
[Io, mind] = sort(langs.vars.michalsky_solar_constant_sdist_filter3.data(mgood));
lenIo=length(Io); quartet = floor(lenIo/4);
mbad = unique([mbad, mgood(mind(1:(quartet-1))), mgood(mind(end-quartet+1:end))]);
mgood = unique(mgood(mind(quartet:end-quartet)));
y = smooth(serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter3.data(mgood),.25, 'lowess');
yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
yi = smooth(serial2doy0(langs.time),yi,.25, 'lowess')';
%  yi = polyval(polyfit(serial2doy0(langs.time(mgood)), y',1), ... 
%     serial2doy0(langs.time));
figure; plot(serial2doy0(langs.time),langs.vars.michalsky_solar_constant_sdist_filter3.data, 'r.', serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter3.data(mgood), 'g.', serial2doy0(langs.time), yi, 'k');
title('filter 3');
langs.vars.michalsky_smoothed_Io_615nm = langs.vars.michalsky_solar_constant_sdist_filter1;
langs.vars.michalsky_smoothed_Io_615nm.data = yi;
langs.vars.michalsky_smoothed_Io_615nm.atts.long_name.data = 'smoothed Io';
langs.vars.michalsky_smoothed_Io_615nm.atts = rmfield(langs.vars.michalsky_smoothed_Io_615nm.atts, 'actual_wavelength');
langs.vars.michalsky_smoothed_Io_615nm.id = length(fieldnames(langs.vars))+1;

%filter4 673nm
mgood = find(~(langs.vars.michalsky_solar_constant_sdist_filter4.data<.1));
mbad = find(~(langs.vars.michalsky_solar_constant_sdist_filter4.data>=.1));
[Io, mind] = sort(langs.vars.michalsky_solar_constant_sdist_filter4.data(mgood));
lenIo=length(Io); quartet = floor(lenIo/4);
mbad = unique([mbad, mgood(mind(1:(quartet-1))), mgood(mind(end-quartet+1:end))]);
mgood = unique(mgood(mind(quartet:end-quartet)));
y = smooth(serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter4.data(mgood),.25, 'lowess');
yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
yi = smooth(serial2doy0(langs.time),yi,.25, 'lowess')';
% yi = polyval(polyfit(serial2doy0(langs.time(mgood)), y',1), ... 
%     serial2doy0(langs.time));
figure; plot(serial2doy0(langs.time),langs.vars.michalsky_solar_constant_sdist_filter4.data, 'r.', serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter4.data(mgood), 'g.', serial2doy0(langs.time), yi, 'k')
title('filter 4');
langs.vars.michalsky_smoothed_Io_673nm = langs.vars.michalsky_solar_constant_sdist_filter1;
langs.vars.michalsky_smoothed_Io_673nm.data = yi;
langs.vars.michalsky_smoothed_Io_673nm.atts.long_name.data = 'smoothed Io';
langs.vars.michalsky_smoothed_Io_673nm.atts = rmfield(langs.vars.michalsky_smoothed_Io_673nm.atts, 'actual_wavelength');
langs.vars.michalsky_smoothed_Io_673nm.id = length(fieldnames(langs.vars))+1;

%filter5 870nm
mgood = find(~(langs.vars.michalsky_solar_constant_sdist_filter5.data<.1));
mbad = find(~(langs.vars.michalsky_solar_constant_sdist_filter5.data>=.1));
[Io, mind] = sort(langs.vars.michalsky_solar_constant_sdist_filter5.data(mgood));
lenIo=length(Io); quartet = floor(lenIo/4);
mbad = unique([mbad, mgood(mind(1:(quartet-1))), mgood(mind(end-quartet+1:end))]);
mgood = unique(mgood(mind(quartet:end-quartet)));
y = smooth(serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter5.data(mgood),.25, 'lowess');
yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
yi = smooth(serial2doy0(langs.time),yi,.25, 'lowess')';
% yi = polyval(polyfit(serial2doy0(langs.time(mgood)), y',1), ... 
%     serial2doy0(langs.time));
figure; plot(serial2doy0(langs.time),langs.vars.michalsky_solar_constant_sdist_filter5.data, 'r.', serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter5.data(mgood), 'g.', serial2doy0(langs.time), yi, 'k')
title('filter 5');
langs.vars.michalsky_smoothed_Io_870nm = langs.vars.michalsky_solar_constant_sdist_filter1;
langs.vars.michalsky_smoothed_Io_870nm.data = yi;
langs.vars.michalsky_smoothed_Io_870nm.atts.long_name.data = 'smoothed Io';
langs.vars.michalsky_smoothed_Io_870nm.atts = rmfield(langs.vars.michalsky_smoothed_Io_870nm.atts, 'actual_wavelength');
langs.vars.michalsky_smoothed_Io_870nm.id = length(fieldnames(langs.vars))+1;

%filter6 940nm
mgood = find(~(langs.vars.michalsky_solar_constant_sdist_filter6.data<.1));
mbad = find(~(langs.vars.michalsky_solar_constant_sdist_filter6.data>=.1));
[Io, mind] = sort(langs.vars.michalsky_solar_constant_sdist_filter6.data(mgood));
lenIo=length(Io); quartet = floor(lenIo/4);
mbad = unique([mbad, mgood(mind(1:(quartet-1))), mgood(mind(end-quartet+1:end))]);
mgood = unique(mgood(mind(quartet:end-quartet)));
y = smooth(serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter6.data(mgood),.25, 'lowess');
yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap')';
yi = smooth(serial2doy0(langs.time),yi',.25, 'lowess')';
% yi = polyval(polyfit(serial2doy0(langs.time(mgood)), y',1), ... 
%     serial2doy0(langs.time));
figure; plot(serial2doy0(langs.time),langs.vars.michalsky_solar_constant_sdist_filter6.data, 'r.', serial2doy0(langs.time(mgood)),langs.vars.michalsky_solar_constant_sdist_filter6.data(mgood), 'g.', serial2doy0(langs.time), yi, 'k')
title('filter 6');
langs.vars.michalsky_smoothed_Io_940nm = langs.vars.michalsky_solar_constant_sdist_filter1;
langs.vars.michalsky_smoothed_Io_940nm.data = yi;
langs.vars.michalsky_smoothed_Io_940nm.atts.long_name.data = 'smoothed Io';
langs.vars.michalsky_smoothed_Io_940nm.atts = rmfield(langs.vars.michalsky_smoothed_Io_940nm.atts, 'actual_wavelength');
langs.vars.michalsky_smoothed_Io_940nm.id = length(fieldnames(langs.vars))+1;

figure; plot(serial2doy0(langs.time),[langs.vars.michalsky_smoothed_Io_415nm.data; langs.vars.michalsky_smoothed_Io_500nm.data; langs.vars.michalsky_smoothed_Io_615nm.data; langs.vars.michalsky_smoothed_Io_673nm.data; langs.vars.michalsky_smoothed_Io_870nm.data; langs.vars.michalsky_smoothed_Io_940nm.data]);
legend('415', '500', '615', '673', '870','940')
% %!! Mich ends
% mgood = find(~(langs.vars.barnard_solar_constant_sdist_filter2.data<.1)&~(langs.vars.barnard_solar_constant_sdist_filter2.data>10));
% mbad = find((langs.vars.barnard_solar_constant_sdist_filter2.data<.1)|(langs.vars.barnard_solar_constant_sdist_filter2.data>10));
% %[length(mgood)+length(mbad)]
% [Io, mind] = sort(langs.vars.barnard_solar_constant_sdist_filter2.data(mgood));
% lenIo=length(Io);
% quartet = floor(lenIo/4);
% %figure; plot(serial2doy0(langs.time),langs.vars.barnard_solar_constant_sdist_filter2.data, 'r.', serial2doy0(langs.time(mgood(mind(quartet:(end-quartet))))),langs.vars.barnard_solar_constant_sdist_filter2.data(mgood(mind(quartet:(end-quartet)))), 'g.')
% mbad = unique([mbad, mgood(mind(1:(quartet-1))), mgood(mind(end-quartet+1:end))]);
% mgood = unique(mgood(mind(quartet:end-quartet)));
% [length(langs.vars.time_offset.data) , length(mbad), length(mgood),length(mbad)+ length(mgood)];
% %filter2 500nm
% y = smooth(serial2doy0(langs.time(mgood)),langs.vars.barnard_solar_constant_sdist_filter2.data(mgood),.25, 'lowess');
% yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
% langs.vars.barnard_smoothed_Io_500nm = langs.vars.barnard_solar_constant_sdist_filter2;
% langs.vars.barnard_smoothed_Io_500nm.data = yi;
% langs.vars.barnard_smoothed_Io_500nm.atts.long_name.data = 'smoothed Io';
% langs.vars.barnard_smoothed_Io_500nm.atts = rmfield(langs.vars.barnard_smoothed_Io_500nm.atts, 'actual_wavelength');
% langs.vars.barnard_smoothed_Io_500nm.id = length(fieldnames(langs.vars))+1;
% %filter1 415nm
% y = smooth(serial2doy0(langs.time(mgood)),langs.vars.barnard_solar_constant_sdist_filter1.data(mgood),.25, 'lowess');
% yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
% langs.vars.barnard_smoothed_Io_415nm = langs.vars.barnard_solar_constant_sdist_filter1;
% langs.vars.barnard_smoothed_Io_415nm.data = yi;
% langs.vars.barnard_smoothed_Io_415nm.atts.long_name.data = 'smoothed Io';
% langs.vars.barnard_smoothed_Io_415nm.atts = rmfield(langs.vars.barnard_smoothed_Io_415nm.atts, 'actual_wavelength');
% langs.vars.barnard_smoothed_Io_415nm.id = length(fieldnames(langs.vars))+1;
% 
% %filter3 615nm
% y = smooth(serial2doy0(langs.time(mgood)),langs.vars.barnard_solar_constant_sdist_filter3.data(mgood),.25, 'lowess');
% yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
% langs.vars.barnard_smoothed_Io_615nm = langs.vars.barnard_solar_constant_sdist_filter1;
% langs.vars.barnard_smoothed_Io_615nm.data = yi;
% langs.vars.barnard_smoothed_Io_615nm.atts.long_name.data = 'smoothed Io';
% langs.vars.barnard_smoothed_Io_615nm.atts = rmfield(langs.vars.barnard_smoothed_Io_615nm.atts, 'actual_wavelength');
% langs.vars.barnard_smoothed_Io_615nm.id = length(fieldnames(langs.vars))+1;
% 
% %filter4 673nm
% y = smooth(serial2doy0(langs.time(mgood)),langs.vars.barnard_solar_constant_sdist_filter4.data(mgood),.25, 'lowess');
% yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
% langs.vars.barnard_smoothed_Io_673nm = langs.vars.barnard_solar_constant_sdist_filter1;
% langs.vars.barnard_smoothed_Io_673nm.data = yi;
% langs.vars.barnard_smoothed_Io_673nm.atts.long_name.data = 'smoothed Io';
% langs.vars.barnard_smoothed_Io_673nm.atts = rmfield(langs.vars.barnard_smoothed_Io_673nm.atts, 'actual_wavelength');
% langs.vars.barnard_smoothed_Io_673nm.id = length(fieldnames(langs.vars))+1;
% 
% %filter5 870nm
% y = smooth(serial2doy0(langs.time(mgood)),langs.vars.barnard_solar_constant_sdist_filter5.data(mgood),.25, 'lowess');
% yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
% langs.vars.barnard_smoothed_Io_870nm = langs.vars.barnard_solar_constant_sdist_filter1;
% langs.vars.barnard_smoothed_Io_870nm.data = yi;
% langs.vars.barnard_smoothed_Io_870nm.atts.long_name.data = 'smoothed Io';
% langs.vars.barnard_smoothed_Io_870nm.atts = rmfield(langs.vars.barnard_smoothed_Io_870nm.atts, 'actual_wavelength');
% langs.vars.barnard_smoothed_Io_870nm.id = length(fieldnames(langs.vars))+1;
% 
% %filter6 940nm
% y = smooth(serial2doy0(langs.time(mgood)),langs.vars.barnard_solar_constant_sdist_filter6.data(mgood),.25, 'lowess');
% yi = interp1(serial2doy0(langs.time(mgood)), y, serial2doy0(langs.time),'spline', 'extrap');
% langs.vars.barnard_smoothed_Io_940nm = langs.vars.barnard_solar_constant_sdist_filter1;
% langs.vars.barnard_smoothed_Io_940nm.data = yi;
% langs.vars.barnard_smoothed_Io_940nm.atts.long_name.data = 'smoothed Io';
% langs.vars.barnard_smoothed_Io_940nm.atts = rmfield(langs.vars.barnard_smoothed_Io_940nm.atts, 'actual_wavelength');
% langs.vars.barnard_smoothed_Io_940nm.id = length(fieldnames(langs.vars))+1;
% 
langs.clobber = 1;
[PATHSTR,NAME,EXT] = fileparts(langs.fname);
%ancsave(langs, [PATHSTR,'\',NAME,'.nc']);
