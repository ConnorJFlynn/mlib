function [run_lblrtm_output] = ...
          run_lblrtm(run_lblrtm_input)
%function [run_lblrtm_output] = ...
%          run_lblrtm(run_lblrtm_input)
%
%(C) Dan Feldman 2009, all rights retained
%    Disclaimer of Warranty. DANIEL FELDMAN PROVIDES THE SOFTWARE AND THE SERVICES "AS IS" WITHOUT WARRANTY 
%    OF ANY KIND EITHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
%    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. ALL RISK OF QUALITY AND PERFORMANCE OF THE 
%    SOFTWARE OR SERVICES REMAINS WITH YOU. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF THIS AGREEMENT.
%
%    Limitation of Remedies. IN NO EVENT WILL DANIEL FELDMAN, DISTRIBUTORS, DIRECTORS OR AGENTS BE LIABLE 
%    FOR ANY INDIRECT DAMAGES OR OTHER RELIEF ARISING OUT OF YOUR USE OR INABILITY TO USE THE SOFTWARE OR 
%    SERVICES INCLUDING, BY WAY OF ILLUSTRATION AND NOT LIMITATION, LOST PROFITS, LOST BUSINESS OR LOST  
%    OPPORTUNITY, OR ANY INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL OR EXEMPLARY DAMAGES,  
%    INCLUDING LEGAL FEES, ARISING OUT OF SUCH USE OR INABILITY TO USE THE PROGRAM, EVEN IF DANIEL FELDMAN 
%    OR AN AUTHORIZED LICENSOR DEALER, DISTRIBUTOR OR SUPPLIER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, 
%    OR FOR ANY CLAIM BY ANY OTHER PARTY. BECAUSE SOME STATES OR JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR THE  
%    LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, IN SUCH STATES OR JURISDICTIONS, 
%    DANIEL FELDMAN'S LIABILITY SHALL BE LIMITED TO THE EXTENT PERMITTED BY LAW.
%
%    Daniel Feldman's Liability. Daniel Feldman assumes no liability hereunder for, 
%    and shall have no obligation to defend you or to pay costs, damages or attorney's fees for, 
%    any claim based upon: (i) any method or process in which the Software or Services may be used by you; 
%    (ii) any results of using the Software or Services; 
%    (iii) any use of other than a current unaltered release of the Software; or 
%    (iv) the combination, operation or use of any of the Software or Services furnished hereunder 
%    with other programs or data if such infringement would have been avoided by the combination, 
%    operation, or use of the Software or Services with other programs or data. 
%
%    If you do not agree to these terms, discontinue use of this software immediately.
%    Daniel Feldman is not affiliated with AER, Inc.
%
%
%This function will write an appropriate TAPE5 for LNFL and LBLRTM execution
%The hard-wired variables in this execution are designed with a
%satellite-borne instrument in mind.
%
%%%%%%%%%%%%%%%%%%%
%%Input variables%%
%%%%%%%%%%%%%%%%%%%
%run_lblrtm_input.v1 = starting wavenumber (cm^-1)
%run_lblrtm_input.v2 = ending wavenumber (cm^-1)
%run_lblrtm_input.observer_angle = viewing angle (0=zenith,180=nadir)
%run_lblrtm_input.pz_obs = pressure or altitude of observer (mbar)
%run_lblrtm_input.pz_surf = pressure or altitude of target (surface for
%                          observer_angle = 180 and TOA for observer_angle = 0)
%run_lblrtm_input.t_surf = temperature at surface (K)
%run_lblrtm_input.surf_v    = wavenumber coordinate system for
%                             surface properties
%run_lblrtm_input.surf_emis = surface emissivity (function of wavenumber)
%run_lblrtm_input.surf_refl = surface reflectivity (function of wavenumber)
%run_lblrtm_input.model = model atmosphere
%                         0 = user-specified
%                         1 = tropical model
%                         2 = mid-latitude summer model
%                         3 = mid-latitude winter model
%                         4 = sub-arctic summer model
%                         5 = sub-arctic winter model
%                         6 = US standard 1976 atmosphere
%run_lblrtm_input.species_vec = vector of flags to set which
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
%run_lblrtm_input.full_atm = total atmospheric state (no aerosols)
%                          column 1 = altitudes of levels
%                          column 2 = pressures of levels
%                          column 3 = temperatures of levels
%                          columns 4 = H2O values at levels
%                                  5-35 = species_vec concentrations
%run_lblrtm_input.ILS = instrument line shape
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
%run_lblrtm_input.Flag_Vec = vector of flag/switch values 
%run_lblrtm_input.Flag_List = listing of flag/switch names
%                            Aerosol_Flag = 1 for aerosol inclusion
%                            Rad_or_Trans = 1 for radiance, 0 for transmittance
%                            RH_Flag = 1 for H2O in RH, 0 for H2O in ppmv
%                            Temp_Flag = 1 for temporary directory
%                            utilization for multiple calls to run_lblrtm
%run_lblrtm_input.Directory_Mat  = values of directories for
%                                  program execution
%run_lblrtm_input.Directory_List = description of directories:
%                                  LBLRTM
%                                  LNFL
%                                  RADSUM
%
%%%%%%%%%%%%%%%%%%%%
%%Output variables%%
%%%%%%%%%%%%%%%%%%%%
%run_lblrtm_output
%.wavenumber = wavenumber center (cm^-1)
%.radiance = radiance value = W/cm^2/sr/cm^-1
%

s_identify = 'run_lblrtm.m';

for i=1:length(run_lblrtm_input.executable_names(:,1))
  s = deblank(run_lblrtm_input.executable_names(i,:));
  s1 = deblank(run_lblrtm_input.Directory_List(i,:));
  if strcmpi(s1,'LNFL')==1
    lnfl_command = s;
  end
  if strcmpi(s1,'LBLRTM')==1
    lblrtm_command = s;
  end
  if strcmpi(s1,'RADSUM')==1
    radsum_command = s;
  end
  if strcmpi(s1,'CHARTS')==1
    charts_command = s;
  end
end

%Get real variables from input structure
v1             = run_lblrtm_input.v1;
v2             = run_lblrtm_input.v2; 
observer_angle = run_lblrtm_input.observer_angle;
pz_obs         = run_lblrtm_input.pz_obs;
pz_surf        = run_lblrtm_input.pz_surf;
t_surf         = run_lblrtm_input.t_surf;
surf_v         = run_lblrtm_input.surf_v;
surf_emis      = run_lblrtm_input.surf_emis;
surf_refl      = run_lblrtm_input.surf_refl;
model          = run_lblrtm_input.model;
species_vec    = run_lblrtm_input.species_vec;
full_atm       = run_lblrtm_input.full_atm;
ILS            = run_lblrtm_input.ILS;
Flag_Vec       = run_lblrtm_input.Flag_Vec;
Flag_List      = run_lblrtm_input.Flag_List;
Directory_Mat  = run_lblrtm_input.Directory_Mat;
Directory_List = run_lblrtm_input.Directory_List;

lblrtm_directory = get_directory(Directory_Mat,Directory_List,'LBLRTM');
lnfl_directory   = get_directory(Directory_Mat,Directory_List,'LNFL');

lnfl_flag = get_flag(Flag_Vec,Flag_List,'LNFL_Flag');

if get_flag(Flag_Vec,Flag_List,'Temp_Flag') == 0
  %erase old text-dump files
  s = strcat(['rm ',lblrtm_directory,'TAPE27']);
  system(s);
  s = strcat(['rm ',lblrtm_directory,'TAPE28']);
  system(s);
  
  %Copy TAPE5_LNFL and TAPE5_TS
  if lnfl_flag == 1
    clear s
    a = clock;
    %s = strcat(['cp ',lnfl_directory,'TAPE5_LNFL ',...
	%	lnfl_directory,'backup_tp5/tape5_']);
    %s = strcat(s,int2str(a(1)),'_',int2str(a(2)),'_',int2str(a(3)),'_');
    %s = strcat(s,int2str(a(4)),'_',int2str(a(5)),'_lnfl');
    %system(s);
  end
  clear s
  a = clock;
  %s = strcat(['cp ',lblrtm_directory,'TAPE5_TS ',...
	%      lblrtm_directory,'backup_tp5/tape5_']);;
  %s = strcat(s,int2str(a(1)),'_',int2str(a(2)),'_',int2str(a(3)),'_');
  %s = strcat(s,int2str(a(4)),'_',int2str(a(5)),'_ts');
  %system(s);
else
  %Make temporary directories  
  %Initialize random number generator
  rand('state',sum(100*clock));
  n = round(1e9*rand(1));

  s = strcat(['mkdir ',lblrtm_directory,'lblrtm_temp',int2str(n),'/']);
  system(s);
  
  if lnfl_flag == 1
    %Copy LNFL files:
    dir_temp = strcat(lnfl_directory,'lnfl_temp',int2str(n),'/');
    s = strcat(['cp ',lnfl_directory,lnfl_command,' ', ...
		dir_temp]);
    system(s);
    s = strcat(['cp ',lnfl_directory,'TAPE5_backup ',dir_temp]);
    system(s);
    s = strcat(['ln -s ',lnfl_directory,'TAPE1 ',dir_temp,'TAPE1']);
    system(s);
    lnfl_directory = dir_temp;
  end
  
  %Copy LBLRTM files
  dir_temp = strcat(lblrtm_directory,'lblrtm_temp',int2str(n),'/');
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
  s = strcat(['cp ',lblrtm_directory,'TAPE5_TS ',dir_temp]);
  system(s);
  s = strcat(['mkdir ',dir_temp,'AJ/']);
  system(s);
  lblrtm_directory = dir_temp;
  
  if lnfl_flag == 1
    s = strcat(['mkdir ',lnfl_directory,'lnfl_temp',int2str(n),'/']);
    system(s);
  else
    system(['rm ',lblrtm_directory,'TAPE3']);
    system(['ln -s ',lnfl_directory,'TAPE3 ',lblrtm_directory,'TAPE3']);
  end
end

%Write TAPE5 files
write_lblrtm_tape5_input = run_lblrtm_input;
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'LNFL',lnfl_directory);
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'LBLRTM',lblrtm_directory);
write_lblrtm_tape5_input.Directory_Mat = Directory_Mat;
write_lblrtm_tape5(write_lblrtm_tape5_input);

%Make surface emissivity and reflectivity files
%Copy original files EMISSIVITY and REFLECTIVITY
%if Octave_Flag == 1
%  s = strcat('cp ',lblrtm_directory,'EMISSIVITY ',lblrtm_directory,'EMISSIVITY_backup');
%else
  s = strcat(['mv ',lblrtm_directory,'EMISSIVITY ',lblrtm_directory,'EMISSIVITY_backup']);  
%end
system(s);

%if Octave_Flag == 1
%  s = strcat('cp ',lblrtm_directory,'REFLECTIVITY ',lblrtm_directory,'REFLECTIVITY_backup');
%else
  s = strcat(['mv ',lblrtm_directory,'REFLECTIVITY ',lblrtm_directory,'REFLECTIVITY_backup']);  
%end
system(s);

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

if lnfl_flag == 1
  %System call to LNFL
  s_pwd = pwd;
  s = strcat(['cd ',lnfl_directory]);
  eval(s);
  system('rm TAPE2 TAPE3');
  system('cp TAPE5_LNFL TAPE5');
  system(['nice ',lnfl_command]);
  system(['cp TAPE3 ',lblrtm_directory]);
end
  
%System call to LBLRTM
s_pwd = pwd;
s = strcat(['cd ',lblrtm_directory]);
eval(s);
system('cp TAPE5_TS TAPE5');
system(['nice ',lblrtm_command]);
eval(['cd ',s_pwd]);
  
%Modify TAPE27 and TAPE28
s = strcat(lblrtm_directory,'TAPE27');
fid1 = fopen(s,'r');
header_size = 1;
loop = 1;
if get_flag(Flag_Vec,Flag_List,'Rad_or_Trans') == 1
  s = '0     WAVENUMBER          RADIANCE  ';
else
  s = '0     WAVENUMBER        TRANSMISSION';
end
while loop
  s_comp = fgetl(fid1);
  header_size = header_size + 1;
  if strcmp(s,s_comp) | feof(fid1)
    loop = 0;
  end
end
fseek(fid1,0,'bof');
fclose(fid1);

truncate_header_input.input_file  = strcat(lblrtm_directory,'TAPE27');
truncate_header_input.output_file = strcat(lblrtm_directory,'TAPE27_load');
truncate_header_input.header_size = header_size;
truncate_header(truncate_header_input);

a = load([lblrtm_directory,'TAPE27_load']);
wavenumber = a(:,1);
radiance = a(:,2);

run_lblrtm_output.wavenumber = wavenumber;
run_lblrtm_output.radiance   = radiance;

%Erase temporary directories
if get_flag(Flag_Vec,Flag_List,'Temp_Flag') == 1
  if lnfl_flag == 1
    s = strcat(['rm -rf ',lnfl_directory]);
    system(s);
  end
  s = strcat(['rm -rf ',lblrtm_directory]);
  system(s);
end

%Copy original files EMISSIVITY and REFLECTIVITY
%if Octave_Flag == 1
%  s = strcat('cp ',lblrtm_directory,'EMISSIVITY_backup ',lblrtm_directory,'EMISSIVITY');
%else
  s = strcat(['cp ',lblrtm_directory,'EMISSIVITY_backup ',lblrtm_directory,'EMISSIVITY']);  
%end
system(s);

%if Octave_Flag == 1
%  s = strcat('cp ',lblrtm_directory,'REFLECTIVITY_backup ',lblrtm_directory,'REFLECTIVITY');
%else
  s = strcat(['cp ',lblrtm_directory,'REFLECTIVITY_backup ',lblrtm_directory,'REFLECTIVITY']);  
%end
system(s);

return
