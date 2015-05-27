function [run_radsum_output] = run_radsum(run_radsum_input)
%function [run_radsum_output] = run_radsum(run_radsum_input)
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
%This function will run radsum and takes the same inputs as
%run_lblrtm.m
%
%run_radsum_input.v1 = starting wavenumber (cm^-1)
%run_radsum_input.v2 = ending wavenumber (cm^-1)
%run_radsum_input.dv = wavenumber spacing (cm^-1)
%run_radsum_input.observer_angle = viewing angle (0=zenith,180=nadir)
%run_radsum_input.pz_obs = pressure of observer (mbar)
%run_radsum_input.pz_surf = pressure of target (surface for
%                          observer_angle = 180 and TOA for observer_angle = 0)
%run_radsum_input.t_surf = temperature at surface (K)
%run_radsum_input.model = model atmosphere
%                         0 = user-specified
%                         1 = tropical model
%                         2 = mid-latitude summer model
%                         3 = mid-latitude winter model
%                         4 = sub-arctic summer model
%                         5 = sub-arctic winter model
%                         6 = US standard 1976 atmosphere
%run_radsum_input.species_vec = vector of flags to set which
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
%run_radsum_input.full_atm = total atmospheric state (no aerosols)
%                          column 1 = altitudes of levels
%                          column 2 = pressures of levels
%                          column 3 = temperatures of levels
%                          columns 4 = H2O values at levels
%                                  5-35 = species_vec concentrations
%run_radsum_input.ILS = instrument line shape
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
%run_radsum_input.Flag_Vec = vector of flag/switch values 
%run_radsum_input.Flag_List = listing of flag/switch names
%                            Aerosol_Flag = 1 for aerosol inclusion
%                            Rad_or_Trans = 1 for radiance, 0 for transmittance
%                            RH_Flag = 1 for H2O in RH, 0 for H2O in ppmv
%                            Temp_Flag = 1 for temporary directory
%                            utilization for multiple calls to run_radsum
%run_radsum_input.Directory_Mat  = values of directories for
%                                  program execution
%run_radsum_input.Directory_List = description of directories:
%                                  LBLRTM
%                                  LNFL
%                                  RADSUM
%%%%%%%%%%%%%%
%Output variable(s):
%run_radsum_output = spectral heating rate (wavenumber,Pressure)
%

s_identify = 'run_radsum.m';

%Get real variables from input structure
v1             = run_radsum_input.v1;
v2             = run_radsum_input.v2; 
dv             = run_radsum_input.dv;
observer_angle = run_radsum_input.observer_angle;
pz_obs         = run_radsum_input.pz_obs;
pz_surf        = run_radsum_input.pz_surf;
t_surf         = run_radsum_input.t_surf;
model          = run_radsum_input.model;
species_vec    = run_radsum_input.species_vec;
full_atm       = run_radsum_input.full_atm;
ILS            = run_radsum_input.ILS;
Flag_Vec       = run_radsum_input.Flag_Vec;
Flag_List      = run_radsum_input.Flag_List;
Directory_Mat  = run_radsum_input.Directory_Mat;
Directory_List = run_radsum_input.Directory_List;

lblrtm_directory = get_directory(Directory_Mat,Directory_List,'LBLRTM');
lnfl_directory   = get_directory(Directory_Mat,Directory_List,'LNFL');
radsum_directory = get_directory(Directory_Mat,Directory_List,'RADSUM');

for i=1:length(run_radsum_input.executable_names(:,1))
  s = deblank(run_radsum_input.executable_names(i,:));
  s1 = deblank(run_radsum_input.Directory_List(i,:));
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

%lnfl_command   = 'lnfl_v2.1_pgf90_pgi_linux_sgl';
%lblrtm_command = 'lblrtm_v9.3_f90_pgi_linux_dbl';
%lblrtm_command = 'lblrtm_v11.1_pgi_linux_pgf90_dbl';
%radsum_command = 'radsum_v2.4_linux_pgi_f90_dbl'; 

lnfl_flag = 0; %Flat for execution of LNFL

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
    s = strcat(['cp ',lnfl_directory,'TAPE5_LNFL ',...
		lnfl_directory,'backup_tp5/tape5_']);
    s = strcat(s,int2str(a(1)),'_',int2str(a(2)),'_',int2str(a(3)),'_');
    s = strcat(s,int2str(a(4)),'_',int2str(a(5)),'_lnfl');
    system(s);
  end
  
  clear s
  a = clock;
  s = strcat(['cp ',lblrtm_directory,'TAPE5_TS ',...
	      lblrtm_directory,'backup_tp5/tape5_']);;
  s = strcat(s,int2str(a(1)),'_',int2str(a(2)),'_',int2str(a(3)),'_');
  s = strcat(s,int2str(a(4)),'_',int2str(a(5)),'_ts');
  system(s);
else
  %Make temporary directories  
  
  %Initialize random number generator
  rand('state',sum(100*clock));
  n = round(1e9*rand(1));
  
  if lnfl_flag == 1
    s = strcat(['mkdir ',lnfl_directory,'lnfl_temp',int2str(n),'/']);
    system(s);
  end
  s = strcat(['mkdir ',lblrtm_directory,'lblrtm_temp',int2str(n),'/']);
  system(s);
  s = strcat(['mkdir ',radsum_directory,'radsum_temp',int2str(n),'/']);
  system(s);  
  
  %Copy LNFL files:
  if lnfl_flag == 1
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
  s = strcat(['cp ',lblrtm_directory,lblrtm_command,' ',dir_temp]);
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

  %Copy RADSUM files
  dir_temp = strcat(radsum_directory,'radsum_temp',int2str(n),'/');
  s = strcat(['cp ',radsum_directory,radsum_command,' ',dir_temp]);
  system(s);
  radsum_directory = dir_temp;
end

%Write TAPE5 files
write_radsum_tape5_input = run_radsum_input;
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'LNFL',lnfl_directory);
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'LBLRTM',lblrtm_directory);
Directory_Mat = ...
    set_directory(Directory_Mat,Directory_List,'RADSUM',radsum_directory);
write_radsum_tape5_input.Directory_Mat = Directory_Mat;

pz_levs = write_radsum_tape5(write_radsum_tape5_input);

%System call to LNFL
s_pwd = pwd;
s = strcat(['cd ',lnfl_directory]);
eval(s);
if lnfl_flag == 1
  system('rm TAPE2 TAPE3');
  system('cp TAPE5_LNFL TAPE5');
  s = strcat(['nice ',lnfl_command]);
  system(s);
end
system(['ln -s ',lnfl_directory,'TAPE3 ', ...
	lblrtm_directory,'TAPE3']);

%System call to LBLRTM
s = strcat(['rm ',lblrtm_directory,'TAPE31']);
system(s);
s = strcat(['rm ',lblrtm_directory,'TAPE32']);
system(s);
s = strcat(['rm ',lblrtm_directory,'TAPE33']);
system(s);
s = strcat(['rm ',lblrtm_directory,'TAPE61']);
system(s);
s = strcat(['rm ',lblrtm_directory,'TAPE62']);
system(s);
s = strcat(['rm ',lblrtm_directory,'TAPE63']);
system(s);
%s = strcat(['rm ',lblrtm_directory,'ODdeflt']);
%system(s);
s = strcat(['rm OD* ',lblrtm_directory]);
system(s);
s = strcat(['cd ',lblrtm_directory]);
eval(s);
s = strcat(['rm ',radsum_directory,'TAPE31']);
system(s);
s = strcat(['rm ',radsum_directory,'TAPE32']);
system(s);
s = strcat(['rm ',radsum_directory,'TAPE33']);
system(s);
s = strcat(['rm ',radsum_directory,'TAPE61']);
system(s);
s = strcat(['rm ',radsum_directory,'TAPE62']);
system(s);
s = strcat(['rm ',radsum_directory,'TAPE63']);
system(s);
s = strcat(['rm ',radsum_directory,'OD*']);
system(s);
system('cp TAPE5_TS TAPE5');
s = strcat(['nice ',lblrtm_command]);
system(s);
s = strcat(['mv TAPE31 TAPE32 TAPE33 TAPE61 TAPE62 TAPE63 ',radsum_directory]);
system(s);
s = strcat(['mv OD* ',radsum_directory]);
system(s);
eval(['cd ',s_pwd]);

%System call to RADSUM
s = strcat(['cd ',radsum_directory]);
eval(s);
system('cp INPUT_RADSUM_WRITE IN_RADSUM');
system(s);
s = strcat(['nice ',radsum_command]);
system(s);
eval(['cd ',s_pwd]);

s = strcat(radsum_directory,'OUTPUT_RADSUM');

read_radsum_input.filename = s;
read_radsum_input.pz_levs = pz_levs;
[read_radsum_output] = read_radsum(read_radsum_input);

%Erase temporary directories
if get_flag(Flag_Vec,Flag_List,'Temp_Flag') == 1
  if lnfl_flag == 1
    s = strcat(['rm -rf ',lnfl_directory]);
    system(s);
  end
  s = strcat(['rm -rf ',lblrtm_directory]);
  system(s);
  s = strcat(['rm -rf ',radsum_directory]);
  system(s);
end

run_radsum_output = read_radsum_output;

return
