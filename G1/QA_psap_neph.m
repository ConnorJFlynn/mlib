function QA_psap_neph
% Want to generate QA flags for PSAP & Neph. 
% Still trying to understand PSAP issues associated with ramps or pressure
% changes. Intend to load PSAP_raw.txt (for precision absorption), PSAP.txt
% (for associated HK fields including temp and RH at PSAP exhaust), Neph
% (for correlation between Bs and Ba), and probably IWG1 file.
% Use a scan of these to 
% 1. Get a sense of the reliability
% 2. Define some automated tests
% 3. Configure visi-screen for flagging this data set.

% clear; close('all');
% close('all'); clear ax
disp('Getting psap_raw')
[psapo_grid,~,psapi] = rd_psapi_g1;

    if ~exist([psapo_grid.pname, '..',filesep,'flags'],'dir')
        mkdir([psapo_grid.pname, '..',filesep,'flags'])
    end

dstr = psapi.fname(1:8);
disp('Getting psap panel')
[psap_txt] = rd_psap_txt_g1([psapo_grid.pname, strrep(psapo_grid.fname, 'psap_raw','psap')]);

disp('Getting neph')
[neph_grid] = rd_nephD_g1([strrep(psapo_grid.pname,'PSAP','Neph'), strrep(psapo_grid.fname, 'psap_raw','nephD')]);

disp('Getting IWG')
[iwg_grid, iwg] = rd_iwg1_g1([strrep(psapo_grid.pname,'PSAP','IWG1'), strrep(psapo_grid.fname, 'psap_raw','iwg1.a1.ver1')]);
figure(98);scatter3(iwg_grid.Lon,iwg_grid.Lat, iwg_grid.GPS_MSL_Alt,4,serial2hs(iwg_grid.time)) ;colorbar;
% figure; plot(iwg_grid.time, [iwg_grid.GPS_MSL_Alt*100/2.54/12,iwg_grid.Press_Alt,iwg_grid.Radar_Alt],'x'); legend('GPS','Press','Radar')
%Met, IWG1, CPC, SP2

disp('Getting met')
[met_grid, met] = rd_met_g1([strrep(psapo_grid.pname,'PSAP','MET'), strrep(psapo_grid.fname, 'psap_raw','met')]);
%Met, IWG1, CPC, SP2

disp('Getting cpcf')
[cpcf_grid, cpcf] = rd_cpc_3010_g1([strrep(psapo_grid.pname,'PSAP','CPC'), strrep(psapo_grid.fname, 'psap_raw','3010')]);

disp('Getting cpcu')
[cpcu_grid, cpcu] = rd_cpc_3025_g1([strrep(psapo_grid.pname,'PSAP','CPC'), strrep(psapo_grid.fname, 'psap_raw','3025')]);

sp2_ =  rd_sp2_m02(getfullname(['*SP2*.00.',dstr,'.*m02.txt'],'sp2','select mentor-edited SP2 file'));
sp2.time = sp2_.time; sp2.rBC= sp2_.SP2_rBC_conc;

main.t = psapo_grid.time;
main.Ba_B = psapo_grid.Ba_B_sm_Weiss;

% panel_1.RH_post_PSAP = interp1(psap_txt.time(isfinite(psap_txt.time)), psap_txt.RH_post_PSAP(isfinite(psap_txt.time)), main.t,'nearest');
% panel_1.T_post_PSAP = interp1(psap_txt.time(isfinite(psap_txt.time)), psap_txt.T_post_PSAP(isfinite(psap_txt.time)), main.t,'nearest');
panel_2.Bs_B = 1e6.*interp1(neph_grid.time(isfinite(neph_grid.time)), neph_grid.Bs_B_sm(isfinite(neph_grid.time)), main.t,'nearest');
panel_2.Bs_G = 1e6.*interp1(neph_grid.time(isfinite(neph_grid.time)), neph_grid.Bs_G_sm(isfinite(neph_grid.time)), main.t,'nearest');
panel_2.Ba_B_x10 = 10.*main.Ba_B;
panel_1.GPS_Alt_MSL = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.GPS_MSL_Alt(isfinite(iwg_grid.time)), main.t,'nearest');
panel_3.rBC =  interp1(sp2.time(isfinite(sp2.time)), sp2.rBC(isfinite(sp2.time)), main.t,'nearest');
panel_3.Ba_B_x20 = 20.*main.Ba_B;


    ylims.panel_1 = [0, 10e3];
    ylims.panel_2 = [0,100];
    ylims.panel_3 = [0,1e2];
%     ylims.panel_4 = [0,80];
    figs.tau_fig.h = 1;
    figs.tau2_fig.h = 2;
    figs.leg_fig.h = 3;
    figs.aux_fig.h = 4;
    figs.tau_fig.pos = [ 0.2990    0.5250    0.2917    0.3889];
    figs.tau2_fig.pos = [0.3021    0.0537    0.2917    0.3889];
    figs.leg_fig.pos =   [ 0.1109    0.5731    0.1776    0.3611];
    figs.aux_fig.pos = [0.6167 0.0769 0.2917 0.8306];
    
    flags.bad_coef = [];
    flags.cut_S_wave = [];
    flags.no_matched_scat = [];
    flags.no_matched_rBC = [];
    flags.pressure_change = [];
    flags.RH_change = [];
    flags.T_change = [];
    flags.plume = [];
    flags.elevated_layer = [];
    flags.PBL = [];
    no_mask = {'plume','elevated_layer','PBL'};




[flags, screened, good, figs] = visi_screen_v10( main.t,  main.Ba_B,'time_choice',2,'flags',flags,'no_mask',no_mask,'figs',figs,...
        'panel_1', panel_1, 'panel_2',panel_2,'panel_3',panel_3,'ylims',ylims,'time_choice',1, 'figs',figs);


    save([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(psapo_grid.time(1),'yyyymmdd_HHMM'), '.PSAP.flags.mat'], '-struct','flags');

    % INPUTS:
% startDay:     UTC beginning date for data, yyyymmdd
% Start_UTC:    data timestamp. ICARTT format specifies that this is UTC seconds since the beginning of
%                   startDay. Other timestamps can be included as dependent variables. Note that appropriate
%                   timestamps may vary depending on how data is collected or averaged (see ICARTT documenation).
% data:         Structure containing variables to write. All variables should be vectors of the same length at
%                   Start_UTC, and missing values should be NaNs. Field names in this structure will also be
%                   used as varialbe names in the output ICARTT file. Variables will printed in the same order in which they
%                   appear in the structure.
% info:         Structure of information for dependent variables. Field names should be the same as
%                   those in the data structure. Fields should contain short string descriptions of each variable.
% form:         Structure containing format strings for dependent variables. Field names should be the same as
%                   those in the data structure. Default value is '%6.3f'. For more info, see help for fprintf.
% rev:          revision letter (for preliminary data) or number (for final data). MUST BE A STRING!
% ICTdir:       full path for save directory.

Start_of_day = floor(min(main.t(good)));
Start_UTC = (main.t(good)-Start_of_day).*24*60*60;

data_in.Stop_UTC = Start_UTC + 4; info.Stop_UTC = ['seconds']; form.Stop_UTC = '%6.2f';
data_in.Ba_B = psapo_grid.Ba_B_sm_Weiss(good); info.Ba_B = ['1/Mm, aerosol absorption (blue)']; form.Ba_B = '%6.3f';
data_in.Ba_G = psapo_grid.Ba_G_sm_Weiss(good); info.Ba_G = ['1/Mm, aerosol absorption (green)']; form.Ba_G = '%6.3f';
data_in.Ba_R = psapo_grid.Ba_R_sm_Weiss(good); info.Ba_R = ['1/Mm, aerosol absorption (red)']; form.Ba_R = '%6.3f';
rev = '0';
ICTdir = 'G:\case_studies\AAF\2015_ACME-V\PSAP\ict\';

ICARTTwriter_PSAP_ACMEV(datestr(min(main.t(good)),'yyyymmdd'),Start_UTC,data_in,info,form,rev,ICTdir);
    

% Use "screened" to select only "good" values and send to ICART

% Potentially useful quantities to plot:
%   Absorption 

figure; plot(serial2hs(psapo_grid.time), [psapo_grid.trans_B_sm,psapo_grid.trans_G_sm,psapo_grid.trans_R_sm],'-');dynamicDateTicks
legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');
title('PSAP transmittances, full precision');
zoom('on');
ax(1)=gca;

% figure; plot(serial2hs(psapo_grid.time), [psapo_grid.Ba_B_sm_Weiss,psapo_grid.Ba_G_sm_Weiss, psapo_grid.Ba_R_sm_Weiss],'-', ...
%     serial2hs(psapi.time + (15./(24*60*60))), [smooth(psapi.Ba_B,60),smooth(psapi.Ba_G,60), smooth(psapi.Ba_R,60)],'o'); 
figure; plot(serial2hs(psapo_grid.time), [psapo_grid.Ba_B_sm_Weiss,psapo_grid.Ba_G_sm_Weiss, psapo_grid.Ba_R_sm_Weiss],'-'); 
zoom('on')
% legend('Ba B 32s in T','Ba G 32s in T', 'Ba R 32s in T', 'Ba B 60s in Ba','Ba G 60s in Ba', 'Ba R 60s in Ba');
legend('Ba B 32s in T','Ba G 32s in T', 'Ba R 32s in T');
title(['Absorption coeffs ',strtok(psapi.fname,'.')]);
ylabel('1/Mm')
ax(end+1) = gca;
figure; plot(serial2hs(psapo_grid.time), psapo_grid.mass_flow_last, '-x');
ax(end+1) = gca;  
legend('mass flow'); title(['PSAP Mass flow ',strtok(psapi.fname,'.')]);
figure; ax(end+1) = subplot(2,1,1); plot(serial2hs(psap_txt.time), psap_txt.T_post_PSAP, '-x');
legend('T after'); title(['PSAP Mass flow ',strtok(psapi.fname,'.')]);
ax(end+1) = subplot(2,1,2);
plot(serial2hs(psap_txt.time), psap_txt.RH_post_PSAP, '-o');
legend('RH after');

figure; plot(serial2hs(neph_grid.time), [neph_grid.Bs_B_sm,neph_grid.Bs_G_sm,neph_grid.Bs_R_sm].*1e6, '-');
legend('Bs B','Bs G', 'Bs R'); 
ylabel('1/Mm')
ax(end+1) = gca;

figure; plot(serial2hs(neph_grid.time), [neph_grid.T_stat-273,neph_grid.T_vol-273], 'o-');
legend('T s', 'Neph T_v_o_l'); 
ax(end+1) = gca;

figure; plot(serial2hs(neph_grid.time), [neph_grid.P], 'o-');
legend('Neph P'); 
ax(end+1) = gca;

figure; plot(serial2hs(neph_grid.time), [neph_grid.RH], 'o-');
legend('Neph RH'); 
ax(end+1) = gca;

linkaxes(ax,'x');
disp('hi')


return

function out = setup_visi_screen

% y panels
    panel_1.aod_500nm = aod_500nm;
    panel_1.aod_865nm = aod_865nm;
    panel_2.ang = ang_noscreening;
    panel_2.std_ang = sliding_std(ang_noscreening,10)';
    panel_3.rawrelstd = rawrelstd(:,1);
    panel_4.Alt = Alt;
    
    ylims.panel_1 = [-.1, 2];
    ylims.panel_2 = [-1,4];
    ylims.panel_3 = [0,1];
    ylims.panel_4 = [0,8000];
    figs.tau_fig.h = 1;
    figs.tau2_fig.h = 2;
    figs.leg_fig.h = 3;
    figs.aux_fig.h = 4;
    figs.tau_fig.pos = [ 0.2990    0.5250    0.2917    0.3889];
    figs.tau2_fig.pos = [0.3021    0.0537    0.2917    0.3889];
    figs.leg_fig.pos =   [ 0.1109    0.5731    0.1776    0.3611];
    figs.aux_fig.pos = [0.6167 0.0769 0.2917 0.8306];
    
    flags.no_matched_N_CN = [];
    flags.no_matched_scat = [];
    flags.no_matched_rBC = [];
    flags.pressure_change = [];
    flags.RH_change = [];
    flags.T_change = [];
    flags.plume = [];
    flags.elevated_layer = [];
    flags.PBL = [];
    no_mask = {'plume','elevated_layer','PBL'};
    
    out.panel_1 = panel_1;
    out.panel_2 = panel_2;
    out.panel_3 = panel_3;
    out.panel_4 = panel_4;
    out.figs = figs;
    out.ylims = ylims;
    out.no_mask = no_mask;
    

return