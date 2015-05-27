function status = make_daily_ocrzangle(statics);
% status = make_daily_ocrzangle(statics);
% In progress...
% The idea here is to create daily files with ocr profiles averaged to the
% center time of the mirror position.  (This will permit easy registration
% of mplps files to the ocr profiles.)
% But we go in baby steps, first storing the averaged raw_cts, prof_r2, bg,
% and noise all referenced to range, not yet interpolated to height.
% This will set the stage for subsequent processing of overlap_corr
% profiles (only out to 7.5 to 10 km) and of height-interpolated profiles
% suitable for slant-path sensing.
%
% Store _nsamples, *_std, *_snr
% Calculate vertical heights up to 15 km,
% Also should create quicklook images sufficient for data perusal.

%disp('Please select an ipasmplocr.a1 file:');
%[dirlist,ps_pname] = dir_list('*.nc');
if nargin==0
    dir_in = ['C:\case_studies\ipa\Alldays\data\ipasmplpsC1.a1\'];
    %[ocr_dirlist,ocr_pname] = dir_list('*.nc');
    dir_out = ['C:\case_studies\ipa\Alldays\data\ipasmplocrzangle.c1\'];
else
    dir_in = statics.dir_in;
    dir_out = statics.dir_out;
end

[dirlist, dir_in] = get_dir_list(dir_in, 'ipasmplps*.nc');
file_index = 1;
while file_index <= length(dirlist)

 if exist('new_day', 'var');
     [this_day, new_day, file_index] = get_full_day(dir_in, dirlist, file_index, new_day);
     if isempty(new_day)
         clear new_day
     end
 else
     [this_day, new_day, file_index] = get_full_day(dir_in, dirlist, file_index);
 end;

 % Okay, we've got a full day of OCR data.
 % Now get the same day of MPLPS data
%  match_day = floor(this_day.time(1));
%  
%  if ~exist('ps_pname','var')
%      disp('Please select a file from the MPL-PS directory.');
%      [ps_dirlist,ps_pname] = dir_list('*.nc');
%  end
%  if exist('ps_index','var')
%      [mplps_day, ps_index] = get_this_day(ps_pname, ps_dirlist, match_day, ps_index);
%  else
%      [mplps_day, ps_index] = get_this_day(ps_pname, ps_dirlist, match_day);
%  end
% 
%  % Now compute ocr range profiles and mirror averages
%  this_day = compute_ocr_range_profs(this_day);
%  day_avg = avg_ocr_to_mirror(this_day);

end
end % end make_daily_ocrzangle

function [this_day, new_day, file_index] = get_full_day(dir_in, dirlist, file_index, new_day);
    if ~exist('new_day', 'var')
        new_day = read_mpl([dir_in, dirlist(file_index).name]);
        new_day.statics.input_pname = dir_in;
        new_day.statics.input_fname = dirlist(file_index).name;
        file_index = file_index +1;
    end

    if length(new_day.time)>0
        %if ~exist('current_date','var')
        current_date = floor(new_day.time(1));
        disp(['Processing data for ', datestr(current_date)])
        %end
        if file_index <= length(dirlist)
            [this_day, new_day, file_index] = get_rest_of_day(new_day,dirlist,file_index, current_date);
        end
%         if isempty(new_day)
%             clear new_day
%         end
    end;
end %get_full_day
function [full_day, next_day, file_index] = get_rest_of_day(new_mpl,mpl_dirlist,file_index,current_date)
%[full_day, next_day, file_indes] = get_rest_of_day(new_mpl,mpl_dirlist,file_index,current_date)
statics = new_mpl.statics;
next_day = (floor(new_mpl.time)==(current_date+1));
while (~any(next_day)&file_index<=length(mpl_dirlist)) %What happens if the first file input has some next_day records?
    if ~exist('full_day', 'var')
        full_day = new_mpl;
    else
        full_day = collect_ipa_a1(full_day,new_mpl);
    end
    new_mpl = read_mpl([new_mpl.statics.input_pname, mpl_dirlist(file_index).name]);
    new_mpl.statics.input_pname = statics.input_pname;
    file_index = file_index+1;
    %ps_times = new_mpl.time;
    if isempty(new_mpl.time)
        next_day = new_mpl.time;
    else
        next_day = (floor(new_mpl.time)==(current_date+1));
    end
end
same_day = (floor(new_mpl.time)==(current_date));
full_day = collect_ipa_a1(full_day,new_mpl, same_day);
next_day = collect_ipa_a1([],new_mpl,next_day);

end % end get_rest_of_day


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
        mpl_out.hk.bg_noise = [mpl_out.hk.bg_noise, mpl_in.hk.bg_noise];
        mpl_out.hk.energy_monitor = [mpl_out.hk.energy_monitor, mpl_in.hk.energy_monitor];
        mpl_out.hk.zenith_angle = [mpl_out.hk.zenith_angle, mpl_in.hk.zenith_angle];
        mpl_out.hk.shots_summed = [mpl_out.hk.shots_summed, mpl_in.hk.shots_summed];
        if isfield(mpl_in, 'pol_mode')
            mpl_out.pol_mode.odd_even = [mpl_out.pol_mode.odd_even, mpl_in.pol_mode.odd_even ];
            mpl_out.pol_mode.odd_even_span = [mpl_out.pol_mode.odd_even_span, mpl_in.pol_mode.odd_even_span ];
            mpl_out.pol_mode.gt_mean_span = [mpl_out.pol_mode.gt_mean_span, mpl_in.pol_mode.gt_mean_span ];
        end
        mpl_out.rawcts = [mpl_out.rawcts, mpl_in.rawcts];
        mpl_out.noise_MHz = [mpl_out.noise_MHz, mpl_in.noise_MHz];

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
        mpl_out.hk.bg_noise = [mpl_in.hk.bg_noise(mpl_times)];
        mpl_out.hk.energy_monitor = [mpl_in.hk.energy_monitor(mpl_times)];
        mpl_out.hk.zenith_angle = [mpl_in.hk.zenith_angle(mpl_times)];
        mpl_out.hk.shots_summed = [mpl_in.hk.shots_summed(mpl_times)];
        if isfield(mpl_in, 'pol_mode')
            mpl_out.pol_mode.odd_even = [mpl_in.pol_mode.odd_even ];
            mpl_out.pol_mode.odd_even_span = [mpl_in.pol_mode.odd_even_span ];
            mpl_out.pol_mode.gt_mean_span = [mpl_in.pol_mode.gt_mean_span ];
        end
        mpl_out.rawcts = [mpl_in.rawcts(:,mpl_times)];
        mpl_out.noise_MHz = [mpl_in.noise_MHz(:,mpl_times)];
    else
        mpl_out.time = [mpl_out.time , mpl_in.time(mpl_times)];
        mpl_out.hk.instrument_temp = [mpl_out.hk.instrument_temp, mpl_in.hk.instrument_temp(mpl_times)];
        mpl_out.hk.laser_temp = [mpl_out.hk.laser_temp, mpl_in.hk.laser_temp(mpl_times)];
        mpl_out.hk.detector_temp = [mpl_out.hk.detector_temp, mpl_in.hk.detector_temp(mpl_times)];
        mpl_out.hk.filter_temp = [mpl_out.hk.filter_temp, mpl_in.hk.filter_temp(mpl_times)];
        mpl_out.hk.bg = [mpl_out.hk.bg, mpl_in.hk.bg(mpl_times)];
        mpl_out.hk.bg_noise = [mpl_out.hk.bg_noise, mpl_in.hk.bg_noise(mpl_times)];
        mpl_out.hk.energy_monitor = [mpl_out.hk.energy_monitor, mpl_in.hk.energy_monitor(mpl_times)];
        mpl_out.hk.zenith_angle = [mpl_out.hk.zenith_angle, mpl_in.hk.zenith_angle(mpl_times)];
        mpl_out.hk.shots_summed = [mpl_out.hk.shots_summed, mpl_in.hk.shots_summed(mpl_times)];
        if isfield(mpl_in, 'pol_mode')
            mpl_out.pol_mode.odd_even = [mpl_out.pol_mode.odd_even, mpl_in.pol_mode.odd_even(mpl_times) ];
            mpl_out.pol_mode.odd_even_span = [mpl_out.pol_mode.odd_even_span, mpl_in.pol_mode.odd_even_span(mpl_times) ];
            mpl_out.pol_mode.gt_mean_span = [mpl_out.pol_mode.gt_mean_span, mpl_in.pol_mode.gt_mean_span(mpl_times) ];
        end
        mpl_out.rawcts = [mpl_out.rawcts, mpl_in.rawcts(:,mpl_times)];
        mpl_out.noise_MHz = [mpl_out.noise_MHz ,mpl_in.noise_MHz(:,mpl_times)];
    end
end
end % end collect_ipa_a1

%
function [this_day, ind] = get_this_day(pname, dirlist, match_day, ind);
if ~exist('ind', 'var')
    ind = 1;
end
ncid = ncmex('open', [pname dirlist(ind).name]);
in_time = nc_time(ncid);
ncmex('close',ncid);
if all(floor(in_time)>match_day) %then we're already too far in the file index, so reset index
    ind = 0;
end

while (~any(floor(in_time)==match_day))&(ind < length(dirlist))
    ind = ind+1;
    ncid = ncmex('open', [pname dirlist(ind).name]);
    in_time = nc_time(ncid);
    ncmex('close',ncid);
end
if ~any(floor(in_time)==match_day) %then we haven't found any matching data, so return an empty
    this_day = [];
else
   [this_day, new_day, ind] = get_full_day(pname, dirlist, ind);
end
end % end get_this_day

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
mirror_fullname = 'C:\case_studies\ipa\Alldays\mat_files\mirror.mat';
load(mirror_fullname, '-mat');

mpl_avg.statics = mpl_in.statics;
mpl_avg.range = mpl_in.range(mpl_in.r.lte_30);
mpl_avg.height = mpl_avg.range * cos((1/180)*pi*max(mpl_in.hk.zenith_angle));
r.lte_5 = find((mpl_avg.range>.045)&(mpl_avg.range<=5));
r.lte_10 = find((mpl_avg.range>.045)&(mpl_avg.range<=10));
r.lte_15 = find((mpl_avg.range>.045)&(mpl_avg.range<=15));
r.lte_20 = find((mpl_avg.range>.045)&(mpl_avg.range<=20));
r.lte_25 = find((mpl_avg.range>.045)&(mpl_avg.range<=25));
r.lte_30 = find((mpl_avg.range>.045)&(mpl_avg.range<=30));
r.lte_40 = find((mpl_avg.range>.045)&(mpl_avg.range<=40));
mpl_avg.r = r;
n=1;
mirror_position = n;
for p = 2:length(mpl_in.hk.zenith_angle)
    % If the mirror position changes, or if a datagap > 5 minutes occurs,
    % increment the position counter
    if ((mpl_in.hk.zenith_angle(p)~=mpl_in.hk.zenith_angle(p-1))|((24*60)*(mpl_in.time(p)-mpl_in.time(p-1))>5));
        n = n+1;
    end
    mirror_position(p) = n;
end
for p = n:-1:1
    disp(['Averaging ',num2str(n-p+1), ' of ', num2str(n)])
    pos = find(mirror_position==p);
    if length(pos)>1
        mpl_avg.hk.span(p) = mpl_in.time(pos(end))-mpl_in.time(pos(1));
        mpl_avg.hk.zenith_angle(p) = mean(mpl_in.hk.zenith_angle(pos));
        mpl_avg.hk.nsamples(p) = length(pos);
        mpl_avg.hk.shots_summed(p) = sum(mpl_in.hk.shots_summed(pos));
        % standard mean
        
        avg_mpl_time = mean(mpl_in.time(pos));
        mirror_time = find((mirror.start_time <= avg_mpl_time)&(mirror.end_time >= avg_mpl_time));
        mpl_avg.time(p) = (mirror.start_time(mirror_time)+mirror.end_time(mirror_time))/2;
        
        mpl_avg.hk.instrument_temp(p) = mean(mpl_in.hk.instrument_temp(pos));
        mpl_avg.hk.laser_temp(p) = mean(mpl_in.hk.laser_temp(pos));
        mpl_avg.hk.detector_temp(p) = mean(mpl_in.hk.detector_temp(pos));
        mpl_avg.hk.energy_monitor(p) = mean(mpl_in.hk.energy_monitor(pos));
        mpl_avg.hk.bg(p) = mean(mpl_in.hk.bg(pos));
        mpl_avg.hk.bg_noise(p) = mean(mpl_in.hk.bg_noise(pos))./sqrt(length(pos));
        %standard deviations
        mpl_avg.hk.bg_std(p) = std(mpl_in.hk.bg(pos));
        mpl_avg.hk.energy_monitor_std(p) = std(mpl_in.hk.energy_monitor(pos));
        %n-dim mean
        mpl_avg.rawcts(:,p) = mean(mpl_in.rawcts(:,pos)')';
        mpl_avg.range_prof(:,p) = mean(mpl_in.prof(:,pos)')';
        mpl_avg.noise_MHz(:,p) = mean(mpl_in.noise_MHz(:,pos)')'/sqrt(length(pos));
        mpl_avg.range_prof_snr(:,p) = mean(mpl_in.prof_snr(:,pos)')'/sqrt(length(pos));
    elseif length(pos)==1
        mpl_avg.hk.span(p) = mpl_in.time(2)-mpl_in.time(1);
        mpl_avg.hk.zenith_angle(p) = (mpl_in.hk.zenith_angle(pos));
        mpl_avg.hk.nsamples(p) = length(pos);
        mpl_avg.hk.shots_summed(p) = (mpl_in.hk.shots_summed(pos));
        mpl_avg.time(p) = (mpl_in.time(pos));
        mpl_avg.hk.instrument_temp(p) = (mpl_in.hk.instrument_temp(pos));
        mpl_avg.hk.laser_temp(p) = (mpl_in.hk.laser_temp(pos));
        mpl_avg.hk.detector_temp(p) = (mpl_in.hk.detector_temp(pos));
        mpl_avg.hk.energy_monitor(p) = (mpl_in.hk.energy_monitor(pos));
        mpl_avg.hk.bg(p) = (mpl_in.hk.bg(pos));
        mpl_avg.hk.bg_noise(p) = mpl_in.hk.bg_noise(pos);
        mpl_avg.hk.bg_std(p) = mpl_in.hk.bg(pos);
        mpl_avg.hk.energy_monitor_std(p) = (mpl_in.hk.energy_monitor(pos));;
        mpl_avg.rawcts(:,p) = (mpl_in.rawcts(:,pos));
        mpl_avg.range_prof(:,p) = (mpl_in.prof(:,pos));
        mpl_avg.noise_MHz(:,p) = mpl_in.noise_MHz(:,pos);
        mpl_avg.range_prof_snr(:,p) = mpl_in.prof_snr(:,pos);
    else
        disp(['Pos is zero?'])
    end
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

function mplps = add_pol_mode(mplps);
span = 60;
mplps.statics.pol_test_span = span;
sig = mplps.rawcts(3:100,:) - ones(size(mplps.range(3:100)))*mplps.hk.bg;
summed_sig = sum(sig);
if length(mplps.time)>1
    mplps.pol_mode.odd_even = 0*mplps.time;
    odd_mean = mean(summed_sig(1:2:end));
    even_mean = mean(summed_sig(2:2:end));
    if odd_mean>even_mean
        mplps.pol_mode.odd_even(1:2:end) = 1;
    else
        mplps.pol_mode.odd_even(2:2:end) = 1;
    end
    edge = span;
    mplps.pol_mode.odd_even_span = 0*mplps.time;
    mplps.pol_mode.lt_gt_mean_span = 0*mplps.time;
    while edge < length(mplps.time)-span
        odds = [1+edge-span:2:edge];
        evens = [2+edge-span:2:edge];
        odd_mean = mean(summed_sig(odds));
        even_mean =mean(summed_sig(evens));
        if odd_mean>even_mean
            mplps.pol_mode.odd_even_span(odds) = 1;
        else
            mplps.pol_mode.odd_even_span(evens) = 1;
        end
        edge = edge + span;
    end
    odds = [1+edge-span:2:length(mplps.time)];
    evens = [2+edge-span:2:length(mplps.time)];
    odd_mean = mean(summed_sig(odds));
    even_mean = mean(summed_sig(evens));
    if odd_mean>even_mean
        mplps.pol_mode.odd_even_span(odds) = 1;
    else
        mplps.pol_mode.odd_even_span(evens) = 1;
    end
    %         figure(1);
    %         subplot(2,1,1); plot(serial2Hh(mplps.time(mplps.pol_mode.odd_even==1)), summed_sig(mplps.pol_mode.odd_even==1), 'r.',serial2Hh(mplps.time(mplps.pol_mode.odd_even==0)), summed_sig(mplps.pol_mode.odd_even==0), 'g.', serial2Hh(mplps.time(mplps.pol_mode.odd_even_span==1)), summed_sig(mplps.pol_mode.odd_even_span==1), 'ro', serial2Hh(mplps.time(mplps.pol_mode.odd_even_span==0)), summed_sig(mplps.pol_mode.odd_even_span==0), 'go')
    %         title('Compare of odd/even versus odd/even for a span.')
    %         subplot(2,1,2); plot(serial2Hh(mplps.time), mplps.pol_mode.odd_even - mplps.pol_mode.odd_even_span, 'ro')
    edge = length(mplps.time)-span;
    mplps.pol_mode.gt_mean_span = 0*mplps.time;
    while edge >= span
        window = [edge:edge+span];
        window_mean = mean(summed_sig(window));
        gt_mean = find(summed_sig(window)>window_mean);
        mplps.pol_mode.gt_mean_span(window(gt_mean)) = 1;
        edge = edge - span;
    end
    window = [1:edge+span];
    window_mean = mean(summed_sig(window));
    gt_mean = find(summed_sig(window)>window_mean);
    mplps.pol_mode.gt_mean_span(window(gt_mean)) = 1;
    %         figure(2);
    %         subplot(2,1,1)
    %         plot(serial2Hh(mplps.time(mplps.pol_mode.odd_even==1)), summed_sig(mplps.pol_mode.odd_even==1), 'r.',serial2Hh(mplps.time(mplps.pol_mode.odd_even==0)), summed_sig(mplps.pol_mode.odd_even==0), 'g.', serial2Hh(mplps.time(mplps.pol_mode.gt_mean_span==1)), summed_sig(mplps.pol_mode.gt_mean_span==1), 'ro', serial2Hh(mplps.time(mplps.pol_mode.gt_mean_span==0)), summed_sig(mplps.pol_mode.gt_mean_span==0), 'go')
    %         title('Compare of odd/even versus gt mean for a span.')
    %         subplot(2,1,2); plot(serial2Hh(mplps.time), mplps.pol_mode.odd_even - mplps.pol_mode.gt_mean_span, 'ro')
    
else
    disp(['Skipping this empty file.'])
end
end %end of add_pol_mode function

function mpl = compute_ocr_range_profs(mpl);
%mpl = compute_range_profs(mpl)
%This function computes range-corrected profiles from dtc-corrected data.
%It is intended to be use replaceable sub-functions so improved versions of
%afterpulse, overlap, and so on can be applied as they become available.
% Error propagation applied at each appropriate stage

%Define range > bg
mpl.r.lt_bg = find((mpl.range>=0)&(mpl.range < mpl.range(mpl.r.bg(1))));
mpl.r.lte_40 = find((mpl.range>=0)&(mpl.range <= 40));
%Afterpulse subtract

%Background subtract

mpl.prof = mpl.rawcts(mpl.r.lte_40,:) - ones(size(mpl.r.lte_40))*mpl.hk.bg;
mpl.prof_snr = mpl.prof ./ mpl.noise_MHz(mpl.r.lte_40,:);

%Range-dependent dtc

%Range-squared
mpl.prof = mpl.prof .* (mpl.range(mpl.r.lte_40)*ones(size(mpl.time)));
mpl.prof = mpl.prof .* (mpl.range(mpl.r.lte_40)*ones(size(mpl.time)));

%Temp-dependent molecular profile?
%Acid-test versus molecular?
%Far-range correct?

end %end of compute_range_profs
    %for i = 1:length(dirlist);
    %disp(['Processing ', dirlist(file_index).name, ' : ', num2str(file_index), ' of ', num2str(length(dirlist))]);
%     if ~exist('new_day', 'var')
%         new_day = read_mpl([dir_in, dirlist(file_index).name]);
%         new_day.statics.input_pname = dir_in;
%         new_day.statics.input_fname = dirlist(file_index).name;
%         file_index = file_index +1;
%     end
% 
%     if length(new_day.time)>0
%         %if ~exist('current_date','var')
%         current_date = floor(new_day.time(1));
%         disp(['Processing data for ', datestr(current_date)])
%         %end
%         if file_index <= length(dirlist)
%             [this_day, new_day, file_index] = get_rest_of_day(new_day,dirlist,file_index, current_date);
%         end
%         if isempty(new_day)
%             clear new_day
%         end
%     end;