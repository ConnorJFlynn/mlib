close all
clear

UT_start=-inf;   
UT_end=inf;     

disp(sprintf('%g-%g UT',UT_start,UT_end))

data_dir='c:\jens\data\ace-asia\';

[day,month,year,UT,UT_GPS,Mean_volts,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,...
   Temperature,Temperature_sd,Az_err,Az_pos,Elev_err,Elev_pos,Elev_pos_sd,Az_pos_sd,Elev_err_sd,...
   Az_err_sd,site,Airmass,AvePeriod,ScanFreq,path,filename,Heading,GPS_Altkm,AmbientTempC]=Ames6_Raw([data_dir '?????01.*']);


%Apply time boundaries
L=(UT>=UT_start & UT<=UT_end);
UT=UT(L);

if(  strcmp(lower(site),'ace-asia') & (julian(day,month, year,0)==julian(8,4,2001,0) |  julian(day,month, year,0)==julian(12,4,2001,0) )  )
        UT_GPS = UT(L);    %set UT_GPS to UT for days without good GPS time in AATS-6 file
    else
        UT_GPS=UT_GPS(L);
end
    
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



if(strcmp(lower(site),'ace-asia'))
    
     
     flight_no_arr = {'RF01' 'RF02' 'RF03' 'RF04' 'RF05' 'RF06' ...
                      'RF07' 'RF08' 'RF09' 'RF10' 'RF11' 'RF12' ...
                      'RF13' 'RF14' 'RF15' 'RF16' 'RF17' 'RF18' 'RF19' };
              
     day_arr = [ julian(31,3,2001,0) julian(2,4,2001,0) julian(4,4,2001,0) julian(6,4,2001,0) julian(8,4,2001,0) julian(11,4,2001,0)...
                 julian(12,4,2001,0) julian(13,4,2001,0) julian(17,4,2001,0) julian(18,4,2001,0) julian(20,4,2001,0) julian(23,4,2001,0)...
                 julian(24,4,2001,0) julian(25,4,2001,0) julian(27,4,2001,0) julian(30,4,2001,0) julian(1,5,2001,0) julian(2,5,2001,0) julian(4,5,2001,0)];
              
         
     p0_arr = [ 1016  1014  1022  1022  1018  1013 ...
                1013  1018  1013  1013  1022  1018 ...
                1013  1018  1018  1015  1013  1013  1013 ];
        
     T0_arr = [ 278  282  284  291  290  288 ...
                282  285  288  288  285  293 ...
                288  290  290  290  288  288  288 ];
         
     flight_no = char(flight_no_arr(find( day_arr == julian(day, month,year,0)))); %char needed because elements of array are cells
             
     fn=deblank(['RAF_' flight_no '.asc']);
     [UT_RAF,GLON,GLAT,GALT,PSFDC,ATX]=read_C130_nav_ascii(fn,flight_no);  %get nav. data routinely from NCAR RAF ASCII file
     
     ii=find(diff(UT_RAF)<0);
     UT_RAF(ii+1:end)=UT_RAF(ii+1:end)+24;
     
     if (strcmp(flight_no,'RF04') | strcmp(flight_no,'RF08'))  %for these days, RAF data file starts on the next day and hence 0<UT_RAF<12 making the interpl. below flunk
         UT_RAF = UT_RAF +24;
     end
     
     if (strcmp(flight_no,'RF07') | strcmp(flight_no,'RF11') | strcmp(flight_no,'RF14') | strcmp(flight_no,'RF16'))   %for these days, RAF data file starts on the previous day and hence 12<UT_RAF<36 making the interpl. below flunk
         UT_RAF = UT_RAF -24;
     end
     
     ii= INTERP1(UT_RAF,1:size(UT_RAF),UT,'nearest', 'extrap');
     
     Pressure=PSFDC(ii)';
     temp=ATX(ii)'+273.15;
     Longitude=GLON(ii)';
     Latitude=GLAT(ii)';
     %r=GALT(ii)'/1000;
     GPS_Alt=GALT(ii)'/1000;
     
     p0 = p0_arr(find( day_arr == julian(day, month,year,0)));
     T0 = T0_arr(find( day_arr == julian(day, month,year,0)));
     
     Press_Alt = T0/6.5*(1-(Pressure/p0).^(1/5.255876114));
     ii= find(Pressure >100 & Pressure <= 226.32);
     Press_Alt(ii) = 11 - 6.34162008 * log(Pressure(ii) / 226.32);
     
 end
     


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
%axis([-inf inf -inf inf])
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

%figure(41)
%worldmap([min(Latitude)-.4,max(Latitude)+0.5],[min(Longitude)-0.4
%max(Longitude)+0.5],'patch')
%plotm(Latitude,Longitude)
%scaleruler on
%set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
%setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
%hidem(gca)


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

%plot times
figure(7)
plot(UT,3600*(UT_GPS-UT))
axis([-inf inf -30 30])
xlabel('UT from PC')
ylabel('UT (sec) GPS-PC')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
grid on



if(strcmp(lower(site),'ace-asia'))
   %alt_smooth=0.999995;
   %new_GPS_Altkm =  csaps(UT,GPS_Altkm,alt_smooth,UT); %


   figure(8)
   subplot(5,1,1)
   plot(UT,GPS_Altkm,'b-')
   hold on
   plot(UT,Press_Alt,'r-',UT,GPS_Alt,'c-')  %GPS_Altkm comes from AATS-6 data file; GPS_Alt comes from RAF ASCII file
   axis([-inf inf 0 6])
   ylabel('Aircraft altitude')
   legend('GPS','PressAlt','GPS ASCII')
   grid on
   subplot(5,1,2)
   plot(UT,(GPS_Alt-GPS_Altkm)*1000,'c-')
   axis([-inf inf -200 200])
   ylabel('GPS ASCII - GPS [m]')
   grid on
   subplot(5,1,3)
   plot(UT,(GPS_Alt-GPS_Altkm)*1000,'c-')
   axis([-inf inf -1500 1500])
   ylabel('GPS ASCII - GPS [m]')
   grid on
   subplot(5,1,4)
   plot(UT,(GPS_Alt-Press_Alt)*1000,'r-')
   axis([-inf inf -200 200])
   ylabel('GPS ASCII - Press. Alt [m]')
   grid on
   subplot(5,1,5)
   plot(UT,(GPS_Alt-Press_Alt)*1000,'r-')
   axis([-inf inf -1500 1500])
   ylabel('GPS ASCII - Press. Alt [m]')
   grid on
   
end

