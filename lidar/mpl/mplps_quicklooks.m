function status = mplps_quicklooks(mplps,  outdir , options)
%status = mplps_quicklooks(mplps, output, outdir, fname)
%if 'options' is provided it must be a string exactly as matlab print
%function expects. 
if nargin==1
   outdir = [];
   options = []; 
   out_ext = [];
else
   if nargin==2
      options = ['-dpng'];
      out_ext = 'png';
   else
      if findstr(options, 'png')
         out_ext = 'png';
      elseif findstr(options, 'meta')
         out_ext = 'xmf';
      elseif findstr(options, 'jpeg')
         out_ext = 'jpeg';
      end;
   end
   %construct output file name with outdir, time, and output format
   ds_name_stem = strtok(mplps.statics.datastream, '.');
   begin_date = floor(mplps.time(1));
   begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
   ds_name = [outdir, ds_name_stem, '.', begin_datestr, '.'];
end;
figure(99);
bot = [.4, .4, .4];
top = [1,1,1];
jet_bt = colormap([bot; jet; top]);
% bot = [.2,.2,.5];
% top = [1,.5,.5];
%bone_bt = colormap([bot; gray; top]);
close(99);
pause(.1);

figure(99); set(gcf,'windowstyle','docked')
ax99(1) = subplot(2,1,1);
imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.copol.prof))); 
axis('xy'); 
colormap(jet_bt); 
colorbar
ylabel('range (km AGL)');
title(['MPL-PS Log(Co-Polarized Backscatter): ', datestr(mplps.time(1),1)]);
axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 12 caxis -3 2]);

ax99(2) = subplot(2,1,2);
imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.crosspol.prof))); 
axis('xy'); 
colormap(jet_bt); 
colorbar
xlabel('time (UTC)');
ylabel('range (km)');
title(['Log(Cross-Polarized Backscatter): ', datestr(mplps.time(1),1)]);
axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 12 caxis -3 2]);
linkaxes(ax99,'xy')
file_label = 'bi-bscat.0_12km.';
if ~isempty(out_ext)
   fn = [ds_name, file_label, out_ext];
   print( gcf, [options], fn );
   saveas(gcf,[ds_name, 'bscat.fig'],'fig');
end

figure(100);set(gcf,'windowstyle','docked')
ax100(1)=subplot(2,1,1);
%imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.dpr).*mplps.good)); 
imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.dpr).*mplps.good)+mplps.good -1); 
axis('xy'); zoom; colormap(jet_bt); 
ylabel('range (km)');
title(['MPL-PS depolarization ratio: ', datestr(mplps.time(1),1)]);
cv = caxis;
axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 12 cv -.2 1]); 
caxis([0,1]);
colorbar

ax100(2)=subplot(2,1,2);
imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.dpr.*mplps.good))); 
title(['Log(depolarization ratio): ', datestr(mplps.time(1),1)]);
axis('xy'); zoom; colormap(jet_bt); 
xlabel('time (UTC)');
ylabel('range (km)');

axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 12 caxis -4 0]); 
caxis([-2,0]);
colorbar
linkaxes(ax100,'xy')
file_label = 'bi-dpr.0_12km.';
if ~isempty(out_ext)
   fn = [ds_name, file_label, out_ext];
   print( gcf, [options], fn );
   saveas(gcf,[ds_name, 'dpr.fig'],'fig');
end

figure(99); 
ylim([0,6])
% subplot(2,1,1);
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.copol.prof))); 
% axis('xy'); 
% colormap(jet_bt); 
% colorbar
% ylabel('range (km)');
% title(['MPL-PS Log(Co-Polarized Backscatter): ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 6 caxis -3 2]);
% 
% subplot(2,1,2);
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.crosspol.prof))); 
% axis('xy'); 
% colormap(jet_bt); 
% colorbar
% xlabel('time (UTC)');
% ylabel('range (km)');
% title(['Log(Cross-Polarized Backscatter): ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 6 caxis -3 2]);

file_label = 'bi-bscat.0_6km.';
if ~isempty(out_ext)
   fn = [ds_name, file_label, out_ext];
   print( gcf, [options], fn );
end

figure(100);
ylim([0,6]);
% subplot(2,1,1);
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.dpr).*mplps.good)+mplps.good -1); 
% axis('xy'); zoom; colormap(jet_bt); 
% ylabel('range (km)');
% title(['MPL-PS depolarization ratio: ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 6 caxis -.02 1]); 
% colorbar
% 
% subplot(2,1,2);
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.dpr.*mplps.good))); 
% title(['Log(depolarization ratio): ', datestr(mplps.time(1),1)]);
% axis('xy'); zoom; colormap(jet_bt); 
% xlabel('time (UTC)');
% ylabel('range (km)');
% 
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 6 caxis -4 0]); 
% colorbar

file_label = 'bi-dpr.0_6km.';
if ~isempty(out_ext)
   fn = [ds_name, file_label, out_ext];
   print( gcf, [options], fn );
end

figure(99); 
ylim([0,3]);
% subplot(2,1,1);
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.copol.prof))); 
% axis('xy'); 
% colormap(jet_bt); 
% colorbar
% ylabel('range (km)');
% title(['MPL-PS Log(Co-Polarized Backscatter): ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 3 caxis -3 2]);
% 
% subplot(2,1,2);
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.crosspol.prof))); 
% axis('xy'); 
% colormap(jet_bt); 
% colorbar
% xlabel('time (UTC)');
% ylabel('range (km)');
% title(['MPL-PS Log(Cross-Polarized Backscatter): ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 3 caxis -3 2]);

file_label = 'bi-bscat.0_3km.';
if ~isempty(out_ext)
   fn = [ds_name, file_label, out_ext];
   print( gcf, [options], fn );
end

figure(100);
ylim([0,3]);
% subplot(2,1,1);
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.dpr).*mplps.good)+mplps.good -1); 
% axis('xy'); zoom; colormap(jet_bt); 
% ylabel('range (km)');
% title(['MPL-PS depolarization ratio: ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 3 caxis -.02 1]); 
% colorbar
% 
% subplot(2,1,2);
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.dpr.*mplps.good))); 
% title(['Log(depolarization ratio): ', datestr(mplps.time(1),1)]);
% axis('xy'); zoom; colormap(jet_bt); 
% xlabel('time (UTC)');
% ylabel('range (km)');
% 
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 3 caxis -4 0]); 
% colorbar

file_label = 'bi-dpr.0_3km.';
if ~isempty(out_ext)
   fn = [ds_name, file_label, out_ext];
   print( gcf, [options], fn );
end

% colorbar


% figure(1); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.prof))); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['Range-corrected Attenuated Backscatter: ', datestr(mplps.time(1),1)]);
% %text(5,13, 'no overlap correction applied')
% axis([0 24 0 15 0 1 0 4]);
% 
% file_label = 'bscat_range_corrected.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
   
% 
% figure(2); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.cts))); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['log_1_0 of Attenuated Backscatter: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 -3 1]); 
% colorbar
% file_label = 'combined_cts_log.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
% 
% figure(3); 
% % imagesc(serial2Hh([mplps.time ]), mplps.range,
% % real(log10(mplps.copol.prof.*mplps.good))); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.copol.prof))); 
% axis('xy'); zoom; colormap(jet_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['Co-Polarized Backscatter (log arbitrary units): ', datestr(mplps.time(1),1)]);
% %text(5,13, 'no overlap correction applied')
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 5 0 1 -3 2]);
% file_label = 'copol_range_corrected.0_5km.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% end
% 
% 
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 15 0 1 -3 2]);
% % colorbar
% 
% file_label = 'copol_range_corrected.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% end
% if ~isempty(out_ext)
%    close(gcf);
% end
% 
%    
% figure(4); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.crosspol.prof.*mplps.good))); 
% axis('xy'); zoom; colormap(jet_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['Cross-Polarized Backscatter (arbitrary units): ', datestr(mplps.time(1),1)]);
% %text(5,13, 'no overlap correction applied')
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 5 0 1 -3 2]);
% 
% file_label = 'crosspol_range_corrected.0_5km.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% 
% end
% 
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 15 0 1 -3 2]);
% 
% % colorbar
% file_label = 'crosspol_range_corrected.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% 
% end
% if ~isempty(out_ext)
%    close(gcf);
% end
   

% figure(5); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.copol.sample_std./mplps.copol.sample_noise))); 
% axis('xy'); zoom; colormap(bone_bt
% ylabel('range (km)');
% title(['copol sample stability: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 0 3]); 
% colorbar
% file_label = 'copol_stability.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end

% figure(6); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.copol.sample_std./mplps.copol.sample_noise))); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['log_1_0 copol sample stability: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 -1 1]); 
% colorbar
% file_label = 'copol_stability_log.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end

% figure(7); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.crosspol.sample_std./mplps.crosspol.sample_noise))); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['crosspol sample stability: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 0 3]); 
% colorbar
% file_label = 'crosspol_stability.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end

% figure(8); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.crosspol.sample_std./mplps.crosspol.sample_noise))); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['log_1_0 crosspol sample stability: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 -1 1]);; 
% colorbar
% file_label = 'crosspol_stability_log.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
% 
% figure(9); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.sample_stability))); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['total (combined) sample stability: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 0 3]); 
% colorbar
% file_label = 'stability.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
% 
% figure(10); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.sample_stability))); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['log_1_0 relative sample stability ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 -1 1]); 
% %colorbar
% file_label = 'stability_log.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
% 
% figure(11); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.dpr).*mplps.good)+mplps.good -1); 
% axis('xy'); zoom; colormap(jet_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['depolarization ratio: ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 5 0 1 -.02 1]); 
% colorbar
% file_label = 'dpr.0_5km.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% 
% end
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 15 0 1 -.02 1]); 
% colorbar
% file_label = 'dpr.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    
% end
% 
% if ~isempty(out_ext)
%    close(gcf);
% end
% 
% 
% figure(12); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.dpr.*mplps.good))); 
% axis('xy'); zoom; colormap(jet_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['log_1_0 of depolarization ratio: ', datestr(mplps.time(1),1)]);
% 
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 5 0 1 -4 0]); 
% colorbar
% file_label = 'dpr_log.0_5km.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% end
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 15 0 1 -4 0]); 
% colorbar
% file_label = 'dpr_log.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% end
% 
% if ~isempty(out_ext)
%    close(gcf);
% end


% figure(14); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.ldpr).*mplps.good)+mplps.good -1); 
% axis('xy'); zoom; colormap(bone_bt); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['linear depolarization ratio: ', datestr(mplps.time(1),1)]);
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 15])
% %axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 15 0 1 -.02 1]); 
% % colorbar
% file_label = 'ldpr.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    
% end
% axis([floor(serial2Hh(mplps.time(1))) ceil(serial2Hh(max(mplps.time))) 0 5 0 1 -.02 1]); 
% % colorbar
% file_label = 'ldpr.0_5km.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
% 
% end
% if ~isempty(out_ext)
%    close(gcf);
% end


status = 1;
return
