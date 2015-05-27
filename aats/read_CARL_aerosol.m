function [CARL_Alt,CARL_ext]=read_CARL_aerosol();

%reads in CARL aerosol data
[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\CARL Aerosol\*.ext','Choose CARL file', 0, 0);
fid=fopen([pathname filename]);

for i=1:6,
fgetl(fid);
end

%Alt, AATS-14 ext (519nm), AATS-14 (519nm) err, AATS-14 ext (354nm), AATS-14 (354nm) err, CARL ext, CARL err, MPL ext, MPL err, IAP ext

data=fscanf(fid,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%g',[10,inf]);

fclose(fid);

CARL_Alt=data(1,:);   
CARL_ext=data(6,:); 

return

