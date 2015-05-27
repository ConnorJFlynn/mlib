% reads UW scattering profile
% Time(secs)      Press(mb)      Altitude(m)       DRY_scat      AMB_scat

lambda_UW=[550]/1e3;

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\UW\','Choose UW scattering profile', 0, 0);
fid=fopen([pathname filename]);
fgetl(fid);
data=fscanf(fid,'%g',[5,inf]);

UT_UW   = mod(data(1,:),86400)/60/60;
Press_UW=data(2,:);
Altitude_UW=data(3,:);
DRY_scat=data(4,:);
AMB_scat=data(5,:);

fclose(fid);

figure(1)
subplot(3,1,1)
plot(UT_UW,Press_UW)
subplot(3,1,2)
plot(UT_UW,Altitude_UW)
subplot(3,1,3)
plot(UT_UW,AMB_scat)

i=find(UT<=max(UT_UW) & UT>=min(UT_UW));
DRY_scat= interp1(UT_UW,DRY_scat,UT(i));
AMB_scat= interp1(UT_UW,AMB_scat,UT(i));