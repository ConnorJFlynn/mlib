function QA_ACMEV_NEPH
% Want to generate Neph data screened for valve_state and output to ICT
disp('Getting neph directory')
% Loop over all neph files
neph_dir = uigetdir(['E:\case_studies\AAF\2015_ACME-V\Neph\']);
neph_files = dir([neph_dir,filesep,'*nephD.txt']);

for nf = 1:length(neph_files)
disp(['Getting ',neph_files(nf).name])   

[neph_grid] = rd_nephD_g1([neph_dir,filesep, neph_files(nf).name]);
flight = strtok(neph_files(nf).name,'.')
corr_to_STP = (1013.5./neph_grid.P).*(neph_grid.T_vol./273.15); % STP 1013.5 Pa, 0 C
% Multiply neph scattering by this density correction factor to get values at STP.
% Compute angstrom exponent from non-truncation corrected scattering
% Adjust non-truncation corrected scattering to PSAP wavelengths of 470, 522, and 660 nm
% using initial AE in the neph_grid file (which were computed before
% truncation correction)

disp('Getting IWG')
date_str = datestr(neph_grid.time(1),'yyyymmdd');
% aaf.iwg1001s.g1.acmev.20150816a.a2.txt
iwg_file = [strrep(neph_dir,'Neph','IWG1'),filesep,'aaf.iwg1001s.g1.acmev.',flight,'.a2.txt'];
if exist(iwg_file,'file')
   no_iwg = false;
   [iwg_grid, iwg] = rd_iwg1_g1(iwg_file);
   corr_STP_to_ambient = (iwg_grid.Static_Press ./1013.5) .* (273.15./(iwg_grid.Ambient_Temp+273.15));
   figure(98);scatter3(iwg_grid.Lon,iwg_grid.Lat, iwg_grid.GPS_MSL_Alt,4,serial2hs(iwg_grid.time)) ;
xlabel('Lon [deg]'); ylabel('Lat [deg]'); zlabel('GPS MSL [m]'); cb = colorbar; set(get(cb,'title'),'string','Time UTC')

else
   no_iwg = true;
   iwg_grid.time = neph_grid.time;
   corr_STP_to_ambient = NaN(size(corr_to_STP);
   close(98)
end

% [iwg_grid, iwg] = rd_iwg1_g1([strrep(psapo_grid.pname,'PSAP','IWG1'), strrep(psapo_grid.fname, 'psap_raw','iwg1.a1.ver2')]);

% figure; plot(iwg_grid.time, [iwg_grid.GPS_MSL_Alt*100/2.54/12,iwg_grid.Press_Alt,iwg_grid.Radar_Alt],'x'); legend('GPS','Press','Radar')
%Met, IWG1, CPC, SP2

% Next, screen Neph and output 
clear main data_in info
main.t = neph_grid.time;
main.Bs_G = 1e6.*neph_grid.Bs_G_sm; 

% panel_1.RH_post_PSAP = interp1(psap_txt.time(isfinite(psap_txt.time)), psap_txt.RH_post_PSAP(isfinite(psap_txt.time)), main.t,'nearest');
% panel_1.T_post_PSAP = interp1(psap_txt.time(isfinite(psap_txt.time)), psap_txt.T_post_PSAP(isfinite(psap_txt.time)), main.t,'nearest');
panel_1.Bs_B = 1e6.*neph_grid.Bs_B_sm_tr;
panel_1.Bs_G = 1e6.*neph_grid.Bs_G_sm_tr;
panel_1.Bs_R = 1e6.*neph_grid.Bs_R_sm_tr;

% panel_2.RH = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.RH_water(isfinite(iwg_grid.time)), main.t,'nearest');
% panel_2.RH_ice = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.RH_ice(isfinite(iwg_grid.time)), main.t,'nearest');
% panel_2.RH_neph = neph_grid.RH;

% panel_3.pitch_x_2 = 2.*interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.Pitch(isfinite(iwg_grid.time)), main.t,'nearest');
% panel_3.roll_by_5 = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.Roll(isfinite(iwg_grid.time)), main.t,'nearest')./4;
% panel_3.flag_AC = interp1(iwg_grid.time(isfinite(iwg_grid.time)), iwg_grid.Flag_ac(isfinite(iwg_grid.time)), main.t,'nearest');

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
r    flags.in_cloud = (interp1(iwg_grid.time, double(iwg_grid.Flag_cloud==1), main.t, 'nearest'))==1;
    flags.plume = [];
    flags.elevated_layer = [];
    flags.PBL = [];
%     no_mask = {'plume','elevated_layer','PBL', 'in_cloud'};% keep clouds in
    no_mask = {'plume','elevated_layer','PBL'}; % mask clouds as bad
 

    
%     if exist([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(neph_grid.time(1),'yyyymmdd_HHMM'), '.Neph.flags.mat'],'file')
%         load_me = menu('An existing flags file was found.  Load the existing file?','Yes','No');
%         if load_me ==1
%         flags = load([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(neph_grid.time(1),'yyyymmdd_HHMM'), '.Neph.flags.mat']);
%         end
%     end

% [flags, screened, good, figs] = visi_screen_v10( main.t,  main.Bs_G,'time_choice',2,'flags',flags,'no_mask',no_mask,'figs',figs,...
%         'panel_1', panel_1, 'panel_2',panel_2,'panel_3',panel_3,'panel_4',panel_4,'ylims',ylims,'time_choice',1, 'figs',figs);
% 
% 
%     save([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(neph_grid.time(1),'yyyymmdd_HHMM'), '.Neph.flags.mat'], '-struct','flags');
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
if ~no_iwg
corr_STP_to_ambient = (iwg_grid.Static_Press ./1013.5) .* (273.15./(iwg_grid.Ambient_Temp+273.15));
end
corr_STP_to_ambient = interp1(iwg_grid.time, corr_STP_to_ambient , main.t,'nearest');

    good = ~flags.valve_mode;
Start_of_day = floor(min(main.t(good)));
Start_UTC = (main.t(good)-Start_of_day).*24*60*60;

% data_in.Stop_UTC = Start_UTC + 4; info.Stop_UTC = ['seconds']; form.Stop_UTC = '%6.2f';
data_in.Bs_B = 1e6.*neph_grid.Bs_B_sm_tr(good).*neph_grid.dens_corr(good); 
info.Bs_B = ['1/Mm, aerosol total scattering (blue)']; form.Bs_B = '%6.3f';
data_in.Bs_G = 1e6.*neph_grid.Bs_G_sm_tr(good).*neph_grid.dens_corr(good); 
info.Bs_G = ['1/Mm, aerosol total scattering (green)']; form.Bs_G = '%6.3f';
data_in.Bs_R = 1e6.*neph_grid.Bs_R_sm_tr(good).*neph_grid.dens_corr(good); 
info.Bs_R = ['1/Mm, aerosol total scattering (red)']; form.Bs_R = '%6.3f';

data_in.Bb_B = 1e6.*neph_grid.Bb_B_sm_tr(good).*neph_grid.dens_corr(good); 
info.Bb_B = ['1/Mm, aerosol back hemispheric scattering (blue)']; form.Bb_B = '%6.3f';
data_in.Bb_G = 1e6.*neph_grid.Bb_G_sm_tr(good).*neph_grid.dens_corr(good); 
info.Bb_G = ['1/Mm, aerosol back hemispheric scattering (green)']; form.Bb_G = '%6.3f';
data_in.Bb_R = 1e6.*neph_grid.Bb_R_sm_tr(good).*neph_grid.dens_corr(good); 
info.Bb_R = ['1/Mm, aerosol back hemispheric scattering (red)']; form.Bb_R = '%6.3f';
data_in.dens_corr_STP_to_ambient = corr_STP_to_ambient(good); 
info.dens_corr_STP_to_ambient = ['none, correction factor to convert reported values at STP to ambient conditions outside aircraft']; 
form.dens_corr_STP_to_ambient = '%6.3f';


rev = '0';
% save([psapo_grid.pname, filesep,'..',filesep,'flags',filesep,datestr(psapo_grid.time(1),'yyyymmdd_HHMM'), '.PSAP.flags.mat'], '-struct','flags');
% ICTdir = 'G:\case_studies\AAF\2015_ACME-V\PSAP\ict\';
ICTdir = [neph_dir, filesep,'..',filesep,'ict',filesep];
if ~exist(ICTdir,'dir')
    mkdir(ICTdir);
end
ICARTTwriter_Neph_ACMEV(datestr(min(main.t(good)),'yyyymmdd'),Start_UTC,data_in,info,form,rev,ICTdir);


end
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