function [nncoml,info_sav,UTdechr,Latitude,Longitude,Geom_alt_km,Press_alt_km,Pressmb,...
	  Wvlnm,CWV_cm,CWVunc_cm,O3col_DU,cloud_flag,a2_polyfit,a1_polyfit,a0_polyfit,...
	  Taupart,Unctaup,mission_name,year,month,day,filename]=read_AATS14_GH_SOLVE2(name); 

% read_AATS14_GH_SOLVE2.m
% Reads file of AATS-14 SOLVE2 data archived in Gaines-Hipskind format
% John Livingston 12/23/2002

%opens data file
[filename,path]=uigetfile(name,'Choose a File', 0, 0);
fid=fopen([path filename]);

nlhead = fscanf(fid,'%i',1);
filetype = fscanf(fid,'%i',1);
line = fgetl(fid);		%skip end-of-line character

investigator_names=fgetl(fid);
org_name=fgetl(fid);
instrument_name=fgetl(fid);
mission_name=fgetl(fid);
%skip a line
line=fgetl(fid);  

%read date of data acquisition
datein = fscanf(fid,'%d',6);
year = datein(1);
month = datein(2);
day = datein(3);
line = fgetl(fid);		%skip end-of-line character

%skip 2 lines
for i = 1:2
  line = fgetl(fid);
end

%read number of sunphotometer aerosol channels
nwl = fscanf(fid,'%i',1);

%read bandpass center wavelengths in nm; convert to microns
Wvlnm = fscanf(fid,'%f',nwl);

line = fgetl(fid);		%skip end-of-line character

%skip 2 lines
for i = 1:2
  line = fgetl(fid);
end

%read number of primary variables
nprimv = fscanf(fid,'%i',1);
line = fgetl(fid);		%skip end-of-line character

%read scale factors, missing values
vscal = fscanf(fid,'%f',nprimv);
line = fgetl(fid);		%skip end-of-line character

vmiss = fscanf(fid,'%f',nprimv);
line = fgetl(fid);		%skip end-of-line character

%read primary variable names
for i = 1:nprimv
   vname{i} = fgetl(fid);  
end

%read number of auxiliary variables
nauxv = fscanf(fid,'%i',1);

%read scale factors, missing values
ascal = fscanf(fid,'%f',nauxv);
line = fgetl(fid);		%skip end-of-line character

amiss = fscanf(fid,'%f',nauxv);
line = fgetl(fid);		%skip end-of-line character

%read auxiliary variable names
for i = 1:nauxv
	aname{i} = fgetl(fid);
end
   
%read number of special comment lines 
nscoml = fscanf(fid,'%i',1);
line = fgetl(fid);		%skip end-of-line character

if nscoml >= 1
 for i = 1:nscoml
  line = fgetl(fid);
 end
end

% read number of normal comment lines 
nncoml = fscanf(fid,'%i',1);
line = fgetl(fid);		%skip end-of-line character

% These lines contain values used for NO2 column content; 
% cloud screening relative standard deviation criteria for aerosol and for H2O;
% max m_aero, tau_aero, tau_aero_error allowed;
% min alpha angstrom allowed;
% water vapor coeff; 
% Ozone fit flag: "Yes" or "No" ;
% wavelengths and zero-airmass intercept voltages;
% special notes pertaining to the data in the file

info_sav=cell(nncoml,1);
if nncoml >= 1
 for i = 1:nncoml
    line = fgetl(fid);
    info_sav(i) = cellstr(line);
 end
end

% read the data and apply scale factors as necessary
num_per_obs = 13 + nprimv*nwl;
[data,ndata] = fscanf(fid,'%i',[num_per_obs,inf]);
fclose(fid);

nobs = ndata/num_per_obs;

UTdechr = 24*data(1,:)/86400;
Latitude = data(2,:)*ascal(1);
Longitude = data(3,:)*ascal(2);
Geom_alt_km = data(4,:)*ascal(3)*.001;
Press_alt_km = data(5,:)*ascal(4)*.001;
Pressmb = data(6,:)*ascal(5);
CWV_cm = data(7,:)*ascal(6);
CWVunc_cm = data(8,:)*ascal(7);
O3col_DU = data(9,:)*ascal(8);
cloud_flag = data(10,:)*ascal(9);
a2_polyfit = data(11,:)*ascal(10);
a1_polyfit = data(12,:)*ascal(11);
a0_polyfit = data(13,:)*ascal(12);
  
for iwl = 1:nwl,
    Taupart(iwl,:) = vscal(1)*data(13+iwl,:);
  	Unctaup(iwl,:) = vscal(2)*data(13+nwl+iwl,:);
end

clear data