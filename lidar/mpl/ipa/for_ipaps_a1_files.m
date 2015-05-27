function status = for_ipaps_a1_files;
% status = for_ipaps_a1_files;
% In progress...
% Use this instead of for_ocr_a1_files, but look in for_ocr_a1_files too
% avg_to_mirror is incomplete.  It needs to use isNaN for zenith_angle 
% and is the time to calculate statistics.  
% Store samples, *_std, *_snr
% Calculate vertical heights up to 15 km, 
% Separate copol/depol of at least two methods
% Supposed to average ipamplps.a1 files for each mirror position
% and create a new output file with truncated range (30 km)
% interpolated (and denoised) height profiles suitable for slant-sensing
% as well as noise, snr, and samples fields.
% Also should create quicklook images sufficient for data perusal.

%disp('Please select an ipasmplps.a1 file:');
%[ps_dirlist,ps_pname] = dir_list('*.nc');
ps_pname = ['C:\case_studies\ipa\Alldays\mplps\ipasmplpsC1.a1\'];
[ps_dirlist, ps_pname] = get_dir_list(ps_pname, 'ipasmplps*.nc;ipasmplps*.cdf');
ps_file = 1;

%[ocr_dirlist,ocr_pname] = dir_list('*.nc');
ocr_pname = ['C:\case_studies\ipa\Alldays\ocr\ipasmplocrC1.a1\'];
[ocr_dirlist,ocr_pname] = get_dir_list(ocr_pname, 'ipasmplocr*.nc;ipasmplocr*.cdf');

while ps_file <= length(ps_dirlist)
    %for i = 1:length(ps_dirlist);
    disp(['Processing ', ps_dirlist(ps_file).name, ' : ', num2str(ps_file), ' of ', num2str(length(ps_dirlist))]);
    if ~exist('new_ps', 'var')
        new_ps = read_mpl([ps_pname, ps_dirlist(ps_file).name]);
        ps_file = ps_file +1;
    else
        [ps_day, ps_next_day, ps_file] = get_rest_of_day(new_ps,ps_dirlist,ps_file, current_day);
    end
    ps_day = collect_ipa_a1([],new_ps,ps_next_day);
    current_day = floor(min(ps_times(ps_next_day)));
    ps_next_day = (floor(ps_times)==(current_day+1));
    new_ps.statics.input_pname = ps_pname;
    new_ps.statics.input_fname = ps_dirlist(ps_file).name;
    %ps_times = new_ps.time;
    if length(new_ps.time)>0
        if ~exist('current_day','var')
            current_day = floor(new_ps.time(1));
        end
        [ps_day, ps_next_day] = get_rest_of_day(new_ps,ps_dirlist,ps_file, current_day);
        if any(ps_next_day)
            ps_day = collect_ipa_a1([],new_ps,ps_next_day);
            current_day = floor(min(ps_times(ps_next_day)));
            ps_next_day = (floor(ps_times)==(current_day+1));
        end

%         [new_ocr, ocr_file] = get_first_file_with_date(ocr_pname, ocr_dirlist, current_day);
%         if ~isempty(new_ocr)
%             [ocr_day, ocr_next_day] = get_rest_of_day(new_ocr,ocr_dirlist,ocr_file, current_day);
%         end
        
        %Cool, we now have the full day for both ps and ocr.
%         
%         ps_avg = avg_ps_to_mirror(ps_day);
%         status = ps_avg_quicklooks(ps_avg);
%         %ps_avg = ps_avg_calcs(ps_avg);
%         ps_avg.statics.input_source = new_ps.statics.datastream;
%         %status = output_smplps_c1(ps_avg);
%         
%         ocr_avg = avg_ocr_to_mirror(ocr_day);
%         status = ocr_avg_quicklooks(ocr_avg);
%         ocr_avg.statics.input_source = ocr_file.statics.datastream;
%         %status = output_smplocr_c1(ocr_avg);

    else
        %skip this empty file
        ps_file = ps_file +1;
    end;
    %         %%%
    %     end
    %       %Now we've got the entire day of ps data.
    %       %Grab the day's worth for PS data too.
    %       match_day = floor(ps_avg.time(1));
    %       if ~exist('ps_pname','var')
    %           disp('Please select a file from the MPL-PS directory.');
    %           [ps_dirlist,ps_pname] = dir_list('*.nc');
    %       end
    %       [mplps_avg, ps_dirlist] = get_ps_day(ps_dirlist, match_day );
    %             disp(['Done processing ', dirlist(i).name]);
    %
    %    disp(' ')
    %    disp(['Finished with processing all files in directory ' pname])
    %    disp(' ')
    % end
end
end

function mpl_out = collect_ipa_a1(mpl_out, mpl_in, mpl_times);
%mpl_out = collect_ipa_a1(mpl_out,mpl_in, mpl_times );
if nargin<2
    disp('Incorrect number of arguments')
elseif nargin ==2
    if isempty(mpl_out)
        mpl_out = mpl_in;
    else
        mpl_out.time = [mpl_out.time , mpl_in.time];
        mpl_out.hk.instrument_temp = [mpl_out.hk.instrument_temp, mpl_in.hk.instrument_temp];
        mpl_out.hk.laser_temp = [mpl_out.hk.laser_temp, mpl_in.hk.laser_temp];
        mpl_out.hk.detector_temp = [mpl_out.hk.detector_temp, mpl_in.hk.detector_temp];
        mpl_out.hk.filter_temp = [mpl_out.hk.filter_temp, mpl_in.hk.filter_temp];
        mpl_out.hk.bg = [mpl_out.hk.bg, mpl_in.hk.bg];
        mpl_out.hk.energy_monitor = [mpl_out.hk.energy_monitor, mpl_in.hk.energy_monitor];
        mpl_out.hk.zenith_angle = [mpl_out.hk.zenith_angle, mpl_in.hk.zenith_angle];
        mpl_out.hk.shots_summed = [mpl_out.hk.shots_summed, mpl_in.hk.shots_summed];
        if isfield(mpl_in, 'pol_mode')
            mpl_out.pol_mode.odd_even = [mpl_out.pol_mode.odd_even, mpl_in.pol_mode.odd_even ];
            mpl_out.pol_mode.odd_even_span = [mpl_out.pol_mode.odd_even_span, mpl_in.pol_mode.odd_even_span ];
            mpl_out.pol_mode.gt_mean_span = [mpl_out.pol_mode.gt_mean_span, mpl_in.pol_mode.gt_mean_span ];
        end
        mpl_out.rawcts = [mpl_out.rawcts, mpl_in.rawcts];
    end
else
    if isempty(mpl_out)
        mpl_out.statics = mpl_in.statics;
        mpl_out.range = mpl_in.range;
        mpl_out.r = mpl_in.r;
        mpl_out.time = [mpl_in.time(mpl_times)];
        mpl_out.hk.instrument_temp = [mpl_in.hk.instrument_temp(mpl_times)];
        mpl_out.hk.laser_temp = [mpl_in.hk.laser_temp(mpl_times)];
        mpl_out.hk.detector_temp = [mpl_in.hk.detector_temp(mpl_times)];
        mpl_out.hk.filter_temp = [mpl_in.hk.filter_temp(mpl_times)];
        mpl_out.hk.bg = [mpl_in.hk.bg(mpl_times)];
        mpl_out.hk.energy_monitor = [mpl_in.hk.energy_monitor(mpl_times)];
        mpl_out.hk.zenith_angle = [mpl_in.hk.zenith_angle(mpl_times)];
        mpl_out.hk.shots_summed = [mpl_in.hk.shots_summed(mpl_times)];
        if isfield(mpl_in, 'pol_mode')
            mpl_out.pol_mode.odd_even = [mpl_in.pol_mode.odd_even ];
            mpl_out.pol_mode.odd_even_span = [mpl_in.pol_mode.odd_even_span ];
            mpl_out.pol_mode.gt_mean_span = [mpl_in.pol_mode.gt_mean_span ];
        end
        mpl_out.rawcts = [mpl_in.rawcts(:,mpl_times)];
    else
        mpl_out.time = [mpl_out.time , mpl_in.time(mpl_times)];
        mpl_out.hk.instrument_temp = [mpl_out.hk.instrument_temp, mpl_in.hk.instrument_temp(mpl_times)];
        mpl_out.hk.laser_temp = [mpl_out.hk.laser_temp, mpl_in.hk.laser_temp(mpl_times)];
        mpl_out.hk.detector_temp = [mpl_out.hk.detector_temp, mpl_in.hk.detector_temp(mpl_times)];
        mpl_out.hk.filter_temp = [mpl_out.hk.filter_temp, mpl_in.hk.filter_temp(mpl_times)];
        mpl_out.hk.bg = [mpl_out.hk.bg, mpl_in.hk.bg(mpl_times)];
        mpl_out.hk.energy_monitor = [mpl_out.hk.energy_monitor, mpl_in.hk.energy_monitor(mpl_times)];
        mpl_out.hk.zenith_angle = [mpl_out.hk.zenith_angle, mpl_in.hk.zenith_angle(mpl_times)];
        mpl_out.hk.shots_summed = [mpl_out.hk.shots_summed, mpl_in.hk.shots_summed(mpl_times)];
        if isfield(mpl_in, 'pol_mode')
            mpl_out.pol_mode.odd_even = [mpl_out.pol_mode.odd_even, mpl_in.pol_mode.odd_even(mpl_times) ];
            mpl_out.pol_mode.odd_even_span = [mpl_out.pol_mode.odd_even_span, mpl_in.pol_mode.odd_even_span(mpl_times) ];
            mpl_out.pol_mode.gt_mean_span = [mpl_out.pol_mode.gt_mean_span, mpl_in.pol_mode.gt_mean_span(mpl_times) ];
        end
        mpl_out.rawcts = [mpl_out.rawcts, mpl_in.rawcts(:,mpl_times)];
    end
end
end

function mpl_avg = avg_ps_to_mirror(mpl_in);
% mpl_avg = avg_ps_to_mirror(mpl_in);
%
% We need to be careful with the polarization.
mpl_avg.statics = mpl_in.statics;
mpl_avg.range = mpl_in.range(mpl_in.r.lte_30);
mpl_avg.height = mpl_avg.range * cos((1/180)*pi*max(mpl_in.hk.zenith_angle));
r.lte_5 = find((mpl_avg.range>.045)&(mpl_avg.range<=5));
r.lte_10 = find((mpl_avg.range>.045)&(mpl_avg.range<=10));
r.lte_15 = find((mpl_avg.range>.045)&(mpl_avg.range<=15));
r.lte_20 = find((mpl_avg.range>.045)&(mpl_avg.range<=20));
r.lte_25 = find((mpl_avg.range>.045)&(mpl_avg.range<=25));
r.lte_30 = find((mpl_avg.range>.045)&(mpl_avg.range<=30));
mpl_avg.r = r;
n=1
mirror_position = n;
for p = 2:length(mpl_in.hk.zenith_angle)
    if mpl_in.hk.zenith_angle(p)~=mpl_in.hk.zenith_angle(p-1);
        n = n+1;
    end
    mirror_position(p) = n;
end


for p = n:-1:1
    disp(['Averaging ',num2str(n-p+1), ' of ', num2str(n)])
    pos = find(mirror_position==p);
    mpl_avg.time(p) = mean(mpl_in.time(pos));
%     mpl_avg.samples(p) = length(pos);
%     mpl_avg.hk.shots_summed(p) = sum(mpl_in.hk.shots_summed(pos));
    copol_1 = find(mpl_in.pol_mode.odd_even(pos)==1);
    crosspol_1 =find(mpl_in.pol_mode.odd_even(pos)==0);
    copol_2 = find(mpl_in.pol_mode.odd_even_span(pos)==1);
    crosspol_2 =find(mpl_in.pol_mode.odd_even_span(pos)==0);
    copol_3 = find(mpl_in.pol_mode.gt_mean_span(pos)==1);
    crosspol_3 =find(mpl_in.pol_mode.gt_mean_span(pos)==0);
    mpl_avg.hk.instrument_temp(p) = mean(mpl_in.hk.instrument_temp(pos));
    mpl_avg.hk.laser_temp(p) = mean(mpl_in.hk.laser_temp(pos));
    mpl_avg.hk.detector_temp(p) = mean(mpl_in.hk.detector_temp(pos));
    mpl_avg.hk.energy_monitor(p) = mean(mpl_in.hk.energy_monitor(pos));
    mpl_avg.hk.zenith_angle(p) = mean(mpl_in.hk.zenith_angle(pos));
    mpl_avg.hk.cop_samps_1(p) = length(copol_1);
%     mpl_avg.hk.cop_samps_2(p) = length(copol_2);
%     mpl_avg.hk.cop_samps_3(p) = length(copol_3);
    mpl_avg.hk.dep_samps_1(p) = length(crosspol_1);
%     mpl_avg.hk.dep_samps_2(p) = length(crosspol_2);
%     mpl_avg.hk.dep_samps_3(p) = length(crosspol_3);         
   mpl_avg.hk.cop_bg_1(p) = mean(mpl_in.hk.bg(copol_1));
%    mpl_avg.hk.cop_bg_2(p) = mean(mpl_in.hk.bg(copol_2));
%    mpl_avg.hk.cop_bg_3(p) = mean(mpl_in.hk.bg(copol_3));
   mpl_avg.hk.dep_bg_1(p) = mean(mpl_in.hk.bg(crosspol_1));
%    mpl_avg.hk.dep_bg_2(p) = mean(mpl_in.hk.bg(cross_2));
%    mpl_avg.hk.dep_bg_3(p) = mean(mpl_in.hk.bg(cross_3));
   mpl_avg.raw_cop_1(:,p) = mean(mpl_in.rawcts(mpl_avg.r.lte_30,copol_1)')';
%    mpl_avg.raw_cop_2(:,p) = mean(mpl_in.rawcts(mpl_avg.r.lte_30,copol_2)')';
%    mpl_avg.raw_cop_3(:,p) = mean(mpl_in.rawcts(mpl_avg.r.lte_30,copol_3)')';
   mpl_avg.raw_dep_1(:,p) = mean(mpl_in.rawcts(mpl_avg.r.lte_30,crosspol_1)')';
%    mpl_avg.raw_dep_2(:,p) = mean(mpl_in.rawcts(mpl_avg.r.lte_30,crosspol_2)')';
%    mpl_avg.raw_dep_3(:,p) = mean(mpl_in.rawcts(mpl_avg.r.lte_30,crosspol_3)')';
end
end

function mpl_avg = avg_ocr_to_mirror(mpl_in);
% mpl_avg = avg_ps_to_mirror(mpl_in);
%

mpl_avg.statics = mpl_in.statics;
mpl_avg.range = mpl_in.range(mpl_in.r.lte_30);
mpl_avg.height = mpl_avg.range * cos((1/180)*pi*max(mpl_in.hk.zenith_angle));
r.lte_5 = find((mpl_avg.range>.045)&(mpl_avg.range<=5));
r.lte_10 = find((mpl_avg.range>.045)&(mpl_avg.range<=10));
r.lte_15 = find((mpl_avg.range>.045)&(mpl_avg.range<=15));
r.lte_20 = find((mpl_avg.range>.045)&(mpl_avg.range<=20));
r.lte_25 = find((mpl_avg.range>.045)&(mpl_avg.range<=25));
r.lte_30 = find((mpl_avg.range>.045)&(mpl_avg.range<=30));
mpl_avg.r = r;
n=1
mirror_position = n;
for p = 2:length(mpl_in.hk.zenith_angle)
    if mpl_in.hk.zenith_angle(p)~=mpl_in.hk.zenith_angle(p-1);
        n = n+1;
    end
    mirror_position(p) = n;
end


for p = n:-1:1
    disp(['Averaging ',num2str(n-p+1), ' of ', num2str(n)])
    pos = find(mirror_position==p);
    mpl_avg.time(p) = mean(mpl_in.time(pos));
    mpl_avg.samples(p) = length(pos);
    mpl_avg.hk.shots_summed(p) = sum(mpl_in.hk.shots_summed(pos));
    mpl_avg.hk.instrument_temp(p) = mean(mpl_in.hk.instrument_temp(pos));
    mpl_avg.hk.laser_temp(p) = mean(mpl_in.hk.laser_temp(pos));
    mpl_avg.hk.detector_temp(p) = mean(mpl_in.hk.detector_temp(pos));
    mpl_avg.hk.energy_monitor(p) = mean(mpl_in.hk.energy_monitor(pos));
    mpl_avg.hk.zenith_angle(p) = mean(mpl_in.hk.zenith_angle(pos));
    mpl_avg.rawcts(:,p) = mean(mpl_in.rawcts(:,pos)')';
end
end



function [mplps_avg, ps_dirlist] = get_ps_day(ps_dirlist, match_day );
disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(ps_dirlist))]);
   ncid = ncmex('open', [pname, ps_dirlist(i).name]);
   ps_times = nc_time(ncid);
   ncmex('close', ncid);
   if length(ps_times)>0
      new_mpl = read_mpl([pname, ps_dirlist(i).name]);
      if i==1
         current_day = floor(ps_times(1));
      end
      same_day = (floor(ps_times)==(current_day));
      next_day = (floor(ps_times)==(current_day+1));
      if ~exist('mpl', 'var')
         mpl = collect_ipa_a1(new_mpl, same_day);
      else
         mpl = collect_ipa_a1(new_mpl, same_day,mpl);
      end
      while any(next_day)
         mplps_avg = avg_ps_to_mirror(mpl);
         %output processed data
         %start afresh with new current_day and new mpl.
         mpl = collect_ipa_a1(new_mpl, next_day);
         current_day = floor(min(ps_times(next_day)));
         same_day = (floor(ps_times)==(current_day));
         next_day = (floor(ps_times)==(current_day+1));
      end
      %Now we've got the entire day of MPL-PS data.
      %Remove
   end   
end

function mpl_avg = ps_avg_calcs(mpl_avg);

   %Calculate the effective height for range at this zenith_angle
   
   for p = length(mpl_avg.time):-1:1
       mpl_avg.cop_1(:,p) = mpl_avg.raw_cop_1(:,p) - mpl_avg.hk.cop_bg_1(p);
       mpl_avg.dep_1(:,p) = mpl_avg.raw_dep_1(:,p) - mpl_avg.hk.dep_bg_1(p);
       mpl_avg.prof(:,p) = mpl_avg.cop_1(:,p)+mpl_avg.dep_1(:,p);
       mpl_avg.prof(:,p) = mpl_avg.prof(:,p) .* mpl_avg.range.^2;
       height = mpl_avg.range * cos(pi*mpl_avg.hk.zenith_angle(p)/180);
      %interpolate this height-profile to the finest height resolution
      mpl_avg.height_prof(:,p) = interp1(height, mpl_avg.prof(:,p), mpl_avg.height,'linear');
      %mpl_avg.height_prof(:,p) = smooth(height, mpl_avg.height_prof(:,p),5, 'lowess');
   end
%    mpl_avg = noise_calcs2(mpl_avg);
end

function status = output_ps_avg_to_file(ps_avg);
ps_pname = ps_avg.statics.input_pname;
ps_out_dir = [ps_pname,'/daily/'];
ps_c1_fstem = 'ipasmplpsC1.c1.';
[d_str,t_str] = strtok(datestr(ps_avg.time(1),30),'T');
hh_str = t_str(2:3);
[ps_c1_ncid, rcode] = ncmex('create', [ps_out_dir,ps_c1_fstem,d_str,'.',hh_str,'0000.nc'], 'write');
if ps_c1_ncid
    disp(['Opening ',[ps_out_dir,ps_c1_fstem,d_str,'.',hh_str,'0000.nc']])
end
ps_avg.statics.datastream = ps_c1_fstem(1:end-1);
ps_avg.statics.datalevel = 1;
ps_avg.statics.polarized = 'yes';
ps_avg.statics.ocr = 'no';
ps_avg.statics.scanning = 'yes';


ps_avg.overlap_range = ps_avg.range(find((ps_avg.range>0)&(ps_avg.range<=10)));
dims.time = ps_avg.time;
dims.range = ps_avg.range;
dims.height = ps_avg.height;
dims.overlap_range = ps_avg.overlap_range;
status = define_smpl_ps_c1(ps_c1_ncid, dims, ps_avg.statics);

%status = output_smpl_ps_c1(ps_c1_ncid, ps_avg);
status = ncmex('close', ps_c1_ncid);
end

function status = ps_avg_quicklooks(ps_avg);
        %Then output ps_avg to file


        grid = zeros([length(ps_avg.height),24*60]);
        minute = floor((ps_avg.time-floor(ps_avg.time))*24*60);

        grid(:,minute+1) = ps_avg.height_prof;
        figure(1); imagesc(serial2doy0(ps_avg.time), ps_avg.height, grid); axis('xy');
        v = axis;
        axis([v(1), v(2), 0, 10, 0, 5, 0, 5]); colorbar; zoom
        status = 1
end

function [ps_day, next_day, ps_file] = get_rest_of_day(new_ps,ps_dirlist,ps_file,current_day)
%[ps_day, next_day] = get_rest_of_day(new_ps)
statics = new_ps.statics;
next_day = (floor(new_ps.time)==(current_day+1));
while ~any(next_day)
    if ~exist('ps_day', 'var')
        ps_day = new_ps;
    else
        ps_day = collect_ipa_a1(ps_day,new_ps);
    end
    new_ps = read_mpl([new_ps.statics.input_pname, ps_dirlist(ps_file).name]);
    new_ps.statics.input_pname = statics.input_pname;
    ps_file = ps_file+1;
    %ps_times = new_ps.time;
    if isempty(new_ps.time)
        next_day = new_ps.time;
    else
        next_day = (floor(new_ps.time)==(current_day+1));
    end
end
same_day = (floor(new_ps.time)==(current_day));
ps_day = collect_ipa_a1(ps_day,new_ps, same_day);
end

function [new_mpl, file_number] = get_first_file_with_date(pname, dirlist, current_day);
%[new_mpl, file_number] = get_first_file_with_date(dirlist,current_day);
% Assumes dirlist is chronologically sorted
% current_day is a Matlab serial time
file_number = 1;
new_mpl = read_mpl([pname, dirlist(file_number).name]);
if new_mpl.time(1) >= current_day+1
    new_mpl = [];
    file_number = 1;
else
    while new_mpl.time(end)<current_day
        file_number = file_number+1;
        new_mpl = read_mpl([pname, dirlist(file_number)]);
    end
end
end

function status = ps_avg_quicklooks(ps_avg);
%status = ps_avg_quicklooks(ps_avg);
end

function status = ocr_avg_quicklooks(mpl_avg);

         grid = zeros([length(mpl_avg.height),24*60]);
         minute = floor((mpl_avg.time-floor(mpl_avg.time))*24*60);
         
         grid(:,minute+1) = mpl_avg.height_prof;
         figure(1); imagesc(serial2doy0(mpl_avg.time), mpl_avg.height, grid); axis('xy'); 
         v = axis;
         axis([v(1), v(2), 0, 10, 0, 5, 0, 5]); colorbar; zoom
         pause(1)
         %status = output_ocr_avg(mpl_avg);
%status = ocr_avg_quicklooks(ocr_avg);
end