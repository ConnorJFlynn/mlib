function status = plot_mpace_lidar_file(lidar, pname);
% status = plot_mpace_lidar_file(lidar, pname, fname);
% Given a PARSL MPACE lidar structure, several plots are generated and
% saved as .png files.
if nargin==0
   [fid, fname, pname] = getfile('*.nc', 'mpace');
   fclose(fid);
   ncid = ncmex('open', [pname, fname]);
   lidar = read_mpace_lidar_file(ncid);
   ncmex('close', ncid);
end
status = 0;
date_name = datestr(lidar.time(1),30);
[date_part, time_part] = strtok(date_name, 'T');
[time_part] = strtok(time_part, 'T');
date_name = [date_part, '.', time_part];


figure(99);
subplot(2,1,1);
imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_12), real(log10(lidar.copol(lidar.r.lte_12, :)))); axis('xy'); 
title(['PARSL Lidar co-polarized backscatter ', datestr(lidar.time(1),29)]);
ylabel('range (km AGL)');
v = axis;
%axis([v(1), v(2), v(3), v(4), caxis -2 2]) ;
axis([10, 20, v(3), v(4), caxis -2 2]) ;
colorbar

subplot(2,1,2);
imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_12), real(log10(lidar.depol(lidar.r.lte_12, :)))); axis('xy'); 
title(['Cross-polarized backscatter ', datestr(lidar.time(1),29)]);
xlabel('time (UTC)');
ylabel('range (km AGL)');
axis([v(1), v(2), v(3), v(4), caxis, -2, 2]) ;
axis([10, 20, v(3), v(4), caxis, -2, 2]) ;
colorbar 


status = status + 1;
print('-dpng',[pname, 'parsl_lidar.',date_name, '.bi-bscat.12km.png']);


subplot(2,1,1);
imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_12), ((lidar.dpr_masked(lidar.r.lte_12, :)))); axis('xy'); 
title(['PARSL Lidar depolarization ratio ', datestr(lidar.time(1),29)]);
ylabel('range (km AGL)');
axis([v(1), v(2), v(3), v(4), caxis, 0, 1]);
axis([10, 20, v(3), v(4), caxis,  0,1]);

colorbar

subplot(2,1,2);
imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_12), real(log10(lidar.dpr_masked(lidar.r.lte_12, :)))); axis('xy'); 
title(['Log(depolarization ratio) ', datestr(lidar.time(1),29)]);
xlabel('time (UTC)');
ylabel('range (km AGL)');
axis([v(1), v(2), v(3), v(4), caxis, -2.5, 0]);
axis([10, 20, v(3), v(4), caxis, -2.5, 0]);
colorbar

status = status + 1;
print('-dpng',[pname, 'parsl_lidar.',date_name, '.bi-dpr.12km.png']);

% 
% figure(99);
% subplot(2,1,1);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_6), real(log10(lidar.copol(lidar.r.lte_6, :)))); axis('xy'); 
% title(['PARSL Lidar co-polarized backscatter ', datestr(lidar.time(1),29)]);
% ylabel('range (km AGL)');
% v = axis;
% axis([v(1), v(2), v(3), v(4), caxis -2 2]) ;
% 
% colorbar
% 
% subplot(2,1,2);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_6), real(log10(lidar.depol(lidar.r.lte_6, :)))); axis('xy'); 
% title(['Cross-polarized backscatter ', datestr(lidar.time(1),29)]);
% ylabel('range (km AGL)');
% xlabel('time (UTC)');
% axis([v(1), v(2), v(3), v(4), caxis, -2, 2]) ;
% colorbar 
% 
% 
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.bi-bscat.6km.png']);
% 
% 
% subplot(2,1,1);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_6), ((lidar.dpr_masked(lidar.r.lte_6, :)))); axis('xy'); 
% title(['PARSL Lidar depolarization ratio ', datestr(lidar.time(1),29)]);
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), v(4), caxis, 0, 1]);
% colorbar
% 
% subplot(2,1,2);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_6), real(log10(lidar.dpr_masked(lidar.r.lte_6, :)))); axis('xy'); 
% title(['Log(depolarization ratio) ', datestr(lidar.time(1),29)]);
% xlabel('time (UTC)');
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), v(4), caxis, -2.5, 0]);
% colorbar
% 
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.bi-dpr.6km.png']);
% 
% 
% figure(99);
% subplot(2,1,1);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.copol(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar co-polarized backscatter ', datestr(lidar.time(1),29)]);
% ylabel('range (km AGL)');
% v = axis;
% axis([v(1), v(2), v(3), v(4), caxis -2 2]) ;
% colorbar
% 
% subplot(2,1,2);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.depol(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar cross-polarized backscatter ', datestr(lidar.time(1),29)]);
% ylabel('range (km AGL)');
% xlabel('time (UTC)');
% axis([v(1), v(2), v(3), v(4), caxis, -2, 2]) ;
% colorbar 
% 
% 
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.bi-bscat.3km.png']);
% 
% 
% subplot(2,1,1);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), ((lidar.dpr_masked(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar depolarization ratio ', datestr(lidar.time(1),29)]);
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), v(4), caxis, 0, 1]);
% colorbar
% 
% subplot(2,1,2);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.dpr_masked(lidar.r.lte_3, :)))); axis('xy'); 
% title(['Log(depolarization ratio) ', datestr(lidar.time(1),29)]);
% xlabel('time (UTC)');
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), v(4), caxis, -2.5, 0]);
% colorbar
% 
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.bi-dpr.3km.png']);
% 

% 
% figure(99);
% subplot(3,1,1);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.copol(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar co-polarized backscatter ', datestr(lidar.time(1),31)]);
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), 3, caxis, -2, 2]) ;
% colorbar
% 
% subplot(3,1,2);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.depol(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar cross-polarized backscatter ', datestr(lidar.time(1),31)]);
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), 3, caxis, -2, 2]) ;
% colorbar
% 
% subplot(3,1,3);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.dpr_masked(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar log_1_0(depolarization ratio) ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), 3, caxis, -2.5, 0]) ;
% colorbar
% 
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.trigraph.3km.png']);
% status = status + 1;
% figure(99);
% subplot(3,1,1);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_6), real(log10(lidar.copol(lidar.r.lte_6, :)))); axis('xy'); 
% title(['PARSL Lidar co-polarized backscatter ', datestr(lidar.time(1),31)]);
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), 6, caxis, -2, 2]) ;
% colorbar
% 
% subplot(3,1,2);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_6), real(log10(lidar.depol(lidar.r.lte_6, :)))); axis('xy'); 
% title(['PARSL Lidar cross-polarized backscatter ', datestr(lidar.time(1),31)]);
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), 6, caxis, -2, 2]) ;
% colorbar
% 
% subplot(3,1,3);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_6), real(log10(lidar.dpr_masked(lidar.r.lte_6, :)))); axis('xy'); 
% title(['PARSL Lidar log_1_0(depolarization ratio)', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (km AGL)');
% axis([v(1), v(2), v(3), 6, caxis, -2.5, 0]) ;
% colorbar
% 
% 
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.trigraph.6km.png']);

% 
% figure(101);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.copol(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar co-polarized backscatter ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (km AGL)');
% axis([axis caxis -2 2]) 
% colorbar
% zoom on
% 
% figure(102);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.depol(lidar.r.lte_3, :)))); axis('xy'); 
% title(['PARSL Lidar cross-polarized backscatter ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (km AGL)');
% axis([axis caxis -2 2]) 
% colorbar
% zoom on
% 
% figure(103);
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_3), real(log10(lidar.dpr_masked(lidar.r.lte_3, :)))); axis('xy');
% title(['PARSL Lidar log_1_0(depolarization ratio)', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (km AGL)');
% axis([axis, caxis, -2.5, 0]);  
% colorbar
% zoom on
% 
% % disp('Zoom into desired feature or range.  Hit enter when finished.')
% % pause
% region = axis;
% figure(101);
% axis([region caxis -2 2])
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.copol.3km.png']);
% 
% figure(102);
% axis([region caxis -2 2])
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.depol.3km.png']);
% 
% figure(103);
% axis([region, caxis, -2.5,0]);
% status = status + 1;
% print('-dpng',[pname, 'parsl_lidar.',date_name, '.log_dpr.3km.png']);

close('all');
% figure(11); imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_10), lidar.copol_by_power(lidar.r.lte_10, :)); axis('xy'); colorbar
% title(['PARSL Lidar copol normalized to laser power', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% axis([axis caxis 0 7.5*17]); colorbar

% figure(12); imagesc(real(log(detA))); axis('xy'); colorbar
% figure(20); imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_10), lidar.copol_snr(lidar.r.lte_10, :)); axis('xy'); colorbar
% title(['PARSL Lidar copol snr ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% axis([axis caxis 0 100]); colorbar



% figure(40); imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_10), lidar.depol_snr(lidar.r.lte_10, :)); axis('xy'); colorbar
% title(['PARSL Lidar depol snr ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% axis([axis caxis 0 100]); colorbar
% subplot(2,2,3)
% %figure(50); 
% imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_10), lidar.OCR(lidar.r.lte_10, :)); axis('xy'); colorbar
% title(['PARSL Lidar OCR ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% axis([axis caxis 0 .75]); colorbar

% figure(60); imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_10), lidar.OCR_snr(lidar.r.lte_10, :)); axis('xy'); colorbar
% title(['PARSL Lidar OCR snr ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% axis([axis caxis 0 100]); colorbar


%axis([axis caxis 0 10]); colorbar

% figure(80); imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_10), lidar.dpr_snr(lidar.r.lte_10, :)); axis('xy'); colorbar
% title(['PARSL Lidar dpr snr ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% axis([axis caxis 0 100]); colorbar
% 

% figure(90); imagesc(serial2Hh(lidar.time), lidar.range(lidar.r.lte_10), lidar.dpr_masked(lidar.r.lte_10, :)); axis('xy'); colorbar
% title(['PARSL Lidar dpr masked ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% axis([axis caxis 0 10]); colorbar
% 
% figure(100); plot(serial2Hh(lidar.time), [lidar.hk.cop_tz_bin, lidar.hk.dep_tz_bin]);
% title(['PARSL Lidar tz_bins ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% legend('copol tz bin', 'depol tz bin', 0);
% 
% figure(110); semilogy(serial2Hh(lidar.time), lidar.hk.copol_bg, 'x', serial2Hh(lidar.time), [lidar.hk.depol_bg, lidar.hk.OCR_bg], '.');
% title(['PARSL Lidar bg ', datestr(lidar.time(1),31)]);
% xlabel('time (Hh)');
% ylabel('range (meters AGl)');
% legend('copol bkgnd', 'depol bkgnd', 'OCR bkgnd', 0);
