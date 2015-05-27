function [date,Cad_UT,Mission_time,Ext_675,Ext_1550,Sca_675,Cad_RH,Cad_prs,Cad_temp,Ext_675_amb,Sca_675_amb,Abso_675_amb,SSA_675_amb,Ext_1550_amb,RH_amb,Prs_amb,Temp_amb]=...
         read_cadenza_IOP_ver4();

%reads in Cadenza data from version 4 and up.
% 16 Variables are:
% Mission_time,JulianCadTime,Ext_675,Ext_1550,Sca_675,Cad_RH,Cad_prs,Cad_temp,Ext_675_amb,Sca_675_amb,Abso_675_amb,SSA_675_amb,Ext_1550_amb,RH_amb,Prs_amb,Temp_amb

%[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Cadenza\Ver4\*.*','Choose Cadenza file');
%[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Cadenza\Ver5\*.*','Choose Cadenza file');
%[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Cadenza\Ver6\*.*','Choose Cadenza file');
 [filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Cadenza\Ver7\*.*','Choose Cadenza file');

fid=fopen([pathname filename]);

% 3 header lines
date=fgetl(fid);
fgetl(fid);
fgetl(fid);
data=fscanf(fid,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[16,inf]);
fclose(fid);

Mission_time=data(1,:);
JulianCadTime=data(2,:);
Ext_675=data(3,:)/1e3; 
Ext_1550=data(4,:)/1e3; 
Sca_675=data(5,:)/1e3; 
Cad_RH=data(6,:); 
Cad_prs=data(7,:); 
Cad_temp=data(8,:)-273.15; 
Ext_675_amb=data(9,:)/1e3;; 
Sca_675_amb=data(10,:)/1e3;; 
Abso_675_amb=data(11,:)/1e3;; 
SSA_675_amb=data(12,:); 
Ext_1550_amb=data(13,:)/1e3;; 
RH_amb=data(14,:); 
Prs_amb=data(15,:); 
Temp_amb=data(16,:)-273.15; 

Cad_UT=24*(JulianCadTime-floor(JulianCadTime));

return

