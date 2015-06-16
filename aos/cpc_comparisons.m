%%
% cpc_nc = anc_bundle_files;
% [pname,fname] = fileparts(cpc_nc.fname);
% save([pname, filesep,'..',filesep,fname,'.mat'],'-struct','cpc_nc')
%%
 % root directory for this analysis: D:\dmf\data\datastream\mao

ins = anc_load;
[pname, fname, ext] = fileparts(ins.fname);
pname = [pname,filesep];
files = dir([pname, 'maoaoscpcf*.cdf']);
% ins = anc_downsample_nomiss(ins, 60,'time');

for f = 2:length(files)
    disp([files(f).name])
    ins_ = anc_load([pname, files(f).name]);
%     ins_ = anc_downsample_nomiss(ins_, 60,'time');
    ins = anc_cat(ins, ins_);
    disp([num2str(f),' of ',num2str(length(files))])
end

%%
% save([pname,'..',filesep,fname,'.mat'],'-struct','ins');

%%
% fname = getfullname(['D:\dmf\data\datastream\mao\*.mat']);
cpc.fname = 'D:\dmf\data\datastream\mao\maoaoscpcM1.a1.20131211.143743.mat';
cpcf.fname = 'D:\dmf\data\datastream\mao\maoaoscpcfS1.a1.20140122.140927.mat';
cpcu.fname = 'D:\dmf\data\datastream\mao\maoaoscpcuS1.a1.20140122.135422.mat';
cpc = load(cpc.fname);
cpcf = load(cpcf.fname);
cpcu = load(cpcu.fname);


miss = (cpc.vdata.concentration <=0)|isNaN(cpc.vdata.concentration);
cpc = anc_sift(cpc,~miss);
miss = (cpcf.vdata.concentration <=0)|isNaN(cpcf.vdata.concentration);
cpcf = anc_sift(cpcf, ~miss);
miss = (cpcu.vdata.concentration <=0)|isNaN(cpcu.vdata.concentration);
cpcu = anc_sift(cpcu, ~miss);
[ainf, fina] =nearest(cpc.time, cpcf.time);
[ainu, uina] = nearest(cpc.time, cpcu.time);
[finu, uinf] = nearest(cpcf.time, cpcu.time);

cpc_ainf = anc_sift(cpc, ainf);
cpcf_fina = anc_sift(cpcf, fina);
cpc_ainu = anc_sift(cpc, ainu);
cpcu_uina = anc_sift(cpcu, uina);

[c_finu, c_unif] =nearest(cpc_ainf.time, cpc_ainu.time);
cpc_ = anc_sift(cpc_ainf, c_finu);
cpcf_ = anc_sift(cpcf_fina, c_finu);
cpcu_ = anc_sift(cpcu_uina, c_unif);

figure; s(1) = subplot(2,1,1); 
plot(cpc_.time, cpc_.vdata.concentration, 'r.', cpc_.time, cpcf_.vdata.concentration, 'b.'); 
dynamicDateTicks; legend('cpc','cpc f');
logy;
ylabel('N');
title({'CPC 3772 and CPC 3010 concentrations';['MAO M1 and S1: ',datestr(cpc_.time(1), 'yyyy-mm-dd')]});
s(2) = subplot(2,1,2);
cpc_mean = (cpc_.vdata.concentration + cpcf_.vdata.concentration)./2;
plot(cpc_.time, 100.*(cpc_.vdata.concentration./(cpc_mean)-1), 'k.', [min(cpc_.time),max(cpc_.time)],[0,0],'r--'); 
dynamicDateTicks;
title('CPC 3010 - CPC 3772');
ylabel('%diff');
xlabel('time');

figure; s(3) = subplot(2,1,1); 
plot(cpcu_.time, cpcu_.vdata.concentration, 'r.', cpcf_.time, cpcf_.vdata.concentration, 'b.'); 
logy
dynamicDateTicks; legend('cpc u','cpc f');
ylabel('N');
title({'CPC 3772 and CPC 3776 concentrations';['MAO fine (3772) and ultrafine (3776): ',datestr(cpcf_.time(1), 'yyyy-mm-dd')]});
s(4) = subplot(2,1,2);

plot(cpc_.time, (cpcu_.vdata.concentration./cpcf_.vdata.concentration), 'k.', [min(cpc_.time),max(cpc_.time)],[1,1],'r--'); 
title('ultrafine / fine');
ylabel('ratio');
xlabel('time');
dynamicDateTicks;
linkaxes(s,'x')
%%
xl = xlim;
xl_ = cpc_.time>=xl(1) &cpc_.time<=xl(2);

maxd = max([max(cpc_.vdata.concentration(xl_)),max(cpcf_.vdata.concentration(xl_))]);
figure; plot(cpcf_.vdata.concentration(xl_), cpc_.vdata.concentration(xl_), 'o',[0,maxd],[0,maxd],'r--');axis('square');
title('CPC 3772 vs CPC 3010')
xlabel('CPC 3772 N');
ylabel('CPC 3010 N');

maxd = max([maxd,max(cpcu_.vdata.concentration(xl_))]);
figure; plot(cpcu_.vdata.concentration(xl_), cpcf_.vdata.concentration(xl_), 'o',[0,maxd],[0,maxd],'r--');axis('square');
title('CPC 3772 vs CPC 3776')
xlabel('CPC 3772 N');
ylabel('CPC 3776 N');


%% cpc output for Anne
V = datevec(cpcf_.time);

text_out = [V(:,1:5),cpcf_.vdata.concentration'];
[pname, fname] = fileparts(cpcf_.fname);
[toc1, rest] = strtok(fname, '.');
toc2 = strtok(rest,'.');
out_file = [pname, filesep,'..',filesep,toc1,'.',toc2,'.txt'];
fout = fopen(out_file,'w+');
fprintf(fout,'%s \n', 'year, month, day, hour, minute, concentration');
fprintf(fout, '%d, %d, %d, %d, %d, %g \n',text_out');
fclose(fout);

out_nc = [pname, filesep,'..',filesep,toc1,'.',toc2,'.nc'];
anc_save(cpc_, out_nc)


% 
% 
% 
% cpcS1 = load(['D:\case_studies\aos\naos\pvcaoscpcfS1.a1\pvcaoscpcfS1.a1.20120624.164103.mat']);
% cpcM1 = ancbundle_files;
% %
% bad = cpcM1.vars.concentration.data > -100  & cpcM1.vars.concentration.data < 1e5;
% [cpcM1, ~] = ancsift(cpcM1, cpcM1.dims.time, bad);
% 
% bad = cpcS1.vars.concentration.data > -100  & cpcS1.vars.concentration.data < 1e5;
% [cpcS1, ~] = ancsift(cpcS1, cpcS1.dims.time, bad);
% 
% 
% [ainb, bina] = nearest(cpcM1.time, cpcS1.time);
% 
% %%
% figure;plot(serial2doys(cpcM1.time), cpcM1.vars.concentration.data, 'g.', serial2doys(cpcS1.time), cpcS1.vars.concentration.data,'r.');
% legend('AMF1','MAOS')
% 
% %%
% figure; plot(cpcM1.vars.concentration.data(ainb), cpcS1.vars.concentration.data(bina),'k.');
% %%
% figure; scatter(cpcM1.vars.concentration.data, cpcS1.vars.concentration.data,8,serial2doys(cpcM1.time));
% title('Comparison of uncorrected CPC concentrations at PVC')
% axis('square');
% hold('on'); plot([0,2e4],[0,2e4],'g-',[0,2e4],[0,2e4],'r:');
% %
% xlabel('M1 CPC concentration'); ylabel('S1 CPCconcentration');cb = colorbar;
% xlim([0,1.55e4]); ylim([0,1.55e4]);
% set(get(cb,'title'),'string',{'days since' ;'Jan 1 2012'})
% %%
% cpcM1_ = ancsift(cpcM1, cpcM1.dims.time,ainb);
% cpcS1_ = ancsift(cpcS1,cpcS1.dims.time,bina);
% %%
% cpcM1 = load(['D:\case_studies\aos\naos\pvcaoscpcM1.a1\pvcaoscpcM1.a1.20120717.000000.mat']);
% cpcS1 = load(['D:\case_studies\aos\naos\pvcaoscpcfS1.a1\pvcaoscpcfS1.a1.20120624.164103.mat']);
% %%
% figure; ax(1) = subplot(2,1,2); plot((cpcM1.time), cpcS1.vars.concentration.data./cpcM1.vars.concentration.data, 'k.') ;
% legend('MAOS / AMF1 CPC');
% xlabel('days since Jan 1, 2012')
% ylim([0,5]);
% ax(2) = subplot(2,1,1); plot((cpcM1.time), cpcM1.vars.concentration.data, 'b.', (cpcS1.time), cpcS1.vars.concentration.data,'r.');
% legend('AMF1','MAOS')
% ylabel('1/cc');
% 
% % plot(serial2doys(cpcM1.time), cpcS1.vars.cabinet_temp.data, '.');
% % legend('cab temp');
% % ax(3) = subplot(4,1,3); plot(serial2doys(cpcM1.time),cpcS1.vars.orifice_pressure.data,'.r-');
% % legend('orifice temp');
% % ax(4) = subplot(4,1,4); plot(serial2doys(cpcM1.time),cpcS1.vars.ambient_pressure.data,'.c-',...
% %     serial2doys(cpcM1.time),cpcS1.vars.nozzle_pressure.data.*30, 'xg-');
% % legend('amb pres','noz pres x 30');
% linkaxes(ax,'x');
% zoom('on')
% %%


