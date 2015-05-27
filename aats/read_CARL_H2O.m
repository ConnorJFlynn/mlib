function [Altitude,H2O_CARL,H2O_AATS14,H2O_Otter,H2O_IAP]=read_CARL_H2O();

%reads in CARL aerosol data
[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\CARL H2O\*.wv','Choose CARL file', 0, 0);
fid=fopen([pathname filename]);

for i=1:6,
fgetl(fid);
end

% Altitude (km, ASL), CARL, AATS-14, AATS-14 insitu, IAP

data=fscanf(fid,'%g,%g,%g,%g,%g',[5,inf]);

fclose(fid);

Altitude=data(1,:);   
H2O_CARL=data(2,:);
H2O_AATS14=data(3,:);
H2O_Otter=data(4,:);
H2O_IAP=data(5,:);

return

