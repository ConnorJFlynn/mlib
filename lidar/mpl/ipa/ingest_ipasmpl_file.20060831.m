function [mpl] = ingest_ipasmpl_file(statics,mpl);
%% [mpl] = ingest_ipasmpl_file(statics,mpl);
% Need to modify the below lines to reflect ocr or ps
%CJF: 20006-08-31 rewriting to process single files at a time
if nargin==0
    in_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplocrC1.00\'];
    out_dir = ['C:\case_studies\ipa\Alldays\data\ipasmplocrC1.a0\'];
    fstem = 'ipasmplocrC1.a0';
    % ipa.lat = 40.38;
    % ipa.lon = -79.06;
    % ipa.alt = 1405*12*2.54*1e-2;%feet to inches to cm to meters
    statics.datastream = fstem ;
    statics.datalevel = 'a0';
    statics.polarized = 'no';
    statics.ocr = 'yes';
    statics.scanning = 'yes';
    statics.averaging_int = '10 seconds';
    statics.lat = 40.38;
    statics.lon = -79.06;
    statics.alt = 1405*12*2.54*1e-2;%feet to inches to cm to meters
else
    in_dir = statics.in_dir;
    out_dir = statics.out_dir;
    fstem = statics.fstem;
end
if ~exist('mpl','var')
[fname, pname]=   uigetfile([statics.in_dir,'*.*']);
mpl = read_mpl([pname, fname]);
end
%%
    mpl.statics.datastream = statics.datastream ;
    mpl.statics.datalevel = statics.datalevel;
    mpl.statics.polarized = statics.polarized;
    mpl.statics.ocr = statics.ocr ;
    mpl.statics.scanning = statics.scanning;
    mpl.statics.averaging_int = statics.averaging_int;
    mpl.statics.alt = statics.alt;
    mpl.statics.lon = statics.lon;
    mpl.statics.lat = statics.lat;
%     mpl.statics.pol_test_span = span;
%     sig = mpl.rawcts(3:100,:) - ones(size(mpl.range(3:100)))*mpl.hk.bg;
%     summed_sig = sum(sig);
%     if length(mpl.time)>1
%         %mpl = apply_dtc_to_mpl(mpl, 'dtc_apd7335', 'SPCM-AQR-FC SN7335');
%         [d_str,t_str] = strtok(datestr(mpl.time(1),30),'T');
%         fullname = [out_dir,fstem,'.',d_str,'.',t_str(2:end),'.nc'];
%         [a1_ncid] = ncmex('create', fullname, 'write');
%         if a1_ncid
%             disp(['Opening ',fullname])
%             status = define_ipasmpl_a0(a1_ncid, mpl.time(1),mpl.range, mpl.statics);
%             disp(['Populating and closing ',fullname])
%             status = output_ipasmpl_a0(a1_ncid, mpl);
%             ncmex('close',a1_ncid);
%             clear mpl
%         end
%     else
%         disp(['Skipping this empty file: ', dirlist(ps).name])
%     end
status = 1;
end

%
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
