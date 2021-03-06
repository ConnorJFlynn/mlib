function [mpl, status] = mpl_con_nor(filename)
% [mpl,status] = mpl_con_nor(filename)
% 2005-02-25: Noise calculations corrected CJF
if nargin==0
    [fid, fname, pname] = getfile('*.*', 'mpl_data');
    filename = [pname fname];
    fclose(fid);
else
   [fname, pname] = strtok(fliplr(filename),'\/');
   fname = fliplr(fname);
   pname = fliplr(pname);
end
 [mpl, status] = read_mpl(filename);
 % if mpl.statics.deadtime_corrected==1 then it's already done, so don't repeat it. 
 % if mpl.statics.datalevel==1 then output the corrected data to file
 % change the netcdf attributes and the mpl.statics fields.
 mpl.statics.filename = filename;
 if (mpl.statics.deadtime_corrected<1)
    disp('Applying deadtime correction.')
    mpl.prof = dtc_apd6850_ipa(mpl.rawcts);
    %disp('Removing rawcts.');
    %mpl = rmfield(mpl, 'rawcts');
    mpl.statics.deadtime_corrected = 1;
 else 
    ncid = ncmex('open', filename, 'write');
    prof = nc_getvar(ncid, 'detector_counts');
    ncmex('close', ncid);
    %The following step is required to re-trim prof to exclude first_bins
    [row_raw, col_raw] = size(prof);
    [rows,cols] = size(mpl.rawcts);
    mpl.prof =  (prof(row_raw-rows+1:end,col_raw-cols+1:end));
    clear prof
    %mpl = rmfield(mpl, 'rawcts');
 end %end of "if (mpl.statics.deadtime_corrected<1)"
%Calculating statistical noise
% hard-coded for 200 ns bins (30 meter resolution)
[bins, times] = size(mpl.prof);
avg_interval = min(diff(mpl.time))*24*60*60;
%noise = mpl.prof .* ((0.2 * ones([bins,1]))* (mpl.hk.pulse_rep * avg_interval));
noise = mpl.rawcts .* ((0.2 * ones([bins,1]))* (mpl.hk.pulse_rep * avg_interval));
noise = sqrt(noise); 
noise = noise ./ ((0.2 * ones([bins,1]))* (mpl.hk.pulse_rep * avg_interval));
 
 disp('Subtracting afterpulse.');
 ap = loadinto('C:\case_studies\ABE_TWPICE\twpmplC3.a1\twp_ice.ap');
 mpl.ap = interp1(ap(:,1), ap(:,2), mpl.range,'linear','extrap');
 mpl.prof = mpl.prof - mpl.ap*ones(size(mpl.time));
%  for t = times:-1:1
%     mpl.prof(:,t) = mpl.prof(:,t) - mpl.ap;
%  end;
 disp('Removing background.');
 mpl.hk.bg = mean(mpl.prof(mpl.r.bg,:));
 mpl.snr = zeros(size(mpl.prof));
 
    mpl.prof = mpl.prof - ones(size(mpl.range))*mpl.hk.bg;
    bg_noise = sqrt(mpl.hk.bg .* ((0.2) * (mpl.hk.pulse_rep * avg_interval)))./ ((0.2)* (mpl.hk.pulse_rep * avg_interval));
    bg_noise = ones(size(mpl.range))*bg_noise;
    
    low_cts = (noise< bg_noise);
    noise  = (noise .* ~low_cts) + (bg_noise.* low_cts);
 for t = times:-1:1
    pos = find((mpl.prof(:,t) > 0) & (noise(:,t) > 0));
    mpl.snr(pos,t) = mpl.prof(pos,t)./noise(pos,t);
 end;
  
 mpl.noise = noise; clear noise bg_noise 
 disp('Applying range-squared correction.');
 for t = times:-1:1
    mpl.prof(:,t) = mpl.prof(:,t).*(mpl.range.^2) ;
 end; 
%  disp('Skipping overlap correction.');
 disp('Applying overlap correction.');
ol= loadinto('C:\case_studies\ABE_TWPICE\twpmplC3.a1\ol_corr.mat');
mpl.ol = ol.corr2;
%mpl.ol = ol_renorm(mpl.ol, 1.2, 3);
 overlap_corr = mpl.ol * ones([1,times]);
 mpl.prof = mpl.prof .* overlap_corr;
disp('Applying energy normalization');
norm_baseline = smooth(serial2Hh(mpl.time), mpl.hk.energy_monitor, 200, 'loess')';
disp('Applying de-trended bin normalization.');
mpl.prof = mpl.prof./(ones([length(mpl.range),1])*norm_baseline);

%  disp('Adjusting ap correction for background.');
%  ap_r2 = mpl.ap .* mpl.range.*mpl.range;
%  norm_bg = lowess(serial2doy(mpl.time)-145, (mpl.hk.bg ./ max(mpl.hk.bg)),.01);
%  mpl.nap = mpl.nor+(ap_r2*30*norm_bg.^.5);
 % 
 if ~exist([pname, '..\images\'],'dir')
    mkdir([pname, '..\images\']);
 end
 status = quicklooks(mpl, [pname, '..\images\']); % Save images
 %status = quicklooks(mpl); % Don't save images
 
 % mean_bin2 = mean(mpl.prof(2,:));
 % norm2 =  mean_bin2 ./ mpl.prof(2,:);
 % mpl.prof = mpl.prof.*(ones([length(mpl.range),1])*norm2);
 % 
 % for b = 750:-1:1
 %    mpl.prof(b,:) = smooth_sav(mpl.prof(b,:), 5, 3);
 %    disp(['b = ' num2str(b)])
 % end
 % 
 % disp('Determining far-range signal.');
 % 

 return
 
 function status = quicklooks(mpl,  outdir , options)
%status = quicklooks(mplps, output, outdir, fname)
%if 'options' is provided it must be a string exactly as matlab print function expects. 
% plots_ppt;
if nargin==1
   outdir = [];
   options = []; 
   out_ext = [];
else
   if nargin==2
      options = ['-dmeta'];
      out_ext = 'emf';
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
   ds_name_stem = strtok(mpl.statics.datastream, '.');
   begin_date = floor(mpl.time(1));
   begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
   doy = sprintf('%.3d',floor(serial2doy(mpl.time(1))));
   ds_name = [outdir, ds_name_stem, '.', begin_datestr, '.doy_',doy, '.'];
   %', DOY
   %',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy(mpl.time(1))))])
end;
% 
 figure(101); colormap('jet')
 imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20),real(log10(mpl.prof(mpl.r.lte_20,:))));
 axis('xy'); axis([0,24,0,6,-.55,1.15,-.55,1.15]);colorbar; zoom
%  title(['normalized MPL backscatter: ' num2str(datestr(mpl.time(1),1)), ', DOY ',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy(mpl.time(1))))])
%  xlabel('time (UT)');
 colorbar('off')
 figure_position = [62   495   771   211];
 set(gcf, 'Position',figure_position);
 set(gca,'fontsize',14);
 ylabel('z (km)');
%  set(gca,'Position',[.06,0.13,.90,.80]);
 xlabel('time (UT)');
 text(.58,5.2,datestr(mpl.time(1),'mmm dd'),'color','white','fontsize',14,'fontweight','demi');
 set(gca,'Position',[.06,0.23,.90,.7]);
 file_label = 'log_atten_bscat.';
 if ~isempty(out_ext)
    fn = [ds_name, file_label, out_ext];
    print( 101, [options], fn );
%     fn = [ds_name, file_label, 'png'];
%     print( 101, '-dpng', fn );
    disp(['Writing ', fn]);
    fn = [ds_name, file_label, 'fig'];
    saveas(101,fn)
    %close(101);
 end
 figure(102); colormap('jet')
 imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20),((mpl.prof(mpl.r.lte_20,:))));
 axis('xy'); axis([0,24,0,6]); caxis([0,3.5]); colorbar; zoom
%  title(['normalized MPL backscatter: ' num2str(datestr(mpl.time(1),1)), ', DOY ',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy(mpl.time(1))))])
%  xlabel('time (UT)');
 ylabel('z (km)');
 colorbar('off')
 figure_position = [62   495   771   211];
 set(gcf, 'Position',figure_position);
 set(gca,'fontsize',14);
 ylabel('z (km)');
%  set(gca,'Position',[.06,0.13,.90,.80]);
 xlabel('time (UT)');
  text(.58,5.2,datestr(mpl.time(1),'mmm dd'),'color','white','fontsize',14,'fontweight','demi');
 set(gca,'Position',[.06,0.23,.90,.7]);
 file_label = 'atten_bscat.';
 if ~isempty(out_ext)
    fn = [ds_name, file_label, out_ext];
    print( 102, [options], fn );
%     fn = [ds_name, file_label, 'png'];
%     print( 102, '-dpng', fn );
    disp(['Writing ', fn]);
    fn = [ds_name, file_label, 'fig'];
    saveas(102,fn)
    %close(102);
 end
%  plots_default;
status = 1;
return
