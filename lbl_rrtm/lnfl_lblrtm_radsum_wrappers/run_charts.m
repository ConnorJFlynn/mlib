function [run_charts_output] = ...
          run_charts(run_charts_input)
%function [run_charts_output] = ...
%          run_charts(run_charts_input)
%
%This function will write an appropriate TAPE5 for LNFL and CHARTS execution
%(C) Dan Feldman 2006
%
%This function will write an appropriate TAPE5 for LNFL and CHARTS execution
%The hard-wired variables in this execution are designed with a
%satellite-borne instrument in mind.
%(C) Dan Feldman 2006
%
%%%%%%%%%%%%%%%%%%%
%%Input variables%%
%%%%%%%%%%%%%%%%%%%
%run_charts_input.v1 = starting wavenumber (cm^-1)
%run_charts_input.v2 = ending wavenumber (cm^-1)
%run_charts_input.dv = wavenumber spacing (cm^-1)
%run_charts_input.observer_angle = viewing angle (0=zenith,180=nadir)
%run_charts_input.pz_obs = pressure or altitude of observer (mbar)
%run_charts_input.pz_surf = pressure or altitude of target (surface for
%                          observer_angle = 180 and TOA for observer_angle = 0)
%run_charts_input.t_surf = temperature at surface (K)
%run_charts_input.surf_v    = wavenumber coordinate system for
%                             surface properties
%run_charts_input.surf_emis = surface emissivity (function of wavenumber)
%run_charts_input.surf_refl = surface reflectivity (function of wavenumber)
%run_charts_input.model = model atmosphere
%                         0 = user-specified
%                         1 = tropical model
%                         2 = mid-latitude summer model
%                         3 = mid-latitude winter model
%                         4 = sub-arctic summer model
%                         5 = sub-arctic winter model
%                         6 = US standard 1976 atmosphere
%run_charts_input.species_vec = vector of flags to set which
%                               gaseous species will be included (1x32)
%                               (1) H2O
%                               (2) CO2
%                               (3) O3
%                               (4) N2O
%                               (5) CO
%                               (6) CH4
%                               (7) O2
%                               (8) NO
%                               (9) SO2
%                               (10) NO2
%                               (11) NH3
%                               (12) HNO3
%                               (13) OH
%                               (14) HF
%                               (15) HCL
%                               (16) HBR
%                               (17) HI
%                               (18) CLO
%                               (19) OCS
%                               (20) H2CO
%                               (21) HOCL
%                               (22) N2
%                               (23) HCN
%                               (24) CH3CL
%                               (25) H2O2
%                               (26) C2H2
%                               (27) C2H6
%                               (28) PH3
%                               (29) COF2
%                               (30) SF6
%                               (31) H2S
%                               (32) HCOOH                               
%run_charts_input.full_atm = total atmospheric state (no aerosols)
%                          column 1 = altitudes of levels
%                          column 2 = pressures of levels
%                          column 3 = temperatures of levels
%                          columns 4 = H2O values at levels
%                                  5-35 = species_vec concentrations
%run_charts_input.ILS = instrument line shape
%                       .ILS_use = 0 for no ILS utilization
%                       .HWHM    = half-width half maximum
%                       .scan_func = scanning function
%                                0 = boxcar
%                                1 = triangular
%                                2 = gaussian
%                                3 = sinc-squared
%                                4 = sinc
%                                5 = Beer
%                                6 = Hanning
%                      for apodization, set scan_func = -1*scan_func
%run_charts_input.Flag_Vec = vector of flag/switch values 
%run_charts_input.Flag_List = listing of flag/switch names
%                            Aerosol_Flag = 1 for aerosol inclusion
%                            Rad_or_Trans = 1 for radiance, 0 for transmittance
%                            RH_Flag = 1 for H2O in RH, 0 for H2O in ppmv
%                            Temp_Flag = 1 for temporary directory
%                            utilization for multiple calls to run_charts
%run_charts_input.Directory_Mat  = values of directories for
%                                  program execution
%run_charts_input.Directory_List = description of directories:
%                                  CHARTS
%                                  LNFL
%                                  RADSUM
%run_charts_input.cloud_struct = information regarding the cloud distribution
%                                including layer height, cloud-water content, cloud
%                                accepted radius
%
%%%%%%%%%%%%%%%%%%%%
%%Output variables%%
%%%%%%%%%%%%%%%%%%%%
%run_charts_output
%.wavenumber = wavenumber center (cm^-1)
%.radiance = radiance value = W/cm^2/sr/cm^-1
%

s_identify = 'run_charts.m';

lnfl_command   = 'lnfl_v2.1_pgf90_pgi_linux_sgl';
lblrtm_command = 'lblrtm_v11.1_f90_pgi_linux_sgl';
charts_command = 'charts_lblv8.sgl';
mie_command    = 'create_MIE_no_lblatm.x';

%Get real variables from input structure
v1             = run_charts_input.v1;
v2             = run_charts_input.v2; 
observer_angle = run_charts_input.observer_angle;
pz_obs         = run_charts_input.pz_obs;
pz_surf        = run_charts_input.pz_surf;
t_surf         = run_charts_input.t_surf;
surf_v         = run_charts_input.surf_v;
surf_emis      = run_charts_input.surf_emis;
surf_refl      = run_charts_input.surf_refl;
model          = run_charts_input.model;
species_vec    = run_charts_input.species_vec;
full_atm       = run_charts_input.full_atm;
ILS            = run_charts_input.ILS;
Flag_Vec       = run_charts_input.Flag_Vec;
Flag_List      = run_charts_input.Flag_List;
Directory_Mat  = run_charts_input.Directory_Mat;
Directory_List = run_charts_input.Directory_List;

lblrtm_directory = get_directory(Directory_Mat,Directory_List,'LBLRTM');
charts_directory = get_directory(Directory_Mat,Directory_List,'CHARTS');
lnfl_directory   = get_directory(Directory_Mat,Directory_List,'LNFL');
local_directory   = get_directory(Directory_Mat,Directory_List,'LOCAL');

lnfl_flag = get_flag(Flag_Vec,Flag_List,'LNFL_Flag');

if get_flag(Flag_Vec,Flag_List,'Temp_Flag') == 0
  %erase old  tape and od files
  s = strcat(['rm ',lblrtm_directory,'TAPE*']);
  system(s);
  s = strcat(['rm ',lblrtm_directory,'ODint*']);
  system(s);
  
  if lnfl_flag == 1
    s = strcat(['rm ',lnfl_directory,'TAPE2']);
    system(s);
    s = strcat(['rm ',lnfl_directory,'TAPE3']);
    system(s);
  end

else
  %Make temporary directories  
  %Initialize random number generator
  rand('state',sum(100*clock));
  n = round(1e9*rand(1));

  s = strcat(['mkdir ',local_directory,'lblrtm_temp',int2str(n),'/']);
  system(s);
  s = strcat(['mkdir ',local_directory,'charts_temp',int2str(n),'/']);
  system(s);
  
  if lnfl_flag == 1
    %Copy LNFL files:
    s = strcat(['mkdir ',local_directory,'lnfl_temp',int2str(n),'/']);
    system(s);
    
    dir_temp = strcat(local_directory,'lnfl_temp',int2str(n),'/');
    s = strcat(['cp ',lnfl_directory,lnfl_command,' ', ...
		dir_temp]);
    system(s);
    s = strcat(['ln -s ',lnfl_directory,'TAPE1 ',dir_temp,'TAPE1']);
    system(s);
    lnfl_directory = dir_temp;
  end
  
  %Copy LBLRTM files
  dir_temp = strcat(local_directory,'lblrtm_temp',int2str(n),'/');
  s = strcat(['cp ',lblrtm_directory,lblrtm_command,' ', ...
	     dir_temp]);
  system(s);
  s = strcat(['cp ',lblrtm_directory,'ATMSFR ',dir_temp]);
  system(s);
  s = strcat(['cp ',lblrtm_directory,'EMISSIVITY ',dir_temp]);
  system(s);
  s = strcat(['cp ',lblrtm_directory,'FSCDXS ',dir_temp]);
  system(s);
  s = strcat(['cp ',lblrtm_directory,'REFLECTIVITY ',dir_temp]);
  system(s);
  s = strcat(['mkdir ',dir_temp,'AJ/']);
  system(s);
  lblrtm_directory = dir_temp;

  dir_temp = strcat(local_directory,'charts_temp',int2str(n),'/');
  s = strcat(['cp ',charts_directory,charts_command,' ',dir_temp]);
  system(s);
  s = strcat(['cp ',charts_directory,mie_command,' ',dir_temp]);
  system(s);
  s = strcat(['cp ',charts_directory,'AER* ',dir_temp]);
  system(s);
  s = strcat(['cp ',lblrtm_directory,lblrtm_command,' ',dir_temp]);
  system(s);
  charts_directory = dir_temp;
end

%Write TAPE5 files
write_charts_tape5_input = run_charts_input;
%In case of temp_flag, reassign directories and write input files
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'LNFL',lnfl_directory);
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'LBLRTM',lblrtm_directory);
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'CHARTS',charts_directory);
write_charts_tape5_input.Directory_Mat = Directory_Mat;
write_charts_tape5(write_charts_tape5_input);

%make linelist file
if lnfl_flag == 1
  %System call to LNFL
  s_pwd = pwd;
  s = strcat(['cd ',lnfl_directory]);
  eval(s);
  system('rm TAPE2 TAPE3');
  system(['nice ',lnfl_command]);
  eval(['cd ',s_pwd]);
end

%link linelist file
s_pwd = pwd;
eval(['cd ',lblrtm_directory]);
system(['ln -s ',lnfl_directory,'TAPE3 TAPE3']);
system(['cd ',s_pwd]);   
eval(['cd ',s_pwd]);

%Make surface emissivity and reflectivity files
s = strcat(lblrtm_directory,'EMISSIVITY');
fid = fopen(s,'w');
fprintf(fid,'%10.3f',surf_v(1));
fprintf(fid,'%10.3f',surf_v(length(surf_v)));
fprintf(fid,'%10.3f',surf_v(2)-surf_v(1));
fprintf(fid,'%10i',length(surf_v));
fprintf(fid,'\n');
for i=1:length(surf_v)
  fprintf(fid,'%10.7f',surf_emis(i));
  fprintf(fid,'%10.4f',surf_v(i));
  fprintf(fid,'\n');
end
fclose(fid);

s = strcat(lblrtm_directory,'REFLECTIVITY');
fid = fopen(s,'w');
fprintf(fid,'%10.3f',surf_v(1));
fprintf(fid,'%10.3f',surf_v(length(surf_v)));
fprintf(fid,'%10.3f',surf_v(2)-surf_v(1));
fprintf(fid,'%10i',length(surf_v));
fprintf(fid,'\n');
for i=1:length(surf_v)
  fprintf(fid,'%10.7f',surf_refl(i));
  fprintf(fid,'%10.4f',surf_v(i));
  fprintf(fid,'\n');
end
fclose(fid);

%System call to LBLRTM
s_pwd = pwd;
s = strcat(['cd ',lblrtm_directory]);
eval(s);
system(['nice ',lblrtm_command]);
eval(['cd ',s_pwd]);
  
%Copy ODint results to charts directory
s = strcat(['cd ',lblrtm_directory]);
eval(s);
system(['mv ODint* ',charts_directory]);
eval(['cd ',s_pwd]); 

%Execute mie scattering code
s = strcat(['cd ',charts_directory]);
eval(s);
system(mie_command);
eval(['cd ',s_pwd]);

%Execute charts cod
s = strcat(['cd ',charts_directory]);
eval(s);
system(charts_command);
eval(['cd ',s_pwd]);

%Read in CHARTS_RAD files
s = strcat(charts_directory,'CHARTS_RAD');
[a,b] = charts_reader(s,v1,v2);

%Erase temporary directories
if get_flag(Flag_Vec,Flag_List,'Temp_Flag') == 1
  if lnfl_flag == 1
    s = strcat(['rm -rf ',lnfl_directory]);
    system(s);
  end
  s = strcat(['rm -rf ',lblrtm_directory]);
  system(s);
  s = strcat(['rm -rf ',charts_directory]);
  system(s);
end

run_charts_output.wavenumber = b;
run_charts_output.radiance   = a;

return
