function status = make_hourly_ocrzangle(statics);
% status = make_daily_ocrzangle(statics);
% In progress...
% The idea here is to create hourly files with ocr profiles averaged to the
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
%     dir_in = ['C:\case_studies\ipa\Alldays\data\ipasmplpsC1.a1\'];
    %[ocr_dirlist,ocr_pname] = dir_list('*.nc');
    dir_out = ['C:\case_studies\ipa\Alldays\data\ipasmplocrzangle.c1\no_time\'];
    ocr_pname = ['C:\case_studies\ipa\Alldays\data\ipasmplocrC1.a1\'];
%     ps_pname = ['C:\case_studies\ipa\Alldays\data\ipasmplpsC1.a1\'];
else
    dir_in = statics.dir_in;
    dir_out = statics.dir_out;
end
%%!!
statics.fstem = 'ipasmplzangle.c1';
statics.datastream = statics.fstem ;
statics.datalevel = 'c1';
statics.polarized = 'no';
statics.ocr = 'yes';
statics.scanning = 'yes';
statics.averaging_int = '60 seconds';
statics.pname = dir_out;
%%!!


if ~exist('ocr_pname','var')
    disp('Please select a file from the OCR directory.');
    [ocr_dirlist,ocr_pname] = dir_list('*.nc');
else
    ocr_dirlist = get_dir_list(ocr_pname, ['*.nc']);
end
%
% if ~exist('ps_pname','var')
%     disp('Please select a file from the MPL-PS directory.');
%     [ps_dirlist,ps_pname] = dir_list('*.nc');
% else
%     ps_dirlist = get_dir_list(ps_pname, ['*.nc']);
% end

mirror_fullname = 'C:\case_studies\ipa\Alldays\mat_files\mirror.mat';
load(mirror_fullname, '-mat');
fixed_angles = unique(round(10*mirror.angle)/10);
%overlap_by_angle = NaN([332,length(fixed_angles)]);
mirror.mid_time = (mirror.start_time+mirror.end_time)/2;
mirror.mid_hour = mirror.mid_time * 24;
mir_ind = 1;
% mir_ind = 10000;
while mir_ind < length(mirror.start_time)
    hour = floor(mirror.mid_hour(mir_ind));
    this_hour.mir = find(floor(mirror.mid_hour)==hour);
    mir_ind = this_hour.mir(end) +1; %This should be the first point from the next hour
    disp(['Collecting data for ', datestr(mirror.start_time(this_hour.mir(1)))]);

    %Now that we've identified the relevant mirror indices for this hour,
    %get the OCR and MPLPS data for this hour too.

    if exist('ocr_index','var')
        [ocr_hour, ocr_index] = get_this_hour(ocr_pname, ocr_dirlist, hour, ocr_index);
    else
        [ocr_hour, ocr_index] = get_this_hour(ocr_pname, ocr_dirlist, hour);
    end
    if ~isempty(ocr_hour)
        disp(['  Read MPL-OCR data for ', datestr(ocr_hour.time(1))]);
        ocr_hour = compute_range_profs(ocr_hour);
        ocr_hour_mavg = avg_ocr_to_mirror(ocr_hour, mirror,this_hour.mir);
    else
        disp(['  No MPL-OCR data!']);
        ocr_hour_mavg = [];
    end

    %     if exist('ps_index','var')
    %         [mplps_hour, ps_index] = get_this_hour(ps_pname, ps_dirlist, hour, ps_index);
    %     else
    %         [mplps_hour, ps_index] = get_this_hour(ps_pname, ps_dirlist, hour);
    %     end
    %     if ~isempty(mplps_hour)
    %         disp(['  Read MPL-PS data for ', datestr(mplps_hour.time(1))]);
    %         mplps_hour = add_pol_mode(mplps_hour);
    %         mplps_hour = compute_range_profs(mplps_hour);
    %         mplps_hour_mavg = avg_ps_to_mirror(mplps_hour, mirror, this_hour.mir);
    %     else
    %         disp(['  No MPL-PS data! ']);
    %         mplps_hour_mavg = [];
    %     end

    ocr_hour_mavg.fixed_angles = fixed_angles;
    if ~isempty(ocr_hour)

        disp(['Writing out data for ', datestr(mirror.start_time(this_hour.mir(1)))]);
        %disp(['Writing out data for ', datestr(mplps_hour_mavg.time(1))]);
        status = output_ocr_hour_mavg(ocr_hour_mavg, statics);
        disp('.')
    end
end % end make_daily_ocrzangle
end

function [this_hour, new_hour, file_index] = get_full_hour(dir_in, dirlist, file_index, new_hour);
if ~exist('new_hour', 'var')
    new_hour = read_mpl([dir_in, dirlist(file_index).name]);
    new_hour.statics.input_pname = dir_in;
    new_hour.statics.input_fname = dirlist(file_index).name;
    file_index = file_index +1;
end

if length(new_hour.time)>0
    %if ~exist('current_date','var')
    current_date = floor(new_hour.time(1));
    current_hour = floor(24*new_hour.time(1));
    %disp(['Processing data for ', datestr(new_hour.time(1))])
    %end
    if file_index <= length(dirlist)
        [this_hour, new_hour, file_index] = get_rest_of_hour(new_hour,dirlist,file_index, current_hour);
    end
    %         if isempty(new_hour)
    %             clear new_hour
    %         end
end;
end %get_full_hour

function [full_hour, next_hour, file_index] = get_rest_of_hour(new_mpl,mpl_dirlist,file_index,current_hour)
%[full_hour, next_hour, file_indes] = get_rest_of_hour(new_mpl,mpl_dirlist,file_index,current_hour)
statics = new_mpl.statics;
this_hour = (floor(24*new_mpl.time)==(current_hour));
while (any(this_hour)&(file_index<=length(mpl_dirlist))) %What happens if the first file input has some next_hour records?
    if ~exist('full_hour', 'var')
        full_hour = new_mpl;
    else
        full_hour = collect_ipa_a1(full_hour,new_mpl);
    end
    new_mpl = read_mpl([new_mpl.statics.input_pname, mpl_dirlist(file_index).name]);
    new_mpl.statics.input_pname = statics.input_pname;
    file_index = file_index+1;
    %ps_times = new_mpl.time;
    if isempty(new_mpl.time)
        next_hour = new_mpl.time;
        this_hour = new_mpl.time;
    else
        this_hour = (floor(24*new_mpl.time)==(current_hour));
        next_hour = (floor(24*new_mpl.time)==(current_hour+1));
    end
end
same_hour = (floor(24*new_mpl.time)==(current_hour));
full_hour = collect_ipa_a1(full_hour,new_mpl, same_hour);
next_hour = collect_ipa_a1([],new_mpl,next_hour);

end % end get_rest_of_hour

function [this_hour, ind] = get_this_hour(pname, dirlist, match_hour, ind);
if ~exist('ind', 'var')
    ind = 1;
end
% inc = 1;
if ind < length(dirlist)
    ncid = ncmex('open', [pname dirlist(ind).name]);
    in_time = nc_time(ncid);
    ncmex('close',ncid);
    % if all(floor(24*in_time)>match_hour) %then we're already too far in the file index, so reset index
    %     inc = -1;
    % end

    while (~any(floor(24*in_time)==match_hour)&(~all(floor(24*in_time)>(match_hour+1)))&(ind < length(dirlist)))
        ind = ind+1;
        ncid = ncmex('open', [pname dirlist(ind).name]);
        in_time = nc_time(ncid);
        ncmex('close',ncid);
    end
    ind = ind;
    while (~any(floor(24*in_time)==match_hour)&(~all(floor(24*in_time)<(match_hour+1)))&(ind > 1))
        ind = ind-1;
        ncid = ncmex('open', [pname dirlist(ind).name]);
        in_time = nc_time(ncid);
        ncmex('close',ncid);
    end
    ind = ind;
    if ~any(floor(24*in_time)==match_hour) %then we haven't found any matching data, so return an empty
        this_hour = [];
    else
        [this_hour, new_hour, ind] = get_full_hour(pname, dirlist, ind);
    end
    if ind ==0
        ind =1;
    end
else
    this_hour = [];
end
end % end get_this_hour

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

function mpl_avg = avg_ocr_to_mirror(mpl_in, mirror, mirror_ind);
% mpl_avg = avg_ocr_to_mirror(mpl_in, mirror);
%
mpl_avg.statics = mpl_in.statics;
mpl_avg.range = mpl_in.range;
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
%for p = n:-1:1
for p = length(mirror_ind):-1:1
    % disp(['Averaging ',num2str(n-p+1), ' of ', num2str(n)])
    pos = find(mirror_position==p);
    mpl_avg.time(p) = mirror.mid_time(mirror_ind(p));
    mpl_avg.hk.zenith_angle(p) = mirror.angle(mirror_ind(p));
    mpl_avg.hk.span(p) = 24*60*60*(mirror.end_time(mirror_ind(p))-mirror.start_time(mirror_ind(p)));
    if length(pos)>1
        %         mpl_avg.hk.span(p) = mpl_in.time(pos(end))-mpl_in.time(pos(1));
        %         mpl_avg.hk.zenith_angle(p) = mean(mpl_in.hk.zenith_angle(pos));
        mpl_avg.hk.nsamples(p) = length(pos);
        mpl_avg.hk.shots_summed(p) = sum(mpl_in.hk.shots_summed(pos));
        % standard mean

        %         avg_mpl_time = mean(mpl_in.time(pos));
        %         mirror_time = find((mirror.start_time <= avg_mpl_time)&(mirror.end_time >= avg_mpl_time));
        %         mpl_avg.time(p) = (mirror.start_time(mirror_time)+mirror.end_time(mirror_time))/2;

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
        %         mpl_avg.hk.span(p) = mpl_in.time(2)-mpl_in.time(1);
        %         mpl_avg.hk.zenith_angle(p) = (mpl_in.hk.zenith_angle(pos));
        mpl_avg.hk.nsamples(p) = length(pos);
        mpl_avg.hk.shots_summed(p) = (mpl_in.hk.shots_summed(pos));
        %         mpl_avg.time(p) = (mpl_in.time(pos));
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
        %         disp(['  Pos is zero for p=',num2str(p),'  ',datestr(mpl_avg.time(p))])
        %         mpl_avg.hk.span(p) = NaN;
        %         mpl_avg.hk.zenith_angle(p) = NaN;
        mpl_avg.hk.nsamples(p) = 0;
        mpl_avg.hk.shots_summed(p) = 0;
        %         mpl_avg.time(p) = (NaN);
        mpl_avg.hk.instrument_temp(p) = NaN;
        mpl_avg.hk.laser_temp(p) = NaN;
        mpl_avg.hk.detector_temp(p) = NaN;
        mpl_avg.hk.energy_monitor(p) = NaN;
        mpl_avg.hk.bg(p) = NaN;
        mpl_avg.hk.bg_noise(p) = NaN;
        mpl_avg.hk.bg_std(p) = NaN;
        mpl_avg.hk.energy_monitor_std(p) = NaN;
        mpl_avg.rawcts(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.noise_MHz(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof_snr(:,p) = NaN(size(mpl_in.prof(:,1)));

    end
end
for p = length(mpl_avg.time):-1:1
    height = mpl_avg.range * cos(pi*mpl_avg.hk.zenith_angle(p)/180);
    %interpolate this height-profile to the finest height resolution
    mpl_avg.height_prof(:,p) = interp1(height, mpl_avg.range_prof(:,p), mpl_avg.height,'linear');
    mpl_avg.height_prof(:,p) = smooth(height, mpl_avg.height_prof(:,p),5, 'lowess');
end

end

function mpl_avg = avg_ps_to_mirror(mpl_in, mirror, mirror_ind);
% mpl_avg = avg_ps_to_mirror(mpl_in, mirror);
%  Have discontinued use of pol_mode 1 and 3 in favor of 2.
%  To catch HW problems (like non-switching mode) try a variable
% width span with pol_mode_2
mpl_avg.statics = mpl_in.statics;
mpl_avg.range = mpl_in.range;
% mpl_avg.height = mpl_avg.range * cos((1/180)*pi*max(mpl_in.hk.zenith_angle));
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
%for p = n:-1:1
for p = length(mirror_ind):-1:1
    %disp(['Averaging ',num2str(n-p+1), ' of ', num2str(n)])
    pos = find(mirror_position==p);
    mpl_avg.time(p) = mirror.mid_time(mirror_ind(p));
    mpl_avg.hk.zenith_angle(p) = mirror.angle(mirror_ind(p));
    %mpl_avg.hk.span(p) = mirror.end_time(mirror_ind(p))-mirror.start_time(mirror_ind(p));
    mpl_avg.hk.span(p) = 24*60*60*(mirror.end_time(mirror_ind(p))-mirror.start_time(mirror_ind(p)));
    if length(pos)>1

        %         mpl_avg.hk.zenith_angle(p) = mean(mpl_in.hk.zenith_angle(pos));
        mpl_avg.hk.nsamples(p) = length(pos);
        mpl_avg.hk.shots_summed(p) = sum(mpl_in.hk.shots_summed(pos));
        % standard mean

        %         avg_mpl_time = mean(mpl_in.time(pos));
        %         mirror_time = find((mirror.start_time <= avg_mpl_time)&(mirror.end_time >= avg_mpl_time));
        %         mpl_avg.time(p) = (mirror.start_time(mirror_time)+mirror.end_time(mirror_time))/2;

        mpl_avg.hk.instrument_temp(p) = mean(mpl_in.hk.instrument_temp(pos));
        mpl_avg.hk.laser_temp(p) = mean(mpl_in.hk.laser_temp(pos));
        mpl_avg.hk.detector_temp(p) = mean(mpl_in.hk.detector_temp(pos));
        mpl_avg.hk.energy_monitor(p) = mean(mpl_in.hk.energy_monitor(pos));

        %standard deviation
        mpl_avg.hk.energy_monitor_std(p) = std(mpl_in.hk.energy_monitor(pos));
        copol = find(mpl_in.pol_mode.odd_even_span(pos)==1);
        copol = pos(copol);
        cross =find(mpl_in.pol_mode.odd_even_span(pos)==0);
        cross = pos(cross);
        mpl_avg.hk.cop_nsamples(p) = length(copol);
        mpl_avg.hk.crs_nsamples(p) = length(cross);
        mpl_avg.hk.cop_shots_summed(p) = sum(mpl_in.hk.shots_summed(copol));
        mpl_avg.hk.crs_shots_summed(p) = sum(mpl_in.hk.shots_summed(cross));

        if length(copol)>1
            mpl_avg.hk.cop_bg(p) = mean(mpl_in.hk.bg(copol));
            mpl_avg.hk.cop_bg_noise(p) = mean(mpl_in.hk.bg_noise(copol))./sqrt(length(copol));
            %standard deviations
            mpl_avg.hk.cop_bg_std(p) = std(mpl_in.hk.bg(copol));
            %n-dim mean
            mpl_avg.copol(:,p) = mean(mpl_in.prof(:,copol)')';
            mpl_avg.cop_snr(:,p) = mean(mpl_in.prof_snr(:,copol)')'/sqrt(length(copol));
            mpl_avg.cop_noise(:,p) = mean(mpl_in.noise_MHz(:,copol)')'/sqrt(length(copol));
        elseif length(copol)==1
            mpl_avg.hk.cop_bg(p) = (mpl_in.hk.bg(copol));
            mpl_avg.hk.cop_bg_noise(p) = (mpl_in.hk.bg_noise(copol));
            %standard deviations
            mpl_avg.hk.cop_bg_std(p) = (mpl_in.hk.bg(copol));
            %n-dim mean
            mpl_avg.copol(:,p) = (mpl_in.prof(:,copol));
            mpl_avg.cop_snr(:,p) = (mpl_in.prof_snr(:,copol));
            mpl_avg.cop_noise(:,p) = (mpl_in.noise_MHz(:,copol));
        else
            disp(['Empty copol at ', datestr(mpl_in.time(p))]);
            mpl_avg.hk.cop_bg(p) = NaN;
            mpl_avg.hk.cop_bg_noise(p) = NaN;
            %standard deviations
            mpl_avg.hk.cop_bg_std(p) = NaN;
            %n-dim mean
            mpl_avg.copol(:,p) = NaN(size(mpl_in.prof(:,1)));
            mpl_avg.cop_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
            mpl_avg.cop_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        end

        if length(cross)>1
            mpl_avg.hk.crs_bg(p) = mean(mpl_in.hk.bg(cross));
            mpl_avg.hk.crs_bg_noise(p) = mean(mpl_in.hk.bg_noise(cross))./sqrt(length(cross));
            %standard deviations
            mpl_avg.hk.crs_bg_std(p) = std(mpl_in.hk.bg(cross));
            %n-dim mean
            mpl_avg.crosspol(:,p) = mean(mpl_in.prof(:,cross)')';
            mpl_avg.crs_snr(:,p) = mean(mpl_in.prof_snr(:,cross)')'/sqrt(length(cross));
            mpl_avg.crs_noise(:,p) = mean(mpl_in.noise_MHz(:,cross)')'/sqrt(length(cross));
        elseif length(cross)==1
            mpl_avg.hk.crs_bg(p) = (mpl_in.hk.bg(cross));
            mpl_avg.hk.crs_bg_noise(p) = (mpl_in.hk.bg_noise(cross));
            %standard deviations
            mpl_avg.hk.crs_bg_std(p) = (mpl_in.hk.bg(cross));
            %n-dim mean
            mpl_avg.crosspol(:,p) = (mpl_in.prof(:,cross));
            mpl_avg.crs_snr(:,p) = (mpl_in.prof_snr(:,cross));
            mpl_avg.crs_noise(:,p) = (mpl_in.noise_MHz(:,cross));
        else
            disp(['Empty cross at ', datestr(mpl_in.time(p))]);
            mpl_avg.hk.crs_bg(p) = NaN;
            mpl_avg.hk.crs_bg_noise(p) = NaN;
            %standard deviations
            mpl_avg.hk.crs_bg_std(p) = NaN;
            %n-dim mean
            mpl_avg.crosspol(:,p) = NaN(size(mpl_in.prof(:,1)));
            mpl_avg.crs_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
            mpl_avg.crs_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        end

        if ((length(copol)>=1) & (length(cross)>=1))
            goods = find((mpl_avg.copol(:,p)>0) & (mpl_avg.crosspol(:,p)>0));
            mpl_avg.dpr(:,p) = 0*mpl_avg.copol(:,p);
            mpl_avg.dpr(goods,p) = mpl_avg.crosspol(goods,p)./mpl_avg.copol(goods,p);
            mpl_avg.dpr_snr(:,p) = 0*mpl_avg.copol(:,p);
            pder1(:,p) = 0*mpl_avg.copol(:,p);
            pder2(:,p) = 0*mpl_avg.copol(:,p);
            pder1(goods,p) = mpl_avg.crs_snr(goods,p)./mpl_avg.copol(goods,p);
            pder2(goods,p) = (mpl_avg.cop_snr(goods,p).*mpl_avg.crosspol(goods,p))./(mpl_avg.copol(goods,p).^2);
            mpl_avg.dpr_snr(goods,p) = sqrt(pder1(goods,p).^2 + pder2(goods,p).^2);
            mpl_avg.range_prof(:,p) = mpl_avg.copol(:,p) + mpl_avg.crosspol(:,p);
            mpl_avg.range_prof_snr(:,p) = sqrt((mpl_avg.cop_snr(:,p).^2)+(mpl_avg.crs_snr(:,p).^2));
            mpl_avg.range_prof_noise(:,p) = sqrt((mpl_avg.cop_noise(:,p).^2)+(mpl_avg.crs_noise(:,p).^2));
        else
            disp('Empty copol or cross');

            mpl_avg.dpr(:,p) = NaN(size(mpl_in.prof(:,1)));
            mpl_avg.dpr_snr(goods,p) = NaN(size(mpl_in.prof(:,1)));

            mpl_avg.range_prof(:,p) = NaN(size(mpl_in.prof(:,1)));
            mpl_avg.range_prof_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
            mpl_avg.range_prof_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        end
        %end pol_mod_2

    elseif length(pos)==1
        %         mpl_avg.hk.span(p) = mpl_in.time(2)-mpl_in.time(1);
        %         mpl_avg.hk.zenith_angle(p) = (mpl_in.hk.zenith_angle(pos));
        mpl_avg.hk.nsamples(p) = length(pos);
        mpl_avg.hk.shots_summed(p) = (mpl_in.hk.shots_summed(pos));
        %         mpl_avg.time(p) = (mpl_in.time(pos));
        mpl_avg.hk.instrument_temp(p) = (mpl_in.hk.instrument_temp(pos));
        mpl_avg.hk.laser_temp(p) = (mpl_in.hk.laser_temp(pos));
        mpl_avg.hk.detector_temp(p) = (mpl_in.hk.detector_temp(pos));
        mpl_avg.hk.energy_monitor(p) = (mpl_in.hk.energy_monitor(pos));
        %n-dim mean
        mpl_avg.copol(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.cop_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.cop_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.crosspol(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.crs_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.crs_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.dpr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.dpr_snr(:,p) = NaN(size(mpl_in.prof(:,1)));

    else
        %         disp([   'Pos is zero for p=',num2str(p),'  ',datestr(mpl_avg.time(p))])
        %         mpl_avg.hk.span(p) = NaN;
        %         mpl_avg.hk.zenith_angle(p) = NaN;
        mpl_avg.hk.nsamples(p) = NaN;
        mpl_avg.hk.shots_summed(p) = NaN;
        %         mpl_avg.time(p) = (mpl_in.time(pos));
        mpl_avg.hk.instrument_temp(p) = NaN;
        mpl_avg.hk.laser_temp(p) = NaN;
        mpl_avg.hk.detector_temp(p) = NaN;
        mpl_avg.hk.energy_monitor(p) = NaN;
        %n-dim mean
        mpl_avg.copol(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.cop_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.cop_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.crosspol(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.crs_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.crs_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.range_prof_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.dpr(:,p) = NaN(size(mpl_in.prof(:,1)));
        mpl_avg.dpr_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
    end
end
end %avg_ps_to_mirror

function ocr = fill_ocr_with_nans(mplps);
ocr.hk.nsamples = NaN(size(mplps.time));
ocr.hk.bg = NaN(size(mplps.time));
ocr.hk.bg_std = NaN(size(mplps.time));
ocr.hk.bg_noise = NaN(size(mplps.time));
ocr.range_prof = NaN(size(mplps.range_prof));
ocr.range_prof_snr = NaN(size(mplps.range_prof));
ocr.noise_MHz = NaN(size(mplps.range_prof));

end % full_ocr_with_nans
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

function mplps = add_pol_mode(mplps, span);
% Several methods are tested for assigning polarization mode.
% Each method flags copol with a value of 1 and crosspol with 0
% Method 1: odd_even
% Signal (from bin 3:100) is compared for odd and even time records
% Whichever is greater is labelled copol
% Method 2: odd_even_span
% Same as above except window of size 'span' restricts the sample
% Span is stepped from the beginning to the end of the file.
% Method 3: gt_mean_span
% The same moving window is used but points are assigned copol
% if they exceed the mean signal value for the entire span
% This is distinct from the above methods in that it does not
% require pol mode to alternate for every record, as may happen in
% cases of hardware switching problems
if nargin<2
    span = 60;
end
mplps.pol_mode.copol = 1;
mplps.pol_mode.crosspol = 0;
mplps.statics.pol_test_span = span;
sig = mplps.rawcts(3:100,:) - ones(size(mplps.range(3:100)))*mplps.hk.bg;
summed_sig = sum(sig);

if length(mplps.time)>1
    % Method 1: odd_even
    mplps.pol_mode.odd_even = 0*mplps.time;
    odd_mean = mean(summed_sig(1:2:end));
    even_mean = mean(summed_sig(2:2:end));
    if odd_mean>even_mean
        mplps.pol_mode.odd_even(1:2:end) = 1;
    else
        mplps.pol_mode.odd_even(2:2:end) = 1;
    end
    % Method 2: odd_even_span
    mplps.pol_mode.odd_even_span = 0*mplps.time;
    edge = span;

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

    % Method 3: gt_mean_span
    mplps.pol_mode.gt_mean_span = 0*mplps.time;
    edge = length(mplps.time)-span;
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

function mpl = compute_range_profs(mpl);
%mpl = compute_range_profs(mpl);
%This function computes range-corrected profiles from dtc-corrected data.
%It is intended to be use replaceable sub-functions so improved versions of
%afterpulse, overlap, and so on can be applied as they become available.
% Error propagation applied at each appropriate stage

%Define range > bg
mpl.r.lt_bg = find((mpl.range>=0)&(mpl.range < mpl.range(mpl.r.bg(1))));
mpl.r.lte_40 = find((mpl.range>=0)&(mpl.range <= 40));
%Afterpulse subtract

%Background subtract
mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
mpl.prof = mpl.rawcts - ones(size(mpl.range))*mpl.hk.bg;
mpl.prof_snr = mpl.prof ./ mpl.noise_MHz;

%Range-dependent dtc

%Range-squared
mpl.prof = mpl.prof .* (mpl.range*ones(size(mpl.time)));
mpl.prof = mpl.prof .* (mpl.range*ones(size(mpl.time)));

%Temp-dependent molecular profile?
%Acid-test versus molecular?
%Far-range correct?

end %end of compute_range_profs

%
% function mpl_avg = avg_ps_to_mirror(mpl_in, mirror);
% % mpl_avg = avg_ps_to_mirror(mpl_in, mirror);
% %  Have discontinued use of pol_mode 1 and 3 in favor of 2.
% %  To catch HW problems (like non-switching mode) try a variable
% % width span with pol_mode_2
% mpl_avg.statics = mpl_in.statics;
% mpl_avg.range = mpl_in.range(mpl_in.r.lte_30);
% mpl_avg.height = mpl_avg.range * cos((1/180)*pi*max(mpl_in.hk.zenith_angle));
% r.lte_5 = find((mpl_avg.range>.045)&(mpl_avg.range<=5));
% r.lte_10 = find((mpl_avg.range>.045)&(mpl_avg.range<=10));
% r.lte_15 = find((mpl_avg.range>.045)&(mpl_avg.range<=15));
% r.lte_20 = find((mpl_avg.range>.045)&(mpl_avg.range<=20));
% r.lte_25 = find((mpl_avg.range>.045)&(mpl_avg.range<=25));
% r.lte_30 = find((mpl_avg.range>.045)&(mpl_avg.range<=30));
% r.lte_40 = find((mpl_avg.range>.045)&(mpl_avg.range<=40));
% mpl_avg.r = r;
% n=1;
% mirror_position = n;
% for p = 2:length(mpl_in.hk.zenith_angle)
%     % If the mirror position changes, or if a datagap > 5 minutes occurs,
%     % increment the position counter
%     if ((mpl_in.hk.zenith_angle(p)~=mpl_in.hk.zenith_angle(p-1))|((24*60)*(mpl_in.time(p)-mpl_in.time(p-1))>5));
%         n = n+1;
%     end
%     mirror_position(p) = n;
% end
% for p = n:-1:1
%     %disp(['Averaging ',num2str(n-p+1), ' of ', num2str(n)])
%     pos = find(mirror_position==p);
%     if length(pos)>1
%         mpl_avg.hk.span(p) = mpl_in.time(pos(end))-mpl_in.time(pos(1));
%         mpl_avg.hk.zenith_angle(p) = mean(mpl_in.hk.zenith_angle(pos));
%         mpl_avg.hk.nsamples(p) = length(pos);
%         mpl_avg.hk.shots_summed(p) = sum(mpl_in.hk.shots_summed(pos));
%         % standard mean
%
%         avg_mpl_time = mean(mpl_in.time(pos));
%         mirror_time = find((mirror.start_time <= avg_mpl_time)&(mirror.end_time >= avg_mpl_time));
%         mpl_avg.time(p) = (mirror.start_time(mirror_time)+mirror.end_time(mirror_time))/2;
%
%         mpl_avg.hk.instrument_temp(p) = mean(mpl_in.hk.instrument_temp(pos));
%         mpl_avg.hk.laser_temp(p) = mean(mpl_in.hk.laser_temp(pos));
%         mpl_avg.hk.detector_temp(p) = mean(mpl_in.hk.detector_temp(pos));
%         mpl_avg.hk.energy_monitor(p) = mean(mpl_in.hk.energy_monitor(pos));
%
%         %standard deviation
%         mpl_avg.hk.energy_monitor_std(p) = std(mpl_in.hk.energy_monitor(pos));
%
% %         copol_1 = find(mpl_in.pol_mode.odd_even(pos)==1);
% %         cross_1 =find(mpl_in.pol_mode.odd_even(pos)==0);
%         copol_2 = find(mpl_in.pol_mode.odd_even_span(pos)==1);
%         cross_2 =find(mpl_in.pol_mode.odd_even_span(pos)==0);
% %         copol_3 = find(mpl_in.pol_mode.gt_mean_span(pos)==1);
% %         cross_3 =find(mpl_in.pol_mode.gt_mean_span(pos)==0);
% %         mpl_avg.hk.cop1_samps(p) = length(copol_1);
% %         mpl_avg.hk.crs1_samps(p) = length(cross_1);
%         mpl_avg.hk.cop2_samps(p) = length(copol_2);
%         mpl_avg.hk.crs2_samps(p) = length(cross_2);
% %         mpl_avg.hk.cop3_samps(p) = length(copol_3);
% %         mpl_avg.hk.crs3_samps(p) = length(cross_3);
% %         mpl_avg.hk.cop1_shots_summed(p) = sum(mpl_in.hk.shots_summed(copol_1));
% %         mpl_avg.hk.crs1_shots_summed(p) = sum(mpl_in.hk.shots_summed(cross_1));
%         mpl_avg.hk.cop2_shots_summed(p) = sum(mpl_in.hk.shots_summed(copol_2));
%         mpl_avg.hk.crs2_shots_summed(p) = sum(mpl_in.hk.shots_summed(cross_2));
% %         mpl_avg.hk.cop3_shots_summed(p) = sum(mpl_in.hk.shots_summed(copol_3));
% %         mpl_avg.hk.crs3_shots_summed(p) = sum(mpl_in.hk.shots_summed(cross_3));
%
%         %for pol_mod_1
% %         if length(copol_1)>1
% %             mpl_avg.hk.cop1_bg(p) = mean(mpl_in.hk.bg(copol_1));
% %             mpl_avg.hk.cop1_bg_noise(p) = mean(mpl_in.hk.bg_noise(copol_1))./sqrt(length(copol_1));
% %             %standard deviations
% %             mpl_avg.hk.cop1_bg_std(p) = std(mpl_in.hk.bg(copol_1));
% %             %n-dim mean
% % %             mpl_avg.copol_1(:,p) = mean(mpl_in.prof(:,copol_1)')';
% % %             mpl_avg.cop1_snr(:,p) = mean(mpl_in.prof_snr(:,copol_1)')'/sqrt(length(copol_1));
% % %             mpl_avg.cop1_noise(:,p) = mean(mpl_in.noise_MHz(:,copol_1)')'/sqrt(length(copol_1));
% %         elseif length(copol_1)==1
% %             mpl_avg.hk.cop1_bg(p) = (mpl_in.hk.bg(copol_1));
% %             mpl_avg.hk.cop1_bg_noise(p) = (mpl_in.hk.bg_noise(copol_1));
% %             %standard deviations
% %             mpl_avg.hk.cop1_bg_std(p) = (mpl_in.hk.bg(copol_1));
% %             %n-dim mean
% % %             mpl_avg.copol_1(:,p) = (mpl_in.prof(:,copol_1));
% % %             mpl_avg.cop1_snr(:,p) = (mpl_in.prof_snr(:,copol_1));
% % %             mpl_avg.cop1_noise(:,p) = (mpl_in.noise_MHz(:,copol_1));
% %         else
% %             disp(['Empty copol_1 at ', datestr(mpl_in.time(p))]);
% %             mpl_avg.hk.cop1_bg(p) = NaN;
% %             mpl_avg.hk.cop1_bg_noise(p) = NaN;
% %             %standard deviations
% %             mpl_avg.hk.cop1_bg_std(p) = NaN;
% %             %n-dim mean
% % %             mpl_avg.copol_1(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.cop1_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.cop1_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         end
%
% %         if length(cross_1)>1
% %             mpl_avg.hk.crs1_bg(p) = mean(mpl_in.hk.bg(cross_1));
% %             mpl_avg.hk.crs1_bg_noise(p) = mean(mpl_in.hk.bg_noise(cross_1))./sqrt(length(cross_1));
% %             %standard deviations
% %             mpl_avg.hk.crs1_bg_std(p) = std(mpl_in.hk.bg(cross_1));
% %             %n-dim mean
% % %             mpl_avg.cross_1(:,p) = mean(mpl_in.prof(:,cross_1)')';
% % %             mpl_avg.crs1_snr(:,p) = mean(mpl_in.prof_snr(:,cross_1)')'/sqrt(length(cross_1));
% % %             mpl_avg.crs1_noise(:,p) = mean(mpl_in.noise_MHz(:,cross_1)')'/sqrt(length(cross_1));
% %         elseif length(cross_1)==1
% %             mpl_avg.hk.crs1_bg(p) = (mpl_in.hk.bg(cross_1));
% %             mpl_avg.hk.crs1_bg_noise(p) = (mpl_in.hk.bg_noise(cross_1));
% %             %standard deviations
% %             mpl_avg.hk.crs1_bg_std(p) = (mpl_in.hk.bg(cross_1));
% %             %n-dim mean
% % %             mpl_avg.cross_1(:,p) = (mpl_in.prof(:,cross_1));
% % %             mpl_avg.crs1_snr(:,p) = (mpl_in.prof_snr(:,cross_1));
% % %             mpl_avg.crs1_noise(:,p) = (mpl_in.noise_MHz(:,cross_1));
% %         else
% %             disp(['Empty cross_1 at ', datestr(mpl_in.time(p))]);
% %             mpl_avg.hk.crs1_bg(p) = NaN;
% %             mpl_avg.hk.crs1_bg_noise(p) = NaN;
% %             %standard deviations
% %             mpl_avg.hk.crs1_bg_std(p) = NaN;
% %             %n-dim mean
% % %             mpl_avg.cross_1(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.crs1_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.crs1_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         end
% %
% %         if ((length(copol_1)>=1)&(length(cross_1)>=1))
% % %             goods = find(mpl_avg.copol_1(:,p)>0 & mpl_avg.cross_1>0(:,p))
% % %             mpl_avg.dpr1(:,p) = 0*mpl_avg.copol_1(:,p);
% % %             mpl_avg.dpr1(goods,p) = mpl_avg.cross_1(goods,p)./mpl_avg.copol_1(goods,p);
% % %             mpl_avg.dpr1_snr(:,p) = 0*mpl_avg.copol_1(:,p);
% % %             pder1(:,p) = 0*mpl_avg.copol_1(:,p);
% % %             pder2(:,p) = 0*mpl_avg.copol_1(:,p);
% % %             pder1(goods,p) = mpl_avg.crs1_snr(goods,p)./mpl_avg.copol_1(goods,p);
% % %             pder2(goods,p) = (mpl_avg.cop1_snr(goods,p).*mpl_avg.cross_1(goods,p))./(mpl_avg.copol_1(goods,p).^2);
% % %             mpl_avg.dpr1_snr(goods,p) = sqrt(pder1(goods,p).^2 + pder2(goods,p).^2);
% % %             mpl_avg.range_prof1(:,p) = mpl_avg.copol_1(:,p) + mpl_avg.cross_1(:,p);
% % %             mpl_avg.range_prof1_snr(:,p) = sqrt((mpl_avg.cop1_snr(:,p).^2)+(mpl_avg.crs1_snr(:,p).^2));
% % %             mpl_avg.range_prof1_noise(:,p) = sqrt((mpl_avg.cop1_noise(:,p).^2)+(mpl_avg.crs1_noise(:,p).^2));
% %         else
% % %             mpl_avg.dpr1(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.dpr1_snr(goods,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.range_prof1(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.range_prof1_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.range_prof1_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         end
% %         %end pol_mod_1
%         %for pol_mod_2
%         if length(copol_2)>1
%             mpl_avg.hk.cop2_bg(p) = mean(mpl_in.hk.bg(copol_2));
%             mpl_avg.hk.cop2_bg_noise(p) = mean(mpl_in.hk.bg_noise(copol_2))./sqrt(length(copol_2));
%             %standard deviations
%             mpl_avg.hk.cop2_bg_std(p) = std(mpl_in.hk.bg(copol_2));
%             %n-dim mean
%             mpl_avg.copol_2(:,p) = mean(mpl_in.prof(:,copol_2)')';
%             mpl_avg.cop2_snr(:,p) = mean(mpl_in.prof_snr(:,copol_2)')'/sqrt(length(copol_2));
%             mpl_avg.cop2_noise(:,p) = mean(mpl_in.noise_MHz(:,copol_2)')'/sqrt(length(copol_2));
%         elseif length(copol_2)==1
%             mpl_avg.hk.cop2_bg(p) = (mpl_in.hk.bg(copol_2));
%             mpl_avg.hk.cop2_bg_noise(p) = (mpl_in.hk.bg_noise(copol_2));
%             %standard deviations
%             mpl_avg.hk.cop2_bg_std(p) = (mpl_in.hk.bg(copol_2));
%             %n-dim mean
%             mpl_avg.copol_2(:,p) = (mpl_in.prof(:,copol_2));
%             mpl_avg.cop2_snr(:,p) = (mpl_in.prof_snr(:,copol_2));
%             mpl_avg.cop2_noise(:,p) = (mpl_in.noise_MHz(:,copol_2));
%         else
%             disp(['Empty copol_2 at ', datestr(mpl_in.time(p))]);
%             mpl_avg.hk.cop2_bg(p) = NaN;
%             mpl_avg.hk.cop2_bg_noise(p) = NaN;
%             %standard deviations
%             mpl_avg.hk.cop2_bg_std(p) = NaN;
%             %n-dim mean
%             mpl_avg.copol_2(:,p) = NaN(size(mpl_in.prof(:,1)));
%             mpl_avg.cop2_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
%             mpl_avg.cop2_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%         end
%
%         if length(cross_2)>1
%             mpl_avg.hk.crs2_bg(p) = mean(mpl_in.hk.bg(cross_2));
%             mpl_avg.hk.crs2_bg_noise(p) = mean(mpl_in.hk.bg_noise(cross_2))./sqrt(length(cross_2));
%             %standard deviations
%             mpl_avg.hk.crs2_bg_std(p) = std(mpl_in.hk.bg(cross_2));
%             %n-dim mean
%             mpl_avg.cross_2(:,p) = mean(mpl_in.prof(:,cross_2)')';
%             mpl_avg.crs2_snr(:,p) = mean(mpl_in.prof_snr(:,cross_2)')'/sqrt(length(cross_2));
%             mpl_avg.crs2_noise(:,p) = mean(mpl_in.noise_MHz(:,cross_2)')'/sqrt(length(cross_2));
%         elseif length(cross_2)==1
%             mpl_avg.hk.crs2_bg(p) = (mpl_in.hk.bg(cross_2));
%             mpl_avg.hk.crs2_bg_noise(p) = (mpl_in.hk.bg_noise(cross_2));
%             %standard deviations
%             mpl_avg.hk.crs2_bg_std(p) = (mpl_in.hk.bg(cross_2));
%             %n-dim mean
%             mpl_avg.cross_2(:,p) = (mpl_in.prof(:,cross_2));
%             mpl_avg.crs2_snr(:,p) = (mpl_in.prof_snr(:,cross_2));
%             mpl_avg.crs2_noise(:,p) = (mpl_in.noise_MHz(:,cross_2));
%         else
%             disp(['Empty cross_2 at ', datestr(mpl_in.time(p))]);
%             mpl_avg.hk.crs2_bg(p) = NaN;
%             mpl_avg.hk.crs2_bg_noise(p) = NaN;
%             %standard deviations
%             mpl_avg.hk.crs2_bg_std(p) = NaN;
%             %n-dim mean
%             mpl_avg.cross_2(:,p) = NaN(size(mpl_in.prof(:,1)));
%             mpl_avg.crs2_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
%             mpl_avg.crs2_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%         end
%
%         if ((length(copol_2)>=1) & (length(cross_2)>=1))
%             goods = find((mpl_avg.copol_2(:,p)>0) & (mpl_avg.cross_2(:,p)>0));
%             mpl_avg.dpr2(:,p) = 0*mpl_avg.copol_2(:,p);
%             mpl_avg.dpr2(goods,p) = mpl_avg.cross_2(goods,p)./mpl_avg.copol_2(goods,p);
%             mpl_avg.dpr2_snr(:,p) = 0*mpl_avg.copol_2(:,p);
%             pder1(:,p) = 0*mpl_avg.copol_2(:,p);
%             pder2(:,p) = 0*mpl_avg.copol_2(:,p);
%             pder1(goods,p) = mpl_avg.crs2_snr(goods,p)./mpl_avg.copol_2(goods,p);
%             pder2(goods,p) = (mpl_avg.cop2_snr(goods,p).*mpl_avg.cross_2(goods,p))./(mpl_avg.copol_2(goods,p).^2);
%             mpl_avg.dpr2_snr(goods,p) = sqrt(pder1(goods,p).^2 + pder2(goods,p).^2);
%             mpl_avg.range_prof2(:,p) = mpl_avg.copol_2(:,p) + mpl_avg.cross_2(:,p);
%             mpl_avg.range_prof2_snr(:,p) = sqrt((mpl_avg.cop2_snr(:,p).^2)+(mpl_avg.crs2_snr(:,p).^2));
%             mpl_avg.range_prof2_noise(:,p) = sqrt((mpl_avg.cop2_noise(:,p).^2)+(mpl_avg.crs2_noise(:,p).^2));
%         else
%             disp('Empty copol_2 or cross_2');
%
%             mpl_avg.dpr2(:,p) = NaN(size(mpl_in.prof(:,1)));
%             mpl_avg.dpr2_snr(goods,p) = NaN(size(mpl_in.prof(:,1)));
%
%             mpl_avg.range_prof2(:,p) = NaN(size(mpl_in.prof(:,1)));
%             mpl_avg.range_prof2_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
%             mpl_avg.range_prof2_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%         end
%         %end pol_mod_2
% %         %for pol_mod_3
% %         if length(copol_3)>1
% %             mpl_avg.hk.cop3_bg(p) = mean(mpl_in.hk.bg(copol_3));
% %             mpl_avg.hk.cop3_bg_noise(p) = mean(mpl_in.hk.bg_noise(copol_3))./sqrt(length(copol_3));
% %             %standard deviations
% %             mpl_avg.hk.cop3_bg_std(p) = std(mpl_in.hk.bg(copol_3));
% %             %n-dim mean
% % %             mpl_avg.copol_3(:,p) = mean(mpl_in.prof(:,copol_3)')';
% % %             mpl_avg.cop3_snr(:,p) = mean(mpl_in.prof_snr(:,copol_3)')'/sqrt(length(copol_3));
% % %             mpl_avg.cop3_noise(:,p) = mean(mpl_in.noise_MHz(:,copol_3)')'/sqrt(length(copol_3));
% %         elseif length(copol_3)==1
% %             mpl_avg.hk.cop3_bg(p) = (mpl_in.hk.bg(copol_3));
% %             mpl_avg.hk.cop3_bg_noise(p) = (mpl_in.hk.bg_noise(copol_3));
% %             %standard deviations
% %             mpl_avg.hk.cop3_bg_std(p) = (mpl_in.hk.bg(copol_3));
% %             %n-dim mean
% % %             mpl_avg.copol_3(:,p) = (mpl_in.prof(:,copol_3));
% % %             mpl_avg.cop3_snr(:,p) = (mpl_in.prof_snr(:,copol_3));
% % %             mpl_avg.cop3_noise(:,p) = (mpl_in.noise_MHz(:,copol_3));
% %         else
% %             disp(['Empty copol_3 at ', datestr(mpl_in.time(p))]);
% %             mpl_avg.hk.cop3_bg(p) = NaN;
% %             mpl_avg.hk.cop3_bg_noise(p) = NaN;
% %             %standard deviations
% %             mpl_avg.hk.cop3_bg_std(p) = NaN;
% %             %n-dim mean
% % %             mpl_avg.copol_3(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.cop3_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.cop3_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         end
% %
% %         if length(cross_3)>1
% %             mpl_avg.hk.crs3_bg(p) = mean(mpl_in.hk.bg(cross_3));
% %             mpl_avg.hk.crs3_bg_noise(p) = mean(mpl_in.hk.bg_noise(cross_3))./sqrt(length(cross_3));
% %             %standard deviations
% %             mpl_avg.hk.crs3_bg_std(p) = std(mpl_in.hk.bg(cross_3));
% %             %n-dim mean
% % %             mpl_avg.cross_3(:,p) = mean(mpl_in.prof(:,cross_3)')';
% % %             mpl_avg.crs3_snr(:,p) = mean(mpl_in.prof_snr(:,cross_3)')'/sqrt(length(cross_3));
% % %             mpl_avg.crs3_noise(:,p) = mean(mpl_in.noise_MHz(:,cross_3)')'/sqrt(length(cross_3));
% %         elseif length(cross_3)==1
% %             mpl_avg.hk.crs3_bg(p) = (mpl_in.hk.bg(cross_3));
% %             mpl_avg.hk.crs3_bg_noise(p) = (mpl_in.hk.bg_noise(cross_3));
% %             %standard deviations
% %             mpl_avg.hk.crs3_bg_std(p) = (mpl_in.hk.bg(cross_3));
% %             %n-dim mean
% % %             mpl_avg.cross_3(:,p) = (mpl_in.prof(:,cross_3));
% % %             mpl_avg.crs3_snr(:,p) = (mpl_in.prof_snr(:,cross_3));
% % %             mpl_avg.crs3_noise(:,p) = (mpl_in.noise_MHz(:,cross_3));
% %         else
% %             disp(['Empty cross_3 at ', datestr(mpl_in.time(p))]);
% %             mpl_avg.hk.crs3_bg(p) = NaN;
% %             mpl_avg.hk.crs3_bg_noise(p) = NaN;
% %             %standard deviations
% %             mpl_avg.hk.crs3_bg_std(p) = NaN;
% %             %n-dim mean
% % %             mpl_avg.cross_3(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.crs3_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.crs3_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         end
% %
% %         if ((length(copol_3)>=1)&(length(cross_3)>=1))
% % %             goods = find(mpl_avg.copol_3(:,p)>0 & mpl_avg.cross_3>0(:,p))
% % %             mpl_avg.dpr3(:,p) = 0*mpl_avg.copol_3(:,p);
% % %             mpl_avg.dpr3(goods,p) = mpl_avg.cross_3(goods,p)./mpl_avg.copol_3(goods,p);
% % %             mpl_avg.dpr3_snr(:,p) = 0*mpl_avg.copol_3(:,p);
% % %             pder1(:,p) = 0*mpl_avg.copol_3(:,p);
% % %             pder2(:,p) = 0*mpl_avg.copol_3(:,p);
% % %             pder1(goods,p) = mpl_avg.crs3_snr(goods,p)./mpl_avg.copol_3(goods,p);
% % %             pder2(goods,p) = (mpl_avg.cop3_snr(goods,p).*mpl_avg.cross_3(goods,p))./(mpl_avg.copol_3(goods,p).^2);
% % %             mpl_avg.dpr3_snr(goods,p) = sqrt(pder1(goods,p).^2 + pder2(goods,p).^2);
% % %             mpl_avg.range_prof3(:,p) = mpl_avg.copol_3(:,p) + mpl_avg.cross_3(:,p);
% % %             mpl_avg.range_prof3_snr(:,p) = sqrt((mpl_avg.cop3_snr(:,p).^2)+(mpl_avg.crs3_snr(:,p).^2));
% % %             mpl_avg.range_prof3_noise(:,p) = sqrt((mpl_avg.cop3_noise(:,p).^2)+(mpl_avg.crs3_noise(:,p).^2));
% %         else
% % %             mpl_avg.dpr3(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.dpr3_snr(goods,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.range_prof3(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.range_prof3_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% % %             mpl_avg.range_prof3_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         end
% %         %end pol_mod_3
%
%     elseif length(pos)==1
%         mpl_avg.hk.span(p) = mpl_in.time(2)-mpl_in.time(1);
%         mpl_avg.hk.zenith_angle(p) = (mpl_in.hk.zenith_angle(pos));
%         mpl_avg.hk.nsamples(p) = length(pos);
%         mpl_avg.hk.shots_summed(p) = (mpl_in.hk.shots_summed(pos));
%         mpl_avg.time(p) = (mpl_in.time(pos));
%         mpl_avg.hk.instrument_temp(p) = (mpl_in.hk.instrument_temp(pos));
%         mpl_avg.hk.laser_temp(p) = (mpl_in.hk.laser_temp(pos));
%         mpl_avg.hk.detector_temp(p) = (mpl_in.hk.detector_temp(pos));
%         mpl_avg.hk.energy_monitor(p) = (mpl_in.hk.energy_monitor(pos));
%         %         mpl_avg.hk.bg(p) = (mpl_in.hk.bg(pos));
%         %         mpl_avg.hk.bg_noise(p) = mpl_in.hk.bg_noise(pos);
%         %         mpl_avg.hk.bg_std(p) = mpl_in.hk.bg(pos);
%         %         mpl_avg.hk.energy_monitor_std(p) = (mpl_in.hk.energy_monitor(pos));;
%         % %         mpl_avg.rawcts(:,p) = (mpl_in.rawcts(:,pos));
%         %         mpl_avg.range_prof(:,p) = (mpl_in.prof(:,pos));
%         %         mpl_avg.noise_MHz(:,p) = mpl_in.noise_MHz(:,pos);
%         %         mpl_avg.range_prof_snr(:,p) = mpl_in.prof_snr(:,pos);
%
% %         mpl_avg.hk.cop1_bg(p) = NaN;
% %         mpl_avg.hk.cop1_bg_noise(p) = NaN;
% %         %standard deviations
% %         mpl_avg.hk.cop1_bg_std(p) = NaN;
%         %n-dim mean
% %         mpl_avg.copol_1(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.cop1_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.cop1_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.cross_1(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.crs1_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.crs1_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.range_prof1(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.range_prof1_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.range_prof1_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%
%         mpl_avg.copol_2(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.cop2_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.cop2_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.cross_2(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.crs2_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.crs2_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.range_prof2(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.range_prof2_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
%         mpl_avg.range_prof2_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%
% %         mpl_avg.copol_3(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.cop3_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.cop3_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.cross_3(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.crs3_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.crs3_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.range_prof3(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.range_prof3_snr(:,p) = NaN(size(mpl_in.prof(:,1)));
% %         mpl_avg.range_prof3_noise(:,p) = NaN(size(mpl_in.prof(:,1)));
%
%
%     else
%         disp(['Pos is zero?'])
%     end
% end
% end
%
