function [nncoml,info_sav,UTdechr,Latitude,Longitude,Geom_alt_km,Press_alt_km,Pressmb,...
	  Wvlnm,CWV_cm,uncCWV_cm,O3col_DU,uncO3col_DU,cloud_flag,a2_polyfit,a1_polyfit,a0_polyfit,...
	  Taupart,Unctaup,mission_name,year,month,day,filename]=read_AATS14_GH_ICARTT(name); 

% read_AATS14_GH_ICARTT.m
% Reads file of AATS-14 ICARTT data archived in modified Gaines-Hipskind format
% John Livingston 7/13/2004

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
% Ozone fit flag: "Yes" or "No" ; V0 source;
% wavelengths and zero-airmass intercept voltages;
% Finally, 18 lines required by the ICARTT modified GH format.
% The last normal comment line must include the names of all variables.

info_sav=cell(nncoml,1);
if nncoml >= 1
 for i = 1:nncoml
    line = fgetl(fid);
    info_sav(i) = cellstr(line);
 end
end

nwl=14;
wvlstr=char(info_sav(10));
V0str=char(info_sav(11));
[Wvlnm,ndum]=sscanf(wvlstr(18:end),'%f',14);
[V0,ndum]=sscanf(V0str(18:end),'%f',14);

% read the data and apply scale factors as necessary
num_per_obs = nprimv+1;
[data,ndata] = fscanf(fid,'%f',[num_per_obs,inf]);
fclose(fid);

nobs = ndata/num_per_obs;

UTdechr = data(1,:)/3600;
UTstop = data(2,:)/3600;
UTmid = data(3,:)/3600;
Latitude = data(4,:)*vscal(3);
Longitude = data(5,:)*vscal(4);
Geom_alt_km = data(6,:)*vscal(5)*.001;
Press_alt_km = data(7,:)*vscal(6)*.001;
Pressmb = data(8,:)*vscal(7);
CWV_cm = data(9,:)*vscal(8);
uncCWV_cm = data(10,:)*vscal(9);
O3col_DU = data(11,:)*vscal(10);
uncO3col_DU = data(12,:)*vscal(11);
cloud_flag = data(13,:)*vscal(12);
a2_polyfit = data(14,:)*vscal(13);
a1_polyfit = data(15,:)*vscal(14);
a0_polyfit = data(16,:)*vscal(15);
  
for iwl = 1:13,
    Taupart(iwl,:) = vscal(15+iwl)*data(16+iwl,:);
  	Unctaup(iwl,:) = vscal(28+iwl)*data(29+iwl,:);
end

clear data