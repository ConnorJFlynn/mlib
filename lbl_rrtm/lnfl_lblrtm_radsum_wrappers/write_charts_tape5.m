function dummy = ...
    write_charts_tape5(write_charts_tape5_input)
%function dummy = ...
%    write_charts_tape5(write_charts_tape5_input)
%
%This function will write an appropriate TAPE5 for LNFL and CHARTS execution
%The hard-wired variables in this execution are designed with a
%satellite-borne instrument in mind.
%(C) Dan Feldman 2004
%
%%%%%%%%%%%%%%%%%%%
%%Input variables%%
%%%%%%%%%%%%%%%%%%%
%write_charts_tape5_input structure variables:
%.v1: starting wavenumber
%.v2: ending wavenumber 
%.observer_angle = cross-track scan-angle in degrees (180=nadir,0=zenith)
%.pz_obs  = pressure or altitude at observer
%.pz_surf = pressure or altitude at target
%.t_surf  = temperature at target (K)
%.pz_levs = pressure or altitude levels on which charts will perform its calculations
%.model:   selects atmospheric profile
%                     = 0  user supplied atmospheric profile
%                     = 1  tropical model
%                     = 2  midlatitude summer model
%                     = 3  midlatitude winter model
%                     = 4  subarctic summer model
%                     = 5  subarctic winter model
%                     = 6  U.S. standard 1976
% .species_vec: [1x32] vector, entry = 1 for species being included:
%    1.  H2O (ppmv)
%    2.  CO2 (ppmv)
%    3.  O3 (ppmv)
%    4.  N2O (ppmv)
%    5.  CO  (ppmv)
%    6.  CH4 (ppmv)
%    7.  O2 (ppmv)
%    8.  NO  (ppmv)
%    9.  SO2 (ppmv)
%    10. NO2 (ppmv)
%    11. NH3 (ppmv)
%    12. HNO3 (ppmv)
%    13. OH (ppmv)
%    14. HF (ppmv)
%    15. HCL (ppmv)
%    16. HBR (ppmv)
%    17. HI (ppmv)
%    18. CLO (ppmv)
%    19. OCS (ppmv)
%    20. H2CO (ppmv)
%    21. HOCL (ppmv)
%    22. N2 (ppmv)
%    23. HCN (ppmv)
%    24. CH3CL (ppmv)
%    25. H2O2 (ppmv)
%    26. C2H2 (ppmv)
%    27. C2H6 (ppmv)
%    28. PH3 (ppmv)
%    29. COF2 (ppmv)
%    30. SF6 (ppmv)
%    31. H2S (ppmv)
%    32. HCOOH (ppmv)
%.full_atm:
%   column 1: altitude profile (km)
%   column 2: pressure profile (mbar)
%   column 3: temperature profile (K)
%   column 4:35: profile of trace species 
%.ILS: instrument line-shape function structure
%  .ILS_use = 1 for using internal ILS function, else = 0
%             (if =0, ignore rest of structure)
%  .JFN = scanning function
%      0 = boxcar
%      1 = triangular
%      2 = gaussian
%      3 = sinc-squared
%      4 = sinc
%      5 = Beer
%      6 = Hanning
%    for apodization, set scan_func = -1*scan_func
%  .HWHM = half-width at half-maximum
%  .V1 = starting wavenumber of scan
%  .V2 = ending wavenumber of scan
%.Flag_Vec         = set of flags/switches for running charts
%   Aerosol_Flag = 1 for inclusion of aerosols (still undeveloped)
%   P_or_Z       = 1 for levels determined by pressure, 0 for altitude
%   Rad_or_Trans = 1 for output in radiance, 0 for transmittance
%   RH_Flag      = 1 for treatment of H2O in RH, 0 for H2O in ppmv
%   Temp_Flag    = 1 for execution in temporary directories (allows
%                    for simultaneous calculations to proceed)
%.Flag_List        = flag/switch name list
%.Directory_Mat    = string matrix of directories
%.Directory_List   = associated string matrix of directory names
%   LBLRTM = location of lblrtm executable files
%   LNFL   = location of lnfl executable files
%   CHARTS = location of charts executable files
%
%%%%%%%%%%%%%%%%%%%
% CHARTS variables%
%%%%%%%%%%%%%%%%%%%
%.aerosol_struct
%  .aerosol_number
%  .aerosol_omega
%  .aerosol_g
%  .aerosol_z
%.cloud_struct
%  .cloud_number
%  .cloud_omega
%  .cloud_g
%  .cloud_z
%  .cloud
%%%%%%%%%%%%%%%%%%%%
%%Output variables%%
%%%%%%%%%%%%%%%%%%%%
%dummy = generic dummy output variable
%

s_identify = 'write_charts_tape5.m';

%Assign real variables from write_charts_tape5_input structure:

v1             = write_charts_tape5_input.v1;
v2             = write_charts_tape5_input.v2; 
observer_angle = write_charts_tape5_input.observer_angle;
pz_obs         = write_charts_tape5_input.pz_obs;
pz_surf        = write_charts_tape5_input.pz_surf;
t_surf         = write_charts_tape5_input.t_surf;
pz_levs        = write_charts_tape5_input.pz_levs;
model          = write_charts_tape5_input.model;
species_vec    = write_charts_tape5_input.species_vec;
full_atm       = write_charts_tape5_input.full_atm;
ILS            = write_charts_tape5_input.ILS;
Flag_Vec       = write_charts_tape5_input.Flag_Vec;
Flag_List      = write_charts_tape5_input.Flag_List;
Directory_Mat  = write_charts_tape5_input.Directory_Mat;
Directory_List = write_charts_tape5_input.Directory_List;

lblrtm_directory = get_directory(Directory_Mat,Directory_List,'LBLRTM');
lnfl_directory   = get_directory(Directory_Mat,Directory_List,'LNFL');
charts_directory = get_directory(Directory_Mat,Directory_List,'CHARTS');

%Set flags

altitude    = full_atm(:,1);
pressure    = full_atm(:,2);
temperature = full_atm(:,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LNFL TAPE5 File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = strcat(lnfl_directory,'TAPE5');
fid = fopen(s,'w');
fprintf(fid,'TAPE5_LNFL from write_charts_tape5.m\n'); %XID
fprintf(fid,' %9.3f',v1-25); %V1
fprintf(fid,' '); %1X
fprintf(fid,'%9.3f\n',v2+25); %V2
for i=1:length(species_vec)
  fprintf(fid,'%1i',species_vec(i)); %MIND(I)
end
fprintf(fid,'          LNOUT\n'); %HOLIND1
fprintf(fid,'%%%'); %EOF
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LBLRTM TAPE5 File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Card 1.2
IHIRAC  = 1;
ILBLF4 = 1;
ICNTNM = 1;
IAERSL = get_flag(Flag_Vec,Flag_List,'Aerosol_Flag');
IEMIT = 1;
ISCAN = 0;
IFILTR  = 0;
IPLOT   = 0;
ITEST  = 0;
IATM   = 1;
IMRG   = 1;
ILAS   = 0;
IOD    = 1;
IXSECT = 0;
MPTS   = 0;
NPTS   = 0;

%Card 1.3
V1 = v1;
V2 = v2;
SAMPLE = 4;
DVSET = 0.001;
ALFALO = 0.04;
AVMASS = 36;
DPTMIN = 0.0002;
DPTFAC = 0.001;
ILNFLG = 1;
DVOUT  = 0.0001;

%Card 1.4
if observer_angle > 90
  TBOUND = t_surf;
  surf_refl = 'l';
  SREMIS(1) = -1;
  SREMIS(2) = 0;
  SREMIS(3) = 0;
  SRREFL(1) = -1;
  SRREFL(2) = 0;
  SRREFL(3) = 0;
else
  TBOUND = 0;
  surf_refl = ' ';
  SREMIS(1) = 0;
  SREMIS(2) = 0;
  SREMIS(3) = 0;
  SRREFL(1) = 0;
  SRREFL(2) = 0;
  SRREFL(3) = 0;
end

%Card 3.1
MODEL = model;
ITYPE = 2;

if get_flag(Flag_Vec,Flag_List,'P_or_Z') == 1
  IBMAX = -1*length(pz_levs);
else
  IBMAX = length(pz_levs);
end

NOZERO  = 1;
NOPRNT  = 1;
NMOL    = max(find(species_vec==1));
IPUNCH  = 1;
IFXTYP  = 0;
MUNITS  = 1;
RE      = 0;
HSPACE  = 100;
VBAR    = (v1+v2)/2;
CO2MX   = 0;
REF_LAT = 30;

%Card 3.2
ANGLE = observer_angle;

%
RANGE = 705-0;
BETA  = 0;
LEN   = 0;

%Card 3.3a
if IBMAX == 0
  AVTRAT = 0;
  TDIFF1 = 0;
  TDIFF2 = 0;
  ALTD1  = 0;
  ALTD2  = 0;
end

%Card 3.3b
ZNBD = pz_levs;

%extra parameters
H1 = pz_obs;
H2 = pz_surf;

%Card 3.4
if MODEL == 0
  if IBMAX > 0
    IMMAX = length(full_atm(:,1));
  else
    IMMAX = -1*length(full_atm(:,1));
  end
  HMOD  = ' user-defined';
end

%Card 3.5
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

%Card 4.1
if get_flag(Flag_Vec,Flag_List,'Aerosol_Flag') == 1
  IHAZE  = 1;
  WSS    = 1;
  WHH    = 1;
else
  IHAZE = 0;
  WSS   = 0;
  WHH   = 0;
end
ISEASN = 0;
IVULCN = 0;
ICSTL  = 3;
ICLD   = 0;
IVSA   = 0;
VIS    = 100;
RAINRT = 0;
GNDALT = 0;

%Card 12.2A
XSIZE  = 10.2;
DELV   = 100;
NUMSBX = 5; 
NOENDX = 0;
LFILE  = [11 11];
LSKIPF = 0;
SCALE  = 1;
IOPT   = 0;
I4P    = 0;
IXDEC  = 0;

%Card 12.3A
YMIN   = 0;
YMAX   = 1.2;
YSIZE  = 7.02;
DELY   = 0.2;
NUMSBY = 4;
NOENDY = 0;
IDEC   = 1;
if get_flag(Flag_Vec,Flag_List,'Rad_or_Trans') == 1
  JEMIT  = 1;
else
  JEMIT = 0;
end
JPLOT  = [0 1]; %radiance = 0, bt = 1
LOGPLT = 0;
JHDR   = 0;
JOUT   = 3;
JPLTFL = [27 28];
%finish with a -1

%write TAPE5_TS
s = strcat(lblrtm_directory,'TAPE5');
fid = fopen(s,'w');
fprintf(fid,'$ LBLRTM TAPE5 from write_charts_tape5.m\n');

%Record 1.2
fprintf(fid,'%5i',IHIRAC);
fprintf(fid,'%5i',ILBLF4);
fprintf(fid,'%5i',ICNTNM);
fprintf(fid,'%5i',IAERSL);
fprintf(fid,'%5i',IEMIT);
fprintf(fid,'%5i',ISCAN);
fprintf(fid,'%5i',IFILTR);
fprintf(fid,'%5i',IPLOT);
fprintf(fid,'%5i',ITEST);
fprintf(fid,'%5i',IATM);
fprintf(fid,'%5i',IMRG);
fprintf(fid,'%5i',ILAS);
fprintf(fid,'%5i',IOD);
fprintf(fid,'%5i',IXSECT);
fprintf(fid,'%5i',MPTS);
fprintf(fid,'%5i',NPTS);
fprintf(fid,'\n');

%Card 1.3
fprintf(fid,'%10.3f',V1);
fprintf(fid,'%10.3f',V2);
fprintf(fid,'          '); %SAMPLE
fprintf(fid,'          '); %DVSET
fprintf(fid,'          '); %ALFALO
fprintf(fid,'          '); %AVMASS
fprintf(fid,'%10.3f',0);   %DPTMIN
fprintf(fid,'%10.3f',0);   %DPTFAC
fprintf(fid,'          '); %ILNFLG
fprintf(fid,'%10.4f',DVOUT);
fprintf(fid,'\n');

if IEMIT >0
  %Card 1.4
  fprintf(fid,'%10.3f',TBOUND);
  fprintf(fid,'%10.3f',SREMIS(1));
  fprintf(fid,'          ');
  fprintf(fid,'          ');
  fprintf(fid,'%10.3f',SRREFL(1));
  fprintf(fid,'          ');
  fprintf(fid,'          ');
  fprintf(fid,'    ');
  fprintf(fid,'%s',surf_refl);
  fprintf(fid,'\n');
end

%Card 3.1
fprintf(fid,'%5i',MODEL);
fprintf(fid,'%5i',ITYPE);
fprintf(fid,'%5i',IBMAX);
fprintf(fid,'%5i',NOZERO);
fprintf(fid,'%5i',NOPRNT);
fprintf(fid,'%5i',NMOL);
fprintf(fid,'%5i',IPUNCH);
fprintf(fid,'%2i',IFXTYP);
fprintf(fid,' ');
fprintf(fid,'%2i',MUNITS);
fprintf(fid,'%10.3f',RE);
fprintf(fid,'%10.3f',HSPACE);
fprintf(fid,'%10.3f',VBAR);
fprintf(fid,'%10.3f',CO2MX);
fprintf(fid,'%10.3f',REF_LAT);
fprintf(fid,'\n');

%Card 3.2
fprintf(fid,'%10.3f',H1);
fprintf(fid,'%10.3f',H2);
fprintf(fid,'%10.3f',ANGLE);
fprintf(fid,'\n');

if abs(IBMAX) > 0
  %Card 3.3B
  for i=1:length(ZNBD)
    fprintf(fid,'%10.3f',ZNBD(i));
    if round(i/8) == i/8 & i<length(ZNBD)
      fprintf(fid,'\n');
    end
  end
  fprintf(fid,'\n');
else
  %Record 3.3A
  AVTRAT = 0;
  TDIFF1 = 0;
  TDIFF2 = 0;
  ALTD1  = 0;
  ALTD2  = 0;
  fprintf(fid,'%10.3f',AVTRAT);
  fprintf(fid,'%10.3f',TDIFF1);
  fprintf(fid,'%10.3f',TDIFF2);
  fprintf(fid,'%10.3f',ALTD1);
  fprintf(fid,'%10.3f',ALTD2);
  fprintf(fid,'\n');
end
if MODEL == 0
  %Card 3.4
  fprintf(fid,'%5.0f',IMMAX);
  fprintf(fid,'%s',HMOD);
  fprintf(fid,'\n');
  
  %Card 3.5 and Card 3.6
  for i=1:length(altitude)
    fprintf(fid,'%10.3f',altitude(i));
    fprintf(fid,'%10.3f',pressure(i));
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

if IAERSL > 0
  %Card 4.1
  fprintf(fid,'%5i',IHAZE);
  fprintf(fid,'%5i',ISEASN);
  fprintf(fid,'%5i',IVULCN);
  fprintf(fid,'%5i',ICSTL);
  fprintf(fid,'%5i',ICLD);
  fprintf(fid,'%5i',IVSA);
  fprintf(fid,'          '); %VIS
  fprintf(fid,'%10.3f',WSS);
  fprintf(fid,'%10.3f',WHH);
  fprintf(fid,'%10.3f',RAINRT);
  fprintf(fid,'%10.3f',GNDALT);
  fprintf(fid,'\n');
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MIE TAPE5 File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = strcat(charts_directory,'TAPE5.MIE');
fid = fopen(s,'w');

%Card 1:
nang = 6;
dv = 1;
fprintf(fid,'%5i',length(pz_levs));
fprintf(fid,'%5i',nang);
fprintf(fid,'     ');
s = strcat(lblrtm_directory,'TAPE5');
fprintf(fid,s);
fprintf(fid,'%10.3f',v1-2);
fprintf(fid,'%10.3f',v2+2);
fprintf(fid,'%10.3f\n',dv);
fprintf(fid,'%15.1f',-1); %No Rayleigh scattering
fprintf(fid,'%15.4f',0);
fprintf(fid,'%15.4f',0);
fprintf(fid,'%15.4f',0);
fprintf(fid,'%15.4f',42.79);
fprintf(fid,'%15.4f\n',41.19);

%Create cloud_level, omega, and asym from cloud_struct
keyboard



for i=1:length(pz_levs)
  fprintf(fid,'%8i',cloud_level(i));
  if (i/9)==round(i/9)
    fprintf(fid,'\n');
  end
end
if (i/9)~=round(i/9)
  fprintf(fid,'\n');
end
%%%%%%%%%%%%%%%
for i=1:length(pz_levs)
  fprintf(fid,'%13.5f',omega(i));
  if (i/6)==round(i/6)
    fprintf(fid,'\n');
  end
end
if (i/6)~=round(i/6)
  fprintf(fid,'\n');
end
%%%%%%%%%%%%%%%
for i=1:length(pz_levs)
  fprintf(fid,'%13.5f',asym(i));
  if (i/6)==round(i/6)
    fprintf(fid,'\n');
  end
end
if (i/6)~=round(i/6)
  fprintf(fid,'\n');
end
%%%%%%%%%%%%%%%
%Scaling factors
for i=1:length(pz_levs)
  if cloud_level(i)>0
    fprintf(fid,'%13.5f',1);
  else
    fprintf(fid,'%13.5f',0);
  end
  if (i/6)==round(i/6)
    fprintf(fid,'\n');
  end
end
if (i/6)~=round(i/6)
  fprintf(fid,'\n');
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CHARTS TAPE5 File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NCANG  = 6;
DELTM  = 'F';
HYG    = 'F';
AZMAV  = 'T';
IPLNCK = 1;
ISBEAM = 0;
ANG0   = 41.2;
TSFC   = t_surf;
ISRFL  = 0;
SALB   = 0.05;
NLAY   = length(pz_levs);
[dummy,LOBS] = min(abs(pz_obs-pz_levs));
THETA  = observer_angle;
DELPHI = 0;
LTYP   = layer_type;
CLW    = scale_factor;

fid = fopen(charts_directory,'TAPE5');
fprintf(fid,'$CHARTS TAPE5 file from write_charts_tape5.m\n');
fprintf(fid,'NCANG=');
fprintf(fid,'%i',NCANG);
fprintf(fid,'DELTM=');
fprintf(fid,'%s',DELTM);
fprintf(fid,'HYG=');
fprintf(fid,'%s',HYG);
fprintf(fid,'AZMAV=');
fprintf(fid,'%s\n',AZMAV);

fprintf(fid,'IPLNCK=');
fprintf(fid,'%i',IPLNCK);
fprintf(fid,'ISBEAM=');
fprintf(fid,'%i',ISBEAM);
fprintf(fid,'ANG0=');
fprintf(fid,'%2i\n',ANG0);

fprintf(fid,'TSFC=');
fprintf(fid,'%5.1f',TSFC);
fprintf(fid,'ISRFL=');
fprintf(fid,'%i',ISRFL);
fprintf(fid,'SALB=');
fprintf(fid,'%3.2f',SALB);
fprintf(fid,'NLAY=');
fprintf(fid,'%i',NLAY);
fprintf(fid,'LOBS=');
fprintf(fid,'%i\n',LOBS);

fprintf(fid,'THETA=');
fprintf(fid,'%3.2f',THETA);
fprintf(fid,'DELPHI=');
fprintf(fid,'%3.2f\n',DELPHI);
fprintf(fid,'LTYP=');
for i=1:NLAY
  fprintf(fid,'%8i',LTYP(i));
  if (i/8)==round(i/8)
    fprintf(fid,'\n');
  end
end
if (i/8)~=round(i/8)
  fprintf(fid,'\n');
end
fprintf(fid,'CLW=');
fprintf(fid,'  ');
for i=1:NLAY
  fprintf(fid,'%13.4f',CLW(i));
  if (i/5)==round(i/5)
    fprintf(fid,'\n');
  end
end
fprintf(fid,'$END TAPE5 file\n');
fclose(fid);

dummy = 0;
return
