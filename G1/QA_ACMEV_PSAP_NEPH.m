function QA_ACMEV_PSAP
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
[psapo_grid,~,psapi] = rd_psapi_g1([],17.51);

    if ~exist([psapo_grid.pname, '..',filesep,'flags'],'dir')
        mkdir([psapo_grid.pname, '..',filesep,'flags'])
    end

dstr = psapi.fname(1:8);
disp('Getting psap panel')
[psap_txt] = rd_psap_txt_g1([psapo_grid.pname, strrep(psapo_grid.fname, 'psap_raw','psap')]);
date_str = datestr(psap_txt.time(1),'yyyymmdd');
disp('Getting neph')
[neph_grid] = rd_nephD_g1([strrep(psapo_grid.pname,'PSAP','Neph'), strrep(psapo_grid.fname, 'psap_raw','nephD')]);

corr_to_STP = (1013.5./neph_grid.P).*(neph_grid.T_vol./273.15); % STP 1013.5 Pa, 0 C
% Multiply neph scattering by this density correction factor to get values at STP.
% Compute angstrom exponent from non-truncation corrected scattering
% Adjust non-truncation corrected scattering to PSAP wavelengths of 470, 522, and 660 nm
% using initial AE in the neph_grid file (which were computed before
% truncation correction)

% new_coef = ang_coef(old_coef, ang, old_wl, new_wl);
Bs_B_psap = ang_coef(neph_grid.Bs_B_sm, neph_grid.Ae_GB, 450, 470);
Bs_G_psap = ang_coef(neph_grid.Bs_G_sm, neph_grid.Ae_RB, 550, 522);
Bs_R_psap = ang_coef(neph_grid.Bs_R_sm, neph_grid.Ae_RG, 700, 660);

Bs_B_psap = Bs_B_psap .* corr_to_STP;
Bs_G_psap = Bs_G_psap .* corr_to_STP;
Bs_R_psap = Bs_R_psap .* corr_to_STP;

AE = neph_grid.Ae_GB;
K1_blue =  0.334.*AE; K1_blue(AE>=0.6) = .02; K1_blue(AE<=0.2) = .00688;
AE = neph_grid.Ae_RB;
K1_green =  0.334.*AE; K1_green(AE>=0.6) = .02; K1_green(AE<=0.2) = .00688;
AE = neph_grid.Ae_RG;
K1_red =  0.334.*AE; K1_red(AE>=0.6) = .02; K1_red(AE<=0.2) = .00688;

Scat_K2 = 1.22 .* 1.031;

Ba_B_scat = 1e6.*(K1_blue./Scat_K2).* Bs_B_psap;
Ba_G_scat = 1e6.*(K1_green./Scat_K2).* Bs_G_psap;
Ba_R_scat = 1e6.*(K1_red./Scat_K2).* Bs_R_psap;


Bs_B = 1e6.*interp1(neph_grid.time,  neph_grid.Bs_B_sm, psapo_grid.time,'nearest');
Bs_G = 1e6.*interp1(neph_grid.time,  neph_grid.Bs_G_sm, psapo_grid.time,'nearest');
Bs_R = 1e6.*interp1(neph_grid.time,  neph_grid.Bs_R_sm, psapo_grid.time,'nearest');

psapo_grid.Ba_B_Bond = psapo_grid.Ba_B_sm_Weiss - interp1(neph_grid.time, Ba_B_scat, psapo_grid.time,'nearest');
low_signal = Bs_B<.1 | Bs_G<.1;
psapo_grid.Ba_B_Bond(low_signal) = psapo_grid.Ba_B_sm_Weiss(low_signal);

psapo_grid.Ba_G_Bond = psapo_grid.Ba_G_sm_Weiss - interp1(neph_grid.time, Ba_G_scat, psapo_grid.time,'nearest');
low_signal = Bs_B<.1 | Bs_R<.1;
psapo_grid.Ba_G_Bond(low_signal) = psapo_grid.Ba_G_sm_Weiss(low_signal);

psapo_grid.Ba_R_Bond = psapo_grid.Ba_R_sm_Weiss - interp1(neph_grid.time, Ba_R_scat, psapo_grid.time,'nearest');
low_signal = Bs_G<.1 | Bs_R<.1;
psapo_grid.Ba_R_Bond(low_signal) = psapo_grid.Ba_R_sm_Weiss(low_signal);


% Blue  
% K1 = 0.2 for Ang >= 0.6, 0.0334*Ang for 0.2<Ang<0.6, and 0.00668 for Ang<= 0.2.
% Ba_B_scat_subtraction = 

% from my email to Brian Ermold June 1, 2015
% We subtract the following term from our Weiss-corrected absorption:
% Scat_sub = K1/K2 * B_s , where:
% K2 = 1.22 * 1.031 = 1.2578
% K1 = 0.2 for Ang >= 0.6, 0.0334*Ang for 0.2<Ang<0.6, and 0.00668 for Ang<= 0.2.
% Ang is the angstrom exponent for the pairing of neph wavelengths closest to the PSAP or CLAP filter being corrected 
% B_s is the nephelometer scattering (without truncation correction) adjusted to the PSAP filter wavelength.  
% Adjust the neph scattering measurements to the filter wavelengths as follows:
% Bs_filter_R = Bs_R * (neph_R_WL / filter_R_WL)^Ang_RG
% Bs_filter_G = Bs_G * (neph_G_WL / filter_G_WL)^Ang_GB
% Bs_filter_B = Bs_B * (neph_B_WL / filter_B_WL)^Ang_GB
% 
% neph R G B wavelengths= 700, 550, 450
% psap R, G, B wavelengths = 660, 522, 470
% clap R, G, B wavelenths = 653, 529, 467 

% Then correct to conditions outside aircraft, OAT and Static_Press

% At this point, we have absorption coefficients with flow correction,
% spot-size correction, and filter-loading correction.
% And we have nephelometer values with and without truncation correction.
% Now, we can apply density correction to neph (wi/out truncation) and then
% scattering subtraction to PSAP.

disp('Getting IWG')
% aaf.iwg1001s.g1.acmev.20150816a.a2.txt
[iwg_grid, iwg] = rd_iwg1_g1(getfullname(['aaf.iwg1001s.g1.acmev.',date_str,'*.a2.txt'],'IWG1','Select IWG1 file'));
corr_STP_to_ambient = (iwg_grid.Static_Press ./1013.5) .* (273.15./(iwg_grid.Ambient_Temp+273.15));

% [iwg_grid, iwg] = rd_iwg1_g1([strrep(psapo_grid.pname,'PSAP','IWG1'), strrep(psapo_grid.fname, 'psap_raw','iwg1.a1.ver2')]);

figure(98);scatter3(iwg_grid.Lon,iwg_grid.Lat, iwg_grid.GPS_MSL_Alt,4,serial2hs(iwg_grid.time)) ;
xlabel('Lon [deg]'); ylabel('Lat [deg]'); zlabel('GPS MSL [m]'); cb = colorbar; set(get(cb,'title'),'string','Time UTC')
% figure; plot(iwg_grid.time, [iwg_grid.GPS_MSL_Alt*100/2.54/12,iwg_grid.Press_Alt,iwg_grid.Radar_Alt],'x'); legend('GPS','Press','Radar')
%Met, IWG1, CPC, SP2

disp('Getting met')
[met_grid, met] = rd_met_g1([strrep(psapo_grid.pname,'PSAP','MET'), strrep(psapo_grid.fname, 'psap_raw','met')]);
%Met, IWG1, CPC, SP2

% disp('Getting cpcf')
% [cpcf_grid, cpcf] = rd_cpc_3010_g1([strrep(psapo_grid.pname,'PSAP','CPC'), strrep(psapo_grid.fname, 'psap_raw','3010')]);
% 
% disp('Getting cpcu')
% [cpcu_grid, cpcu] = rd_cpc_3025_g1([strrep(psapo_grid.pname,'PSAP','CPC'), strrep(psapo_grid.fname, 'psap_raw','3025')]);

sp2_ =  rd_sp2_m02(getfullname(['*SP2*.00.',dstr,'.*m02.txt'],'sp2','select mentor-edited SP2 file'));
sp2.time = sp2_.time; sp2.rBC= sp2_.SP2_rBC_conc;

%% SNIP begin
main.t = psapo_grid.time;
main.Ba_B = psapo_grid.Ba_R_Bond; 

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
    flags.not_in_flight = [];
    flags.in_cloud = (interp1(iwg_grid.time, double(iwg_grid.Flag_cloud==1), main.t, 'nearest'))==1;
    flags.plume = [];
    flags.elevated_layer = [];
    flags.PBL = [];
%     no_mask = {'plume','elevated_layer','PBL', 'in_cloud'};% keep clouds in
    no_mask = {'plume','elevated_layer','PBL'}; % mask clouds as bad
 
    if exist([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(psapo_grid.time(1),'yyyymmdd_HHMM'), '.PSAP.flags.mat'],'file')
        load_me = menu('An existing flags file was found.  Load the existing file?','Yes','No');
        if load_me ==1
        flags = load([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(psapo_grid.time(1),'yyyymmdd_HHMM'), '.PSAP.flags.mat']);
        end
    end

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

corr_STP_to_ambient = interp1(iwg_grid.time, corr_STP_to_ambient , main.t,'nearest');

Start_of_day = floor(min(main.t(good)));
Start_UTC = (main.t(good)-Start_of_day).*24*60*60;

data_in.Stop_UTC = Start_UTC + 4; info.Stop_UTC = ['seconds']; form.Stop_UTC = '%6.2f';
data_in.Ba_B = psapo_grid.Ba_B_Bond(good).*corr_STP_to_ambient(good); info.Ba_B = ['1/Mm, aerosol absorption (blue)']; form.Ba_B = '%6.3f';
data_in.Ba_G = psapo_grid.Ba_G_Bond(good).*corr_STP_to_ambient(good); info.Ba_G = ['1/Mm, aerosol absorption (green)']; form.Ba_G = '%6.3f';
data_in.Ba_R = psapo_grid.Ba_R_Bond(good).*corr_STP_to_ambient(good); info.Ba_R = ['1/Mm, aerosol absorption (red)']; form.Ba_R = '%6.3f';
rev = '0';
% save([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(psapo_grid.time(1),'yyyymmdd_HHMM'), '.PSAP.flags.mat'], '-struct','flags');
% ICTdir = 'G:\case_studies\AAF\2015_ACME-V\PSAP\ict\';
ICTdir = [psapo_grid.pname, filesep,'..',filesep,'ict',filesep];
if ~exist(ICTdir,'dir')
    mkdir(ICTdir);
end

ICARTTwriter_PSAP_ACMEV(datestr(min(main.t(good)),'yyyymmdd'),Start_UTC,data_in,info,form,rev,ICTdir);

%% SNIP End

% Next, screen Neph and output 
main.t = neph_grid.time;
main.Bs_G = 1e6.*neph_grid.Bs_G_sm; 

% panel_1.RH_post_PSAP = interp1(psap_txt.time(isfinite(psap_txt.time)), psap_txt.RH_post_PSAP(isfinite(psap_txt.time)), main.t,'nearest');
% panel_1.T_post_PSAP = interp1(psap_txt.time(isfinite(psap_txt.time)), psap_txt.T_post_PSAP(isfinite(psap_txt.time)), main.t,'nearest');
panel_1.Bs_B = 1e6.*neph_grid.Bs_B_sm_tr;
panel_1.Bs_G = 1e6.*neph_grid.Bs_G_sm_tr;
panel_1.Bs_R = 1e6.*neph_grid.Bs_R_sm_tr;

panel_2.RH = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.RH_water(isfinite(iwg_grid.time)), main.t,'nearest');
panel_2.RH_ice = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.RH_ice(isfinite(iwg_grid.time)), main.t,'nearest');
panel_2.RH_neph = neph_grid.RH;

panel_3.pitch_x_2 = 2.*interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.Pitch(isfinite(iwg_grid.time)), main.t,'nearest');
panel_3.roll_by_5 = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.Roll(isfinite(iwg_grid.time)), main.t,'nearest')./4;
panel_3.flag_AC = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.Flag_ac(isfinite(iwg_grid.time)), main.t,'nearest');

panel_4.Ae_GB = neph_grid.Ae_GB;
panel_4.Ae_RB = neph_grid.Ae_RB;
panel_4.Ae_RG = neph_grid.Ae_RG;



    ylims.panel_1 = [-1, 15];
    ylims.panel_2 = [0,100];
    ylims.panel_3 = [-15,15];
    ylims.panel_4 = [-1,4];
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
    flags.low_sig = [];
    flags.bad_ang = [];
    flags.valve_mode = [neph_grid.ValveState~=1];
    flags.hi_RH = [];
    flags.not_in_flight = [];
    flags.in_cloud = (interp1(iwg_grid.time, double(iwg_grid.Flag_cloud==1), main.t, 'nearest'))==1;
    flags.plume = [];
    flags.elevated_layer = [];
    flags.PBL = [];
%     no_mask = {'plume','elevated_layer','PBL', 'in_cloud'};% keep clouds in
    no_mask = {'plume','elevated_layer','PBL'}; % mask clouds as bad
 
    if exist([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(neph_grid.time(1),'yyyymmdd_HHMM'), '.Neph.flags.mat'],'file')
        load_me = menu('An existing flags file was found.  Load the existing file?','Yes','No');
        if load_me ==1
        flags = load([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(neph_grid.time(1),'yyyymmdd_HHMM'), '.Neph.flags.mat']);
        end
    end

[flags, screened, good, figs] = visi_screen_v10( main.t,  main.Bs_G,'time_choice',2,'flags',flags,'no_mask',no_mask,'figs',figs,...
        'panel_1', panel_1, 'panel_2',panel_2,'panel_3',panel_3,'panel_4',panel_4,'ylims',ylims,'time_choice',1, 'figs',figs);


    save([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(neph_grid.time(1),'yyyymmdd_HHMM'), '.Neph.flags.mat'], '-struct','flags');
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

corr_STP_to_ambient = interp1(iwg_grid.time, corr_STP_to_ambient , main.t,'nearest');

Start_of_day = floor(min(main.t(good)));
Start_UTC = (main.t(good)-Start_of_day).*24*60*60;

% data_in.Stop_UTC = Start_UTC + 4; info.Stop_UTC = ['seconds']; form.Stop_UTC = '%6.2f';
data_in.Bs_B = 1e6.*neph_grid.Bs_B_sm_tr(good).*neph_grid.dens_corr(goood).*corr_STP_to_ambient(good); 
info.Bs_B = ['1/Mm, aerosol total scattering (blue)']; form.Bs_B = '%6.3f';
data_in.Bs_G = 1e6.*neph_grid.Bs_G_sm_tr(good).*neph_grid.dens_corr(goood).*corr_STP_to_ambient(good); 
info.Bs_G = ['1/Mm, aerosol total scattering (green)']; form.Bs_G = '%6.3f';
data_in.Bs_R = 1e6.*neph_grid.Bs_R_sm_tr(good).*neph_grid.dens_corr(goood).*corr_STP_to_ambient(good); 
info.Bs_R = ['1/Mm, aerosol total scattering (red)']; form.Bs_R = '%6.3f';

data_in.Bb_B = 1e6.*neph_grid.Bb_B_sm_tr(good).*neph_grid.dens_corr(goood).*corr_STP_to_ambient(good); 
info.Bb_B = ['1/Mm, aerosol back hemispheric scattering (blue)']; form.Bb_B = '%6.3f';
data_in.Bb_G = 1e6.*neph_grid.Bb_G_sm_tr(good).*neph_grid.dens_corr(goood).*corr_STP_to_ambient(good); 
info.Bb_G = ['1/Mm, aerosol back hemispheric scattering (green)']; form.Bb_G = '%6.3f';
data_in.Bb_R = 1e6.*neph_grid.Bb_R_sm_tr(good).*neph_grid.dens_corr(goood).*corr_STP_to_ambient(good); 
info.Bb_R = ['1/Mm, aerosol back hemispheric scattering (red)']; form.Bb_R = '%6.3f';



rev = '0';
% save([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(psapo_grid.time(1),'yyyymmdd_HHMM'), '.PSAP.flags.mat'], '-struct','flags');
% ICTdir = 'G:\case_studies\AAF\2015_ACME-V\PSAP\ict\';
ICTdir = [psapo_grid.pname, filesep,'..',filesep,'ict',filesep];
if ~exist(ICTdir,'dir')
    mkdir(ICTdir);
end
ICARTTwriter_Neph_ACMEV(datestr(min(main.t(good)),'yyyymmdd'),Start_UTC,data_in,info,form,rev,ICTdir);


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