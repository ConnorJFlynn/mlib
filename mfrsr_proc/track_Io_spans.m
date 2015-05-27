langs = ancbundle_files;
% Saved nsa langs in 'D:\case_studies\nsa_aod\Langleys\from_Annettes_tree\nsamfrsrlangleyC1.c1\nsamfrsrlangleys.mat'
% langs = load('D:\case_studies\nsa_aod\Langleys\from_Annettes_tree\nsamfrsrlangleyC1.c1\nsamfrsrlangleys.mat');
save(['D:\case_studies\mfrsr_aod_qc_help\sgp_new_Io_questions\sgp_langs\sgpmfrsrlangleys.mat'],'-struct','langs');
days = floor(langs.time(1)):ceil(langs.time(end));
good = langs.vars.michalsky_solar_constant_sdist_filter2.data>0;
wind = 15;
for d = length(days):-1:1
    lang.time(d) = days(d);
    in_wind = langs.time>=(days(d)-wind) & langs.time<=(days(d)+wind);
    lang.Io_days(d) = sum(good & in_wind);
    lang.IQF_days(d) = floor(lang.Io_days(d)./2)
end
    
figure; 
plot(lang.time, lang.IQF_days, '-o'); dynamicDateTicks;


sgp_Apr15 = ancload;

figure; plot(epoch2serial(sgp_Apr15.vars.Io_interquartile_time.data(1))
