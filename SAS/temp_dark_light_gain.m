% SAS kooltron, temp, darks, lights, gain
%%
if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\0911137U1.mat','file')
vis = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\0911137U1.mat');
else
if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911137U1.mat','file')
   vis = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911137U1.mat');
else
vis = SAS_read_ava(['C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911137U1.csv']);
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911137U1.mat','vis');
end
if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911137U1.mat','file')
   vis2 = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911137U1.mat');
else
vis2 = SAS_read_ava(['C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911137U1.csv']);
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911137U1.mat','vis');
end
vis.time = [vis.time; vis2.time];
vis.Integration = [vis.Integration;vis2.Integration];
vis.Averages = [vis.Averages; vis2.Averages];
vis.Shuttered_0 = [vis.Shuttered_0;vis2.Shuttered_0];
vis.Temp1 = [vis.Temp1;vis2.Temp1];
vis.Temp2 = [vis.Temp2;vis2.Temp2];
vis.Sum = [vis.Sum;vis2.Sum];
vis.spec = [vis.spec; vis2.spec];
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\0911137U1.mat','vis');
end
%%
if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\0911146U1.mat','file')
   nir = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\0911146U1.mat');
else


if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911146U1.mat','file')
   nir = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911146U1.mat');
else
nir = SAS_read_ava(['C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911146U1.csv']);
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_0911146U1.mat','nir');
end

if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911146U1.mat','file')
   nir2 = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911146U1.mat');
else
nir2 = SAS_read_ava(['C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911146U1.csv']);
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_0911146U1.mat','vis');
end
nir.time = [nir.time; nir2.time];
nir.Integration = [nir.Integration;nir2.Integration];
nir.Averages = [nir.Averages; nir2.Averages];
nir.Shuttered_0 = [nir.Shuttered_0;nir2.Shuttered_0];
nir.Temp1 = [nir.Temp1;nir2.Temp1];
nir.Temp2 = [nir.Temp2;nir2.Temp2];
nir.Sum = [nir.Sum;nir2.Sum];
nir.spec = [nir.spec; nir2.spec];
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\0911146U1.mat','nir');
end

%%

%%
if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\T_RH.mat','file')
   trh = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\T_RH.mat');
else
if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_T_RH.mat','file')
   trh = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_T_RH.mat');
else
trh = SAS_read_trh(['C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_T_RH.csv']);
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100429_T_RH.mat','trh');
end;
if exist('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_T_RH.mat','file')
   trh2 = loadinto('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_T_RH.mat');
else
trh2 = SAS_read_trh(['C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_T_RH.csv']);
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\20100430_T_RH.mat','trh2');
end;
trh_fields = fieldnames(trh);
for f = 1:length(trh_fields)
  trh.(char(trh_fields{f})) = [trh.(char(trh_fields{f}));trh2.(char(trh_fields{f}))];
end
save('C:\case_studies\ARRA\SAS\data_tests\20100429GainDarksVsTemp\T_RH.mat','trh');
end

%%
figure; ax(1) = subplot(2,1,1); plot(serial2doy(trh.time), [trh.Temp1,trh.Temp2],'-');
legend('ambient','cooler');
title('Ambient and internal temperatures');
ax(2) = subplot(2,1,2);
plot(serial2doy(trh.time), [trh.RH1,trh.RH2],'-');
title('Ambient and internal RH');

linkaxes(ax,'x')

%%
figure; plot(serial2doy(vis.time), [vis.Temp1,vis.Temp2],'-',...
   serial2doy(nir.time), [nir.Temp1,nir.Temp2],'.',...
   serial2doy(trh.time), trh.Temp2,'k.');
legend('vis 1','vis 2','nir 1','nir 2','T internal');

%%
vis_dark = NaN(size(vis.spec));
vis_nm = vis.nm>=360&vis.nm<=1100;
vis_dark(vis.Shuttered_0==0,:) = vis.spec(vis.Shuttered_0==0,:);
for nm = find(vis_nm);
   vis_dark(vis.Shuttered_0==1,nm) = interp1(vis.time(vis.Shuttered_0==0),vis.spec(vis.Shuttered_0==0,nm),vis.time(vis.Shuttered_0==1),'linear','extrap');
end
nir_dark = NaN(size(nir.spec));
nir_nm = nir.nm>=1000&nir.nm<=1700;
nir_dark(nir.Shuttered_0==0,:) = nir.spec(nir.Shuttered_0==0,:);
for nm = find(nir_nm);
   nir_dark(nir.Shuttered_0==1,nm) = interp1(nir.time(nir.Shuttered_0==0),nir.spec(nir.Shuttered_0==0,nm),nir.time(nir.Shuttered_0==1),'linear','extrap');
end


%%
% figure; 
% as(1) = subplot(2,1,1);
% imagesc(serial2doy(vis.time(vis.Shuttered_0==0))',vis.nm(vis_nm), vis_dark(vis.Shuttered_0==0,vis_nm)');colorbar; axis('xy');
% title('measured darks');
% cv = caxis;
% as(2) = subplot(2,1,2);
% imagesc(serial2doy(vis.time(vis.Shuttered_0==1))',vis.nm(vis_nm), vis_dark(vis.Shuttered_0==1,vis_nm)');colorbar; axis('xy');
% title('interp darks');
% caxis(cv);
% linkaxes(as,'xy');
% zoom('on')
%%
figure; 
as(1) = subplot(2,1,1);
imagesc(serial2doy(vis.time(vis.Shuttered_0==0))',vis.nm(vis_nm), vis.spec(vis.Shuttered_0==1,vis_nm)');colorbar; axis('xy');
title('no dark subtraction')
as(2) = subplot(2,1,2);
imagesc(serial2doy(vis.time(vis.Shuttered_0==1))',vis.nm(vis_nm), (vis.spec(vis.Shuttered_0==1,vis_nm)-vis_dark(vis.Shuttered_0==1,vis_nm))');colorbar; axis('xy');
title('dark subtracted');
linkaxes(as,'xy');
zoom('on')
%%
figure; 
as(1) = subplot(2,1,1);
imagesc(serial2doy(nir.time(nir.Shuttered_0==0))',nir.nm(nir_nm), nir.spec(nir.Shuttered_0==1,nir_nm)');colorbar; axis('xy');
title('no dark subtraction')
as(2) = subplot(2,1,2);
imagesc(serial2doy(nir.time(nir.Shuttered_0==1))',nir.nm(nir_nm), (nir.spec(nir.Shuttered_0==1,nir_nm)-nir_dark(nir.Shuttered_0==1,nir_nm))');colorbar; axis('xy');
title('dark subtracted');
linkaxes(as,'xy');
zoom('on')
%%
figure; 
as(1) = subplot(2,1,1);
lines = semilogy(vis.nm(vis_nm), (vis.spec(vis.Shuttered_0==1,vis_nm)-vis_dark(vis.Shuttered_0==1,vis_nm))');colorbar;
lines = recolor(lines,serial2doy(vis.time(vis.Shuttered_0==1))');
as(2) = subplot(2,1,2);
lines = semilogy(vis.nm(vis_nm), (vis.spec(vis.Shuttered_0==1,vis_nm))');colorbar;
lines = recolor(lines,serial2doy(vis.time(vis.Shuttered_0==1))');
linkaxes(as,'xy');
zoom('on');
%%
figure; 
as(1) = subplot(2,1,1);
lines = semilogy(nir.nm(nir_nm), (nir.spec(nir.Shuttered_0==1,nir_nm)-nir_dark(nir.Shuttered_0==1,nir_nm))');colorbar;
lines = recolor(lines,serial2doy(nir.time(nir.Shuttered_0==1))');
as(2) = subplot(2,1,2);
lines = semilogy(nir.nm(nir_nm), (nir.spec(nir.Shuttered_0==1,nir_nm))');colorbar;
lines = recolor(lines,serial2doy(nir.time(nir.Shuttered_0==1))');
linkaxes(as,'xy');
zoom('on');
%%
figure; axx(1) = subplot(4,1,1);
plot(serial2doy(vis.time(vis.Shuttered_0==0)), vis.Sum(vis.Shuttered_0==0), '.');
legend('vis, dark')
axx(2) = subplot(4,1,2); plot(serial2doy(nir.time(nir.Shuttered_0==0)), nir.Sum(nir.Shuttered_0==0),'x');
legend('nir, dark')
axx(3) = subplot(4,1,3);
plot(serial2doy(vis.time(vis.Shuttered_0==1)), vis.Sum(vis.Shuttered_0==1), '.');
legend('vis, light')
axx(4) = subplot(4,1,4); plot(serial2doy(nir.time(nir.Shuttered_0==1)), nir.Sum(nir.Shuttered_0==1),'x');
legend('nir','light');
linkaxes(axx,'x');

%%

%%
vis_ii = find((vis.nm>=350)& (vis.nm<=1050));
vis_nm = vis.nm(vis.nm>=350 & vis.nm<=1050);
nir_ii = find((nir.nm>=950 & nir.nm<=1700));
nir_nm = nir.nm(nir.nm>=950 & nir.nm<=1700);
vis_pix = [vis_ii',vis_nm'];
nir_pix = [nir_ii',nir_nm'];
%%
vis_fid = fopen('C:\case_studies\ARRA\SAS\optics\spectrometers\Avantes\CCD_SN37_pixel_map.txt','w');
fprintf(vis_fid,'%s \n',['Pixel_Number, nm']);
fprintf(vis_fid,'%d, %4.2f \n',vis_pix');
fclose(vis_fid);

nir_fid = fopen('C:\case_studies\ARRA\SAS\optics\spectrometers\Avantes\InGaAs_SN46_pixel_map.txt','w');
fprintf(nir_fid,'%s \n',['Pixel_Number, nm']);
fprintf(nir_fid,'%d, %4.2f \n',nir_pix');
fclose(nir_fid);