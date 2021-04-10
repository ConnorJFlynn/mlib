function mini_mpl_mat_quickplots
%-------------------------------------------------------------------------
% Israel Silber
% Last update: 2019/11/22
% CJF 2019/12/19
%-------------------------------------------------------------------------
% The script loads, process, and saves data files of MPL measurements from 
% the TAN1802 voyage.
%-------------------------------------------------------------------------
% For MPL NRB and formulation see Campbell et al., (2002) and Flynn et al.
% (2007).
%-------------------------------------------------------------------------

%% set paths and flags.
Save_process = false; % save files
Plot_process = true; % generate plots (set to false or Save_plot to true if using in a loop)
Save_plot = true; % Plot_process must be true for saving plots.
Path = 'E:\mmpl\tan\raw_data\';
Path = 'E:\mmpl\tan\raw_data\daily\';
Path = getnamedpath('miniMPL','Select miniMPL daily path');
save_path = [Path 'processed_data\']; if ~isadir(save_path) mkdir(save_path); end
save_plot_path = [Path 'processed_data_plots\'];
if ~isadir(save_plot_path) mkdir(save_plot_path); end
cal_path = 'E:\mmpl\tan\';
cal_path = 'E:\mmpl\ER2019\calibration_uc\';
if isafile([cal_path,'miniMPL_cal.mat'])
% load([cal_path, 'MPL_cal.mat']) % load MPL calibration file
% CJF: renamed to 'miniMPL_cal.mat' in mlib/lidar/mpl directory

MPL_cal = load([cal_path, 'miniMPL_cal.mat']); % load MPL calibration file
if isavar('MPL_cal') && isstruct(MPL_cal) && isfield(MPL_cal, 'MPL_cal')
    MPL_cal = MPL_cal.MPL_cal;
end
elseif isafile([cal_path,'calibration_uc.nc'])
    uc_cal = anc_load([cal_path,'calibration_uc.nc']);
end
STR = 'TAN1802'; % southern ocean voyage
Flist = dir([Path '*.mat']);
%% Enter processing loop
for ii = 1:length(Flist) % number 450 is an interesting case.
    %% load raw data.
        mpl_tmp = load([Flist(ii).folder filesep Flist(ii).name]);
    disp(['Now processing ', Flist(ii).name, ' (file ', num2str(ii), ' out of ', num2str(length(Flist)), ')'])
    mpl_dat.rng = MPL_cal.ap(:,1);
    mpl_dat.time_datenum = mpl_tmp.time;
    mpl_dat.time = mpl_tmp.vdata.('time');
    mpl_dat.az = mpl_tmp.vdata.azimuth_angle;
    mpl_dat.elev = mpl_tmp.vdata.('elevation_angle');
    mpl_dat.lat = mpl_tmp.vdata.( 'gps_latitude');
    mpl_dat.lon = mpl_tmp.vdata.( 'gps_longitude');
    mpl_dat.alt = mpl_tmp.vdata.( 'gps_altitude');
    mpl_dat.ad_flg = mpl_tmp.vdata.( 'ad_data_bad_flag'); % 0: A/D data good, 1: A/D data probably out of sync. Energy monitor collection is not exactly aligned with MCS shots
    mpl_dat.cop = double(mpl_tmp.vdata.( 'channel_2')); % co pol is stored in channel 2 (see metadata)
    mpl_dat.crs = double(mpl_tmp.vdata.( 'channel_1')); % cross pol is stored in channel 1 (see metadata)
    mpl_dat.cop_back = double(mpl_tmp.vdata.( 'background_average_2')); %
    mpl_dat.crs_back = double(mpl_tmp.vdata.( 'background_average')); %
    mpl_dat.cop_back_sd = double(mpl_tmp.vdata.( 'background_stddev_2')); %
    mpl_dat.crs_back_sd = double(mpl_tmp.vdata.( 'background_stddev')); %
    mpl_dat.shots = mpl_tmp.vdata.( 'shots_sum'); %
    mpl_dat.energy_monitor = double(mpl_tmp.vdata.( 'energy_monitor'))./ 1e3; % converting to micro Joule
    mpl_dat.bin_time = mpl_tmp.vdata.( 'bin_time'); %
    mpl_dat.trigger_frequency = mpl_tmp.vdata.( 'trigger_frequency'); %
    mpl_dat.measure_t_tot = mpl_dat.bin_time.* 1e6 .* double(mpl_dat.trigger_frequency).* [diff(mpl_dat.time(1:2)), diff(mpl_dat.time)]; % total receiver measurement time in one averaged bin.
    
    % not all the measurements were performed at the same resolution so
    % interpolating vertically if necessary and extrapolating the ap (weak
    % spot here).
    if size(mpl_dat.cop, 1) == 2000
        mpl_dat.rng = linspace(14.989e-3, 29.9792, 2e3)';
        MPL_cal_2_use.ol = [mpl_dat.rng interp1(MPL_cal.ol_interp(:,1), MPL_cal.ol_interp(:,2), mpl_dat.rng)];
        MPL_cal_2_use.ap = [mpl_dat.rng interp1(MPL_cal.ap_interp(:,1), MPL_cal.ap_interp(:,2), mpl_dat.rng, 'linear', 'extrap')  interp1(MPL_cal.ap_interp(:,1), MPL_cal.ap_interp(:,3), mpl_dat.rng, 'linear', 'extrap')];
    else
        MPL_cal_2_use.ol = MPL_cal.ol_interp;
        MPL_cal_2_use.ap = MPL_cal.ap_interp;
    end
    
    %% process data.    
    
    % range and time
    mpl_dat_cor.rng = mpl_dat.rng;
    mpl_dat_cor.time = mpl_dat.time;
    mpl_dat_cor.time_datenum = mpl_dat.time_datenum;
    
    % dtc
%     mpl_dat_cor.cop = mpl_dat.cop .* polyval(MPL_cal.dtc_poly, mpl_dat.cop); % vendor's DTC
%     mpl_dat_cor.crs = mpl_dat.crs .* polyval(MPL_cal.dtc_poly, mpl_dat.crs); % vendor's DTC 
    mpl_dat_cor.cop = mpl_dat.cop .* interp1(MPL_cal.dtc_table_fit(1,:), MPL_cal.dtc_table_fit(2,:), mpl_dat.cop);
    mpl_dat_cor.crs = mpl_dat.crs .*  interp1(MPL_cal.dtc_table_fit(1,:), MPL_cal.dtc_table_fit(2,:), mpl_dat.crs); 
    
    % set background noise
    cop_noise = real(sqrt(mpl_dat_cor.cop./ repmat(mpl_dat.measure_t_tot, size(mpl_dat_cor.cop, 1), 1))); % noise calculation
    cop_back = repmat(mpl_dat.cop_back, size(mpl_dat_cor.cop, 1), 1);
    cop_noise(cop_back > cop_noise) = cop_back(cop_back > cop_noise); % grabbing the max of the background vs. noise.
    crs_noise = real(sqrt(mpl_dat_cor.crs./ repmat(mpl_dat.measure_t_tot, size(mpl_dat_cor.crs, 1), 1))); % noise calculation
    crs_back = repmat(mpl_dat.crs_back, size(mpl_dat_cor.crs, 1), 1);
    crs_noise(crs_back > crs_noise) = crs_back(crs_back > crs_noise); % grabbing the max of the background vs. noise.
    
    % ap + background removal
    mpl_dat_cor.cop = mpl_dat_cor.cop - repmat(MPL_cal_2_use.ap(:, 2), 1, size(mpl_dat_cor.cop, 2)) - cop_back; 
    mpl_dat_cor.crs = mpl_dat_cor.crs - repmat(MPL_cal_2_use.ap(:, 3), 1, size(mpl_dat_cor.crs, 2)) - crs_back; 
    
    % SNR calculation
    mpl_dat_cor.cop_snr = mpl_dat_cor.cop./ cop_noise;
    mpl_dat_cor.crs_snr = mpl_dat_cor.crs./ crs_noise;
    mpl_dat_cor.cop_snr(mpl_dat_cor.cop_snr <= 0) = nan;
    mpl_dat_cor.crs_snr(mpl_dat_cor.crs_snr <= 0) = nan;
    mpl_dat_cor.cop_snr = 10.*log10(mpl_dat_cor.cop_snr);
    mpl_dat_cor.crs_snr = 10.*log10(mpl_dat_cor.crs_snr);
    
    % finalize (ol + range + energy monitor corrections + clear variables)
    mpl_dat_cor.nrb = (mpl_dat_cor.cop + 2.* mpl_dat_cor.crs);
    mpl_dat_cor.nrb_snr = mpl_dat_cor.nrb./ sqrt(cop_noise.^2 + 2.* crs_noise.^2);
    mpl_dat_cor.nrb_snr(mpl_dat_cor.nrb_snr <= 0) = nan;         mpl_dat_cor.nrb_snr = 10.*log10(mpl_dat_cor.nrb_snr);
    mpl_dat_cor.ldr = zeros(size(mpl_dat_cor.nrb));
    ldr_rel_ind = (mpl_dat_cor.cop + mpl_dat_cor.crs > 0 & mpl_dat_cor.crs > 0);
    mpl_dat_cor.ldr(ldr_rel_ind) = abs(mpl_dat_cor.crs(ldr_rel_ind))./...
        (abs(mpl_dat_cor.cop(ldr_rel_ind)) + abs(mpl_dat_cor.crs(ldr_rel_ind)));
    mpl_dat_cor.ldr_snr = real(1./ sqrt( 1./mpl_dat_cor.crs_snr.^2 + 1./...
        ((mpl_dat_cor.cop + mpl_dat_cor.crs)./ sqrt(cop_noise.^2 + crs_noise.^2).^2))); % Flynn's formulation (not published yet)
    mpl_dat_cor.ldr_snr(mpl_dat_cor.ldr_snr <= 0) = nan;         
    mpl_dat_cor.ldr_snr = 10.*log10(mpl_dat_cor.ldr_snr);
    mpl_dat_cor.cop = mpl_dat_cor.cop .* ...
        (repmat(1./MPL_cal_2_use.ol(:,2) .* mpl_dat_cor.rng.^2, 1, size(mpl_dat_cor.cop, 2))...
        ./ repmat(mpl_dat.energy_monitor, size(mpl_dat_cor.cop, 1), 1)); % overlap, range, and energy corrections.
    mpl_dat_cor.crs = mpl_dat_cor.crs .* ....
        (repmat(1./MPL_cal_2_use.ol(:,2) .* mpl_dat_cor.rng.^2, 1, size(mpl_dat_cor.crs, 2))...
        ./ repmat(mpl_dat.energy_monitor, size(mpl_dat_cor.crs, 1), 1)); % overlap, range, and energy corrections.
    mpl_dat_cor.nrb = mpl_dat_cor.nrb .* ....
        (repmat(1./MPL_cal_2_use.ol(:,2) .* mpl_dat_cor.rng.^2, 1, size(mpl_dat_cor.nrb, 2))...
        ./ repmat(mpl_dat.energy_monitor, size(mpl_dat_cor.nrb, 1), 1)); % overlap, range, and energy corrections.
    clear ldr_rel_ind cop_back crs_back cop_noise crs_noise
    
    %%
    if Plot_process
        YLim = [0 15];
        dtmp = datevec(mpl_dat_cor.time_datenum(1));        
        
        if Save_plot;  Visible = 'on';         else       Visible = 'on';     end
        
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
        Fig = figure_(19);
        ax(1) = subplot(2,1,1);
%         pcolor(mpl_dat.time_datenum, mpl_dat.rng, real(log10(mpl_dat.cop)));  shading flat; 
        imagegap(serial2doy(mpl_dat.time_datenum), mpl_dat.rng, real(log10(mpl_dat.cop - ones(size(mpl_dat.rng))*mpl_dat.cop_back)));
%         dynamicDateTicks;
%         h = colorbar;
        ylim(YLim);  caxis([-3 2]);  colormap jet
        title([STR, ' MiniMPL: ',datestr(mpl_dat.time_datenum(1),'yyyy-mm-dd HH')])
        ylabel('range [km]'); 
        
        ax(2) = subplot(2,1,2); 
        plot(serial2doy(mpl_dat.time_datenum), mpl_dat.elev,'-o'); legend('elev');
        set(gca, 'fontsize', 14, 'fontweight', 'bold')
        xlabel('time [date of year]'); ylabel('El [deg]');  
        linkaxes(ax,'x');
        pause(5);
        if Save_plot
            saveas(Fig,[save_plot_path, STR,datestr(mpl_dat_cor.time_datenum(1), '.yyyymmdd_HHMM.'), 'miniMPL_cop_raw_elev',  '.png'])
            saveas(Fig,[save_plot_path, STR,datestr(mpl_dat_cor.time_datenum(1), '.yyyymmdd_HHMM.'), 'miniMPL_cop_raw_elev',  '.fig'])

            %             set(Fig,'PaperPositionMode','auto')
%             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_cop_raw_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
            close(Fig)
        end
        
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
%         pcolor(mpl_dat.time_datenum, mpl_dat.rng, real(log10(mpl_dat.crs)));  shading flat; h = colorbar;
%         ylim(YLim);  caxis([-3 2]);  colormap jet
%         set(gca, 'fontsize', 14, 'fontweight', 'bold', 'xlim', [datenum([dtmp(1:4), 0 0]) datenum([dtmp(1:4)+[0,0,0,1], 0 0])], 'xtick', linspace(datenum([dtmp(1:4), 0 0]), datenum([dtmp(1:4)+[0,0,0,1], 0 0]), 7))
%         title('crosspol raw counts'); dynamicDateTicks; xlabel('date'); ylabel('range [km]');  ylabel(h, '[counts /microsec]')
%         if Save_plot
%             saveas(Fig,[save_plot_path, STR, 'miniMPL_crs_raw_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png']);
% %             set(Fig,'PaperPositionMode','auto')
% %             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_crs_raw_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
%             close(Fig)
%         end
%         
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
%         pcolor(mpl_dat_cor.time_datenum, mpl_dat_cor.rng, real(log10(mpl_dat_cor.cop)));  shading flat; h = colorbar;
%         ylim(YLim);  caxis([-2 2]); colormap jet
%         set(gca, 'fontsize', 14, 'fontweight', 'bold', 'xlim', [datenum([dtmp(1:4), 0 0]) datenum([dtmp(1:4)+[0,0,0,1], 0 0])], 'xtick', linspace(datenum([dtmp(1:4), 0 0]), datenum([dtmp(1:4)+[0,0,0,1], 0 0]), 7))
%         title('copol NRB'); dynamicDateTicks; xlabel('date'); ylabel('range [km]');  ylabel(h, '[counts*km^2 /(\musec*\muJ)]')
%         if Save_plot
%             saveas(Fig,[save_plot_path, STR, 'miniMPL_cop_nrb_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png']);
% %             set(Fig,'PaperPositionMode','auto')
% %             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_cop_nrb_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
%             close(Fig)
%         end
%         
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
%         pcolor(mpl_dat_cor.time_datenum, mpl_dat_cor.rng, real(log10(mpl_dat_cor.crs)));  shading flat; h = colorbar;
%         ylim(YLim);  caxis([-2 2]); colormap jet
%         set(gca, 'fontsize', 14, 'fontweight', 'bold', 'xlim', [datenum([dtmp(1:4), 0 0]) datenum([dtmp(1:4)+[0,0,0,1], 0 0])], 'xtick', linspace(datenum([dtmp(1:4), 0 0]), datenum([dtmp(1:4)+[0,0,0,1], 0 0]), 7))
%         title('crosspol NRB'); dynamicDateTicks; xlabel('date'); ylabel('range [km]');  ylabel(h, '[counts*km^2 /(\musec*\muJ)]')
%         if Save_plot
%             saveas(Fig,[save_plot_path, STR, 'miniMPL_crs_nrb_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png']);
% %             set(Fig,'PaperPositionMode','auto')
% %             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_crs_nrb_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
%             close(Fig)
%         end
%         
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
%         pcolor(mpl_dat_cor.time_datenum, mpl_dat_cor.rng, real(log10(mpl_dat_cor.nrb)));  shading flat; h = colorbar;
%         ylim(YLim);  caxis([-2 2]); colormap jet
%         set(gca, 'fontsize', 14, 'fontweight', 'bold', 'xlim', [datenum([dtmp(1:4), 0 0]) datenum([dtmp(1:4)+[0,0,0,1], 0 0])], 'xtick', linspace(datenum([dtmp(1:4), 0 0]), datenum([dtmp(1:4)+[0,0,0,1], 0 0]), 7))
%         title('NRB'); dynamicDateTicks; xlabel('date'); ylabel('range [km]');  ylabel(h, '[counts*km^2 /(\musec*\muJ)]')
%         if Save_plot
%             saveas(Fig,[save_plot_path, STR, 'miniMPL_tot_nrb_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png']);
% %             set(Fig,'PaperPositionMode','auto')
% %             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_tot_nrb_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
%             close(Fig)
%         end
%         
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
%         pcolor(mpl_dat_cor.time_datenum, mpl_dat_cor.rng, mpl_dat_cor.nrb_snr);  shading flat; h = colorbar;
%         ylim(YLim);  caxis([0 30]); colormap jet
%         set(gca, 'fontsize', 14, 'fontweight', 'bold', 'xlim', [datenum([dtmp(1:4), 0 0]) datenum([dtmp(1:4)+[0,0,0,1], 0 0])], 'xtick', linspace(datenum([dtmp(1:4), 0 0]), datenum([dtmp(1:4)+[0,0,0,1], 0 0]), 7))
%         title('NRB SNR'); dynamicDateTicks; xlabel('date'); ylabel('range [km]');  ylabel(h, '[dB]')
%         if Save_plot
%             saveas(Fig,[save_plot_path, STR, 'miniMPL_tot_nrb_snr_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png']);
% %             set(Fig,'PaperPositionMode','auto')
% %             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_tot_nrb_snr_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
%             close(Fig)
%         end
%         
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
%         pcolor(mpl_dat_cor.time_datenum, mpl_dat_cor.rng, mpl_dat_cor.ldr);  shading flat; h = colorbar;
%         ylim(YLim);  caxis([0 0.6]); colormap jet
%         set(gca, 'fontsize', 14, 'fontweight', 'bold', 'xlim', [datenum([dtmp(1:4), 0 0]) datenum([dtmp(1:4)+[0,0,0,1], 0 0])], 'xtick', linspace(datenum([dtmp(1:4), 0 0]), datenum([dtmp(1:4)+[0,0,0,1], 0 0]), 7))
%         title('LDR'); dynamicDateTicks; xlabel('date'); ylabel('range [km]');  ylabel(h, 'LDR')
%         if Save_plot
%             saveas(Fig,[save_plot_path, STR, 'miniMPL_ldr_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png']);
% %             set(Fig,'PaperPositionMode','auto')
% %             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_ldr_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
%             close(Fig)
%         end
%         
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
%         pcolor(mpl_dat_cor.time_datenum, mpl_dat_cor.rng, mpl_dat_cor.ldr_snr);  shading flat; h = colorbar;
%         ylim(YLim);  caxis([0 20]); colormap jet
%         set(gca, 'fontsize', 14, 'fontweight', 'bold', 'xlim', [datenum([dtmp(1:4), 0 0]) datenum([dtmp(1:4)+[0,0,0,1], 0 0])], 'xtick', linspace(datenum([dtmp(1:4), 0 0]), datenum([dtmp(1:4)+[0,0,0,1], 0 0]), 7))
%         title('LDR SNR'); dynamicDateTicks; xlabel('date'); ylabel('range [km]');  ylabel(h, '[dB]')
%         if Save_plot
%             saveas(Fig,[save_plot_path, STR, 'miniMPL_ldr_snr_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png']);
% %             set(Fig,'PaperPositionMode','auto')
% %             print('-dpng','-opengl','-r150',[save_plot_path, STR, 'miniMPL_ldr_snr_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.png'])
%             close(Fig)
%         end
    end
    
    %% write to file
    
    if  Save_process
        nc_Filename = [STR, 'miniMPL_process_', datestr(mpl_dat_cor.time_datenum(1), 'yyyymmddHHMM'), '.nc'];
        t_num = length(mpl_dat.alt);
        Num_layers = size(mpl_dat.cop, 1);
        
        nccreate([save_path, nc_Filename], 'altitude', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'altitude', mpl_dat.alt')
        ncwriteatt([save_path, nc_Filename], 'altitude', 'Units', 'm')
        ncwriteatt([save_path, nc_Filename], 'altitude', 'Description', 'Altitude (GPS)')
        nccreate([save_path, nc_Filename], 'latitude', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'latitude', mpl_dat.lat')
        ncwriteatt([save_path, nc_Filename], 'latitude', 'Units', 'degrees N')
        ncwriteatt([save_path, nc_Filename], 'latitude', 'Description', 'Latitude (GPS)')
        nccreate([save_path, nc_Filename], 'longitude', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'longitude', mpl_dat.lon')
        ncwriteatt([save_path, nc_Filename], 'longitude', 'Units', 'degrees E')
        ncwriteatt([save_path, nc_Filename], 'longitude', 'Description', 'Longitude (GPS)')
        nccreate([save_path, nc_Filename], 'elevation', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'elevation', mpl_dat.elev')
        ncwriteatt([save_path, nc_Filename], 'elevation', 'Units', 'degrees')
        ncwriteatt([save_path, nc_Filename], 'elevation', 'Description', 'MPL elevation angle')
        nccreate([save_path, nc_Filename], 'azimuth', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'azimuth', mpl_dat.az')
        ncwriteatt([save_path, nc_Filename], 'azimuth', 'Units', 'degrees')
        ncwriteatt([save_path, nc_Filename], 'azimuth', 'Description', 'MPL azimuth')
        nccreate([save_path, nc_Filename], 'time', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'double', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'time', mpl_dat_cor.time')
        ncwriteatt([save_path, nc_Filename], 'time', 'Units', 's')
        ncwriteatt([save_path, nc_Filename], 'time', 'description', 'Time (seconds since 1970-01-01 00:00 UTC)')
        nccreate([save_path, nc_Filename], 'time_datenum', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'double', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'time_datenum', mpl_dat_cor.time_datenum')
        ncwriteatt([save_path, nc_Filename], 'time_datenum', 'description', 'Time (MATLAB''s datenum format)')
        nccreate([save_path, nc_Filename], 'range', 'dimensions', {'Num_layers', Num_layers, '1', 1}, 'datatype', 'double', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'range', mpl_dat_cor.rng)
        ncwriteatt([save_path, nc_Filename], 'range', 'Units', 'km')
        ncwriteatt([save_path, nc_Filename], 'range', 'description', 'Range')
        nccreate([save_path, nc_Filename], 'ad_flag', 'dimensions', {'1', 1, 'Samples', t_num}, 'datatype', 'int8', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'ad_flag', mpl_dat.ad_flg')
        ncwriteatt([save_path, nc_Filename], 'ad_flag', 'Units', 's')
        ncwriteatt([save_path, nc_Filename], 'ad_flag', 'description', 'A/D error flag (0 - OK measurement)')
        % write processed data fields.
        nccreate([save_path, nc_Filename], 'nrb_cop', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'nrb_cop', mpl_dat_cor.cop)
        ncwriteatt([save_path, nc_Filename], 'nrb_cop', 'Units', 'Counts * km^2 / (microsec * micro Joule)')
        ncwriteatt([save_path, nc_Filename], 'nrb_cop', 'description', 'Co-polar NRB signal after dead time, afterpulse, overlap, background noise, and range corrections')
        nccreate([save_path, nc_Filename], 'nrb_crs', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'nrb_crs', mpl_dat_cor.crs)
        ncwriteatt([save_path, nc_Filename], 'nrb_crs', 'Units', 'Counts * km^2 / (microsec * micro Joule)')
        ncwriteatt([save_path, nc_Filename], 'nrb_crs', 'description', 'Cross-polar NRB signal after dead time, afterpulse, overlap, background noise, and range corrections')
        nccreate([save_path, nc_Filename], 'nrb_tot', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'nrb_tot', mpl_dat_cor.nrb)
        ncwriteatt([save_path, nc_Filename], 'nrb_tot', 'Units', 'Counts * km^2 / (microsec * micro Joule)')
        ncwriteatt([save_path, nc_Filename], 'nrb_tot', 'description', 'Total NRB signal after dead time, afterpulse, overlap, background noise, and range corrections')
        nccreate([save_path, nc_Filename], 'nrb_cop_snr', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'nrb_cop_snr', mpl_dat_cor.cop_snr)
        ncwriteatt([save_path, nc_Filename], 'nrb_cop_snr', 'Units', 'dB')
        ncwriteatt([save_path, nc_Filename], 'nrb_cop_snr', 'description', 'Co-polar NRB signal-to-noise ratio')
        nccreate([save_path, nc_Filename], 'nrb_crs_snr', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'nrb_crs_snr', mpl_dat_cor.crs_snr)
        ncwriteatt([save_path, nc_Filename], 'nrb_crs_snr', 'Units', 'dB')
        ncwriteatt([save_path, nc_Filename], 'nrb_crs_snr', 'description', 'Cross-polar NRB signal-to-noise ratio')
        nccreate([save_path, nc_Filename], 'nrb_tot_snr', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'nrb_tot_snr', mpl_dat_cor.nrb_snr)
        ncwriteatt([save_path, nc_Filename], 'nrb_tot_snr', 'Units', 'dB')
        ncwriteatt([save_path, nc_Filename], 'nrb_tot_snr', 'description', 'Total NRB signal-to-noise ratio')
        nccreate([save_path, nc_Filename], 'ldr', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'ldr', mpl_dat_cor.ldr)
        ncwriteatt([save_path, nc_Filename], 'ldr', 'description', 'Linear depolarization ratio')
        nccreate([save_path, nc_Filename], 'ldr_snr', 'dimensions', {'Num_layers', Num_layers, 'Samples', t_num}, 'datatype', 'single', 'format', 'netcdf4', 'DeflateLevel', 9)
        ncwrite([save_path, nc_Filename], 'ldr_snr', mpl_dat_cor.ldr_snr)
        ncwriteatt([save_path, nc_Filename], 'ldr_snr', 'Units', 'dB')
        ncwriteatt([save_path, nc_Filename], 'ldr_snr', 'description', 'Linear depolarization ratio signal-to-noise-ratio')
        ncwriteatt([save_path, nc_Filename], '/', 'Processing calculation references', 'Campbell et al. (2002); Flynn et al. (2007)')
        ncwriteatt([save_path, nc_Filename], '/', 'Date generated', datestr(now))
        ncwriteatt([save_path, nc_Filename], '/', 'Generated by', 'Israel Silber')
    end
    clear mpl_dat_cor mpl_dat_cor mpl_dat ans
end

return