C1 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfrsraod1michC1.c1.20090330.000000.cdf']);
E13 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfrsraod1michE13.c1.20090330.000000.cdf']);
nim = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpnimfraod1michC1.c1.20090330.000000.cdf']);

m10 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfr10mC1.b1.20090330.000000.cdf']);
m25 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfr25mC1.b1.20090330.000000.cdf']);
%%
C1 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfrsraod1michC1.c1.20091101.000000.cdf']);
E13 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfrsraod1michE13.c1.20091101.000000.cdf']);
nim = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpnimfraod1michC1.c1.20091101.000000.cdf']);

m10 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfr10mC1.b1.20091101.000000.cdf']);
m25 = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\Jan21\sgpmfr25mC1.b1.20091101.000000.cdf']);
%%

[cina, ainc] = nearest(C1.time, m10.time);
[eina, aine] = nearest(E13.time, m10.time);
[nina, ainn] = nearest(nim.time, m10.time);

[cinb, binc] = nearest(C1.time, m25.time);
[einb, bine] = nearest(E13.time, m25.time);
[ninb, binn] = nearest(nim.time, m25.time);

ratio_C1_m10.time = C1.time(cina);
ratio_E13_m10.time = E13.time(eina);
ratio_nim_m10.time = nim.time(nina);

ratio_C1_m25.time = C1.time(cinb);
ratio_E13_m25.time = E13.time(einb);
ratio_nim_m25.time = nim.time(ninb);
%%

for f = 1:5

Nom_C1 = C1.vars.(['nominal_calibration_factor_filter',num2str(f)]).data;
Io_C1= C1.vars.(['Io_filter',num2str(f)]).data;

Nom_E13 = E13.vars.(['nominal_calibration_factor_filter',num2str(f)]).data;
Io_E13= E13.vars.(['Io_filter',num2str(f)]).data;

Nom_nim = nim.vars.(['nominal_calibration_factor_filter',num2str(f)]).data;
Io_nim= nim.vars.(['Io_filter',num2str(f)]).data;

down_C1 = C1.vars.(['hemisp_narrowband_filter',num2str(f)]).data;
down_C1_nom = down_C1.*(Nom_C1./Io_C1);

down_E13 = E13.vars.(['hemisp_narrowband_filter',num2str(f)]).data;
down_E13_nom = down_E13.*(Nom_E13./Io_E13);

% down_nim = nim.vars.(['hemisp_narrowband_filter',num2str(f)]).data;
% down_nim_nom = down_nim.*(Nom_nim./Io_nim);

ratio_C1_m10.(['albedo_filter',num2str(f)]) = ...
   m10.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(ainc) ./ ...
   down_C1(cina);

ratio_E13_m10.(['albedo_filter',num2str(f)]) = ...
   m10.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(aine) ./ ...
   down_E13(eina);

% ratio_nim_m10.(['albedo_filter',num2str(f)]) = ...
%    m10.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(ainn) ./ ...
%    down_nim(nina);

ratio_C1_m10.(['nominal_albedo_filter',num2str(f)]) = (1./(Io_C1./Nom_C1)).* ...
   m10.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(ainc) ./ ...
   down_C1_nom(cina);

ratio_E13_m10.(['nominal_albedo_filter',num2str(f)]) = (1./(Io_E13./Nom_E13)).*...
   m10.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(aine) ./ ...
   down_E13_nom(eina);

% ratio_nim_m10.(['nominal_albedo_filter',num2str(f)]) = (Io_nim./Nom_nim).*...
%    m10.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(ainn) ./ ...
%    down_nim_nom(nina);
% now 25 m
ratio_C1_m25.(['albedo_filter',num2str(f)]) = ...
   m25.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(binc) ./ ...
   down_C1(cinb);

ratio_E13_m25.(['albedo_filter',num2str(f)]) = ...
   m25.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(bine) ./ ...
   down_E13(einb);

% ratio_nim_m25.(['albedo_filter',num2str(f)]) = ...
%    m25.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(binn) ./ ...
%    down_nim(ninb);

ratio_C1_m25.(['nominal_albedo_filter',num2str(f)]) = (1./(Io_C1./Nom_C1)).* ...
   m25.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(binc) ./ ...
   down_C1_nom(cinb);

ratio_E13_m25.(['nominal_albedo_filter',num2str(f)]) = (1./(Io_E13./Nom_E13)).*...
   m25.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(bine) ./ ...
   down_E13_nom(einb);

% ratio_nim_m25.(['nominal_albedo_filter',num2str(f)]) = (Io_nim./Nom_nim).*...
%    m25.vars.(['up_hemisp_narrowband_filter',num2str(f)]).data(binn) ./ ...
%    down_nim_nom(ninb);

end
%%
figure; 
plot(serial2doy(ratio_C1_m10.time),[ratio_C1_m10.albedo_filter1;ratio_C1_m10.albedo_filter2;...
ratio_C1_m10.albedo_filter3;ratio_C1_m10.albedo_filter4;ratio_C1_m10.albedo_filter5],'+');
legend('filter1','filter2','filter3','filter4','filter5')
hold('on');

% plot(serial2doy(ratio_nim_m10.time),[ratio_nim_m10.albedo_filter1;ratio_nim_m10.albedo_filter2;...
% ratio_nim_m10.albedo_filter3;ratio_nim_m10.albedo_filter4;ratio_nim_m10.albedo_filter5],'o');

plot(serial2doy(ratio_E13_m10.time),[ratio_E13_m10.albedo_filter1;ratio_E13_m10.albedo_filter2;...
   ratio_E13_m10.albedo_filter3;ratio_E13_m10.albedo_filter4;ratio_E13_m10.albedo_filter5],'k-')
title({['10 m albedos computed from Langley cals of MFRSRs'],['C1 = +, E13 = black lines']});
hold('off')
axis('auto')
%%
figure; 
plot(serial2doy(ratio_C1_m10.time),[ratio_C1_m10.nominal_albedo_filter1;...
   ratio_C1_m10.nominal_albedo_filter2;ratio_C1_m10.nominal_albedo_filter3;...
   ratio_C1_m10.nominal_albedo_filter4;ratio_C1_m10.nominal_albedo_filter5],'+');
legend('filter1','filter2','filter3','filter4','filter5')
hold('on');
% plot(serial2doy(ratio_nim_m10.time),[ratio_nim_m10.nominal_albedo_filter1;...
%    ratio_nim_m10.nominal_albedo_filter2;ratio_nim_m10.nominal_albedo_filter3;...
%    ratio_nim_m10.nominal_albedo_filter4;ratio_nim_m10.nominal_albedo_filter5],'o');

plot(serial2doy(ratio_E13_m10.time),[ratio_E13_m10.nominal_albedo_filter1;...
   ratio_E13_m10.nominal_albedo_filter2; ratio_E13_m10.nominal_albedo_filter3;...
   ratio_E13_m10.nominal_albedo_filter4;ratio_E13_m10.nominal_albedo_filter5],'k-')
title({['10 m albedos computed from nominal cals of MFRSRs'],['C1 = +, E13 = lines']});
axis(v)
hold('off')
%% 25 m
%%
figure; 
plot(serial2doy(ratio_C1_m25.time),[ratio_C1_m25.albedo_filter1;ratio_C1_m25.albedo_filter2;...
ratio_C1_m25.albedo_filter3;ratio_C1_m25.albedo_filter4;ratio_C1_m25.albedo_filter5],'+');
legend('filter1','filter2','filter3','filter4','filter5')
hold('on');

plot(serial2doy(ratio_nim_m25.time),[ratio_nim_m25.albedo_filter1;ratio_nim_m25.albedo_filter2;...
ratio_nim_m25.albedo_filter3;ratio_nim_m25.albedo_filter4;ratio_nim_m25.albedo_filter5],'o');

plot(serial2doy(ratio_E13_m25.time),[ratio_E13_m25.albedo_filter1;ratio_E13_m25.albedo_filter2;...
   ratio_E13_m25.albedo_filter3;ratio_E13_m25.albedo_filter4;ratio_E13_m25.albedo_filter5],'k-')
title({['25 m albedos computed from Langley cals of MFRSRs'],['nim = o, C1 = +, E13 = black lines']});
hold('off')
axis(v)
%%
figure; 
plot(serial2doy(ratio_C1_m25.time),[ratio_C1_m25.nominal_albedo_filter1;...
   ratio_C1_m25.nominal_albedo_filter2;ratio_C1_m25.nominal_albedo_filter3;...
   ratio_C1_m25.nominal_albedo_filter4;ratio_C1_m25.nominal_albedo_filter5],'+');
legend('filter1','filter2','filter3','filter4','filter5')
hold('on');
plot(serial2doy(ratio_nim_m25.time),[ratio_nim_m25.nominal_albedo_filter1;...
   ratio_nim_m25.nominal_albedo_filter2;ratio_nim_m25.nominal_albedo_filter3;...
   ratio_nim_m25.nominal_albedo_filter4;ratio_nim_m25.nominal_albedo_filter5],'o');

plot(serial2doy(ratio_E13_m25.time),[ratio_E13_m25.nominal_albedo_filter1;...
   ratio_E13_m25.nominal_albedo_filter2; ratio_E13_m25.nominal_albedo_filter3;...
   ratio_E13_m25.nominal_albedo_filter4;ratio_E13_m25.nominal_albedo_filter5],'-')
title({['25 m albedos computed from nominal cals of MFRSRs'],['nim = o, C1 = +, E13 = lines']});
axis(v)
hold('off')
