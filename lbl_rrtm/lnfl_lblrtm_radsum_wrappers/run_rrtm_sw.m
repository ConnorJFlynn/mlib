function [run_rrtm_sw_output] = run_rrtm_sw(run_rrtm_sw_input)
%function [run_rrtm_sw_output] = ...
%          run_rrtm_sw(run_rrtm_sw_input)
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
%This function will write an appropriate INPUT_RRTM for RRTM execution
%The hard-wired variables in this execution are designed with a
%satellite-borne instrument in mind.
%This program will create and run a batch of rrtm files for more
%efficient running
%
%%%%%%%%%%%%%%%%%%%
%%Input variables%%
%%%%%%%%%%%%%%%%%%%
%run_rrtm_sw_input.pz_obs = pressure or altitude of observer (mbar)
%run_rrtm_sw_input.pz_surf = pressure or altitude of target (surface for
%                          observer_angle = 180 and TOA for observer_angle = 0)
%run_rrtm_sw_input.t_surf = temperature at surface (K)
%run_rrtm_sw_input.surf_v    = wavenumber coordinate system for
%                             surface properties
%run_rrtm_sw_input.surf_emis = surface emissivity (function of wavenumber)
%run_rrtm_sw_input.surf_refl = surface reflectivity (function of wavenumber)
%run_rrtm_sw_input.model = model atmosphere
%                         0 = user-specified
%                         1 = tropical model
%                         2 = mid-latitude summer model
%                         3 = mid-latitude winter model
%                         4 = sub-arctic summer model
%                         5 = sub-arctic winter model
%                         6 = US standard 1976 atmosphere
%run_rrtm_sw_input.Latitude = latitude (degrees North)
%run_rrtm_sw_input.Julian_Day = day of the year
%run_rrtm_sw_input.Solar_Zenith = solar zenith angle (degrees)
%run_rrtm_sw_input.species_vec = vector of flags to set which
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
%run_rrtm_sw_input.full_atm = total atmospheric state (no aerosols)
%                          column 1 = altitudes of levels
%                          column 2 = pressures of levels
%                          column 3 = temperatures of levels
%                          columns 4 = H2O values at levels
%                                  5-35 = species_vec concentrations
%run_rrtm_sw_input.Flag_Vec = vector of flag/switch values 
%run_rrtm_sw_input.Flag_List = listing of flag/switch names
%                            Aerosol_Flag = 1 for aerosol inclusion
%                            Rad_or_Trans = 1 for radiance, 0 for transmittance
%                            RH_Flag = 1 for H2O in RH, 0 for H2O in ppmv
%                            Temp_Flag = 1 for temporary directory
%                            utilization for multiple calls to run_rrtm_sw
%run_rrtm_sw_input.Directory_Mat  = values of directories for
%                                  program execution
%run_rrtm_sw_input.Directory_List = description of directories:
%                                  RRTM
%                                  LNFL
%                                  RADSUM
%run_rrtm_sw_input.IWC_struct
% .num_clouds = number of ice-water clouds
% .CWP = cloud water path (g/m^2)
% .Reff = effective radius of particles (micron) 
% .levels  = upper and lower pressure level (mbar)
% .CLDFRAC = cloud fraction in layer
%run_rrtm_sw_input.LWC_struct
% .num_clouds = number of liquid-water clouds
% .CWP = cloud water path (g/m^2)
% .Reff = effective radius of particles (micron) 
% .levels  = upper and lower pressure level (mbar)
% .CLDFRAC = cloud fraction in layer
%
%%%%%%%%%%%%%%%%%%%%
%%Output variables%%
%%%%%%%%%%%%%%%%%%%%
%run_rrtm_sw_output
%.spectral_heating_rate = [17 x length(pz_levs)] [K/day]
%			  heating rate for various spectral bands from TOA to surface
%			  row 1 = total IR heating rate (10-3250)
%			  row 2-17: 10-350,350-500,500-630,630-700,700-820,820-980,1080-1180,
%				    1180-1390,1390-1480,1480-1800,1800-2080,2080-2250,2250-2380,
%				    2380-2600,2600-3250
%.flux_up = upward flux = [17 x length(pz_levs)] [W/m^2], same bands as spectral heating rate
%.flux_down = downward flux = [17 x length(pz_levs)] [W/m^2], same bands as spectral heating rate
%.net_flux = net flux = [17 x length(pz_levs)] [W/m^2], same bands as spectral heating rate
%		up-down
%.channels = channels as designated above for spectral heating rate
%.press_levs = pressure coordinate scheme (mbar) oriented from TOA (element 1) to surface
%.pz_levs = original orientation of pressure/altitude coordinates (km or mbar)
  
s_identify = 'run_rrtm_sw.m';

%Get real variables from input structure
t_surf         = run_rrtm_sw_input.t_surf;
surf_v         = run_rrtm_sw_input.surf_v;
surf_emis      = run_rrtm_sw_input.surf_emis;
surf_refl      = run_rrtm_sw_input.surf_refl;
model          = run_rrtm_sw_input.model;
Latitude       = run_rrtm_sw_input.Latitude;
Julian_Day     = run_rrtm_sw_input.Julian_Day;
Solar_Zenith   = run_rrtm_sw_input.Solar_Zenith;
species_vec    = run_rrtm_sw_input.species_vec;
full_atm       = run_rrtm_sw_input.full_atm;
Flag_Vec       = run_rrtm_sw_input.Flag_Vec;
Flag_List      = run_rrtm_sw_input.Flag_List;
Directory_Mat  = run_rrtm_sw_input.Directory_Mat;
Directory_List = run_rrtm_sw_input.Directory_List;
IWC_struct     = run_rrtm_sw_input.IWC_struct;
LWC_struct     = run_rrtm_sw_input.LWC_struct;

rrtm_directory = get_directory(Directory_Mat,Directory_List,'RRTM_SW');
local_directory = get_directory(Directory_Mat,Directory_List,'LOCAL');
Flag_Vec = set_flag(Flag_Vec,Flag_List,'Temp_Flag',1);


for i=1:length(run_rrtm_sw_input.executable_names(:,1))
  s = deblank(run_rrtm_sw_input.executable_names(i,:));
  s1 = deblank(run_rrtm_sw_input.Directory_List(i,:));
  if strcmpi(s1,'RRTM_SW')==1
    rrtm_command = s;
  end
end

%rrtm_command = 'rrtm_sw_linux_pgi_v2.5';

channels = [820 50000;
	    2600 3250;
	    3250 4000;
	    4000 4650;
	    4650 5150;
	    5150 6150;
	    6150 7700;
	    7700 8050;
	    8050 12850;
	    12850 16000;
	    16000 22650;
	    22650 29000;
	    29000 38000;
	    38000 50000;
	    820 2600];
if run_rrtm_sw_input.channel ~= 0 & run_rrtm_sw_input.channel ~= 98
  channels = channels(run_rrtm_sw_input.channel+1,:);
end

rand('state',sum(100*clock));
n = round(1e15*rand(1));
s_com = strcat(local_directory,'rrtm_com',int2str(n),'.sh');
fid_com = fopen(s_com,'w');
fprintf(fid_com,'#!/bin/sh\n');

%Make temporary directories  
  
%Initialize random number generator
%rand('state',sum(100*clock));
%n = round(1e15*rand(1));
n = round(sum(clock)*1e12);
directory_numbers = n;

s = strcat(['mkdir ',local_directory,'rrtm_temp',int2str(n),'/']);
fprintf(fid_com,'%s\n',s);  

%Copy RRTM files
dir_temp = strcat(local_directory,'rrtm_temp',int2str(n),'/');
s = strcat(['cp ',rrtm_directory,rrtm_command,' ',dir_temp]);
fprintf(fid_com,'%s\n',s);
fclose(fid_com);

%%%%%%%%%%%%%%%%%%%%%%%%%
%Write INPUT_RRTM file
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'RRTM',dir_temp);

write_rrtm_tape5_input.pz_obs         = run_rrtm_sw_input.pz_obs;
write_rrtm_tape5_input.pz_surf        = run_rrtm_sw_input.pz_surf;
write_rrtm_tape5_input.pz_levs        = run_rrtm_sw_input.pz_levs;
write_rrtm_tape5_input.t_surf         = t_surf;
write_rrtm_tape5_input.surf_v         = surf_v;
write_rrtm_tape5_input.surf_emis      = surf_emis;
write_rrtm_tape5_input.surf_refl      = surf_refl;
write_rrtm_tape5_input.model          = model;
write_rrtm_tape5_input.Latitude       = Latitude;
write_rrtm_tape5_input.Julian_Day     = Julian_Day;
write_rrtm_tape5_input.Solar_Zenith   = Solar_Zenith;
write_rrtm_tape5_input.species_vec    = species_vec;
write_rrtm_tape5_input.full_atm       = full_atm;
write_rrtm_tape5_input.Flag_Vec       = run_rrtm_sw_input.Flag_Vec;
write_rrtm_tape5_input.Flag_List      = run_rrtm_sw_input.Flag_List;
write_rrtm_tape5_input.Directory_List = run_rrtm_sw_input.Directory_List;  
write_rrtm_tape5_input.Directory_Mat  = Directory_Mat;
write_rrtm_tape5_input.filename       = strcat(local_directory, ...
					       'INPUT_RRTM',int2str(n));
write_rrtm_tape5_input.suffix = int2str(n);
write_rrtm_tape5_input.channel        = run_rrtm_sw_input.channel;
write_rrtm_tape5_input.IWC_struct = IWC_struct;
write_rrtm_tape5_input.LWC_struct = LWC_struct;

output = write_rrtm_tape5_sw(write_rrtm_tape5_input);

fid_com = fopen(s_com,'a');
fprintf(fid_com,'\n');
s = strcat(['mv ',output.filename, ...
	    ' ',dir_temp,'INPUT_RRTM']);
fprintf(fid_com,'%s\n',s);
if get_flag(Flag_Vec,Flag_List,'IWC_Flag') == 1 | ...
      get_flag(Flag_Vec,Flag_List,'LWC_Flag') == 1
  s = strcat(['mv ',local_directory,'INPUT_RRTM', ...
	      int2str(n),'_CLD ',dir_temp,'IN_CLD_RRTM']);
  fprintf(fid_com,'%s\n',s);
end

%System call to RRTM
s_pwd = pwd;
s = strcat(['cd ',dir_temp]);
fprintf(fid_com,'%s\n',s);
s = strcat(['nice ',rrtm_command]);
fprintf(fid_com,'%s\n',s);
s = strcat(['echo ',dir_temp]);
fprintf(fid_com,'%s\n',s);
s = strcat(['cd ',s_pwd]);
fprintf(fid_com,'%s\n',s);
fclose(fid_com);
system(['chmod 755 ',s_com]);
system(s_com);
delete(s_com);

s = strcat(local_directory,'rrtm_temp',int2str(directory_numbers));
read_rrtm_input.filename = strcat(s,'/OUTPUT_RRTM');
read_rrtm_input.channel = run_rrtm_sw_input.channel;
read_rrtm_input.full_atm = run_rrtm_sw_input.full_atm;
[read_rrtm_output] = read_rrtm_sw(read_rrtm_input);  

spectral_heating_rate = read_rrtm_output.spectral_heating_rate;
flux_up = read_rrtm_output.flux_up;
flux_down = read_rrtm_output.flux_down;
net_flux = read_rrtm_output.net_flux;


%Erase temporary directories
rand('state',sum(100*clock));
n = round(1e15*rand(1));
s_com = strcat(local_directory,'rrtm_com',int2str(n),'.sh');
fid_com = fopen(s_com,'w');
fprintf(fid_com,'#!/bin/sh\n');

try
  erase_flag = get_flag(Flag_Vec,Flag_List,'Erase_Flag');
  if erase_flag == 1  
    s = strcat(['rm -rf ',local_directory,'rrtm_temp', ...
	      int2str(directory_numbers)]);
    fprintf(fid_com,'%s\n',s);
  end
catch
    s = strcat(['rm -rf ',local_directory,'rrtm_temp', ...
	      int2str(directory_numbers)]);
    fprintf(fid_com,'%s\n',s);
end

fclose(fid_com);
system(['chmod 755 ',s_com]);
system(s_com);
delete(s_com);

run_rrtm_sw_output.spectral_heating_rate = spectral_heating_rate';
run_rrtm_sw_output.flux_up               = flux_up;
run_rrtm_sw_output.flux_down             = flux_down;
run_rrtm_sw_output.net_flux              = net_flux;
run_rrtm_sw_output.channels              = channels;

run_rrtm_sw_output.press_levs = ...
    flipud(run_rrtm_sw_input.pz_levs);
run_rrtm_sw_output.pz_levs = run_rrtm_sw_input.pz_levs;

return
