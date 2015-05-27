function [MT_TSI,scat_450,scat_550,scat_700,RH_TSI,alpha550_450,alpha700_450,alpha700_550,...
          MT_humid,scat_540_low_RH,scat_540_mid_RH,scat_540_high_RH,low_RH,mid_RH,high_RH,gamma,...
          MT_PSAP,PSAP_467,PSAP_530,PSAP_660,...
          MT_SSA,SSA_467,SSA_530,SSA_660]=read_Neph

% neph_{DATE}.txt
% TSI nephalometer data for dry relative humidity. The dataset has been corrected 
% for angular non-idealities (angular truncation and lamp nonlambertian error). 
% The data apply to the temperature and pressure inside the nephalometer. Corrections 
% will need to be applied to get scattering at STP or at conditions outside the 
% airplane. 10 second averages are reported. The Angstrom exponent is a one minute 
% boxcar average.
% The columns are:
% 1. Mission Time
% 2. Total (as opposed to backscatter) aerosol scattering at 450 nm in Mm^-1
% 3. Total aerosol scattering at 550 nm in Mm^-1
% 4. Total aerosol scattering at 700 nm in Mm^-1
% 5. Inlet relative humidity in %
% 6. 550/450 Angstrom exponent
% 7. 700/450 Angstrom exponent
% 8. 700/550 Angstrom exponent


[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\nephs_psap\neph*.txt','Choose Neph data file', 0, 0);
fid=fopen([pathname filename]); 
data=fscanf(fid,'%g %g %g %g %g %g %g %g',[8,inf]);
MT_TSI=data(1,:);
scat_450=data(2,:)/1e3; % convert  to 1/km
scat_550=data(3,:)/1e3;
scat_700=data(4,:)/1e3;
RH_TSI=data(5,:);
alpha550_450=data(6,:);
alpha700_450=data(7,:);
alpha700_550=data(8,:);

fclose(fid);


% humid_{date}.txt
% Humidograph data from the three Radiance Research nephalometers. The data have 
% not been corrected for angular non-idealities. A first-cut growth factor, gamma, 
% has also been calculated: 
% gamma = [ log((sigma_sp at ~85%)/(sigma_sp at ~20%)) ] / log [( 1 - RH@~20%) / (1 - RH@~85%) ]
% The columns are:
% 1. Mission Time
% 2. Total aerosol scattering at 540 nm for the low RH (~20%) in Mm^-1
% 3. Total aerosol scattering at 540 nm for the middle RH (~50%) in Mm^-1
% 4. Total aerosol scattering at 540 nm for the high RH (~85%) in Mm^-1
% 5. Low inlet RH (RR#1) in %
% 6. Mid inlet RH (RR#3) in %
% 7. High inlet RH (RR#2) in %
% 8. Growth factor, gamma, between 20% and 85% scattering

[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\nephs_psap\humid*.txt','Choose Humid data file', 0, 0);
fid=fopen([pathname filename]); 
data=fscanf(fid,'%g %g %g %g %g %g %g %g',[8,inf]);
MT_humid=data(1,:);
scat_540_low_RH=data(2,:)/1e3;
scat_540_mid_RH=data(3,:)/1e3;
scat_540_high_RH=data(4,:)/1e3;
low_RH=data(5,:);
mid_RH=data(6,:);
high_RH=data(7,:);
gamma=data(8,:);
fclose(fid);

% psap_{DATE}.txt
% Particle Soot Absorption Photometer data. The absorption coefficients have been 
% adjusted to account for all well-established artifacts as well as for aerosol 
% scattering. The data apply to the temperature and pressure inside the instrument.
% The columns are:
% 1. Mission Time
% 2. Aerosol absorption at 467 nm in Mm^-1
% 3. Aerosol absorption at 530 nm in Mm^-1
% 4. Aerosol absorption at 660 nm in Mm^-1
% 

[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\nephs_psap\psap*.txt','Choose PSAP data file', 0, 0);
fid=fopen([pathname filename]); 
data=fscanf(fid,'%g %g %g %g',[4,inf]);
MT_PSAP=data(1,:);
PSAP_467=data(2,:)/1e3;
PSAP_530=data(3,:)/1e3;
PSAP_660=data(4,:)/1e3;
fclose(fid);


% ssa_{DATE}.txt
% Single scattering albedo from the TSI nephalometer and PSAP data. 10 second averages 
% are given.
% The columns are:
% 1. Mission Time
% 2. SSA at 467 nm
% 3. SSA at 530 nm
% 4. SSA at 660 nm


[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\nephs_psap\SSA*.txt','Choose SSAdata file', 0, 0);
fid=fopen([pathname filename]); 
data=fscanf(fid,'%g %g %g %g',[4,inf]);
MT_SSA=data(1,:);
SSA_467=data(2,:);
SSA_530=data(3,:);
SSA_660=data(4,:);
fclose(fid);