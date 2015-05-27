close all
clear

UT_start=-inf;
UT_end=inf;
disp(sprintf('%g-%g UT',UT_start,UT_end))

data_dir='c:\beat\data\Ace-asia\';

[day,month,year,UT,UT_GPS,Mean_volts,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,...
      Temperature,Temperature_sd,Az_err,Az_pos,Elev_err,Elev_pos,Elev_pos_sd,Az_pos_sd,Elev_err_sd,...
      Az_err_sd,site,Airmass,AvePeriod,ScanFreq,path,filename,Heading,GPS_Altkm,AmbientTempC]=Ames6_Raw([data_dir '?????01.*']);

%Apply time boundaries
L=(UT>=UT_start & UT<=UT_end);
UT=UT(L);
UT_GPS=UT_GPS(L);
Mean_volts=Mean_volts(:,L);
Sd_volts=Sd_volts(:,L);
Pressure=Pressure(:,L);
Press_Alt=Press_Alt(L);
Latitude=Latitude(L);
Longitude=Longitude(L);
Temperature=Temperature(:,L);
Temperature_sd=Temperature_sd(:,L);
Az_err=Az_err(L);
Az_pos=Az_pos(L);
Elev_err=Elev_err(L);
Elev_pos=Elev_pos(L);
Airmass=Airmass(L);
AvePerio=AvePeriod(L);
ScanFreq=ScanFreq(L);
Heading=Heading(L);
GPS_Altkm=GPS_Altkm(L);
AmbientTempC=AmbientTempC(L);


figure(1)
orient landscape
subplot(6,1,1)
plot(UT,Mean_volts)
axis([-inf inf 0 5])
ylabel('Signals (V)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend('380','451','525','864', '941', '1020')

subplot(6,1,2)
plot(UT,Sd_volts./Mean_volts*100)
axis([-inf inf 0 50])
ylabel('Stdev (%)')

subplot(6,1,3)
plot(UT,Airmass)
axis([-inf inf -inf inf])
ylabel('Airmass')

subplot(6,1,4)
plot(UT,Temperature([1:2],:))
axis([-inf inf 44 49])
ylabel('Temp(°C)')

subplot(6,1,5)
plot(UT,Temperature([3:5],:))
axis([-inf inf -inf inf])
ylabel('Temp(°C)')

subplot(6,1,6)
plot(UT,Pressure)
axis([-inf inf -inf inf])
ylabel('Pressure [hPa]')
xlabel('UT')

%subplot(6,1,6)
%plot(UT,Press_Alt,UT,GPS_Altkm)
%axis([-inf inf -inf inf])
%ylabel('P Altitude [hPa]')
%xlabel('UT')

figure(2)
orient landscape
subplot(6,1,1)
plot(UT,Az_pos)
%axis([-inf inf -inf inf])
ylabel('Azimuth(°)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));

subplot(6,1,2)
plot(UT,Elev_pos)
%axis([-inf inf -inf inf])
ylabel('Elevation (°)')

subplot(6,1,3)
plot(UT,Az_err)
%axis([-inf inf -inf inf])
ylabel('Az Err (°)')

subplot(6,1,4)
plot(UT,Elev_err)
%axis([-inf inf -inf inf])
ylabel('Ele Err (°)')
xlabel('UT')

subplot(6,1,5)
plot(UT,Latitude)
%axis([-inf inf -inf inf])
ylabel('Latitude (°)')
xlabel('UT')

subplot(6,1,6)
plot(UT,Longitude)
%axis([-inf inf -inf inf])
ylabel('Longitude(°)')
xlabel('UT')

figure(3)
orient landscape
subplot(1,2,1)
plot3(Longitude,Latitude,Press_Alt)
xlabel('Longitude')
ylabel('Latitude')
zlabel('Altitude (km)')
grid on
axis([-inf inf -inf inf -inf inf])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));

subplot(1,2,2)
plot(Longitude,Latitude)
xlabel('Longitude')
ylabel('Latitude')
grid on
axis([min(Longitude)-0.1 max(Longitude)+0.1 min(Latitude)-0.1 max(Latitude)+0.1])

figure(41)
worldmap([min(Latitude)-0.4,max(Latitude)+1],[min(Longitude)-0.4 max(Longitude)+1],'patch')
plotm(Latitude,Longitude)
scaleruler on
set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
hidem(gca)


figure(4)
%plot dark currents
plot(UT,Mean_volts)
axis([-inf inf -0.01 0.01])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
ylabel('Signals (V)')
xlabel('UT')
legend('380','451','525','864', '941', '1020')
grid on

figure(5)
orient landscape
subplot(6,1,1)
hold on
plot(UT,Sd_volts(1,:),'.')
axis([-inf inf 0 0.01])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
ylabel('Signals (V)')
legend('380')

subplot(6,1,2)
plot(UT,Sd_volts(2,:),'.')
axis([-inf inf 0 0.01])
ylabel('Signals (V)')
legend('451')

subplot(6,1,3)
plot(UT,Sd_volts(3,:),'.')
axis([-inf inf 0 0.01])
ylabel('Signals (V)')
legend('525')

subplot(6,1,4)
plot(UT,Sd_volts(4,:),'.')
axis([-inf inf 0 0.01])
ylabel('Signals (V)')
legend('864')

subplot(6,1,5)
plot(UT,Sd_volts(5,:),'.')
axis([-inf inf 0 0.01])
ylabel('Signals (V)')
legend('941')

subplot(6,1,6)
plot(UT,Sd_volts(6,:),'.')
axis([-inf inf 0 0.01])
ylabel('Signals (V)')
legend('1020')

% compute the solar position is optional here
[Az_Sun, Elev_Sun]=sun(Longitude,Latitude,day, month, year, UT,ones(1,length(UT))*293,Pressure);

%plot elevation
figure(6)
orient landscape
subplot(4,1,1)
plot(UT,Elev_pos,UT,Elev_Sun)
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
ylabel('Elevation (°)')
legend('AATS-6','Sun')
set(gca,'ylim',[-inf inf])
%set(gca,'xlim',[16 22])
grid on

subplot(4,1,2)
plot(UT,Elev_Sun-Elev_pos)
ylabel('Difference (°)')
set(gca,'ylim',[-10 10])
%set(gca,'xlim',[16 22])
grid on

subplot(4,1,3)
plot(UT,mod(Az_pos+Heading,360),UT,Az_Sun)
legend('AATS-6','Sun')
ylabel('Azimuth (°)')
%set(gca,'xlim',[16 22])
grid on

subplot(4,1,4)
plot(UT,mod(Az_pos+Heading,360)-Az_Sun)
ylabel('Difference (°)')
%set(gca,'ylim',[-10 10])
grid on

figure(8)
subplot(3,1,1)
plot(UT,GPS_Altkm,'b-',UT,Press_Alt,'r-')
%axis([-inf inf 0 6])
ylabel('Aircraft altitude')
legend('GPS','PressAlt')
grid on

subplot(3,1,2)
plot(UT,GPS_Altkm-Press_Alt,'r-')
set (gca,'ylim',[-0.2 0.2])
ylabel('GPS-Press')
grid on

subplot(3,1,3)
plot(UT,AmbientTempC)
%axis([-inf inf -inf inf])
ylabel('Ambient Temp (C)')
xlabel('UT')
grid on

%plot times
figure(7)
plot(UT,3600*(UT_GPS-UT))
axis([-inf inf -30 30])
xlabel('UT from PC')
ylabel('UT (sec) GPS-PC')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
grid on
