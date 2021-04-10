function temp_dark_light_gain
% SAS kooltron, temp, darks, lights, gain
% Concatenationg consecutive 2-day measurement into 1 file wtih vis and vis2
% But better off 
% C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp
%%
if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\0911137U1.mat')
   vis = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\0911137U1.mat');
else
   if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_0911137U1.mat')
      vis = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_0911137U1.mat');
   else
      vis = SAS_read_Albert_csv(['20100429_0911137U1.csv']);
      save([vis.pname, strrep(vis.fname{:},'.csv','.mat')],'-struct','vis');
   end
   if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_0911137U1.mat')
      vis2 = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_0911137U1.mat');
   else
      vis2 = SAS_read_Albert_csv(['20100430_0911137U1.csv']);
      save([vis2.pname, strrep(vis2.fname{:},'.csv','.mat')],'-struct','vis2');
      % save('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_0911137U1.mat','vis');
   end
   vis.time = [vis.time; vis2.time];
   vis.Integration = [vis.Integration;vis2.Integration];
   vis.Averages = [vis.Averages; vis2.Averages];
   vis.Shuttered_0 = [vis.Shuttered_0;vis2.Shuttered_0];
   vis.Temp1 = [vis.Temp1;vis2.Temp1];
   vis.Temp2 = [vis.Temp2;vis2.Temp2];
   vis.Sum = [vis.Sum;vis2.Sum];
   vis.spec = [vis.spec; vis2.spec];
   save(['C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\','0911137U1.mat'],'-struct','vis');
end
%%
if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\0911146U1.mat')
   nir = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\0911146U1.mat');
else
   
   if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_0911146U1.mat')
      nir = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_0911146U1.mat');
   else
      nir = SAS_read_Albert_csv(['20100429_0911146U1.csv']);
      save([nir.pname, strrep(nir.fname{:},'.csv','.mat')],'-struct','nir');
   end
   
   if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_0911146U1.mat')
      nir2 = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_0911146U1.mat');
   else
      nir2 = SAS_read_Albert_csv(['20100430_0911146U1.csv']);
      % save('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_0911146U1.mat','vis');
      save([nir2.pname, strrep(nir2.fname{:},'.csv','.mat')],'-struct','nir2');
   end
   nir.time = [nir.time; nir2.time];
   nir.Integration = [nir.Integration;nir2.Integration];
   nir.Averages = [nir.Averages; nir2.Averages];
   nir.Shuttered_0 = [nir.Shuttered_0;nir2.Shuttered_0];
   nir.Temp1 = [nir.Temp1;nir2.Temp1];
   nir.Temp2 = [nir.Temp2;nir2.Temp2];
   nir.Sum = [nir.Sum;nir2.Sum];
   nir.spec = [nir.spec; nir2.spec];
   save(['C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\','0911146U1.mat'],'-struct','nir');
end

%%

%%
if isafile(['C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\','T_RH.mat'])
   trh = loadinto(['C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\','T_RH.mat']);
else
   if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_T_RH.mat')
      trh = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_T_RH.mat');
   else
      trh = SAS_read_trh(['C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_T_RH.csv']);
      save('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100429_T_RH.mat','-struct','trh');
   end;
   if isafile('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_T_RH.mat')
      trh2 = loadinto('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_T_RH.mat');
   else
      trh2 = SAS_read_trh(['C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_T_RH.csv']);
      save('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\20100430_T_RH.mat','-struct','trh2');
   end;
   trh_fields = fieldnames(trh);
   for f = 1:length(trh_fields)
      trh.(char(trh_fields{f})) = [trh.(char(trh_fields{f}));trh2.(char(trh_fields{f}))];
   end
%    save('C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\T_RH.mat','-struct','trh');
   save(['C:\case_studies\sas\testing_and_characterization\temp_tests\20100429GainDarksVsTemp\','T_RH.mat'],'-struct','trh')
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
% figure; plot(serial2doy(vis.time), [vis.Temp1,vis.Temp2],'-',...
%    serial2doy(nir.time), [nir.Temp1,nir.Temp2],'.',...
%    serial2doy(trh.time), trh.Temp2,'k.');
% legend('vis 1','vis 2','nir 1','nir 2','T internal');

%%
vis.spec(:,703) = (vis.spec(:,702) +vis.spec(:,704))./2;
vis.spec(:,end) = NaN;
vis_dark = NaN(size(vis.spec));
vis_nm = vis.nm>=360&vis.nm<=1100;
vis_dark(vis.Shuttered_0==0,:) = vis.spec(vis.Shuttered_0==0,:);
for nm = find(vis_nm);
   vis_dark(vis.Shuttered_0==1,nm) = interp1(vis.time(vis.Shuttered_0==0),vis.spec(vis.Shuttered_0==0,nm),vis.time(vis.Shuttered_0==1),'linear','extrap');
end
nir.spec(:,end) = NaN;
nir_dark = NaN(size(nir.spec));
nir_nm = nir.nm>=890&nir.nm<=1800;
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
vis_shut_1 = find(vis.Shuttered_0==1); vis_shut_0 = find(vis.Shuttered_0==0);
figure_(3); these = plot(vis.nm(vis_nm), vis.spec(vis_shut_1(1:50:end),vis_nm)-vis_dark(vis_shut_1(1:50:end),vis_nm),'-');
recolor(these, vis.Temp2(vis_shut_1(1:50:end)));
xlim([400,1060]);
xlabel('wavelength [nm]'); 
ylabel('counts - dark');
title('Signal temperature response, UV/VIS Spectrometer');
cb = colorbar; title(cb,'\circC');
saveas(gcf,[getnamedpath('EK_figs'),'Sig_temp_resp_CCD.fig']);

nir_shut_1 = find(nir.Shuttered_0==1); nir_shut_0 = find(nir.Shuttered_0==0);
figure_(4); these = plot(nir.nm(nir_nm), nir.spec(nir_shut_1(1:50:end),nir_nm)- nir_dark(nir_shut_1(1:50:end),nir_nm),'-');
recolor(these, nir.Temp2(nir_shut_1(1:50:end)));
xlim([950,1700]); 
xlabel('wavelength [nm]'); 
ylabel('counts - dark');
title('Signal temperature response, NIR Spectrometer');
cb = colorbar; title(cb,['\circC']); 
saveas(gcf,[getnamedpath('EK_figs'),'Sig_temp_resp_NIR.fig']);
%%
% figure;
% as(1) = subplot(2,1,1);
% imagesc(serial2doy(vis.time(vis.Shuttered_0==0))',vis.nm(vis_nm), vis.spec(vis.Shuttered_0==1,vis_nm)');colorbar; axis('xy');
% title('no dark subtraction')
% as(2) = subplot(2,1,2);
% imagesc(serial2doy(vis.time(vis.Shuttered_0==1))',vis.nm(vis_nm), (vis.spec(vis.Shuttered_0==1,vis_nm)-vis_dark(vis.Shuttered_0==1,vis_nm))');colorbar; axis('xy');
% title('dark subtracted');
% linkaxes(as,'xy');
% zoom('on')
% figure;
% as(1) = subplot(2,1,1);
% imagesc(serial2doy(nir.time(nir.Shuttered_0==0))',nir.nm(nir_nm), nir.spec(nir.Shuttered_0==1,nir_nm)');colorbar; axis('xy');
% title('no dark subtraction')
% as(2) = subplot(2,1,2);
% imagesc(serial2doy(nir.time(nir.Shuttered_0==1))',nir.nm(nir_nm), (nir.spec(nir.Shuttered_0==1,nir_nm)-nir_dark(nir.Shuttered_0==1,nir_nm))');colorbar; axis('xy');
% title('dark subtracted');
% linkaxes(as,'xy');
% zoom('on')
%%
figure_(5);
aa(1) = subplot(2,1,2);
lines = plot(vis.nm(vis_nm), (vis.spec(vis_shut_1(1:50:end),vis_nm)-vis_dark(vis_shut_1(1:50:end),vis_nm))');
ylabel('counts'); title('Signal - Dark Counts, UV/VIS spectrometer')
recolor(lines, vis.Temp2(vis_shut_1(1:50:end)));
cb = colorbar; title(cb,['\circC']); 
aa(2) = subplot(2,1,1);
lines = plot(vis.nm(vis_nm), (vis_dark(vis_shut_0(1:5:end),vis_nm))');
ylabel('counts'); title('Dark counts, UV/VIS spectrometer');
lines = recolor(lines,vis.Temp2(vis_shut_0(1:5:end)));
cb = colorbar; title(cb,['\circC']); 
linkaxes(aa,'x');
xlim([400,1060]); xlabel('wavelength [nm]'); 
zoom('on');
saveas(gcf,[getnamedpath('EK_figs'),'Light_Dark_temp_resp_VIS.fig']);
%%
figure_(6);
ab(1) = subplot(2,1,2);
lines = plot(nir.nm, (nir.spec(nir_shut_1(1:50:end),:)-nir_dark(nir_shut_1(1:50:end),:))');
ylabel('counts'); title('Dark-subtracted Signal, NIR spectrometer');
lines = recolor(lines,nir.Temp2(nir_shut_1(1:50:end)));
cb = colorbar; title(cb,'\circC')
ab(2) = subplot(2,1,1);
lines = plot(nir.nm, nir.spec(nir_shut_0(1:5:end),:)');
ylabel('counts'); title('Dark counts, NIR spectrometer');
lines = recolor(lines,nir.Temp2(nir_shut_0(1:5:end)));
cb = colorbar;title(cb,'\circC')
linkaxes(ab,'x');
xlim([950,1700]);
zoom('on');
saveas(gcf,[getnamedpath('EK_figs'),'Light_Dark_temp_resp_NIR.fig']);
%%
vis_sig = vis.spec - vis_dark; nir_sig = nir.spec - nir_dark;

for T = 25:-1:3
   dT = vis.Temp2>=T & vis.Temp2<(T+1);
   vis_sig_T(T-2,:) = nanmean(vis_sig(dT&vis.Shuttered_0==1,:)); 
   vis_sig_std(T-2,:) = nanstd(vis_sig(dT&vis.Shuttered_0==1,:));
   vis_dark_T(T-2,:) = nanmean(vis_dark(dT,:)); vis_dark_std(T-2,:) = nanstd(vis_dark(dT,:));
   clear dT; dT = nir.Temp2>=T & nir.Temp2<(T+1);
   nir_sig_T(T-2,:) = nanmean(nir_sig(dT&nir.Shuttered_0==1,:)); 
   nir_sig_std(T-2,:) = nanstd(nir_sig(dT&nir.Shuttered_0==1,:));
   nir_dark_T(T-2,:) = nanmean(nir_dark(dT,:)); nir_dark_std(T-2,:) = nanstd(nir_dark(dT,:));
end

vis_sig_dT = 200.*(vis_sig_T(2:end,:)-vis_sig_T(1:(end-1),:))./(vis_sig_T(2:end,:)+vis_sig_T(1:(end-1),:));
vis_dark_dT = 200.*(vis_dark_T(2:end,:)-vis_dark_T(1:(end-1),:))./(vis_dark_T(2:end,:)+vis_dark_T(1:(end-1),:));
nir_sig_dT = 200.*(nir_sig_T(2:end,:)-nir_sig_T(1:(end-1),:))./(nir_sig_T(2:end,:)+nir_sig_T(1:(end-1),:));
nir_dark_dT = 200.*(nir_dark_T(2:end,:)-nir_dark_T(1:(end-1),:))./(nir_dark_T(2:end,:)+nir_dark_T(1:(end-1),:));

figure_(7)
ac(1) = subplot(2,1,1);
lines = plot(vis.nm(vis_nm), (vis_dark(vis_shut_0(1:5:end),vis_nm))');
ylabel('counts'); title('Dark response to temperature, Si CCD');
lines = recolor(lines,vis.Temp2(vis_shut_0(1:5:end)));
cb = colorbar; title(cb,['\circC']); 
ac(2) = subplot(2,1,2);
 T_lines = plot(vis.nm, flipud(abs(vis_sig_dT)),'-'); 
 recolor(T_lines,fliplr([3:24]));
ylabel('%'); ylim([0,2]); liny;
xlabel('wavelength [nm]');
tl = title('Optical signal change per \circC, Si CCD'); set(tl,'interp','tex')
cb = colorbar; title(cb,['\circC']); ;
linkaxes(ac,'x');
xlim([400,1060]); 
zoom('on');
saveas(gcf,[getnamedpath('EK_figs'),'dark_and_signal_vs_T_SiCCD.fig']);

figure_(8); 
ad(1) = subplot(2,1,1);
lines = plot(nir.nm, nir.spec(nir_shut_0(1:5:end),:)');
ylabel('counts'); title('Dark response to temperature, InGaAs array');
lines = recolor(lines,nir.Temp2(nir_shut_0(1:5:end)));
cb = colorbar;title(cb,'\circC')
xlim([950,1700]);
ad(2) = subplot(2,1,2);
 T_lines = plot(nir.nm, flipud(abs(nir_sig_dT)),'-'); 
 recolor(T_lines,fliplr([3:24]));
ylabel('%'); ylim([0,2]); 
tl = title('Optical signal change per \circC, InGaAs array'); set(tl,'interp','tex')
cb = colorbar; title(cb,['\circC']); 
linkaxes(ad,'x'); xlim([950,1700]);
 saveas(gcf,[getnamedpath('EK_figs'),'dark_and_signal_vs_T_InGaAS.fig']);









% %%
% vis_ii = find((vis.nm>=350)& (vis.nm<=1050));
% vis_nm = vis.nm(vis.nm>=350 & vis.nm<=1050);
% nir_ii = find((nir.nm>=950 & nir.nm<=1700));
% nir_nm = nir.nm(nir.nm>=950 & nir.nm<=1700);
% vis_pix = [vis_ii',vis_nm'];
% nir_pix = [nir_ii',nir_nm'];
% %%
% vis_fid = fopen('C:\case_studies\sas\optics\spectrometers\Avantes\CCD_SN37_pixel_map.txt','w');
% fprintf(vis_fid,'%s \n',['Pixel_Number, nm']);
% fprintf(vis_fid,'%d, %4.2f \n',vis_pix');
% fclose(vis_fid);
% 
% nir_fid = fopen('C:\case_studies\sas\optics\spectrometers\Avantes\InGaAs_SN46_pixel_map.txt','w');
% fprintf(nir_fid,'%s \n',['Pixel_Number, nm']);
% fprintf(nir_fid,'%d, %4.2f \n',nir_pix');
% fclose(nir_fid);

end