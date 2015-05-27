%[day,month,year,UT,data,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,...
%   Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,path,filename]=Ames14_raw('d:\beat\data\');

%opens data file
[filename_NOVA,path_NOVA]=uigetfile('d:\beat\data\ACE-2\Diff_GPS\*.dat','Choose NOVA differential GPS File', 0, 0);
fid_NOVA=fopen([path_NOVA filename_NOVA]);
for i=1:2
  fgetl(fid_NOVA);
end
Nova_data=fscanf(fid_NOVA,'%g',[4,inf]);
fclose(fid_NOVA);

Nova_UT=(Nova_data(1,:)-12)/60/60; % % In the Diff GPS files time is GPS time not UT
Nova_lat =Nova_data(2,:);
Nova_long=Nova_data(3,:);
Nova_alt =Nova_data(4,:);
clear Nova_data


%figure(1)
%subplot(4,1,1)
%plot(UT,Longitude,Nova_UT,Nova_long)
%ylabel('Longitude')
%grid on
%subplot(4,1,3)
%plot(UT,Latitude,Nova_UT,Nova_lat)
%ylabel('Latitude')
%grid on

%figure(2)
%subplot(2,1,1)
%plot(UT,Press_Alt,Nova_UT,Nova_alt/1000)
%ylabel('Altitude [km]')
%grid on
%legend('Pressure Altitude', 'Differential GPS NovaTel')
%axis([14 20 -0.1 5 ])

i=find(UT<=max(Nova_UT) & UT>=min(Nova_UT));
Nova_lat= interp1(Nova_UT,Nova_lat,UT(i));
Nova_long= interp1(Nova_UT,Nova_long,UT(i));
Nova_alt= interp1(Nova_UT,Nova_alt,UT(i));


%figure(1)
%subplot(4,1,2)
%plot(UT(i),Longitude(i)-Nova_long)
%ylabel('Longitude')
%grid on
%subplot(4,1,4)
%plot(UT(i),Latitude(i)-Nova_lat)
%ylabel('Latitude')
%grid on
%figure(2)
%subplot(2,1,2)
%plot(UT(i),Press_Alt(i)-Nova_alt/1000)
%ylabel('Difference [km]')
%grid on
%axis([14 20 -0.7 0.3])



