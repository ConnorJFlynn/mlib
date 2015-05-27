function [Cad_time,Cad_ext_675,Cad_ext_1550,Cad_RH,Cad_press]=read_cadenza_IOP();

%reads in cadenza data
%[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Cadenza\*.*','Choose Cadenza file', 0, 0);
[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Cadenza\ver2\*.*','Choose Cadenza file', 0, 0);
fid=fopen([pathname filename]);

for i=1:6,
fgetl(fid);
end

%Cad_time,Ext_675,Ext_1550,RH,Cad_prs

data=fscanf(fid,'%g,%g,%g,%g,%g',[5,inf]);

fclose(fid);

Cad_time=data(1,:);   
Cad_ext_675=data(2,:)/1e3; 
Cad_ext_1550=data(3,:)/1e3; 
Cad_RH=data(4,:); 
Cad_press=data(5,:); 

return

