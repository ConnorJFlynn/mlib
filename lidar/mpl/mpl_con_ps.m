function [mplps, status] = mpl_con_ps(pname, fname, outdir)
% [mpl,status] = mpl_con_ps(pname fname)
% This old function for processing MPACE data may no longer be useful.  It creates netcdf files of my
% own construction for the prototype MPL-PS.
% However, using to to provide some data to Mahlon from MPACE.
% Hacked a fix to stop catastrophic abort when polarizer is stuck.  
% Simply catching when copol <= 1 and hard setting cts and std
if nargin<3
   [fid, fname, pname] = getfile('*.*', 'mpl_data');
   filename = [pname fname];
   outdir = pname;
   if fid>0
      fclose(fid);
   end
end
if ~exist([pname 'c1\'],'dir')
   mkdir([pname ,'c1\']);
end
outdir = [pname 'c1\'];
[ncid, status] = ncmex('open', [pname fname]);
outfid = 0;

n_minutes = 1;
mplps.statics.averaging_interval = n_minutes;

if ncid>0
   good_file = 1;
   statics.deadtime_corrected = 0;
   [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
   for i = 1:natts
      temp = ncmex('ATTNAME', ncid, 'nc_global', i-1);
      attname{i} = temp;
      if any(findstr(temp,'eb_platform'))
         [value] = ncmex('ATTGET', ncid, 'nc_global', temp);
         if ischar(value)
            mplps.statics.datastream = value;
         end
      end    
      if any(findstr(temp,'erial_number'))
         [value] = ncmex('ATTGET', ncid, 'nc_global', temp);
         if ischar(value)
            mplps.statics.unitSN = str2double(value);
         else
            mplps.statics.unitSN = value;
         end
      end
      if any(findstr(temp,'Deadtime_correction'))
         mplps.statics.deadtime_corrected = 1;
      end
   end
   
   if (findstr(mplps.statics.datastream, 'mplps')&findstr(mplps.statics.datastream, '.a0'))
      %Reading mplps raw data file
      disp('reading raw mplps...');
      rawps.time = nc_time(ncid);
      [varid, rcode] = ncmex('VARID', ncid, 'range');
      if varid>0
         rawps.range = nc_getvar(ncid, varid)';
      end;
      [varid, rcode] = ncmex('VARID', ncid, 'lat');
      if varid>0
         mplps.statics.lat = nc_getvar(ncid, varid);
      end;
      [varid, rcode] = ncmex('VARID', ncid, 'lon');
      if varid>0
         mplps.statics.lon = nc_getvar(ncid, varid);
      end;
      [varid, rcode] = ncmex('VARID', ncid, 'alt');
      if varid>0
         mplps.statics.alt = nc_getvar(ncid, varid);
      end;
      if max(rawps.range)<30
         good_file = good_file*0;
      end;
      range = rawps.range(find((rawps.range>=0)&(rawps.range<=30)));
      mplps.range = range;

      r.ps_out = [1:length(range)]';
      r.gte_0 = find(rawps.range>0);
      r.bg = find((rawps.range>(0.6*max(rawps.range)))&(rawps.range<(0.95*max(rawps.range))));
      range_len = length(rawps.range);
     
      mplps.copol.ap = ap_copol_mpl005_20031111(rawps.range(r.gte_0));
      mplps.crosspol.ap = ap_crosspol_mpl005_20031111(rawps.range(r.gte_0));
      mplps.overlap = overlap_mpl005_20031119(mplps.range);
      [varid, rcode] = ncmex('VARID', ncid, 'shots_summed');
      if varid>0
         rawps.shots_summed = nc_getvar(ncid, varid);
      end;
      [varid, rcode] = ncmex('VARID', ncid, 'energy_monitor');
      if varid>0
         rawps.energy_monitor = nc_getvar(ncid, varid);
      end;
      [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
      if varid>0
         bin_time_ns = nc_getvar(ncid, varid);
      end;
      [varid, rcode] = ncmex('VARID', ncid, 'range_bin_width');
      if varid>0
         bin_width = nc_getvar(ncid, varid);
         mplps.statics.bin_width = bin_width;
      end;
      
      %Now grab chunks of the rawcts, split it into copol and crosspol, ...
      % Take things in n-minute increments throughout the entire day
      % If fewer than 5 profiles in a given interval, discard entire minute.
      serial_day = floor(min(rawps.time));
      min_time = min(rawps.time) - serial_day;
      max_time = max(rawps.time) - serial_day;
      %skip forward until the time interval is greater than the min time in the file.
      
      start_time = ceil(min_time * (60*24)/n_minutes);
      end_time = floor(max_time *(60*24)/n_minutes);
      outs = 0;
      if good_file > 0;       
         for t = start_time+1: end_time-1
            times = find((rawps.time>= (serial_day + (t-1)*n_minutes/(24*60)))&(rawps.time <= (serial_day + (t+1)*n_minutes/(24*60))));
            if length(times)>1
               outs = outs + 1;
               mplps.time(outs) = mean(rawps.time(times));
               mplps.energy_monitor(outs) = mean(rawps.energy_monitor(times));
               mplps.shots_summed(outs) = mean(rawps.shots_summed(times));
               [rawcts, status] = ncmex('VARGET', ncid, 'detector_counts', [min(times)-1, 0], [length(times),2001]);
               bg = mean(rawcts(r.bg,:));
               sum_rawcts_less_bg = sum(rawcts(5:24,:)-ones([20,1])*bg);
               copols = find(sum_rawcts_less_bg > mean(sum_rawcts_less_bg));            
               crosspols = find(sum_rawcts_less_bg < mean(sum_rawcts_less_bg));
               if length(copols)==0
                  cts = zeros(size(rawcts(:,1)));
               elseif length(copols)==1
                  cts = rawcts(:,copols);
               else
                  cts = mean(rawcts(:,copols)')';
               end
               bg = mean(cts(r.bg));
               ap = mplps.copol.ap;
               samples = length(copols);
               %define zero as first bin that (cts-bg) exceeds threshold value (laser spike)
               zerobin = max([1, min(find((cts(1:20)-bg)>.5))]); 
               if (length(ap)+zerobin-1)<=length(cts)
                  cts = cts(zerobin:length(ap)+zerobin-1);
               else
                  cts = cts(zerobin:end);
               end
               pos = find(cts>0);
               sample_noise = zeros(size(cts));
               sample_noise(pos)= sqrt(1e-3*bin_time_ns * mplps.shots_summed(outs)*samples*cts(pos))./(1e-3*bin_time_ns * mplps.shots_summed(outs));
               if length(copols)<=1
                  sample_std = zeros(size(rawcts(:,1)));
               else
               sample_std = std(rawcts(:,copols)')';
               end
               cts = cts - ap(1:length(cts));
               %disp(['copol pre-dtc: ',num2str(min(cts)), ' ', num2str( max(cts))])
               [cts, status] = dtc_apd6851a(cts);
               %[dump,cts_sort] = sort(cts);
               %dtc = dtc_cts ./ cts;
               %r.lte_10 = find(range>0&range<=10);
               %semilogy([range(r.lte_10)],[dtc(r.lte_10)],'.')
               %
               %disp(['copol post-dtc: ',num2str(min(cts)), ' ', num2str( max(cts))])
               if status<0
                  disp('copol was complex');
               end
               bg = mean(cts(r.bg));
               good_bg = find(abs(cts(r.bg)/bg)<100);
               bg = mean(cts(r.bg(good_bg)));
               cts = cts - bg;
               mplps.range = range;
               mplps.copol.cts(:,outs) = cts(r.ps_out);
               mplps.copol.prof(:,outs) = cts(r.ps_out).*(range.^2).*mplps.overlap;
               mplps.copol.sample_noise(:,outs) = sample_noise(r.ps_out);
               mplps.copol.sample_std(:,outs) = sample_std(r.ps_out);
               mplps.copol.samples(outs) = samples;
               mplps.copol.bg(outs) = bg;
               mplps.copol.zerobin(outs) = zerobin;
               clear bg copols sample_std sample_noise cts samples
               if length(crosspols)>1
               cts = mean(rawcts(:,crosspols)')';
               elseif length(crosspols)==1
                  cts = rawcts(:,crosspols);
               else
                  cts = zeros(size(rawcts(:,1)));
               end
               ap = mplps.crosspol.ap;
               samples = length(crosspols);            
               bg = mean(cts(r.bg));
               %define zero as first bin that (cts-bg) exceeds threshold value (laser spike)
               zerobin = max([1, min(find((cts(1:20)-bg)>.5))]);  
               if (length(ap)+zerobin-1)<=length(cts)
                  cts = cts(zerobin:length(ap)+zerobin-1);
               else
                  cts = cts(zerobin:end);
               end
               pos = find(cts>0);            
               sample_noise = zeros(size(cts));
               sample_noise(pos)= sqrt(1e-3*bin_time_ns * mplps.shots_summed(outs)*samples*cts(pos))./(1e-3*bin_time_ns * mplps.shots_summed(outs));
               if length(crosspols)<=1
                  sample_std = zeros(size(rawcts(:,1)));
               else
                  sample_std = std(rawcts(:,crosspols)')';
               end
               cts = cts - ap(1:length(cts));
               
               %disp(['crosspol pre-dtc: ',num2str(min(cts)), ' ', num2str( max(cts))])
               [cts, status] = dtc_apd6851a(cts);
               %disp(['crosspol post-dtc: ',num2str(min(cts)), ' ', num2str( max(cts))])
               if status<0
                  disp('crosspol was complex');
               end
               
               bg = mean(cts(r.bg));
               good_bg = find(abs(cts(r.bg)/bg)<100);
               bg = mean(cts(r.bg(good_bg)));
               cts = cts - bg;
               
               mplps.crosspol.cts(:,outs) = cts(r.ps_out);
               mplps.crosspol.prof(:,outs) = cts(r.ps_out).*(range.^2).*mplps.overlap;
               mplps.crosspol.sample_noise(:,outs) = sample_noise(r.ps_out);
               mplps.crosspol.sample_std(:,outs) = sample_std(r.ps_out);
               mplps.crosspol.samples(outs) = samples;
               mplps.crosspol.bg(outs) = bg;
               mplps.crosspol.zerobin(outs) = zerobin;
               clear bg copols sample_std sample_noise cts samples            
               
               %Check to see if the output netcdf file has been created yet.  
               %If not, create/define it
               
               % At some point we need to subtract afterpulse and do dtc,
               % but not realy sure where I want to do this.  
               % Maybe down below after averaging?
            end; %of times>0
            disp(['Average #', num2str(outs), ', from time slot ', num2str(t-start_time), ' of ', num2str(end_time-start_time)])
         end % of iterations of time between start_time and end_time\
      end %of good_file
      if outs>0
         mplps.copol.ap = mplps.copol.ap(r.ps_out);
         mplps.crosspol.ap = mplps.crosspol.ap(r.ps_out);
         mplps.cts = mplps.copol.cts + mplps.crosspol.cts;
%          mplps.prof = mplps.copol.prof + mplps.crosspol.prof;
      % factor of two required for cross_pol to account for circular copol.
      % Sent wrong version to Mahlon :-(
         mplps.prof = mplps.copol.prof + 2.*mplps.crosspol.prof;         
         mplps.sample_noise = sqrt(mplps.crosspol.sample_noise.^2 + mplps.copol.sample_noise.^2);
         mplps.sample_std = sqrt(mplps.crosspol.sample_std.^2 + mplps.copol.sample_std.^2);
         mplps.sample_stability = mplps.sample_std ./ mplps.sample_noise;
         pos = find(mplps.copol.cts>0);
         mplps.dpr = zeros(size(mplps.copol.cts));
         mplps.dpr(pos) = mplps.crosspol.cts(pos)./mplps.copol.cts(pos);
         mplps.dpr = mplps.dpr./(mplps.dpr+1);
          status = write_mplps(mplps, outdir);
         %status = quicklooks(mplps);
         gtz = find((mplps.copol.cts>0)&(mplps.copol.sample_noise>0));
         mplps.copol.snr = zeros(size(mplps.copol.prof));
         mplps.copol.snr(gtz) = mplps.copol.cts(gtz)./mplps.copol.sample_noise(gtz);
         mplps.good = mplps.copol.snr>.25;
         status = mplps_quicklooks(mplps,  outdir, '-dpng');
         
      end;         
   else %This isn't a mpl-ps file.
      disp(['Sorry, filename ',filename, ' is not a mpl-ps file. Exiting with no action.']);
      mplps = [];
      status = -1;
   end;
   ncmex('close', ncid);
else
   disp(['Sorry, filename ',filename, ' is not a valid netcdf. Exiting with no action.']);
   mplps = [];
   status = -1;
end

return
% 
% function status = mplps_quicklooks(mplps,  outdir , options)
% %status = mplps_quicklooks(mplps, output, outdir, fname)
% %if 'options' is provided it must be a string exactly as matlab print function expects. 
% if nargin==1
%    outdir = [];
%    options = []; 
%    out_ext = [];
% else
%    if nargin==2
%       options = [];
%       out_ext = 'png';
%    else
%       if findstr(options, 'png')
%          out_ext = 'png';
%       elseif findstr(options, 'meta')
%          out_ext = 'xmf';
%       elseif findstr(options, 'jpeg')
%          out_ext = 'jpeg';
%       end;
%    end
%    %construct output file name with outdir, time, and output format
%    ds_name_stem = strtok(mplps.statics.datastream, '.');
%    begin_date = floor(mplps.time(1));
%    begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
%    ds_name = [outdir, ds_name_stem, '.', begin_datestr, '.'];
% end;
% 
% figure(1); 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.prof))); 
% axis('xy'); zoom; colormap('jet'); 
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
% % 
% % figure; 
% % imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.cts))); 
% % axis('xy'); zoom; colormap('jet'); 
% % xlabel('time (HH.hh)');
% % ylabel('range (km)');
% % title(['log_1_0 of Attenuated Backscatter: ', datestr(mplps.time(1),1)]);
% % axis([0 24 0 15 0 1 -3 1]); 
% % colorbar
% % file_label = 'combined_cts_log.';
% % if ~isempty(out_ext)
% %    fn = [ds_name, file_label, out_ext];
% %    print( gcf, [options], fn );
% %    close(gcf);
% % end
% 
% % figure; 
% % imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.copol.prof))); 
% % axis('xy'); zoom; colormap('jet'); 
% % xlabel('time (HH.hh)');
% % ylabel('range (km)');
% % title(['Range-corrected Co-Polarized Backscatter: ', datestr(mplps.time(1),1)]);
% % %text(5,13, 'no overlap correction applied')
% % axis([0 24 0 15 0 1 0 4]);
% % 
% % file_label = 'copol_range_corrected.';
% % if ~isempty(out_ext)
% %    fn = [ds_name, file_label, out_ext];
% %    print( gcf, [options], fn );
% %    close(gcf);
% % end
%    
% figure; 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.crosspol.prof))); 
% axis('xy'); zoom; colormap('jet'); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['Range-corrected Cross-Polarized Backscatter: ', datestr(mplps.time(1),1)]);
% %text(5,13, 'no overlap correction applied')
% axis([0 24 0 15 0 1 0 2]);
% 
% file_label = 'crosspol_range_corrected.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
%    
% 
% % figure; 
% % imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.copol.sample_std./mplps.copol.sample_noise))); 
% % axis('xy'); zoom; colormap('jet');
% % xlabel('time (HH.hh)');
% % ylabel('range (km)');
% % title(['copol sample stability: ', datestr(mplps.time(1),1)]);
% % axis([0 24 0 15 0 1 0 3]); 
% % colorbar
% % file_label = 'copol_stability.';
% % if ~isempty(out_ext)
% %    fn = [ds_name, file_label, out_ext];
% %    print( gcf, [options], fn );
% %    close(gcf);
% % end
% 
% % figure; 
% % imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.copol.sample_std./mplps.copol.sample_noise))); 
% % axis('xy'); zoom; colormap('jet'); 
% % xlabel('time (HH.hh)');
% % ylabel('range (km)');
% % title(['log_1_0 copol sample stability: ', datestr(mplps.time(1),1)]);
% % axis([0 24 0 15 0 1 -1 1]); 
% % colorbar
% % file_label = 'copol_stability_log.';
% % if ~isempty(out_ext)
% %    fn = [ds_name, file_label, out_ext];
% %    print( gcf, [options], fn );
% %    close(gcf);
% % end
% 
% % figure; 
% % imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.crosspol.sample_std./mplps.crosspol.sample_noise))); 
% % axis('xy'); zoom; colormap('jet'); 
% % xlabel('time (HH.hh)');
% % ylabel('range (km)');
% % title(['crosspol sample stability: ', datestr(mplps.time(1),1)]);
% % axis([0 24 0 15 0 1 0 3]); 
% % colorbar
% % file_label = 'crosspol_stability.';
% % if ~isempty(out_ext)
% %    fn = [ds_name, file_label, out_ext];
% %    print( gcf, [options], fn );
% %    close(gcf);
% % end
% 
% % figure; 
% % imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.crosspol.sample_std./mplps.crosspol.sample_noise))); 
% % axis('xy'); zoom; colormap('jet'); 
% % xlabel('time (HH.hh)');
% % ylabel('range (km)');
% % title(['log_1_0 crosspol sample stability: ', datestr(mplps.time(1),1)]);
% % axis([0 24 0 15 0 1 -1 1]);; 
% % colorbar
% % file_label = 'crosspol_stability_log.';
% % if ~isempty(out_ext)
% %    fn = [ds_name, file_label, out_ext];
% %    print( gcf, [options], fn );
% %    close(gcf);
% % end
% 
% figure; 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.sample_stability))); 
% axis('xy'); zoom; colormap('jet'); 
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
% figure; 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.sample_stability))); 
% axis('xy'); zoom; colormap('jet'); 
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
% figure; 
% imagesc(serial2Hh([mplps.time ]), mplps.range, ((mplps.dpr))); 
% axis('xy'); zoom; colormap('jet'); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['depolarization ratio: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 0 .6]); 
% colorbar
% file_label = 'dpr.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
% 
% figure; 
% imagesc(serial2Hh([mplps.time ]), mplps.range, real(log10(mplps.dpr))); 
% axis('xy'); zoom; colormap('jet'); 
% xlabel('time (HH.hh)');
% ylabel('range (km)');
% title(['log_1_0 of depolarization ratio: ', datestr(mplps.time(1),1)]);
% axis([0 24 0 15 0 1 -3 0]); 
% colorbar
% file_label = 'dpr_log.';
% if ~isempty(out_ext)
%    fn = [ds_name, file_label, out_ext];
%    print( gcf, [options], fn );
%    close(gcf);
% end
% status = 1;
% return

function status = write_mplps(mplps, pname);
% status = write_mplps(mplps, pname);
% provided with a complete mplps structure, writes it to netcdf in pname

year = str2num(datestr(mplps.time(1), 10));
epoch = serial2epoch(mplps.time);
julian_day = floor(serial2doy(mplps.time(1)));

base_time = min(epoch);
base_time_str = [datestr(min(mplps.time),31) ' GMT'];
base_time_long_name = 'Base time in Epoch';
base_time_units = 'seconds since 1970-1-1 0:00:00 0:00';

time_offset = epoch - base_time;
time_offset_long_name = ['Time offset from base_time'];
time_offset_units = ['seconds since ' base_time_str] ;

%time is seconds since midnight of the day of the first record
time = (serial2doy(mplps.time) - julian_day) * (24*60*60);
time_long_name  = 'Time offset from midnight';
time_units = ['seconds since ' datestr(floor(mplps.time(1)),31) ' GMT' ];

julian_day_long_name = 'Day of year'; 
julian_day_units = ['days since ' datestr(datenum(year,1,1),31) ' UTC'];
julian_day_comment = ['For example: Jan 1 6:00 AM = 0.25'];      
%      !!

%Create and define the outgoing netcdf file...
%construct outgoing filename
ds_name_stem = strtok(mplps.statics.datastream, '.');
begin_date = floor(mplps.time(1));
begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
ds_name = [ds_name_stem, '.c1.', begin_datestr, '.000000.cdf'];
cdfid = ncmex('create', [pname, ds_name], 'clobber');
status = ncmex('DIMDEF', cdfid, 'time', 0);
status = ncmex('DIMDEF', cdfid, 'range', length(mplps.range));


att_name = 'proc_level';
att_val = 'c1';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'input_source';
att_val = [mplps.statics.datastream];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'site_id';
att_val = 'nsa';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'facility_id';
att_val = 'C1 : PAARCS2:NSA-Barrow_Central_Facility';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'proc_level';
att_val = 'c1';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'averaging_int';
att_val = [num2str(mplps.statics.averaging_interval), ' minutes'];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'deadtime_corrected';
att_val = 'yes';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'Instrument Mentor';
att_val = ['Connor J. Flynn Connor.Flynn@arm.gov 509-375-2041'];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'time_offset_description';
att_val = 'The time is referenced to the middle of each averaging interval.';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'serial_number';
att_val = [num2str(mplps.statics.unitSN)];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'zeb_platform';
att_val = 'nsamplpsC1.c1';
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;

att_name = 'history';
att_val = ['Created by CJF on ', datestr(now)];
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;


varname = 'base_time';
datatype = 4; ndims = 0; dim_ids = [];
status = ncmex('VARDEF', cdfid, 'base_time', datatype, ndims, dim_ids);   
status = ncmex('ATTPUT', cdfid, 'base_time','string', 2, length(base_time_str), base_time_str);
status = ncmex('ATTPUT', cdfid, 'base_time','long_name', 2, length(base_time_long_name), base_time_long_name);
status = ncmex('ATTPUT', cdfid, 'base_time', 'units', 2,  length(base_time_units), base_time_units);

varname = 'time_offset';
datatype = 6; ndims = 1; dim_ids = [0];
status = ncmex('VARDEF', cdfid, 'time_offset', datatype, ndims, dim_ids);   
status = ncmex('ATTPUT', cdfid, 'time_offset','long_name', 2, length(time_offset_long_name), time_offset_long_name);
status = ncmex('ATTPUT', cdfid, 'time_offset', 'units', 2 , length(time_offset_units), time_offset_units);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'time_offset', 'reference_point', 2 , length(att_val), att_val);

status = ncmex('VARDEF', cdfid, 'time', datatype, ndims, dim_ids);   
att_val = 'time in seconds since midnight';
status = ncmex('ATTPUT', cdfid, 'time','long_name', 2, length(time_long_name), time_long_name);
status = ncmex('ATTPUT', cdfid, 'time', 'units', 2 ,length(time_units), time_units);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'time', 'reference_point', 2 , length(att_val), att_val);


status = ncmex('VARDEF', cdfid, 'julian_day', 6, ndims, dim_ids);
status = ncmex('ATTPUT', cdfid, 'julian_day','long_name', 2, length(julian_day_long_name), julian_day_long_name);
status = ncmex('ATTPUT', cdfid, 'julian_day', 'units', 2 , length(julian_day_units), julian_day_units);
status = ncmex('ATTPUT', cdfid, 'julian_day', 'comment', 2 , length(julian_day_comment), julian_day_comment);
att_val = 'times are referenced to the center of the averaging interval';
status = ncmex('ATTPUT', cdfid, 'julian_day', 'reference_point', 2 , length(att_val), att_val);

datatype = 5;
varname = 'range';
status = ncmex('VARDEF', cdfid, varname, datatype, 1, 1);
att_val = 'height above ground level to the center of the bin';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'km';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val);
att_val = mplps.statics.bin_width;
status = ncmex('ATTPUT', cdfid, varname, 'range_resolution', datatype, length(att_val), att_val);

varname = 'overlap_corr';
status = ncmex('VARDEF', cdfid, 'overlap_corr', datatype, 1, 1);
att_val = 'near-range overlap correction factor';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'applied to remove near-field instrument artifact';
status = ncmex('ATTPUT', cdfid, varname, 'utility', 2, length(att_val), att_val) ;
att_val = 'derived from vertical data on 2003-11-19 by CJF';
status = ncmex('ATTPUT', cdfid, varname, 'source', 2, length(att_val), att_val) ;

varname = 'deadtime_corrected';
status = ncmex('VARDEF', cdfid, 'deadtime_corrected', 3, 0, 0);
att_val = 'detector deadtime correction applied';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'y=(a+cx+ex^2)/(1+bx+dx^2+fx^3)';
status = ncmex('ATTPUT', cdfid, varname, 'equation', 2, length(att_val), att_val) ;
att_val = 'a= 0.02300185641971347 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_a', 2, length(att_val), att_val) ;
att_val = 'b= -0.3760112491643825 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_b', 2, length(att_val), att_val) ;
att_val = 'c= 1.050386710451692 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_c', 2, length(att_val), att_val) ;
att_val = 'd= 0.004038376442503992 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_d', 2, length(att_val), att_val) ;
att_val = 'e= -0.3625570586137006 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_e', 2, length(att_val), att_val) ;
att_val = 'f= 0.00128412385484703 ';
status = ncmex('ATTPUT', cdfid, varname, 'coef_f', 2, length(att_val), att_val) ;

varname = 'energyMonitor';
status = ncmex('VARDEF', cdfid, 'energyMonitor', datatype, 1, 0);
att_val = 'average laser pulse energy';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'microjoules';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_afterpulse';
status = ncmex('VARDEF', cdfid, 'copol_afterpulse', datatype, 1, 1);
att_val = 'afterpulse subtracted from circ. copol channel';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/usec';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_samples';
status = ncmex('VARDEF', cdfid, 'copol_samples', datatype, 1, 0);
att_val = 'number of circ. copol samples per average';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'count';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_zerobin';
status = ncmex('VARDEF', cdfid, 'copol_zerobin', datatype, 1, 0);
att_val = 'original location of circ. copol zero bin';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_bg';
status = ncmex('VARDEF', cdfid, 'copol_bg', datatype, 1, 0);
att_val = 'circ co-polarized background';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_cts';
status = ncmex('VARDEF', cdfid, 'copol_cts', datatype, 2, [0 1]);
att_val = 'circ co-polarized counts';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'background subtracted, deadtime corrected, afterpulse subtracted';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'copol_std';
status = ncmex('VARDEF', cdfid, 'copol_std', datatype, 2, [0 1]);
att_val = 'circ copol sample variability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_noise';
status = ncmex('VARDEF', cdfid, 'copol_noise', datatype, 2, [0 1]);
att_val = 'circ copol sample statistical noise';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'copol_prof';
status = ncmex('VARDEF', cdfid, 'copol_prof', datatype, 2, [0 1]);
att_val = 'circ co-polarized range-corrected backscatter';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;


varname = 'crosspol_afterpulse';
status = ncmex('VARDEF', cdfid, 'crosspol_afterpulse', datatype, 1, 1);
att_val = 'afterpulse subtracted from crosspol channel';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/usec';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_samples';
status = ncmex('VARDEF', cdfid, 'crosspol_samples', datatype, 1, [0]);
att_val = 'number of crosspol samples per average';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'count';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_zerobin';
status = ncmex('VARDEF', cdfid, 'crosspol_zerobin', datatype, 1, 0);
att_val = 'original location of crosspol zero bin';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_bg';
status = ncmex('VARDEF', cdfid, 'crosspol_bg', datatype, 1, [0]);
att_val = 'cross-polarized background';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_cts';
status = ncmex('VARDEF', cdfid, 'crosspol_cts', datatype, 2, [0 1]);
att_val = 'cross-polarized backscatter';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'counts per microsecond';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'background subtracted, deadtime corrected, afterpulse subtracted';
status = ncmex('ATTPUT', cdfid, varname, 'corrections', 2, length(att_val), att_val) ;

varname = 'crosspol_std';
status = ncmex('VARDEF', cdfid, 'crosspol_std', datatype, 2, [0 1]);
att_val = 'crosspol sample variability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_noise';
status = ncmex('VARDEF', cdfid, 'crosspol_noise', datatype, 2, [0 1]);
att_val = 'crosspol sample statistical noise';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'crosspol_prof';
status = ncmex('VARDEF', cdfid, 'crosspol_prof', datatype, 2, [0 1]);
att_val = 'cross-polarized range-corrected backscatter';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_cts';
status = ncmex('VARDEF', cdfid, 'total_cts', datatype, 2, [0 1]);
att_val = 'combined linear backscatter components';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_prof';
status = ncmex('VARDEF', cdfid, 'total_prof', datatype, 2, [0 1]);
att_val = 'combined linear range-corrected backscatter components';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_noise';
status = ncmex('VARDEF', cdfid, 'total_noise', datatype, 2, [0 1]);
att_val = 'quadrature combined linear sample noise';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'total_std';
status = ncmex('VARDEF', cdfid, 'total_std', datatype, 2, [0 1]);
att_val = 'quadrature combined linear sample variability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'cts/(us-km^2)';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'sample_stability';
status = ncmex('VARDEF', cdfid, 'sample_stability', datatype, 2, [0 1]);
att_val = 'sample relative stability';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'low values indicate stable conditions';
status = ncmex('ATTPUT', cdfid, varname, 'Comment', 2, length(att_val), att_val) ;

varname = 'depolarization';
status = ncmex('VARDEF', cdfid, 'depolarization', datatype, 2, [0 1]);
att_val = 'linear depolarization ratio';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'unitless';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;
att_val = 'dpr = crosspol_cts/(copol_cts+crosspol_cts)';
status = ncmex('ATTPUT', cdfid, varname, 'equation', 2, length(att_val), att_val) ;
att_val = 'No depolarization = 0';
status = ncmex('ATTPUT', cdfid, varname, 'comment_1', 2, length(att_val), att_val) ;
att_val = 'Full depolarization = 1';
status = ncmex('ATTPUT', cdfid, varname, 'comment_2', 2, length(att_val), att_val) ;

varname = 'lat';
status = ncmex('VARDEF', cdfid, 'lat', datatype, 0, [0]);
att_val = 'north latitude';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'degrees';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'lon';
status = ncmex('VARDEF', cdfid, 'lon', datatype, 0, [0]);
att_val = 'east longitude';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'degrees';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

varname = 'alt';
status = ncmex('VARDEF', cdfid, 'alt', datatype, 0, [0]);
att_val = 'altitude';
status = ncmex('ATTPUT', cdfid, varname, 'long_name', 2, length(att_val), att_val) ;
att_val = 'meters above Mean Sea Level';
status = ncmex('ATTPUT', cdfid, varname, 'units', 2, length(att_val), att_val) ;

ncmex('endef', cdfid);

%[status] = nc_putvar(mplret_id, 'lidar_C', mpl.cal.C);
[status] = nc_putvar(cdfid, 'depolarization', mplps.dpr);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_cts', mplps.cts);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'overlap_corr', mplps.overlap);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_prof', mplps.prof);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_afterpulse', mplps.crosspol.ap);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_cts', mplps.crosspol.cts);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_prof', mplps.crosspol.prof);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_noise', mplps.crosspol.sample_noise); 
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_std', mplps.crosspol.sample_std);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_samples', mplps.crosspol.samples);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_bg', mplps.crosspol.bg);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'crosspol_zerobin', mplps.crosspol.zerobin);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'copol_afterpulse', mplps.copol.ap);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_cts', mplps.copol.cts);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_prof', mplps.copol.prof);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_noise', mplps.copol.sample_noise); 
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_std', mplps.copol.sample_std);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_noise', mplps.sample_noise); 
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'total_std', mplps.sample_std);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'sample_stability', mplps.sample_stability);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_samples', mplps.copol.samples);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_bg', mplps.copol.bg);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'copol_zerobin', mplps.copol.zerobin);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'energyMonitor', mplps.energy_monitor);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'range', mplps.range);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'base_time', base_time);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'time_offset',time_offset );
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'time', time);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'julian_day',serial2doy(mplps.time));
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'deadtime_corrected', 1);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'alt', mplps.statics.alt);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'lon', mplps.statics.lon);
if status<0
   keyboard;
end
[status] = nc_putvar(cdfid, 'lat', mplps.statics.lat);
if status<0
   keyboard;
end

ncmex('close', cdfid);
return

function overlap = overlap_mpl005_20031119(range);
	% overlap = overlap_mpl005_20031119;
	pname = [''];
   fname = ['nsamplpsC1.a1.20031119.overlap_corr.mat'];
% 	[fname, pname] = uigetfile([pname, '*.mat']);
	temp = load([pname fname], '-mat');
   upper_limit = min([length(range),length(temp.ol(:,2))]);
   overlap = ones(size([1:upper_limit]));
	overlap = temp.ol(1:upper_limit,2);
return