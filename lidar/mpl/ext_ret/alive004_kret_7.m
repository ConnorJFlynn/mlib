function mpl = alive004_kret_7(mpl);
% This version does not use mplnor at all.
% AWG Nov meeting
% Version 6 attempting to use a constant lidar C in absence of AOD
% disp('Cleaning up...');
% pause(.2);
close('all');
%ncclose('all'); clear
pause(.2);
%clear
if ~exist('mpl', 'var')
    mpl = mpl004_alive;
end;
pause(.1)
if ~exist([mpl.statics.pname,'..',filesep,datestr(now,'yyyy_mm_dd')],'dir')
    mkdir([mpl.statics.pname,'..',filesep],datestr(now,'yyyy_mm_dd'))
end
date_dir = [mpl.statics.pname,'..',filesep,datestr(now,'yyyy_mm_dd'),filesep];
if ~exist([date_dir,'ext'],'dir')
    mkdir(date_dir,'ext');
end
ext_dir = [date_dir,'ext',filesep];
if ~exist([date_dir,'plots'],'dir')
    mkdir(date_dir,'plots');
end
plot_dir = [date_dir,'plots',filesep];
load odC1.mat
aeroC1 = logical(odC1.vars.variability_flag.data<1e-4);
odC1 = ancsift(odC1, odC1.dims.time, aeroC1);
odC1.aod523 = odC1.vars.aerosol_optical_depth_filter2.data .*((500/523) .^ odC1.vars.angstrom_exponent.data);
mfr_ind = find((serial2doy(odC1.time)>=serial2doy(min(mpl.time))-1)&(serial2doy(odC1.time)<=serial2doy(max(mpl.time))+1));
if max(size(mfr_ind))>1
    %!! 2004-12-04 Adding manual selection of "clear sky" section.  If none
    %provide, then a pre-saved clear sky profile is used.
    prof_fig = figure;
    imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:));
    axis('xy'); colormap('jet');
    axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_30)), max(mpl.range(mpl.r.lte_30))]);
    caxis([ 0 5]);
    if ~exist('clear_sky004.mat', 'file')
       title('Select a time range with some clear sky');
        K = menu('When finished, select: "Done".','Done');
    else
        title('Select a time range with some clear sky or "skip"');
        K = menu('When finished, select: "Done".', 'Done', 'Skip');
    end
    if K~=1
        load('clear_sky004.mat');
    else
        figure(prof_fig);
        zoom off;
        title(['Clear sky for ', datestr(mpl.time(1),1)]);
        v = axis;
        pause(.1);
        clear_sky_ind = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
        r.zoom_ind = find((mpl.range>=v(3))&(mpl.range<=v(4)));
        [pileA] = trimsift_nolog(mpl.range(r.zoom_ind), mpl.prof(r.zoom_ind,clear_sky_ind));
        clear_sky_ind = clear_sky_ind(pileA);
        clear_sky_prof = mean(mpl.prof(:,clear_sky_ind),2);
        clear_sky_prof = smooth(mpl.range,clear_sky_prof,20,'moving');
%         figure; semilogy(mpl.range(mpl.r.lte_30), clear_sky_prof(mpl.r.lte_30));zoom
%         title('Now zoom to select the region to pin a Rayleigh profile to...');
%         K = menu('When finished, select: "Done".','Done')
%         v = axis;
%         ray_range_ind = find(mpl.range>v(1)&mpl.range<=v(2));
        ray_range_ind = find(mpl.range>10&mpl.range<=12);
%         clear_sky_prof = mpl.sonde.atten_ray * (mean(clear_sky_prof(ray_range_ind))/mean(mpl.sonde.atten_ray(ray_range_ind)));

        save('clear_sky004.mat', 'clear_sky_prof')
    end
    %!!
    frac_fig = figure;
    imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:)./(clear_sky_prof(mpl.r.lte_30)*ones(size(mpl.time))));
    axis('xy'); colormap('jet');
    title(['normalized profiles: ', datestr(mpl.time(1),0)]); zoom;
    axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_30)), max(mpl.range(mpl.r.lte_30))]);
    caxis([0,5]);
    title('Zoom to select the region of time to use for retrievals.  Hit enter when done.')
    K = menu('When finished, select: "Done".','Done');
    figure(frac_fig);
    zoom off;
    title(['MPL profiles for selected region of ', datestr(mpl.time(1),1)]);
    frac_axis = axis;
    pause(.5)

    t.zoom_ind = (find(serial2Hh(mpl.time)>=frac_axis(1)&serial2Hh(mpl.time)<=frac_axis(2)));
    r.zoom_ind = find((mpl.range>=frac_axis(3))&(mpl.range<=frac_axis(4)));
    clean_mpl = t.zoom_ind;
    [pileA] = trimsift_nolog(mpl.range(r.zoom_ind), mpl.prof(r.zoom_ind,clean_mpl)./(clear_sky_prof(r.zoom_ind)*ones(size(clean_mpl))));

    clean_mpl = clean_mpl(pileA);
    %     clean_times = mpl.time(clean_mpl);

    %     The following two lines were used to identify and remove a spike cloud at ~2km
    %     cloud_range = find(mpl.range>.5 & mpl.range<2.5);
    %     clean_mpl = clean_mpl(~any(mpl.prof(cloud_range,clean_mpl)>25));

    [avg] = mpl_timeavg3(mpl,10,clean_mpl);
    %[avg] = downsample_mpl(mpl, 9*12);
    %       mpl = rmfield(mpl, 'nor');
    mpl = rmfield(mpl, 'time');
    mpl = rmfield(mpl, 'rawcts');
    mpl = rmfield(mpl, 'prof');
    mpl.time = avg.time;
    mpl.prof = avg.prof;
    mpl.rawcts = avg.rawcts;
    %       mpl.nor = avg.nor;
    mpl = rmfield(mpl, 'hk');
    mpl.hk = avg.hk;
    mpl.clean = logical(avg.clean); % this is a clean/not clean flag determined while averaging
    clear avg
    test = uint32(zeros(size(mpl.time)));
    test = bitset(test,1,~mpl.clean);
    mpl.vars.test.data = test;
    mpl.vars.test.atts.test1_eqn.data = '~mpl.clean';
    mpl.vars.test.atts.test1_desc.data = 'profile determined not to be clean';
    missing = logical(((mpl.hk.bg<=-9998)&(mpl.hk.bg>=-10000))|isNaN(mpl.hk.bg));
    test = bitset(test,2,missing);
    mpl.vars.test.data = test;
    mpl.vars.test.atts.test2_eqn.data = 'missing';
    mpl.vars.test.atts.test2_desc.data = 'missing in raw data';
    clean_mpl_ind = find(mpl.clean);
    % Calibration versus Rayleigh
    pause(0.2);
    figure(prof_fig);

    pause(0.2);
    imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:).*(ones(size(mpl.r.lte_30))*mpl.clean));
    axis('xy'); colormap('jet');zoom
    axis([frac_axis, 0, 5, 0, 5]);

    v = axis;
    title(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
    menu({'Zoom to select an aerosol-free region for calibration.  ';'Select "okay" when done.'},'Okay');
    %Pause execution to permit user to zoom into aerosol-free cal region.
%     pause;
    figure(prof_fig);
    zoom off;
    cal_v = axis;
    axis([frac_axis,0,10,0,10]);
    title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);

    mpl.r.cal_ind = find((mpl.range>=cal_v(3))&(mpl.range<=cal_v(4)));
    %To permit alternate specification of calibration range...
    %keyboard;
    mpl.r.lte_cal_ind = find((mpl.range>.1)&(mpl.range<mpl.range(max(mpl.r.cal_ind))));
    mpl.cal.atten_ray = 10.^(mean(real(log10(mpl.sonde.atten_ray(mpl.r.cal_ind)))));
    mpl.cal.mean_prof(~missing&mpl.clean) = 10.^(mean(real(log10(mpl.prof(mpl.r.cal_ind,(~missing&mpl.clean))))));
    mpl.cal.mean_prof(missing|~mpl.clean) = NaN;
    mpl.cal.lowess_mean_prof(~missing&mpl.clean) = lowess(serial2doy(mpl.time(~missing&mpl.clean))-floor(serial2doy(mpl.time(1))), mpl.cal.mean_prof(~missing&mpl.clean), .02)';
    mpl.cal.lowess_mean_prof(missing|~mpl.clean) = NaN;
    mpl.cal.aod_523 = NaN(size(mpl.time));

    for nm = find(~missing)
        %For each MPL time, find any aod within some time window and
        %interpolate to the MPL time if any found.
        nearby_aod = find(abs(mpl.time(nm)-odC1.time)< (3/24));
        if length(nearby_aod)>15
            mpl.cal.aod_523(nm) = interp1(odC1.time(nearby_aod)-mpl.time(nm),odC1.aod523(nearby_aod),0,'linear');
            if isNaN(mpl.cal.aod_523(nm))
                mpl.cal.aod_523(nm) = interp1(odC1.time(nearby_aod)-mpl.time(nm),odC1.aod523(nearby_aod),0,'nearest','extrap');
            end
%             mpl.cal.aod_523(nm) = local_val(odC1.time(nearby_aod)-mpl.time(nm),odC1.aod523(nearby_aod),0,.5);
            test(nm) = bitset(test(nm),3,~(length(nearby_aod)>15));
            mpl.vars.test.data = test;
            mpl.vars.test.atts.test3_eqn.data = '~(length(nearby_aod)>15))';
            mpl.vars.test.atts.test3_desc.data = 'less than 15 AOD within 3 hours';
        end
    end
    good_aod = ~isnan(mpl.cal.aod_523);
    test = bitset(test,4,isnan(mpl.cal.aod_523));
    mpl.vars.test.data = test;
    mpl.vars.test.atts.test4_eqn.data = 'isnan(mpl.cal.aod_523)';
    mpl.vars.test.atts.test4_desc.data = 'AOD is NaN';
    mpl.cal.C = NaN(size(mpl.time));
    if sum(good_aod)>1
        mpl.cal.C(~missing&good_aod) = mpl.cal.lowess_mean_prof(~missing&good_aod)...
            ./ (mpl.cal.atten_ray * exp(-2*mpl.cal.aod_523(~missing&good_aod)));
        good_C = ~isnan(mpl.cal.C);
        mpl.cal.C(~good_C) = interp1(mpl.time(good_C), ...
            mpl.cal.C(good_C),mpl.time(~good_C),'linear');
        good_C = ~isnan(mpl.cal.C);
        mpl.cal.C(~good_C) = interp1(mpl.time(good_C), ...
            mpl.cal.C(good_C),mpl.time(~good_C),'nearest','extrap');
    end

    % At this point, we should have lidar C for all non_missing times based
    % on interpolation from lidar C via good aod.
    % We are also likely to have some aod==NaN due to lack of nearby value

    % Now, hypothetically, we can cruise through all clean cases with good
    % aod to retrieve Sa and ext.

    % Then, we interpolate Sa to cases without aod.  This provides us with:
    % lidar C and Sa, so we can compute the extinction profile and retrieve
    % aod.

    if length(mpl.r.lte_15)<length(mpl.r.lte_cal_ind)
        shorter = mpl.r.lte_15;
        longer = mpl.r.lte_cal_ind;
    else
        shorter = mpl.r.lte_cal_ind;
        longer = mpl.r.lte_15;
    end
    beta_m = mpl.sonde.beta_R(shorter);
    Sa = 30;
    range = mpl.range(shorter);

    %set missings
    mpl.klett.alpha_a = NaN*ones([length(longer),length(mpl.time)]);
    mpl.klett.beta_a = mpl.klett.alpha_a;
    mpl.klett.Sa = NaN*ones(size(mpl.time));

    clean_mpl_ind = find(mpl.clean & ~isnan(mpl.cal.aod_523));
    missing = (~mpl.clean)|isnan(mpl.cal.aod_523);

    i = 0;
    for clear_bin = clean_mpl_ind
        if ~exist('ext_fig','var')
            ext_fig = figure;
            set(ext_fig, 'Position',[1 29 1280 704]);
        end
        figure(ext_fig);
        i = i + 1;
        %         [dump, closest] = min(abs(mpl.time-mplnor.time(clear_bin)));
        %         [mpl.klett.alpha_a(mpl.r.lte_cal_ind,closest), mpl.klett.beta_a(mpl.r.lte_cal_ind,closest), mpl.klett.Sa(closest)] = mpl_autoklett(mpl.range(mpl.r.lte_cal_ind), mpl.prof(mpl.r.lte_cal_ind,closest), mpl.cal.aod_523(closest), mpl.cal.C(closest), mpl.sonde.beta_R(mpl.r.lte_cal_ind), Sa);
        profile = mpl.prof(shorter,clear_bin);
        aod = mpl.cal.aod_523(clear_bin);
        lidar_C = mpl.cal.C(clear_bin);
        [alpha_a, beta_a, mpl.klett.Sa(clear_bin)] = mpl_autoklett(range,profile,aod, lidar_C, beta_m, Sa, clear_bin);
        if(mpl.klett.Sa(clear_bin)>(8*pi/3))&&(mpl.klett.Sa(clear_bin)<=(200)&(mean(alpha_a)>0))
            mpl.klett.alpha_a(shorter,clear_bin) = alpha_a;
            mpl.klett.beta_a(shorter,clear_bin) = beta_a;
            Sa = mpl.klett.Sa(clear_bin);
            title_str = (sprintf(['#%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),') AOT=%1.2f  SA=%1.1f C=%1.1f '],i ,length(clean_mpl_ind), mpl.cal.aod_523(clear_bin),Sa,mpl.cal.C(clear_bin)));
        else
            test(clear_bin) = bitset(test(clear_bin),5,mpl.klett.Sa(clear_bin)<=(8*pi/3));
            mpl.vars.test.data = test;
            mpl.vars.test.atts.test5_eqn.data = 'mpl.klett.Sa(clear_bin)<=(8*pi/3)';
            mpl.vars.test.atts.test5_desc.data = 'Failure, Sa is too low';
            test(clear_bin) = bitset(test(clear_bin),6,mpl.klett.Sa(clear_bin)<=(8*pi/3));
            mpl.vars.test.data = test;
            mpl.vars.test.atts.test6_eqn.data = 'mpl.klett.Sa(clear_bin)>200';
            mpl.vars.test.atts.test6_desc.data = 'Failure, Sa is too high';
            
            test(clear_bin) = bitset(test(clear_bin),7,(mean(alpha_a)<=0));
            mpl.vars.test.data = test;
            mpl.vars.test.atts.test7_eqn.data = '(mean(alpha_a)<=0))';
            mpl.vars.test.atts.test7_desc.data = 'Failure, averaged extinction is negative';

            title_str = (sprintf(['Retrieval failure for  #%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),')'],i ,length(clean_mpl_ind)));
            % title_str= ['Retrieval failure for record number ',num2str(clear_bin)];
            Sa = 30;
        end
        subplot(1,3,1); semilogx(profile, range, 'c',  exp(-2*aod).*lidar_C.*mpl.sonde.atten_ray(mpl.r.lte_cal_ind), mpl.range(mpl.r.lte_cal_ind), 'r--');
        xlabel('backscatter');
        axis([ .2, 10, min(range), max(range)])
        subplot(1,3,2); semilogx(profile./(exp(-2*aod).*lidar_C.*mpl.sonde.atten_ray(shorter)), range, 'b');
        ylim([min(range), max(range)]);
        xlim([.8, 10]);
        line([1,1],[ylim],'Color','r','LineStyle','--','LineWidth',2);
        xlabel('scattering ratio')
        subplot(1,3,3); plot(mpl.klett.alpha_a(shorter, clear_bin),mpl.range(shorter), '.b');
        axis([-.05, .2 min(range), max(range) ]);
        line([0,0],[min(range), max(range)],'color','r','LineStyle','--','LineWidth',2);
        xlabel('extinction')
        subplot(1,3,1);
        title(title_str);
        pause(.25)
    end
    %     close(ext_fig);

    % Then, we interpolate Sa to cases without aod.  This provides us with:
    % lidar C and Sa, so we can compute the extinction profile and retrieve
    % aod.
    clean_mpl_no_aod_ind = find(mpl.clean & isnan(mpl.cal.aod_523));
    %         clean_mpl_no_aod_ind = (mpl.clean & isnan(mpl.cal.aod_523));
    if ((sum(clean_mpl_no_aod_ind)>2)&&(length(clean_mpl_ind)>=2))
        test = bitset(test,8,(mpl.clean & isnan(mpl.cal.aod_523)));
        mpl.klett.Sa(clean_mpl_no_aod_ind) = interp1(mpl.time(clean_mpl_ind), mpl.klett.Sa(clean_mpl_ind),mpl.time(clean_mpl_no_aod_ind),'linear','extrap');
        % Now we should have Sa for all clean profiles
        % So now we'll just do a straight fernald retrieval supplied with lidar C and
        % Sa to yield ext_prof and aod.
        for clear_bin = clean_mpl_no_aod_ind
            profile = mpl.prof(shorter,clear_bin);
            lidar_C = mpl.cal.C(clear_bin);
            %         beta_m = mpl.sonde.beta_R(shorter);
            Sa =  mpl.klett.Sa(clear_bin);
            [alpha_a, beta_a, new_aot] = ...
                mpl_fernald(range, profile, lidar_C, beta_m, Sa);

            if ((new_aot>0)&&(new_aot<5))
                mpl.cal.aod_523(clear_bin)=new_aot;
                mpl.klett.alpha_a(shorter,clear_bin) = alpha_a;
                mpl.klett.beta_a(shorter,clear_bin) = beta_a;
                subplot(1,3,1); semilogx(profile, range, 'c',  exp(-2*new_aot).*lidar_C.*mpl.sonde.atten_ray(mpl.r.lte_cal_ind), mpl.range(mpl.r.lte_cal_ind), 'r--');
                title('Fernald retrieval')
                xlabel('backscatter')
                axis([ 1, 50, min(range), max(range)])
                subplot(1,3,2); semilogx(profile./(exp(-2*new_aot).*lidar_C.*mpl.sonde.atten_ray(shorter)), range, 'b');
                title('Fernald retrieval')
                ylim([min(range), max(range)]);
                xlim([.8, 10]);
                line([1,1],[ylim],'Color','r','LineStyle','--','LineWidth',2);
                xlabel('scattering ratio')
                subplot(1,3,3); plot(mpl.klett.alpha_a(shorter, clear_bin),mpl.range(shorter), '.b');
                title('Fernald retrieval')
                axis([-.05, .2 min(range), max(range) ]);
                line([0,0],[min(range), max(range)],'color','r','LineStyle','--','LineWidth',2);
                xlabel('extinction')
                subplot(1,3,1);
                pause(.25)
            else
                test(clear_bin) = bitset(test(clear_bin),9,(new_aot<=0));
                test(clear_bin) = bitset(test(clear_bin),10,(new_aot>=5));
            end
        end
        mpl.vars.test.data = test;
        mpl.vars.test.atts.test8_eqn.data = ['mpl.clean'' & isnan(mpl.cal.aod_523)'];
        mpl.vars.test.atts.test8_desc.data = 'Clean, but AOD missing. Fernald (forward) retrieval used';
        mpl.vars.test.atts.test9_eqn.data = ['(new_aot<=0)'];
        mpl.vars.test.atts.test9_desc.data = 'Fernald (forward) retrieval failure: aot<0';
        mpl.vars.test.atts.test10_eqn.data = ['(new_aot>=5)'];
        mpl.vars.test.atts.test10_desc.data = 'Fernald (forward) retrieval failure: aot>5';
    end

    plots_ppt;
    %%
    ext_fig = figure;
    imagesc(serial2doy(mpl.time),mpl.range(shorter), mpl.klett.alpha_a(shorter,:)); axis('xy'); colormap('jet');title(['aerosol extinction: ', datestr(mpl.time(1),1)]); zoom;
    v = axis;
    axis([v(1), v(2), 0, max(mpl.range(shorter)) 0 1 -.001 .15]);
    colorbar;
    title(['MPL102 extinction: ',datestr(mpl.time(1),'yyyy/mm/dd')]);
    xlabel('time (day of year 2005)');
    ylabel('height (km AGL)')
    print(ext_fig, [plot_dir, 'mpl102_extprof.',datestr(mpl.time(1),'yyyymmdd'),'.png'],'-dpng');


    %     lidarC_fig = figure; subplot(3,1,2);plot(serial2doy(mpl.time(clean_mpl)), mpl.klett.Sa(clean_mpl),'g.',serial2doy(mpl.time(clean_mpl_no_aod)),mpl.klett.Sa(clean_mpl_no_aod),'r.');
    %     ylim([8 1.1*max(mpl.klett.Sa)]);
    %     title('ext/bscat ratio')
    %     subplot(3,1,3); plot(serial2doy(mpl.time(non_missing(good_aod))),mpl.cal.C(non_missing(good_aod)),'g.',serial2doy(mpl.time(non_missing(~good_aod))),mpl.cal.C(non_missing(~good_aod)),'r.');
    %     ylim([300 1.1*max(mpl.cal.C)]);
    %     title('lidar calibration')
    %     subplot(3,1,1); plot(serial2doy(mpl.time(non_missing(good_aod))),mpl.cal.aod_523(non_missing(good_aod)),'g.',serial2doy(mpl.time(non_missing(~good_aod))),mpl.cal.aod_523(non_missing(~good_aod)),'r.')
    %     ylim([0,1.5*max(mpl.cal.aod_523)]); title('aod 523 nm')
    %     print(lidarC_fig, [mpl_pname, '..\plots\mpl102_aod_Sa_C.',datestr(mpl.time(1),'yyyymmdd'),'.png'],'-dpng');
    %     pause(.1)
    plots_default;

    %     zoom;
    %Then output the results to a file
    fstem = 'mpl102.ext.';
    dstem = datestr(mpl.time(1), 'yyyymmdd.');
    vstem = datestr(now, 'yyyymmdd');
    %[fname, mpl_ret_pname] = uiputfile([mpl_ret_pname,fstem,dstem,'ver_',vstem,'.cdf']);
    mpl.vars.test.atts.test5_eqn.data = 'mpl.klett.Sa(clear_bin)<=(8*pi/3)';
    mpl.vars.test.atts.test5_desc.data = 'Failure, Sa is too low';
    mpl.vars.test.atts.test6_eqn.data = 'mpl.klett.Sa(clear_bin)>200';
    mpl.vars.test.atts.test6_desc.data = 'Failure, Sa is too high';
    mpl.vars.test.atts.test7_eqn.data = '(mean(alpha_a)<=0))';
    mpl.vars.test.atts.test7_desc.data = 'Failure, averaged extinction is negative';

    save it_all_04
    status = write_mpl_ret(mpl,[ext_dir,fstem,dstem,'v',vstem,'.cdf']);
end
