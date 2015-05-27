[filename,pathname]=uigetfile('d:\beat\data\ACE-2\UW\','Choose H2O density file', 0, 0);
fid=fopen([pathname filename]);
  fgetl(fid);
data=fscanf(fid,'%g',[5,inf]);
UT_UW   = mod(data(1,:),86400)/60/60;
Press_UW=data(2,:);
Altitude_UW=data(3,:);
CWV_UW=data(4,:);
H2O_Dens_UW=data(5,:);

fclose(fid);
figure(1)
subplot(3,1,1)
plot(UT_UW,Press_UW)
subplot(3,1,2)
plot(UT_UW,Altitude_UW)
subplot(3,1,3)
plot(UT_UW,H2O_Dens_UW)

