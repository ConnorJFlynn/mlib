%This script will call run_charts.m
%for model atmospheres
clear
system('rm screendump.out');
diary('screendump.out');
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Edit these variables to point towards your installation directory for LBLRTM, LNFL,RADSUM, and CHARTS 
run_charts_input.Directory_Mat = ...
    str2mat('/home/hermes_rd1/drf/scratch/lblrtm_v11/lblrtm/', ... %location of lblrtm executable
	    '/home/hermes_rd1/drf/lblrtm/lnfl/', ...   %location of lnfl executable
	    '/home/hermes_rd1/drf/lblrtm/radsum/',...  %location of radsum executable
	    '/home/hermes_rd1/drf/charts/',...         %location of charts executable
	    './scratch/');                             %location of temp directory
run_charts_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS','LOCAL');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM wrapper works

CO2_level = 360;
a = load('/home/hermes_rd1/drf/mod_atm/modtran5/Tropical.atm');

run_charts_input.v1 = 450; %cm^-1
run_charts_input.v2 = 1800; %cm^-1
run_charts_input.dv = 1; %cm^-1
run_charts_input.observer_angle = 180; %zenith observation
run_charts_input.pz_obs = 70; %pressure at observer location (mbar)
run_charts_input.pz_surf = 0; %pressure at end target (mbar)
run_charts_input.t_surf = a(1,3); %surface temperature (K)
run_charts_input.latitude = 32; %latitude of observation (degrees north)
run_charts_input.model = 0;     %Mid-Latitude Summer model atmosphere
run_charts_input.surf_v = [0 3500];
run_charts_input.surf_emis = [1 1];
run_charts_input.surf_refl = [0 0];

z_cutoff = 42;
full_atm = zeros(z_cutoff,35);
full_atm(:,1) = a(1:z_cutoff,1);
full_atm(:,2) = a(1:z_cutoff,2);
full_atm(:,3) = a(1:z_cutoff,3);
full_atm(:,4) = a(1:z_cutoff,5);
full_atm(:,5) = CO2_level*ones(size(a(1:z_cutoff,1)));
full_atm(:,6) = a(1:z_cutoff,6);
full_atm(:,7) = a(1:z_cutoff,7);
full_atm(:,8) = a(1:z_cutoff,8);
full_atm(:,9) = a(1:z_cutoff,9);
run_charts_input.full_atm = full_atm;
run_charts_input.species_vec = zeros(1,32);
run_charts_input.species_vec(1:32) = 1; %first 8 hitran species
ILS.ILS_use = 0;
run_charts_input.pz_levs = a(1:z_cutoff,1);
run_charts_input.ILS = ILS;
run_charts_input.Flag_Vec = [0 1 0 0 1 0 0];
run_charts_input.Flag_List = ...
    str2mat('Aerosol_Flag','Cloud_Flag','LNFL_Flag','P_or_Z', ...
	    'Rad_or_Trans','RH_Flag','Temp_Flag');

for i=1:1
  cloud_struct.levels(i) = 1+(i-1); %pz_levs(indices);   
  cloud_struct.CFC(i) = 1; %fraction (0 to 1)
  cloud_struct.CPH(i) = 2; %phase (2 for liq, 1 for ice)
  cloud_struct.CWC(i) = 0.22; %water content (g/m3)
  cloud_struct.CER(i) = 5.89; %cloud effective radius (um)
end
run_charts_input.cloud_struct = cloud_struct;

%ILS details
ILS.ILS_use = 1;
ILS.HWHM = 0.482147;
ILS.V1   = 500.46878;
ILS.V2   = 1750.19383;
ILS.JFN  = -4;
ILS.DELTAOD = 1.03702766; 
run_charts_input.ILS = ILS;

[run_lblrtm_output] = run_lblrtm(run_charts_input);
keyboard
[run_charts_output] = run_charts(run_charts_input);

toc
diary off
toc
