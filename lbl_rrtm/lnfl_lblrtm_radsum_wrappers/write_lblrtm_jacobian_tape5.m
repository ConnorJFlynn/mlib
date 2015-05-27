function dummy = ...
    write_lblrtm_jacobian_tape5(write_lblrtm_jacobian_tape5_input)
%function dummy = ...
%    write_tape5(write_lblrtm_jacobian_tape5_input)
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
%This function will write an appropriate TAPE5 for LNFL and LBLRTM execution
%The hard-wired variables in this execution are designed with a
%satellite-borne instrument in mind.
%
%%%%%%%%%%%%%%%%%%%
%%Input variables%%
%%%%%%%%%%%%%%%%%%%
%write_lblrtm_jacobian_tape5_input structure variables:
%.v1: starting wavenumber
%.v2: ending wavenumber 
%.observer_angle = cross-track scan-angle in degrees (180=nadir,0=zenith)
%.pz_obs  = pressure or altitude at observer
%.pz_surf = pressure or altitude at target
%.t_surf  = temperature at target (K)
%.pz_levs = pressure or altitude levels on which lblrtm will perform its calculations
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
%.Flag_Vec         = set of flags/switches for running lblrtm
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
%   RADSUM = location of radsum executable files
%.jacobian_species = -2 = surface reflectivity
%                    -1 = surface emissivity and surface skin temperature
%                     0 = temperature
%                     1-N = HITRAN species 1-N
%
%%%%%%%%%%%%%%%%%%%%
%%Output variables%%
%%%%%%%%%%%%%%%%%%%%
%dummy = generic dummy output variable
%

s_identify = 'write_lblrtm_jacobian_tape5.m';

%Assign real variables from write_lblrtm_jacobian_tape5_input structure:

v1             = write_lblrtm_jacobian_tape5_input.v1;
v2             = write_lblrtm_jacobian_tape5_input.v2; 
observer_angle = write_lblrtm_jacobian_tape5_input.observer_angle;
pz_obs         = write_lblrtm_jacobian_tape5_input.pz_obs;
pz_surf        = write_lblrtm_jacobian_tape5_input.pz_surf;
t_surf         = write_lblrtm_jacobian_tape5_input.t_surf;
pz_levs        = write_lblrtm_jacobian_tape5_input.pz_levs;
model          = write_lblrtm_jacobian_tape5_input.model;
species_vec    = write_lblrtm_jacobian_tape5_input.species_vec;
full_atm       = write_lblrtm_jacobian_tape5_input.full_atm;
ILS            = write_lblrtm_jacobian_tape5_input.ILS;
Flag_Vec       = write_lblrtm_jacobian_tape5_input.Flag_Vec;
Flag_List      = write_lblrtm_jacobian_tape5_input.Flag_List;
Directory_Mat  = write_lblrtm_jacobian_tape5_input.Directory_Mat;
Directory_List = write_lblrtm_jacobian_tape5_input.Directory_List;
jacobian_species = write_lblrtm_jacobian_tape5_input.jacobian_species;

lblrtm_directory = get_directory(Directory_Mat,Directory_List,'LBLRTM');
lnfl_directory   = get_directory(Directory_Mat,Directory_List,'LNFL');

%Set flags

altitude    = full_atm(:,1);
pressure    = full_atm(:,2);
temperature = full_atm(:,3);

%write lnfl
if get_flag(Flag_Vec,Flag_List,'LNFL_Flag') == 1
  s = strcat(lnfl_directory,'TAPE5');
  fid = fopen(s,'w');
  fprintf(fid,'TAPE5_LNFL from write_lblrtm_jacobian_tape5.m\n'); %XID
  fprintf(fid,' %9.3f',v1-25); %V1
  fprintf(fid,' '); %1X
  fprintf(fid,'%9.3f\n',v2+25); %V2
  for i=1:length(species_vec)
    fprintf(fid,'%1i',species_vec(i)); %MIND(I)
  end
  fprintf(fid,'          LNOUT\n'); %HOLIND1
  fprintf(fid,'%%%'); %EOF
  fclose(fid);
end

%Record 1.2
%For initial optical depth calculation
IHIRAC  = 1;
ILBLF4 = 1;
ICNTNM = 1;
IAERSL = get_flag(Flag_Vec,Flag_List,'Aerosol_Flag');
IEMIT = 3;
ISCAN = 0;
IFILTR  = 0;
IPLOT   = 0;
ITEST  = 0;
IATM   = 0;
if observer_angle > 90
  IMRG = 43;
else
  IMRG = 42;
end
ILAS   = 0;
IOD    = 3;
IXSECT = 0;
MPTS   = 0;
NPTS   = 0;

%Record 1.3
V1 = v1;
V2 = v2;
SAMPLE = 4;
DVSET = 0.001;
ALFALO = 0.04;
AVMASS = 36;
DPTMIN = 0.0002;
DPTFAC = 0.001;
ILNFLG = 1;
DVOUT  = 0.0;

%Record 1.4
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

%Record 1.5
NSPCRT = jacobian_species;

%Record 3.1
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
IPUNCH  = 2;
IFXTYP  = 0;
MUNITS  = 1;
RE      = 0;
HSPACE  = 100;
VBAR    = (v1+v2)/2;
CO2MX   = 0;
REF_LAT = 30;

%Record 3.2
ANGLE = observer_angle;

%
RANGE = 705-0;
BETA  = 0;
LEN   = 0;

%Record 3.3a
if IBMAX == 0
  AVTRAT = 0;
  TDIFF1 = 0;
  TDIFF2 = 0;
  ALTD1  = 0;
  ALTD2  = 0;
end

%Record 3.3b
ZNBD = pz_levs;

%extra parameters
H1 = pz_obs;
H2 = pz_surf;

%Record 3.4
if MODEL == 0
  if IBMAX > 0
    IMMAX = length(full_atm(:,1));
  else
    IMMAX = -1*length(full_atm(:,1));
  end
  HMOD  = ' user-defined';
end

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

%Record 4.1
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

%Record 12.2A
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

%Record 12.3A
YMIN   = 0;
YMAX   = 1.2;
YSIZE  = 7.02;
DELY   = 0.2;
NUMSBY = 4;
NOENDY = 0;
IDEC   = 1;
if get_flag(Flag_Vec,Flag_List,'Rad_or_Trans') == 1
  JEMIT  = 1;
  %JEMIT = 0;
else
  JEMIT = 0;
end
JPLOT  = [0 1]; %radiance = 0, bt = 1
LOGPLT = 0;
JHDR   = 0;
JOUT   = 3;
JPLTFL = [27 28];
%finish with a -1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%write TAPE5_TS
s = strcat(lblrtm_directory,'TAPE5');
fid = fopen(s,'w');
fprintf(fid,'$ LBLRTM_JACOBIAN_TEST\n');

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

%Record 1.3
fprintf(fid,'%10.3f',V1);
fprintf(fid,'%10.3f',V2);
fprintf(fid,'%10.3f',SAMPLE);
fprintf(fid,'          '); %DVSET
fprintf(fid,'%10.3f',ALFALO);
fprintf(fid,'%10.3f',AVMASS);
fprintf(fid,'%10.3f',DPTMIN);
fprintf(fid,'%10.3f',DPTFAC);
fprintf(fid,'%10.3f',ILNFLG);
fprintf(fid,'%10.3f',DVOUT);
fprintf(fid,'\n');

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

%Record 1.5
fprintf(fid,'%5i',NSPCRT);
fprintf(fid,'\n');

%Record 1.6a
PTHODL = 'ODint_';
fprintf(fid,'%s\n',PTHODL);
fprintf(fid,'\n');
fprintf(fid,'%%%'); %End-of-file

blah = 0;
if blah == 1
%Record 3.1
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

%Record 3.2
fprintf(fid,'%10.3f',H1);
fprintf(fid,'%10.3f',H2);
fprintf(fid,'%10.3f',ANGLE);
fprintf(fid,'\n');

if abs(IBMAX) > 0
  %Record 3.3B
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
  %Record 3.4
  fprintf(fid,'%5.0f',IMMAX);
  fprintf(fid,'%s',HMOD);
  fprintf(fid,'\n');
  
  %Record 3.5 and Record 3.6
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
  %Record 4.1
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

%Record 1.2
fprintf(fid,'%5i',0);      %IHIRAC
fprintf(fid,'%5i',0);      %ILBLF4
fprintf(fid,'%5i',0);      %ICNTNM
fprintf(fid,'%5i',0);      %IAERSL
fprintf(fid,'%5i',1);      %IEMIT
fprintf(fid,'%5i',0);      %ISCAN
fprintf(fid,'%5i',0);      %IFILTR
fprintf(fid,'%5i',0);      %IPLOT
fprintf(fid,'%5i',0);      %ITEST
fprintf(fid,'%5i',0);      %IATM
fprintf(fid,'%5i',40);     %IMRG space-to-ground downwelling 
fprintf(fid,'%5i',0);      %ILAS
fprintf(fid,'%5i',3); %IOD
fprintf(fid,'%5i',IXSECT);
fprintf(fid,'%5i',0);      %MPTS
fprintf(fid,'%5i',0);      %NPTS
fprintf(fid,'\n');

%Record 1.3
fprintf(fid,'%10.3f',V1);
fprintf(fid,'%10.3f',V2);
fprintf(fid,'%10.3f',SAMPLE);
fprintf(fid,'          '); %DVSET
fprintf(fid,'%10.3f',ALFALO);
fprintf(fid,'%10.3f',AVMASS);
fprintf(fid,'%10.3f',DPTMIN);
fprintf(fid,'%10.3f',DPTFAC);
fprintf(fid,'%10.3f',ILNFLG);
fprintf(fid,'%10.3f',DVOUT);
fprintf(fid,'\n');

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

%Record 1.6a
PTHODL = 'ODint_';
fprintf(fid,'%s\n',PTHODL);
fprintf(fid,'\n');
fprintf(fid,'%%%'); %End-of-file
fclose(fid);

%Write files for Jacobian calculations:
fid = fopen('TAPE5_JACOBIAN','w');

%Record 1.1
fprintf(fid,'$  Compute Analytic Jacobian Files in AJ Directory from write_lblrtm_jacobian_tape5.m\n');

%Record 1.2
fprintf(fid,'%5i',IHIRAC);
fprintf(fid,'%5i',ILBLF4);
fprintf(fid,'%5i',ICNTNM);
fprintf(fid,'%5i',IAERSL);
fprintf(fid,'%5i',0);
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
end

dummy = 0;
return
