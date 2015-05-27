lambda_AATS14=[0.3800 0.4491 0.4539 0.4995 0.5248 0.6059 0.6672 0.7119 0.7786 0.8640 1.0194 1.0597 1.5579];

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\results\*.ext_prof.asc','Choose Aerosol extinction file', 0, 0);
fid=fopen([pathname filename]);
fgetl(fid);
title1=fgetl(fid);
title2=fgetl(fid);
fgetl(fid);
fgetl(fid);
fgetl(fid);

data=fscanf(fid,'%g',[46,inf]);
fclose(fid);

UT_AATS14=data(1,:);
Lat_AATS14=data(2,:);
Long_AATS14=data(3,:);
Altitude_AATS14=data(4,:);
p_AATS14=data(5,:);
CWV_AATS14=data(6,:);
O3_AATS14=data(7,:);
AOD_AATS14=data(8:20,:);
AOD_err_AATS14=data(21:33,:);
ext_AATS14=data(34:46,:);
clear data;

