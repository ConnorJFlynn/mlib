function [mpl, status] = mpl_con_nor_sgp20050805(filename)
% [mpl,status] = mpl_con_nor_sgp20050805(filename)
% 2005-02-25: Noise calculations corrected CJF
% putting in new dtc, ap, ol corrections determined from Albert's visit 

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
    mpl = apply_dtc_to_cdf(mpl, 'dtc_apd8126');
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
 
% disp('Skipping afterpulse.');
 disp('Subtracting afterpulse.');
 mpl.ap = ap_mpl004_20030131(mpl.range);

 for t = times:-1:1
    mpl.prof(:,t) = mpl.prof(:,t) - mpl.ap;
 end;
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
 mpl.ol = ol_mpl004_20030131(mpl.range);
% [blah, mpl.ol] = ol_horiz_mpl004_20030131(mpl.range);
 %[blah, mpl.ol] = ol_vert_mpl004_20030131(mpl.range);

 ol_patch = patch_ol_mpl004_20030131(mpl.range);
 mpl.ol = mpl.ol .* ol_patch;

%mpl.ol = ol_renorm(mpl.ol, 1.2, 3);
 overlap_corr = mpl.ol * ones([1,times]);
 mpl.prof = mpl.prof .* overlap_corr;
 
%  disp('Skipping bin normalization.');
disp('Applying de-trended bin normalization.');
 mean_bin3 = mean(mpl.prof(3,:));
 norm3 =  1 ./ mpl.prof(3,:);
 norm_baseline = smooth(serial2Hh(mpl.time), norm3, 200, 'rloess')';
 %mpl.hk.norm3 = mean_bin3*norm3;
 old_norm3 = mean_bin3*norm3;
 mpl.hk.norm3 = norm3./norm_baseline;
 %figure; plot(serial2Hh(mpl.time), old_norm3, 'r', serial2Hh(mpl.time), mpl.hk.norm3 , 'b')

 mpl.prof = mpl.prof.*(ones([length(mpl.range),1])*mpl.hk.norm3);
 
%  disp('Adjusting ap correction for background.');
%  ap_r2 = mpl.ap .* mpl.range.*mpl.range;
%  norm_bg = lowess(serial2doy0(mpl.time)-145, (mpl.hk.bg ./ max(mpl.hk.bg)),.01);
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
   doy = sprintf('%.3d',floor(serial2doy0(mpl.time(1))));
   ds_name = [outdir, ds_name_stem, '.', begin_datestr, '.doy_',doy, '.'];
   %', DOY
   %',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy0(mpl.time(1))))])
end;

 figure(101); colormap('jet')
 imagesc(serial2Hh(mpl.time), mpl.range(mpl.r.lte_20),real(log10(mpl.prof(mpl.r.lte_20,:))));
 axis('xy'); axis([0,24,0,6,-.5,1.5,-.5,1.5]);colorbar; zoom
 title(['log_1_0 MPL backscatter: ' num2str(datestr(mpl.time(1),1)), ', DOY ',datestr(mpl.time(1),10),'\_',num2str(floor(serial2doy0(mpl.time(1))))])
 xlabel('time (HH.hh)');
 ylabel('range (km)');
 
 file_label = 'log_atten_bscat.';
 if ~isempty(out_ext)
    fn = [ds_name, file_label, out_ext];
    print( 101, [options], fn );
    disp(['Writing ', fn]);
      fn = [ds_name, file_label, 'fig'];
      saveas(101,fn)
    %close(101);
 end
   
status = 1;
return
