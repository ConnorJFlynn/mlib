%%
% Comparing absorption:

%%
psapM1 = plot_qcs;
%%
psapS1 = plot_qcs;
%%
nephdryM1 = plot_qcs;
%%
nephdryS1 = plot_qcs;
%% 
plot_qcs;
%%
nephdrySM1 = ancdownsample_nomiss(nephdryS1, 12);
plot_qcs(nephdrySM1);
%%


%%
nephrampM1 = plot_qcs;
%%
nephrampS1 = plot_qcs;
%%
[psapM1_1um, psapM1_10um] = ancsift(psapM1, psapM1.dims.time, psapM1.vars.size_cut.data >0 & psapM1.vars.size_cut.data < 2);
psapM1_10um = ancsift(psapM1_10um, psapM1_10um.dims.time, psapM1_10um.vars.size_cut.data >0 & psapM1_10um.vars.size_cut.data <12);
%%
[sinm, mins] = nearest(psapS1.time, psapM1.time);
psapSM1 = ancsift(psapS1, psapS1.dims.time, sinm);
%%
[psapSM1_1um, psapSM1_10um] = ancsift(psapSM1, psapSM1.dims.time, psapSM1.vars.size_cut.data>0 & psapSM1.vars.size_cut.data<2);
psapSM1_10um = ancsift(psapSM1_10um, psapSM1_10um.dims.time, psapSM1_10um.vars.size_cut.data>0 & psapSM1_10um.vars.size_cut.data<12);

%%
[nephdryM1_1um, nephdryM1_10um] = ancsift(nephdryM1, nephdryM1.dims.time, nephdryM1.vars.size_cut.data >0 & nephdryM1.vars.size_cut.data < 2);
nephdryM1_10um = ancsift(nephdryM1_10um, nephdryM1_10um.dims.time, nephdryM1_10um.vars.size_cut.data >0 & nephdryM1_10um.vars.size_cut.data <12);
%%
nephdrySM1 = ancdownsample_nomiss(nephdryS1,12);
[nephdryS1_1um,nephdryS1_10um] = ancsift(nephdrySM1,nephdrySM1.dims.time, nephdrySM1.vars.size_cut.data>.95&nephdrySM1.vars.size_cut.data<1.05);
nephdryS1_10um = ancsift(nephdryS1_10um, nephdryS1_10um.dims.time, nephdryS1_10um.vars.size_cut.data>9.5 & nephdryS1_10um.vars.size_cut.data < 10.5);
%%
[nephrampM1_1um, nephrampM1_10um] = ancsift(nephrampM1, nephrampM1.dims.time, nephrampM1.vars.size_cut.data > 0 & nephrampM1.vars.size_cut.data<2);
nephrampM1_10um = ancsift(nephrampM1_10um, nephrampM1_10um.dims.time, nephrampM1_10um.vars.size_cut.data > 0 & nephrampM1_10um.vars.size_cut.data<12);
%%
nephrampSM1 = ancdownsample_nomiss(nephrampS1,12);
[nephrampS1_1um,nephrampS1_10um] = ancsift(nephrampSM1,nephrampSM1.dims.time, nephrampSM1.vars.size_cut.data>.95&nephrampSM1.vars.size_cut.data<1.05);
nephrampS1_10um = ancsift(nephrampS1_10um, nephrampS1_10um.dims.time, nephrampS1_10um.vars.size_cut.data>9.5 & nephrampS1_10um.vars.size_cut.data < 10.5);
%%
%%
outdir = ['D:\case_studies\aos\naos\'];
[~,fname,~] = fileparts(psapM1.fname); outmat = [outdir,fname,'.mat'];
% psapM1
save(outmat, '-struct','psapM1');
outmat = [outdir,'psapM1_1um.mat']; save(outmat, '-struct','psapM1_1um')
outmat = [outdir,'psapM1_10um.mat']; save(outmat, '-struct','psapM1_10um')

%psapSM1
outmat = [outdir,'psapS1.mat']; save(outmat, '-struct','psapS1')
outmat = [outdir,'psapSM1.mat']; save(outmat, '-struct','psapSM1')
outmat = [outdir,'psapSM1_1um.mat']; save(outmat, '-struct','psapSM1_1um')
outmat = [outdir,'psapSM1_10um.mat']; save(outmat, '-struct','psapSM1_10um')

% nephdryM1
outmat = [outdir,'nephdryM1.mat']; save(outmat, '-struct','nephdryM1')
outmat = [outdir,'nephdryM1_1um.mat']; save(outmat, '-struct','nephdryM1_1um');
outmat = [outdir,'nephdryM1_10um.mat']; save(outmat, '-struct','nephdryM1_10um');

% nephdryS1
outmat = [outdir,'nephdryS1.mat']; save(outmat, '-struct','nephdryS1');
outmat = [outdir,'nephdrySM1.mat']; save(outmat, '-struct','nephdrySM1');
% [nephdryS1_1,nephdryS1_10]
outmat = [outdir,'nephdryS1_1um.mat']; save(outmat, '-struct','nephdryS1_1um');
outmat = [outdir,'nephdryS1_10um.mat']; save(outmat, '-struct','nephdryS1_10um');

% nephwetM1 aka nephramp
outmat = [outdir,'nephrampM1.mat']; save(outmat, '-struct','nephrampM1')
outmat = [outdir,'nephrampM1_1um.mat']; save(outmat, '-struct','nephrampM1_1um');
outmat = [outdir,'nephrampM1_10um.mat']; save(outmat, '-struct','nephrampM1_10um');

% nephwetS1 aka nephramp
outmat = [outdir,'nephrampS1.mat']; save(outmat, '-struct','nephrampS1')
outmat = [outdir,'nephrampS1_1um.mat']; save(outmat, '-struct','nephrampS1_1um');
outmat = [outdir,'nephrampS1_10um.mat']; save(outmat, '-struct','nephrampS1_10um');


%%
figure; 
ps(1) = subplot(2,1,1)
plot(serial2doy(psapM1_10um.time), psapM1_10um.vars.Ba_G_PSAP3W.data, 'g.')
%%
