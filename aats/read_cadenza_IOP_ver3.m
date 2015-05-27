function [Mission_time,Ext_675,Ext_1550,Sca_675,Cad_RH,Cad_prs,Cad_temp,Ext_675_amb,Sca_675_amb,Abso_675_amb,SSA_675_amb,Ext_1550_amb,RH_amb,Prs_amb,Temp_amb]=...
         read_cadenza_IOP_ver3();

%reads in Cadenza data
% 15 Variables are:
% Mission_time,Ext_675,Ext_1550,Sca_675,Cad_RH,Cad_prs,Cad_temp,Ext_675_amb,Sca_675_amb,Abso_675_amb,SSA_675_amb,Ext_1550_amb,RH_amb,Prs_amb,Temp_amb

[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Cadenza\Ver3\*.*','Choose Cadenza file');
fid=fopen([pathname filename]);

% skip 3 header lines
for i=1:3,
fgetl(fid);
end
data=fscanf(fid,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[15,inf]);
fclose(fid);

Mission_time=data(1,:);
Ext_675=data(2,:)/1e3; 
Ext_1550=data(3,:)/1e3; 
Sca_675=data(4,:)/1e3; 
Cad_RH=data(5,:); 
Cad_prs=data(6,:); 
Cad_temp=data(7,:); 
Ext_675_amb=data(8,:)/1e3;; 
Sca_675_amb=data(9,:)/1e3;; 
Abso_675_amb=data(10,:)/1e3;; 
SSA_675_amb=data(11,:); 
Ext_1550_amb=data(12,:)/1e3;; 
RH_amb=data(13,:); 
Prs_amb=data(14,:); 
Temp_amb=data(15,:)-273.15; 

return

