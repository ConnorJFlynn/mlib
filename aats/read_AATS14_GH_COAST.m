function [nncoml,info_sav,UTdechr,Latitude,Longitude,Geom_alt_km,Press_alt_km,Pressmb,...
	  Wvlnm,CWV_cm,uncCWV_cm,O3col_DU,cloud_flag,a2_polyfit,a1_polyfit,a0_polyfit,...
	  Taupart,Unctaup,mission_name,year,month,day,filename,filepath]=read_AATS14_GH_COAST(name); 

% read_AATS14_GH_COAST.m
% Reads file of AATS-14 COAST data archived in modified Gaines-Hipskind format
% John Livingston ... modified Nov. 2011 from similar routines for ARCTAS and ICARTT

%opens data file
if exist(name)
    [fpath,fname,fext,fvers]=fileparts(name);
    filepath=[fpath filesep];
    filename=[fname fext];
else
    [filename,filepath]=uigetfile(name,'Choose a File', 0, 0);
end
fid=fopen([filepath filename]);

nlhead = fscanf(fid,'%i',1);
filetype = fscanf(fid,'%i',1);
linein = fgetl(fid);		%skip end-of-line character

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
year_archive = datein(4);
month_archive = datein(5);
day_archive = datein(6);
linein = fgetl(fid);		%skip end-of-line character

%skip 2 lines
for i = 1:2
  linein = fgetl(fid);
end

%read number of primary variables
nprimv = fscanf(fid,'%i',1);
linein = fgetl(fid);		%skip end-of-line character

%read scale factors, missing values
vscal = fscanf(fid,'%f',nprimv);
linein = fgetl(fid);		%skip end-of-line character

vmiss = fscanf(fid,'%f',nprimv);
linein = fgetl(fid);		%skip end-of-line character

%read primary variable names
for i = 1:nprimv
   vname{i} = fgetl(fid);  
end

%read number of special comment lines 
nscoml = fscanf(fid,'%i',1);
linein = fgetl(fid);		%skip end-of-line character

if nscoml >= 1
 for i = 1:nscoml
  linein = fgetl(fid);
 end
end

% read number of normal comment lines 
nncoml = fscanf(fid,'%i',1);
linein = fgetl(fid);		%skip end-of-line character

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
    linein = fgetl(fid);
    info_sav(i) = cellstr(linein);
 end
end

%extract revision number for check below
linein=char(info_sav(end-1));
revision_number=str2num(linein(2));

wvlstr=char(info_sav(12));
V0str=char(info_sav(13));
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

if strcmp(mission_name,'COAST') & revision_number<=1
    Geom_alt_km = data(6,:)*vscal(5)*.001;
    Press_alt_km = data(7,:)*vscal(6)*.001;
    Pressmb = data(8,:)*vscal(7);
    CWV_cm = data(9,:)*vscal(8);
    uncCWV_cm = data(10,:)*vscal(9);
    O3col_DU = data(11,:)*vscal(10);
    cloud_flag = data(12,:)*vscal(11);
    a2_polyfit = data(13,:)*vscal(12);
    a1_polyfit = data(14,:)*vscal(13);
    a0_polyfit = data(15,:)*vscal(14);
    for iwl = 1:12,
        Taupart(iwl,:) = vscal(14+iwl)*data(15+iwl,:);
        Unctaup(iwl,:) = vscal(26+iwl)*data(27+iwl,:);
    end
else
end

clear data