function dummy = write_rrtm_tape5_lw(write_rrtm_tape5_lw_input)
%function dummy = write_rrtm_tape5_lw(write_rrtm_tape5_input)
%
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
%write_rrtm_tape5_lw_input.v1 = starting wavenumber (cm^-1)
%write_rrtm_tape5_lw_input.v2 = ending wavenumber (cm^-1)
%write_rrtm_tape5_lw_input.dv = wavenumber spacing (cm^-1)
%                          observer_angle = 180 and TOA for observer_angle = 0)
%write_rrtm_tape5_lw_input.pz_obs  = pressure or altitude at observer
%write_rrtm_tape5_lw_input.pz_surf = pressure or altitude at target
%write_rrtm_tape5_lw_input.t_surf = temperature at surface (K)
%write_rrtm_tape5_lw_input.surf_v    = wavenumber coordinate system for
%                             surface properties
%write_rrtm_tape5_lw_input.surf_emis = surface emissivity (function of wavenumber)
%write_rrtm_tape5_lw_input.surf_refl = surface reflectivity (function of wavenumber)
%write_rrtm_tape5_lw_input.Latitude = latitude (degrees North)
%write_rrtm_tape5_lw_input.Julian_Day = day of the year
%write_rrtm_tape5_lw_input.Solar_Zenith = solar zenith angle (degrees)
%write_rrtm_tape5_lw_input.model = model atmosphere
%                         0 = user-specified
%                         1 = tropical model
%                         2 = mid-latitude summer model
%                         3 = mid-latitude winter model
%                         4 = sub-arctic summer model
%                         5 = sub-arctic winter model
%                         6 = US standard 1976 atmosphere
%write_rrtm_tape5_lw_input.species_vec = vector of flags to set which
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
%write_rrtm_tape5_lw_input.full_atm = total atmospheric state (no aerosols)
%                          column 1 = altitudes of levels
%                          column 2 = pressures of levels
%                          column 3 = temperatures of levels
%                          columns 4 = H2O values at levels
%                                  5-35 = species_vec concentrations
%write_rrtm_tape5_lw_input.Flag_Vec = vector of flag/switch values 
%write_rrtm_tape5_lw_input.Flag_List = listing of flag/switch names
%                            Aerosol_Flag = 1 for aerosol inclusion
%                            Rad_or_Trans = 1 for radiance, 0 for transmittance
%                            RH_Flag = 1 for H2O in RH, 0 for H2O in ppmv
%                            Temp_Flag = 1 for temporary directory
%                            utilization for multiple calls to write_rrtm_tape5_lw
%write_rrtm_tape5_lw_input.Directory_Mat  = values of directories for
%                                  program execution
%write_rrtm_tape5_lw_input.Directory_List = description of directories:
%                                  LBLRTM
%                                  LNFL
%                                  RADSUM
%write_rrtm_tape5_lw_input.IWC_struct
% .num_clouds = number of ice-water clouds
% .CWP = cloud water path (g/m^2)
% .Reff = effective radius of particles (micron) 
% .levels  = upper and lower pressure level (mbar)
% .CLDFRAC = cloud fraction in layer
%write_rrtm_tape5_lw_input.LWC_struct
% .num_clouds = number of liquid-water clouds
% .CWP = cloud water path (g/m^2)
% .Reff = effective radius of particles (micron) 
% .levels  = upper and lower pressure level (mbar)
% .CLDFRAC = cloud fraction in layer
%
%%%%%%%%%%%%%%
%Output variable(s):
%write_rrtm_tape5_lw_output.flux_up               = flux_up/dv;
%write_rrtm_tape5_lw_output.flux_down             = flux_down/dv;
%write_rrtm_tape5_lw_output.net_flux              = net_flux/dv;
%write_rrtm_tape5_lw_output.wavenumber            = wavenumber;
%write_rrtm_tape5_lw_output.press_levs            = p_levs;
%write_rrtm_tape5_lw_output = spectral heating rate (wavenumber,Pressure)
%

s_identify = 'write_rrtm_tape5_lw.m';

pz_obs         = write_rrtm_tape5_lw_input.pz_obs;
pz_surf        = write_rrtm_tape5_lw_input.pz_surf;
t_surf         = write_rrtm_tape5_lw_input.t_surf;
surf_v         = write_rrtm_tape5_lw_input.surf_v;
surf_emis      = write_rrtm_tape5_lw_input.surf_emis;
surf_refl      = write_rrtm_tape5_lw_input.surf_refl;
pz_levs        = write_rrtm_tape5_lw_input.pz_levs;
pz_levs(1) = pz_levs(1)+0.001;
model          = write_rrtm_tape5_lw_input.model;
Latitude       = write_rrtm_tape5_lw_input.Latitude;
Julian_Day     = write_rrtm_tape5_lw_input.Julian_Day;
Solar_Zenith   = write_rrtm_tape5_lw_input.Solar_Zenith;
species_vec    = write_rrtm_tape5_lw_input.species_vec;
full_atm       = write_rrtm_tape5_lw_input.full_atm;
Flag_Vec       = write_rrtm_tape5_lw_input.Flag_Vec;
Flag_List      = write_rrtm_tape5_lw_input.Flag_List;
Directory_Mat  = write_rrtm_tape5_lw_input.Directory_Mat;
Directory_List = write_rrtm_tape5_lw_input.Directory_List;
filename       = write_rrtm_tape5_lw_input.filename;
IWC_struct     = write_rrtm_tape5_lw_input.IWC_struct;
LWC_struct     = write_rrtm_tape5_lw_input.LWC_struct;
%rrtm_directory = get_directory(Directory_Mat,Directory_List,'RRTM');

channels = [10 350;
	    350 500;
	    500 630;
	    630 700;
	    700 820;
	    820 980;
	    980 1080;
	    1080 1180;
	    1180 1390;
	    1390 1480;
	    1480 1800;
	    1800 2080;
	    2080 2250;
	    2250 2380;
	    2380 2600;
	    2600 3250];
mean_channels = mean(channels');

altitude    = full_atm(:,1);
pressure    = full_atm(:,2);
temperature = full_atm(:,3);

%Record 1.1
CXID = strcat(['$ RRTM input created by Dan Feldman on ',date]);

%Record 1.2
IATM = 1;
IXSECT = 0;
NUMANGS = 4;
try
  if write_rrtm_tape5_lw_input.channel == 0
    IOUT = 0;
  else
    IOUT = 99;
  end
catch
  IOUT = 99;
end
if get_flag(Flag_Vec,Flag_List,'IWC_Flag') == 1 | ...
     get_flag(Flag_Vec,Flag_List,'LWC_Flag') == 1  
  ICLD = 2;
else
  ICLD = 0;
end

%Record 1.4
TBOUND   = t_surf;
IEMIS    = 2;
IREFLECT = 0;
%SEMISS   = ones(1,16);
SEMISS = extrap1(surf_v,surf_emis,mean_channels,'linear');
for i=1:length(SEMISS)
  if isnan(SEMISS(i))
    SEMISS(i) = 1;
  end
end

%Record 3.1
MODEL = model;
if get_flag(Flag_Vec,Flag_List,'P_or_Z') == 1
  IBMAX = -1*length(pz_levs);
else
  IBMAX = length(pz_levs);
end
NOPRNT  = 0;
NMOL    = 32;
IPUNCH  = 1;
MUNITS  = 1;
RE      = 0;
CO2MX   = 0;
REF_LAT = Latitude;

%Record 3.2

%Card 3.3b
ZNBD = pz_levs;

if get_flag(Flag_Vec,Flag_List,'P_or_Z') == 1
  HBOUND = max([pz_surf pz_obs]);
  HTOA   = min([pz_surf pz_obs]);
else
  HBOUND = min([pz_surf pz_obs]);
  HTOA   = max([pz_surf pz_obs]);
end
  
if IBMAX == 0
  %Record 3.3A
  AVTRAT = 0;
  TDIFF1 = 0;
  TDIFF2 = 0;
  ALT1   = 0;
  ALTD2  = 0;
else
  %Record 3.3B
  %ZNBD = pz_levs;
end

if MODEL == 0
  %Record 3.4
  if IBMAX > 0
    IMMAX = length(full_atm(:,1));
  else
    IMMAX = -1*length(full_atm(:,1));
  end
  HMOD  = ' user-defined';

  %Record 3.5
  ZM = altitude;
  PM = pressure;
  TM = temperature;
  JCHARP = 'A';
  JCHART = 'A';
  JLONG = ' ';
  JCHAR = [];
  for i=1:NMOL
    if i==1 & species_vec(1)==1 & get_flag(Flag_Vec,Flag_List,'RH_Flag')==1
      JCHAR = strcat(JCHAR,'H');
    else
      if species_vec(i) == 1
	JCHAR = strcat(JCHAR,'A');
      else
	JCHAR = strcat(JCHAR,'2');
      end
    end
  end
end

if IATM == 1 & IXSECT == 1
  %Record 3.7 and 3.8
  %!!! undeveloped 
end

%%%%%%%%%%%%%%%%%%%%%
%Write INPUT_RRTM
%%%%%%%%%%%%%%%%%%%%

%write TAPE5_TS
s_fid = strcat(filename,'_',int2str(ICLD));
fid = fopen(s_fid,'w');

%Record 1.1
fprintf(fid,'%s\n',CXID);

%Record 1.2
for i=1:49
  fprintf(fid,' '); %49X
end
fprintf(fid,'%1i',IATM);
for i=1:19
  fprintf(fid,' '); %19X
end
fprintf(fid,'%1i',IXSECT);
for i=1:13
  fprintf(fid,' '); %13X
end
fprintf(fid,'%2i',NUMANGS);
fprintf(fid,'  '); %2X
fprintf(fid,'%3i',IOUT);
fprintf(fid,'    '); %4X
fprintf(fid,'%1i\n',ICLD);

%Record 1.4
fprintf(fid,'%10.3e',TBOUND);
fprintf(fid,' '); %1X
fprintf(fid,'%1i',IEMIS);
fprintf(fid,'  '); %2X
fprintf(fid,'%1i',IREFLECT);
for i=1:16
  fprintf(fid,'%5.3f',SEMISS(i));
end
fprintf(fid,'\n');

%Record 3.1
fprintf(fid,'%5i',MODEL);
fprintf(fid,'     '); %5X
fprintf(fid,'%5i',IBMAX);
fprintf(fid,'     '); %5X
fprintf(fid,'%5i',NOPRNT);
fprintf(fid,'%5i',NMOL);
fprintf(fid,'%5i',IPUNCH);
fprintf(fid,'   '); %3X
fprintf(fid,'%2i',MUNITS);
fprintf(fid,'%10.3f',RE);
for i=1:20
  fprintf(fid,' '); %20X
end
fprintf(fid,'%10.3f',CO2MX);
fprintf(fid,'%10.3f\n',REF_LAT); %!!!

%Record 3.2
fprintf(fid,'%10.3f',HBOUND);
fprintf(fid,'%10.3f\n',HTOA);

if IBMAX == 0
  %Record 3.3A
  fprintf(fid,'%10.3f',AVTRAT);
  fprintf(fid,'%10.3f',TDIFF1);
  fprintf(fid,'%10.3f',TDIFF2);
  fprintf(fid,'%10.3f',ALTD1);
  fprintf(fid,'%10.3f\n',ALTD2);
else
  %Record 3.3B
  for i=1:length(ZNBD)
    fprintf(fid,'%10.3f',ZNBD(i));
    if round(i/8) == i/8 & i<length(ZNBD)
      fprintf(fid,'\n');
    end
  end
  fprintf(fid,'\n');
end

IMMAX = IBMAX;
if MODEL == 0
  %Record 3.4
  fprintf(fid,'%5.0f',IMMAX);
  fprintf(fid,'%s',HMOD);
  fprintf(fid,'\n');
  
  %Card 3.5 and Card 3.6
  for i=1:length(altitude)
    if IBMAX>0
      fprintf(fid,'%10.4f',altitude(i));
    else
      fprintf(fid,'          ');
    end
    fprintf(fid,'%10.4e',pressure(i));
    fprintf(fid,'%10.3f',temperature(i));
    fprintf(fid,'     ');
    fprintf(fid,'%s',JCHARP);
    fprintf(fid,'%s',JCHART);
    fprintf(fid,' ');
    fprintf(fid,'%s',JLONG);
    fprintf(fid,' ');
    fprintf(fid,'%s',JCHAR);
    fprintf(fid,'\n');
    
    for j=1:max(find(species_vec==1))
      if species_vec(j) == 1
	fprintf(fid,'%10.4e',full_atm(i,j+3));
      else
	fprintf(fid,'          ');
      end
      if (floor(j/8) == j/8) & ...
	    (j~=max(find(species_vec==1)))
	fprintf(fid,'\n');
      end
    end
    fprintf(fid,'\n');
  end
end

if IXSECT > 0 %!!! still needs to be developed
  % add in the x-section info
  fprintf(fid,'%5i%5i%5i selected x-sections are :\n',[3 0 0]);
  fprintf(fid,'CCL4      F11       F12 \n');
  fprintf(fid,'%5i%5i  \n',[2 0]);
  fprintf(fid,'%10.3f     AAA\n',min(altitude));
  fprintf(fid,'%10.3e%10.3e%10.3e\n',[1.105e-04 2.783e-09 5.027e-04]);
  fprintf(fid,'%10.3f     AAA\n',max(altitude));
  fprintf(fid,'%10.3e%10.3e%10.3e\n',[1.105e-04 2.783e-09 5.027e-04]);
end

fprintf(fid,'%%%');
fclose(fid);
dummy = 0;

%!!! Ice cloud and liquid cloud functionality
clear effradice effradliq
if get_flag(Flag_Vec,Flag_List,'IWC_Flag') == 1 | ...
      get_flag(Flag_Vec,Flag_List,'LWC_Flag') == 1
  s = strcat(filename,'_CLD');
  s_cld = s;
  fid = fopen(s,'w');
  INFLAG = 2;
  ICEFLAG = 3;
  LIQFLAG = 1;
  TESTCHAR = ' ';

  %Record C1.1
  fprintf(fid,'    '); %4X
  fprintf(fid,'%1i',INFLAG);
  fprintf(fid,'    '); %4X
  fprintf(fid,'%1i',ICEFLAG);
  fprintf(fid,'    '); %4X
  fprintf(fid,'%1i\n',LIQFLAG);
  
  %Determine cloud level crossing
  num_clouds = IWC_struct.num_clouds + LWC_struct.num_clouds;
  cloud_index = 1;
  for i=1:LWC_struct.num_clouds
    [dummy,level_index_below] = min(abs(pz_levs-LWC_struct.levels(i,1)));
    [dummy,level_index_above] = min(abs(pz_levs-LWC_struct.levels(i,2)));
    
    for j=level_index_below:level_index_above
      lay(cloud_index) = j;
      cldfrac(cloud_index) = LWC_struct.CLDFRAC(i);
      cwp(cloud_index) =  LWC_struct.CWP(i);
      fracice(cloud_index) = 0;
      effradice(cloud_index) = 0;  
      effradliq(cloud_index) = LWC_struct.Reff(i);
      cloud_index = cloud_index + 1;
    end  
  end
  for i=1:IWC_struct.num_clouds
    if IWC_struct.CWP(i)>0
      %Check level for cloud presence
      [dummy,level_index_below] = min(abs(pz_levs-IWC_struct.levels(i,1)));
      [dummy,level_index_above] = min(abs(pz_levs-IWC_struct.levels(i,2)));
      
      for j=level_index_below:level_index_above
	lay(cloud_index) = j;
	cldfrac(cloud_index) = IWC_struct.CLDFRAC(i);
	cwp(cloud_index) =  IWC_struct.CWP(i);
	fracice(cloud_index) = 1;
	effradice(cloud_index) = IWC_struct.Reff(i); 
	effradliq(cloud_index) = 0;
	cloud_index = cloud_index + 1;
      end
    end
  end
  for i=1:cloud_index-1
    fprintf(fid,'%s',TESTCHAR);
    fprintf(fid,' '); %1X
    fprintf(fid,'%3i',lay(i));
    fprintf(fid,'%10.5f',cldfrac(i));
    fprintf(fid,'%10.3f',cwp(i));
    fprintf(fid,'%10.5f',fracice(i));
    fprintf(fid,'%10.5f',effradice(i));
    fprintf(fid,'%10.5f\n',effradliq(i));  
  end
  fprintf(fid,'%%\n');
  fclose(fid);
else
  s_cld = 0;
end

clear dummy
dummy.filename = s_fid;
dummy.suffix = strcat(write_rrtm_tape5_lw_input.suffix,'_',int2str(ICLD));
dummy.cloudname = s_cld;
return
