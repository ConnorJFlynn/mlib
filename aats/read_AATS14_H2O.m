[filename,pathname]=uigetfile('d:\beat\data\ACE-2\results\*.h2o_prof.asc','Choose H2O density file', 0, 0);
fid=fopen([pathname filename]);

fgetl(fid);
title1=fgetl(fid);
title2=fgetl(fid);
fgetl(fid);
fgetl(fid);

data=fscanf(fid,'%g',[9,inf]);
fclose(fid);

UT_AATS14=data(1,:);
Lat_AATS14=data(2,:);
Long_AATS14=data(3,:);
Altitude_AATS14=data(4,:);
p_AATS14=data(5,:);
CWV_AATS14=data(6,:);
O3_AATS14=data(7,:);
H2O_Dens_AATS14=data(8,:);
H2O_err_AATS14=data(9,:);

