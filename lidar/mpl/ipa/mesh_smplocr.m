function [status] = mesh_smplocr(statics,mpl);
% [mesh_ipa] = mesh_smplocr(statics,mpl);
% This function requires pre-existing files created by running
% merge_mirror_file and merge_power_file
% Modifying this file to generically add energy monitor and zenith angle
% values to the input a0 files irrespective of mplps or ocr content

%%
status = 1;
if nargin==0
    mirror_fullname = 'C:\case_studies\ipa\Alldays\mat_files\mirror.mat';
    ophir_fullname = 'C:\case_studies\ipa\Alldays\mat_files\ophir.mat';
    % mplps_file_list = 'C:\case_studies\ipa\Alldays\mat_files\mplps_files.mat';
    % mplocr_file_list = ['C:\case_studies\ipa\Alldays\mat_files\mplocr_files.mat'];
    in_dir = ['C:\case_studies\ipa\Alldays\data\ipasmplpsC1.a0\'];
    out_dir = ['C:\case_studies\ipa\Alldays\data\ipasmplpsC1.a1\tmp\'];
    fstem = 'ipasmplpsC1.a1.';
    % in_dir = ['C:\case_studies\ipa\Alldays\data\ipasmplocrC1.a0\'];
    % out_dir = ['C:\case_studies\ipa\Alldays\data\ipasmplocrC1.a1\'];
    % fstem = 'ipasmplocrC1.a1.';
else
    mirror_fullname = statics.mirror_fullname;
    ophir_fullname = statics.ophir_fullname;
    in_dir = statics.in_dir;
    out_dir = statics.out_dir;
    fstem  = statics.fstem;
end
load(mirror_fullname, '-mat');
load(ophir_fullname, '-mat');

% dirlist = get_dir_list(in_dir, ['*.nc']);
% for ps_index = 1:length(dirlist)
%     disp(['Processing ',dirlist(ps_index).name,': ',num2str(ps_index), ' of ',num2str(length(dirlist))]);
%     mpl = read_mpl([in_dir, dirlist(ps_index).name]);
    mpl.statics.proc_level = 'a1';
    mpl.statics.input_source = mpl.statics.datastream;
    mpl.statics.datastream = fstem(1:end-1);
    mpl.statics.zeb_platform = mpl.statics.datastream;
    mpl.statics.datalevel = 'a1';
    span = 30;
    mpl = add_pol_mode(mpl, span);
    
%figure; plot(serial2doy0(mpl.time), mpl.pol_mode.odd_even-mpl.pol_mode.odd_even_span, 'r.', serial2doy0(mpl.time), mpl.pol_mode.odd_even-mpl.pol_mode.gt_mean_span, 'go',serial2doy0(mirror.start_time),mirror.angle/80, 'y' )    

    mirror_times = find((mirror.end_time >= mpl.time(1))&(mirror.start_time<=mpl.time(end)));
    for mir = (mirror_times)
        these_times.mirror = mir;
        these_times.ophir = find((ophir.time>=mirror.start_time(mir))&(ophir.time<=mirror.end_time(mir)));
        these_times.mpl = find((mpl.time >= mirror.start_time(mir))&(mpl.time<= mirror.end_time(mir))&(mpl.hk.bg>1e-6));

        if length(these_times.mpl)>0
            %bg = mean(mplps.rawcts(r.bg,these_times.ps));
            [d_str,t_str] = strtok(datestr(mirror.start_time(mir),30),'T');
            hh_str = t_str(2:3);
            if ~size(dir([out_dir,fstem,d_str,'.',hh_str,'*.nc']),1)
                %if ~size(dir([out_dir,fstem,d_str,'*.nc']),1)
                %If proper hourly file is not found then output existing structures,
                %close the open netcdf files, and open new ones.
                if exist('a1_ncid','var')
                    if a1_ncid > 0
                        disp(['Populating and closing ',open_filename])
                        disp('.')
                        if findstr(upper(mpl_a1.statics.ocr),'YES')
                            %OCR APD SN 7335
                            mpl_a1 = apply_dtc_to_mpl(mpl_a1, 'dtc_apd7335', 'SPCM-AQR-FC SN7335');
                        else
                            %MPL-PS APD SN6850
                            mpl_a1 = apply_dtc_to_mpl(mpl_a1, 'dtc_apd6850_ipa', 'SPCM-AQR-FC SN6850' );
                        end
                        status = output_ipasmpl_a1(a1_ncid, mpl_a1);
                        clear mpl_a1
                        ncmex('close',a1_ncid);
                    end
                end
                %Defining new hourly netcdf files
                open_filename = [out_dir,fstem,d_str,'.',hh_str,'0000.nc'];
                %open_filename = [out_dir,fstem,d_str,'.000000.nc'];
                [a1_ncid, rcode] = ncmex('create', open_filename, 'write');
                if a1_ncid
                    disp(['Opening ',open_filename])
                end
                status = define_ipasmpl_a1(a1_ncid, mpl.time(these_times.mpl(1)),mpl.range, mpl.statics);
            end
            %
            if ~exist('mpl_a1','var')
                %mpl_a1 = mirror_subset(mpl, these_times, ophir, mirror);
                mpl_a1 = mirror_sub(mpl, these_times, ophir, mirror);
            else
                %mpl_a1 = mirror_subset(mpl, these_times, ophir, mirror,mpl_a1);
                mpl_a1 = mirror_sub(mpl, these_times, ophir, mirror,mpl_a1);
            end
        end
    end
end
%close the open netcdf file
if exist('a1_ncid','var')
    if a1_ncid > 0
        disp(['Populating and closing ',open_filename])
        disp('.')
        if findstr(upper(mpl_a1.statics.ocr),'YES')
            %OCR APD SN 7335
            mpl_a1 = apply_dtc_to_mpl(mpl_a1, 'dtc_apd7335', 'SPCM-AQR-FC SN7335');
        else
            %MPL-PS APD SN6850
            mpl_a1 = apply_dtc_to_mpl(mpl_a1, 'dtc_apd6850_ipa', 'SPCM-AQR-FC SN6850' );
        end
        status = output_ipasmpl_a1(a1_ncid, mpl_a1);
        clear mpl_a1
        ncmex('close',a1_ncid);
    end
end

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


%       % Now plot the results
%       date_time_str = datestr(mirror.start_time(mir),30);
%       [date_str,rem] = strtok(date_time_str,'T');
%
%       figure(50);
%
%       %           if length(these_times.ophir)>0
%       %              subplot(3,1,1); plot(serial2doy0(ophir.time(these_times.ophir)), ophir.power(these_times.ophir));
%       %           else
%       %              subplot(3,1,1); plot([1 10], [1 10],'.');text(2,5,'No power measurements.')
%       %           end
%       if length(these_times.ps)>0
%          subplot(2,1,1);
%          if length(these_times.ps)>1
%             %plot(mplps.range(mplps.r.lte_30).*cos(pi*mirror.angle(mir)/180), mplps.prof(mplps.r.lte_30,these_times.ps(copols)),'r',mplps.range(mplps.r.lte_30).*cos(pi*mirror.angle(mir)/180), mplps.prof(mplps.r.lte_30,these_times.ps(crosspols)),'b');
%             plot(mplps.range(mplps.r.lte_30).*cos(pi*mirror.angle(mir)/180), mplps.prof(mplps.r.lte_30,these_times.ps),'r');
%          else
%             plot(mplps.range(mplps.r.lte_30).*cos(pi*mirror.angle(mir)/180), mplps.prof(mplps.r.lte_30,ps_times));
%          end
%          v = axis;
%          axis([0 10 v(3) v(4)]);
%       else
%          subplot(2,1,1); plot([0 10], [0 10],'.');text(3,5,'No mpl-ps profiles.')
%       end
%       title(['Data collected on ', datestr(mirror.start_time(mir),0)]);
%
%       if length(these_times.ocr)>0
%          subplot(2,1,2);
%          plot(mplocr.range(mplocr.r.lte_10), mean(mplocr.prof(mplocr.r.lte_10,these_times.ocr)')'./mean(mplps.prof(mplps.r.lte_10,these_times.ps)')');
%          axis([0,10,0,10]);
%          %status = write_ipa_ocr_a1(mplocr, ophir, mirror, these_times,pname_ps_a1);
%       else
%          subplot(2,1,2); plot([0 10], [0 10],'.');text(3,5,'No mpl-ocr profiles.')
%       end
%       v = axis;
%       axis([0 10 v(3) v(4)]);
%       xlabel(['Mirror angle = ', num2str(mirror.angle(mir)), ' degrees North of zenith']);
%       pause(.05)
