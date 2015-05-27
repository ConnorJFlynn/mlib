pathname='d:\Beat\Data\Oklahoma\gps_cf\version_971105\';
fid=fopen([pathname 'sgp0_sio.dat']);
for i=1:10
 fgetl(fid);
end
data=fscanf(fid,'%*s %i %f %2d:%2d:%2d  %f %f %f %f %f %f %f %f %f %f ',[15,inf]);
fclose(fid)
Year_gps_cf=data(1,:);
DOY_gps_cf=data(2,:);
Hours_gps_cf=data(3,:);
Minutes_gps_cf=data(4,:);
Seconds_gps_cf=data(5,:);
IPWV_gps_cf=data(6,:);
Press_gps_cf=data(7,:);
Temp_gps_cf=data(8,:);
RH_gps_cf=data(9,:);
TD_gps_cf=data(10,:);
WD_gps_cf=data(11,:);
HD_gps_cf=data(12,:);
TM_gps_cf=data(13,:);
PI_gps_cf=data(14,:);
FErr_gps_cf=data(15,:);

