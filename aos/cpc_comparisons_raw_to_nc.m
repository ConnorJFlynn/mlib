% MAO comparison of CPC and Neph

% Read raw cpcf, cpcu, cpc
% Read netcdf cpcf, cpcu, cpc
% D:\dmf\data\datastream\mao\maoaoscpcfS1.a1\
cpcf = anc_load(getfullname('maoaoscpcf*.cdf','cpcf'));
[cpcf_tsv, fmt_str] = rd_bnl_tsv3;

cpcf_tsv.Concentration = cpcf_tsv.Concentration *(1000/970); 
[ainb, bina] = nearest(cpcf.time, cpcf_tsv.time);

figure; plot(cpcf.time(ainb), cpcf.vdata.concentration(ainb), 'x',cpcf_tsv.time(bina), cpcf_tsv.Concentration(bina),'o');
dynamicDateTicks;

%% Now check NOAA AOS CPC
cpc_noaa = rd_noaa_cpc;
cpc_nc = anc_load;
[ainb, bina] = nearest(cpc_noaa.time, cpc_nc.time);
figure; plot(cpc_noaa.time(ainb), cpc_noaa.conc(ainb), 'o' ,cpc_nc.time(bina), cpc_nc.vdata.concentration(bina),'x');dynamicDateTicks
figure; plot(cpc_noaa.time(ainb), cpc_noaa.conc(ainb)-cpc_nc.vdata.concentration(bina),'ro')
%%

[neph_dry_bnl,in_str] = rd_bnl_tsv3;
figure; ax(1) = subplot(2,1,1);plot(neph_dry_bnl.time, neph_dry_bnl.Blue_T, 'b.'); dynamicDateTicks
ax(2) = subplot(2,1,2);plot(neph_dry_bnl.time, neph_dry_bnl.BaroPress, 'b.'); dynamicDateTicks
linkaxes(ax,'x');

neph_dry = anc_load;
[ainb_, bina_] = nearest(neph_dry_bnl.time, neph_dry.time);
figure; plot(neph_dry_bnl.time(ainb_), neph_dry_bnl.BaroPress(ainb_), 'o',neph_dry.time(bina_), neph_dry.vdata.P_Neph_Dry(bina_),'x')
figure; plot(neph_dry_bnl.time(ainb_), neph_dry_bnl.Blue_T(ainb_), 'o',neph_dry.time(bina_), neph_dry.vdata.P_Neph_Dry(bina_),'x')

figure; 
s(1) = subplot(3,1,1); 
plot(neph_dry.time, neph_dry.vdata.Bs_B_Dry_Neph3W_1, 'b.',neph_dry_bnl.time(ainb_), 1e6.*neph_dry_bnl.Blue_T(ainb_),'ro'); dynamicDateTicks;
s(2) = subplot(3,1,2); 
plot(neph_dry.time, neph_dry.vdata.P_Neph_Dry, '-k.');dynamicDateTicks;
s(3) = subplot(3,1,3); 
plot(neph_dry.time, neph_dry.vdata.impactor_setting, '-r.');dynamicDateTicks;
linkaxes(s,'x');
zoom('on')


% Longer time series below

cpc_nc = load(['D:\case_studies\aos\mao\maoaoscpcM1.a1\maoaoscpcM1.mat']);
cpcf_nc = load(['D:\case_studies\aos\mao\maoaoscpcfS1.00\maoaoscpcfS1.mat']);
cpcu_nc = load(['D:\case_studies\aos\mao\maoaoscpcuS1.00\maoaoscpcuS1.mat']);


cpcf_down = ancdownsample_nomiss(cpcf_nc,60);
cpcu_down = ancdownsample_nomiss(cpcu_nc,60);
figure; 
semilogy(cpcu_down.time, cpcu_down.vars.concentration.data, '.',cpcf_down.time, cpcf_down.vars.concentration.data, '.',cpc_nc.time, 1.33.*cpc_nc.vars.concentration.data,'.'); dynamicDateTicks; zoom('on'); legend('cpc-u 3776','cpc-f 3772','cpc 3010')
s(2) = subplot(2,1,2);
semilogy(cpcu_down.time, cpcu_down.vars.concentration.data, '.',cpcf_down.time, cpcf_down.vars.concentration.data, '.',cpc_nc.time, 1.33.*cpc_nc.vars.concentration.data,'.'); dynamicDateTicks; zoom('on'); legend('cpc-u 3776','cpc-f 3772','cpc 3010')
