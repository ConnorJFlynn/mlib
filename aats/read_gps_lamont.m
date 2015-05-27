pathname='d:\Beat\Data\Oklahoma\gps_lamont\version_971105\';
fid=fopen([pathname 'lmno_sio.dat']);
for i=1:10
 fgetl(fid);
end
data=fscanf(fid,'%*s %i %f %2d:%2d:%2d  %f %f %f %f %f %f %f %f %f %f ',[15,inf]);
fclose(fid)
Year_gps_lamont=data(1,:);
DOY_gps_lamont=data(2,:);
Hours_gps_lamont=data(3,:);
Minutes_gps_lamont=data(4,:);
Seconds_gps_lamont=data(5,:);
IPWV_gps_lamont=data(6,:);
Press_gps_lamont=data(7,:);
Temp_gps_lamont=data(8,:);
RH_gps_lamont=data(9,:);
TD_gps_lamont=data(10,:);
WD_gps_lamont=data(11,:);
HD_gps_lamont=data(12,:);
TM_gps_lamont=data(13,:);
PI_gps_lamont=data(14,:);
FErr_gps_lamont=data(15,:);

