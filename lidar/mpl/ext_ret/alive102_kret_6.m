function mpl = alive102_kret_6(mpl);
% This version does not use mplnor at all.
% AWG Nov meeting
% Version 6 attempting to use a constant lidar C in absence of AOD
% disp('Cleaning up...');
% pause(.2);
close('all');
plots_default;
%ncclose('all'); clear
% pause(.2);
clear
if ~exist('mpl', 'var')
    mpl = mpl102_alive;
end;
pause(.1)
mpl_pname = ['C:\case_studies\Alive\data\flynn-mpl-102\Nov2006\day\'];
%mplnor_pname = ['c:\case_studies\Aerosol_IOP\sgpmplnor1campC1.c1\cdf\'];
mpl_ret_pname = ['C:\case_studies\Alive\data\flynn-mpl-102\Nov2006\ext\Nov2006\'];

load odC1.mat
aeroC1 = (odC1.vars.variability_flag.data<1e-4);
odC1 = ancsift(odC1, odC1.dims.time, aeroC1);
odC1.aod523 = odC1.vars.aerosol_optical_depth_filter2.data .*((500/523) .^ odC1.vars.angstrom_exponent.data);


% [mpl.sonde.temperature,mpl.sonde.pressure] = std_atm(mpl.range(mpl.r.lte_30));
% [mpl.sonde.alpha_R, mpl.sonde.beta_R] = ray_a_b(mpl.sonde.temperature,mpl.sonde.pressure);
% [mpl.sonde.atten_ray] = std_ray_atten(mpl.range);
mfr_times = find((serial2doy(odC1.time)>=serial2doy(min(mpl.time))-1)&(serial2doy(odC1.time)<=serial2doy(max(mpl.time))+1));
if max(size(mfr_times))>1
    %!! 2004-12-04 Adding manual selection of "clear sky" section.  If none
    %provide, then a pre-saved clear sky profile is used.
    prof_fig = figure;
    imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:));
    axis('xy'); colormap('jet');
    axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_30)), max(mpl.range(mpl.r.lte_30))]);
    caxis([ 0 25]);
    title('Select a time range with some clear sky.  Hit enter when done zooming or to skip.')
    disp('Select a time range with some clear sky.  Hit enter when done zooming or to skip.')
    figure(prof_fig);
    pause;
    if exist('clear_sky2.mat', 'file')
        keep = input('Press enter again to use this region or type "X" to use a pre-saved Rayleigh profile: ', 's');
        if isempty(keep)
            keep = ' ';
        end;
        if (upper(keep) == ' ') % Use mean of selected region for clear_sky
            figure(prof_fig);
            zoom off;
            title(['Clear sky for ', datestr(mpl.time(1),1)]);
            v = axis;
            pause(.1);
            clear_sky_time = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
            mpl.r.zoom = find((mpl.range>=v(3))&(mpl.range<=v(4)));
            [pileA] = trimsift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clear_sky_time));
            clear_sky_time = clear_sky_time(pileA);
            clear_sky = mean(mpl.prof(:,clear_sky_time),2);
            clear_sky = smooth(mpl.range,clear_sky,20,'moving');
            figure; semilogy(mpl.range(mpl.r.lte_30), clear_sky(mpl.r.lte_30));zoom
            title('Now zoom to select the region to pin a Rayleigh profile to...');
            pause
            v = axis;
            ray_range = find(mpl.range>v(1)&mpl.range<=v(2));
            clear_sky = mpl.sonde.atten_ray * (mean(clear_sky(ray_range))/mean(mpl.sonde.atten_ray(ray_range)));
            save('clear_sky2.mat', 'clear_sky')
        else
            load('clear_sky2.mat');
        end
    else
        figure(prof_fig);
        zoom off;
        title(['Clear sky for ', datestr(mpl.time(1),1)]);
        v = axis;
        pause(.1);
        clear_sky_time = (find(serial2Hh(mpl.time)>=v(1)&serial2Hh(mpl.time)<=v(2)));
        mpl.r.zoom = find((mpl.range>=v(3))&(mpl.range<=v(4)));
        [pileA] = trimsift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clear_sky_time));
        clear_sky_time = clear_sky_time(pileA);
        clear_sky = mean(mpl.prof(:,clear_sky_time),2);
        clear_sky = smooth(mpl.range,clear_sky,20,'moving');
        figure; semilogy(mpl.range(mpl.r.lte_30), clear_sky(mpl.r.lte_30));zoom
        title('Now zoom to select the region to pin a Rayleigh profile to...');
        pause
        v = axis;
        ray_range = find(mpl.range>v(1)&mpl.range<=v(2));
        clear_sky = mpl.sonde.atten_ray * (mean(clear_sky(ray_range))/mean(mpl.sonde.atten_ray(ray_range)));
        save('clear_sky2.mat', 'clear_sky')
    end
    %!!
    frac_fig = figure;
    imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:)./(clear_sky(mpl.r.lte_30)*ones(size(mpl.time))));
    axis('xy'); colormap('jet');
    title(['normalized profiles: ', datestr(mpl.time(1),0)]); zoom;
    axis([serial2Hh(min(mpl.time)), serial2Hh(max(mpl.time)), min(mpl.range(mpl.r.lte_30)), max(mpl.range(mpl.r.lte_30))]);
    caxis([0,5]);
    title('Zoom to select the region of time to use for retrievals.  Hit enter when done.')
    disp('Zoom to select the region of time to use for retrievals.  Hit enter when done.')
    pause
    figure(frac_fig);
    zoom off;
    title(['MPL profiles for selected region of ', datestr(mpl.time(1),1)]);
    frac_axis = axis;
    pause(.5)

    mpl.t.zoom = (find(serial2Hh(mpl.time)>=frac_axis(1)&serial2Hh(mpl.time)<=frac_axis(2)));
    mpl.r.zoom = find((mpl.range>=frac_axis(3))&(mpl.range<=frac_axis(4)));
    clean_mpl = mpl.t.zoom;
    [pileA] = trimsift_nolog(mpl.range(mpl.r.zoom), mpl.prof(mpl.r.zoom,clean_mpl)./(clear_sky(mpl.r.zoom)*ones(size(clean_mpl))));

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
    mpl.clean = avg.clean; % this is a clean/not clean flag determined while averaging
    clear avg
    missing = find((mpl.hk.bg<=-9998)&(mpl.hk.bg>=-10000));
    non_missing = setdiff((1:length(mpl.hk.bg)), missing);
    %Commented out on 10-19-2004 to avoid unnecessary "missing" designations
    %    clean_mpl = [];
    %    for ct = 1:length(clean_times)-1
    %       [clean_mpl] = [clean_mpl find((mpl.time>=clean_times(ct))&(mpl.time<=clean_times(ct+1)))'];
    %    end
    %    [clean_mpl] = [clean_mpl find((mpl.time>=clean_times(end-1))&(mpl.time<=clean_times(end)))'];
    %    [clean_mpl] = unique(clean_mpl);
    clean_mpl = find(mpl.clean);
    % Calibration versus Rayleigh
    pause(0.2);
    figure(prof_fig);

    pause(0.2);
    imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_30), mpl.prof(mpl.r.lte_30,:).*(ones(size(mpl.r.lte_30))*mpl.clean));
    axis('xy'); colormap('jet');zoom
    axis([frac_axis, 0, 25, 0, 25]);

    v = axis;
    title(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
    disp(['Zoom in to select an aerosol-free region for calibration.  Hit enter when done.']);
    %Pause execution to permit user to zoom into aerosol-free cal region.
    pause;
    figure(prof_fig);
    zoom off;
    cal_v = axis;
    axis([frac_axis,0,25,0,25]);
    title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);
    %title(['MPLnor profiles for selected region of ', datestr(mplnor.time(1),1)]);

    mpl.r.cal = find((mpl.range>=cal_v(3))&(mpl.range<=cal_v(4)));
    %To permit alternate specification of calibration range...
    %keyboard;
    mpl.r.lte_cal = find((mpl.range>.1)&(mpl.range<mpl.range(max(mpl.r.cal))));
    mpl.cal.atten_ray = 10.^(mean(log10(mpl.sonde.atten_ray(mpl.r.cal))));
    %    mpl.cal.nor_sonde = mpl.sonde.atten_prof(mpl.r.cal)/mpl.cal.atten_ray;
    mpl.cal.mean_prof(non_missing) = 10.^(mean(real(log10(mpl.prof(mpl.r.cal,(non_missing))))));
    %     for t = length(mpl.time):-1:1
    %         mpl.cal.P(t,:) = polyfit(mpl.range(mpl.r.cal), real(log10(mpl.prof(mpl.r.cal,t))),1);
    %         %test = 10.^(polyval(P(t,:), mean(mpl.range(mpl.r.cal))));
    %     end
    mpl.cal.mean_prof(missing) = -9999;
    mpl.cal.lowess_mean_prof(non_missing) = lowess(serial2doy(mpl.time(non_missing))-floor(serial2doy(mpl.time((non_missing(1))))), mpl.cal.mean_prof(non_missing), .02)';
    mpl.cal.lowess_mean_prof(missing) = -9999;
    mpl.cal.aod_523(missing) = NaN;

    for nm = length(non_missing):-1:1
        %For each MPL time, find any aod within some time window and
        %interpolate to the MPL time if any found.
        nearby_aod = find(abs(mpl.time(non_missing(nm))-odC1.time)< (3/24));
        if length(nearby_aod>5)
            mpl.cal.aod_523(non_missing(nm)) = interp1(odC1.time(nearby_aod),...
                odC1.aod523(nearby_aod), mpl.time(non_missing(nm)),'nearest','extrap');
        else
            mpl.cal.aod_523(non_missing(nm)) = NaN;
        end
    end
    good_aod = ~isnan(mpl.cal.aod_523(non_missing));
    if sum(good_aod)>2
        mpl.cal.C(non_missing(good_aod)) = mpl.cal.lowess_mean_prof(non_missing(good_aod))...
            ./ (mpl.cal.atten_ray * exp(-2*mpl.cal.aod_523(non_missing(good_aod))));
        mpl.cal.C(non_missing(~good_aod)) = interp1(mpl.time(non_missing(good_aod)), ...
            mpl.cal.C(non_missing(good_aod)),mpl.time(non_missing(~good_aod)));
        mpl.cal.C(missing) = -9999;
    end
    % At this point, we should have lidar C for all non_missing times based
    % on interpolation from lidar C via good aod.
    % We are also likely to have some aod==NaN due to lack of nearby value

    % Now, hypothetically, we can cruize through all clean cases with good
    % aod to retrieve Sa and ext.

    % Then, we interpolate Sa to cases without aod.  This provides us with:
    % lidar C and Sa, so we can compute the extinction profile and retrieve
    % aod.


    total = [1:length(mpl.time)];

    if length(mpl.r.lte_15)<length(mpl.r.lte_cal)
        shorter = mpl.r.lte_15;
        longer = mpl.r.lte_cal;
    else
        shorter = mpl.r.lte_cal;
        longer = mpl.r.lte_15;
    end
    beta_m = mpl.sonde.beta_R(shorter);
    Sa = 30;
    range = mpl.range(shorter);

    %set missings
    mpl.klett.alpha_a(longer,total) = -9999*ones([length(longer),length(total)]);
    mpl.klett.beta_a = mpl.klett.alpha_a;
    mpl.klett.Sa = -9999*ones(size(mpl.time));

    missings = setdiff(total, clean_mpl);
    clean_mpl = find(mpl.clean & ~isnan(mpl.cal.aod_523));

    i = 0;


    for clear_bin = clean_mpl
        if ~exist('klett_fig','var')
            klett_fig = figure;
        end
        figure(klett_fig);
        i = i + 1;
        %         [dump, closest] = min(abs(mpl.time-mplnor.time(clear_bin)));
        %         [mpl.klett.alpha_a(mpl.r.lte_cal,closest), mpl.klett.beta_a(mpl.r.lte_cal,closest), mpl.klett.Sa(closest)] = mpl_autoklett(mpl.range(mpl.r.lte_cal), mpl.prof(mpl.r.lte_cal,closest), mpl.cal.aod_523(closest), mpl.cal.C(closest), mpl.sonde.beta_R(mpl.r.lte_cal), Sa);
        profile = mpl.prof(shorter,clear_bin);
        aod = mpl.cal.aod_523(clear_bin);
        lidar_C = mpl.cal.C(clear_bin);
        subplot(1,2,1); semilogx(profile, range, 'c',  exp(-2*aod).*lidar_C.*mpl.sonde.atten_ray(mpl.r.lte_cal), mpl.range(mpl.r.lte_cal), 'r');
        axis([ 1, 50, min(range), max(range)])
        [alpha_a, beta_a, mpl.klett.Sa(clear_bin)] = mpl_autoklett(range,profile,aod, lidar_C, beta_m, Sa, clear_bin);
        if(mpl.klett.Sa(clear_bin)>(8*pi/3))&&(mpl.klett.Sa(clear_bin)<=(200)&(mean(alpha_a)>0))
            mpl.klett.alpha_a(shorter,clear_bin) = alpha_a;
            mpl.klett.beta_a(shorter,clear_bin) = beta_a;
            Sa = mpl.klett.Sa(clear_bin);
            title_str = (sprintf(['#%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),') AOT=%1.2f  SA=%1.1f C=%1.1f '],i ,length(clean_mpl), mpl.cal.aod_523(clear_bin),Sa,mpl.cal.C(clear_bin)));
        else
            title_str = (sprintf(['Retrieval failure for  #%1d of #%1d;  time(',datestr(mpl.time(clear_bin),15),')'],i ,length(clean_mpl)));
            % title_str= ['Retrieval failure for record number ',num2str(clear_bin)];
            Sa = 30;
        end
        subplot(1,2,2); plot(mpl.klett.alpha_a(shorter, clear_bin),mpl.range(shorter), '.b');
        axis([0 .2 min(range), max(range) ]);
        subplot(1,2,1);
        title(title_str);
        pause(.5)
    end
    %     close(klett_fig);

    % Then, we interpolate Sa to cases without aod.  This provides us with:
    % lidar C and Sa, so we can compute the extinction profile and retrieve
    % aod.
    clean_mpl_no_aod = find(mpl.clean & isnan(mpl.cal.aod_523));
    %         clean_mpl_no_aod = (mpl.clean & isnan(mpl.cal.aod_523));
    if ((sum(clean_mpl_no_aod)>2)&&(length(clean_mpl)>=2))
        mpl.klett.Sa(clean_mpl_no_aod) = interp1(mpl.time(clean_mpl), mpl.klett.Sa(clean_mpl),mpl.time(clean_mpl_no_aod),'linear','extrap');
        % Now we should have Sa for all clean profiles
        % So now we'll just do a straight fernald retrieval supplied with lidar C and
        % Sa to yield ext_prof and aod.
        for clean_bin = clean_mpl_no_aod
            profile = mpl.prof(shorter,clean_bin);
            lidar_C = mpl.cal.C(clean_bin);
            %         beta_m = mpl.sonde.beta_R(shorter);
            Sa =  mpl.klett.Sa(clean_bin);
            [alpha_a, beta_a, new_aot] = ...
                mpl_fernald(range, profile, lidar_C, beta_m, Sa);
            if ((new_aot>0)&&(new_aot<5))
                mpl.cal.aod_523(clean_bin)=new_aot;
                mpl.klett.alpha_a(shorter,clean_bin) = alpha_a;
                mpl.klett.beta_a(shorter,clean_bin) = beta_a;
            end
        end
    end
    mpl.klett.Sa(missings) = -9999;
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
    print(ext_fig, [mpl_pname, '..\plots\mpl102_extprof.',datestr(mpl.time(1),'yyyymmdd'),'.png'],'-dpng');


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
    vstem = datestr(now, 'yymmdd');
    %[fname, mpl_ret_pname] = uiputfile([mpl_ret_pname,fstem,dstem,'ver_',vstem,'.cdf']);
    status = write_mpl_ret(mpl,[mpl_ret_pname,fstem,dstem,'v',vstem,'.cdf']);
end
