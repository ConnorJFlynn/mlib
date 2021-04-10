function mini_mpl_mat_lat_lon
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
save_path = [Path 'processed_data\']; if ~isadir(save_path) mkdir(save_path); end
save_plot_path = [Path 'processed_data_plots\'];
if ~isadir(save_plot_path) mkdir(save_plot_path); end
cal_path = 'E:\mmpl\tan\';

% load([cal_path, 'MPL_cal.mat']) % load MPL calibration file
% CJF: renamed to 'miniMPL_cal.mat' in mlib/lidar/mpl directory

MPL_cal = load([cal_path, 'miniMPL_cal.mat']); % load MPL calibration file
if isavar('MPL_cal') && isstruct(MPL_cal) && isfield(MPL_cal, 'MPL_cal')
    MPL_cal = MPL_cal.MPL_cal;
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
    
    %%
    if Plot_process
        YLim = [0 15];
        dtmp = datevec(mpl_dat.time_datenum(1));        
        
        if Save_plot;  Visible = 'off';         else       Visible = 'on';     end
        
%         Fig = figure('position', [0 0 1920 1080], 'visible', Visible);
        Fig = figure_(20);
        ax(1) = subplot(4,1,1);  plot(serial2doy(mpl_dat.time_datenum), mpl_dat.lat,'o'); legend('Lat');
        ax(2) = subplot(4,1,2);  plot(serial2doy(mpl_dat.time_datenum), mpl_dat.lon,'x'); legend('Lon');
        ax(3) = subplot(4,1,3);  plot(serial2doy(mpl_dat.time_datenum), mpl_dat.elev,'+'); legend('Elev');
        ax(4) = subplot(4,1,4);  plot(serial2doy(mpl_dat.time_datenum), mpl_dat.az,'*'); legend('Az');

        title([STR, ' MiniMPL: ',datestr(mpl_dat.time_datenum(1),'yyyy-mm-dd HH')])
        linkaxes(ax,'x');
        menu('zoom, hit OK when done','OK');
        
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
    
    
    clear mpl_dat_cor mpl_dat_cor mpl_dat ans
end

return