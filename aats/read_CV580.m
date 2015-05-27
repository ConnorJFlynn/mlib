function [UT,tans_lat_int,tans_lon_int,tans_alt_int,pstat_int,p_alt]=read_CV580(flight_no);

filename=[flight_no '_pstat.dat'];
pathname='c:\beat\data\SAFARI-2000\UW\pstat\';
fid=fopen([pathname filename]);
[dummy]=fscanf(fid,'Flt %g - %g -%g -%g',4);
flight_no_pstat=dummy(1);
if str2num(flight_no)~=flight_no_pstat
    disp('Flight Numbers don''t match');
end    
year=dummy(2);
month=dummy(3);
day=dummy(4);
fgetl(fid);

fgetl(fid);
fgetl(fid);
[data]=fscanf(fid,'%2d:%2d:%2d %g',[4,inf]);
UT=data(1,:)+data(2,:)/60+data(3,:)/60/60;
pstat=data(4,:);
fclose(fid);

filename=[flight_no '_gps.dat'];
pathname='c:\beat\data\SAFARI-2000\UW\gps\';
fid=fopen([pathname filename]);
[dummy]=fscanf(fid,'Flt %g - %g -%g -%g',4);
flight_no_gps=dummy(1);
if str2num(flight_no)~=flight_no_gps
    disp('Flight Numbers don''t match');
end    
year=dummy(2)
month=dummy(3)
day=dummy(4)
fgetl(fid);
fgetl(fid);
fgetl(fid);

[data]=fscanf(fid,'%2d:%2d:%2d %g %g %g %g %g %g',[9,inf]);
UT=data(1,:)+data(2,:)/60+data(3,:)/60/60;
tans_lat=data(4,:);
tans_lon=data(5,:);
tans_azimth=data(6,:);
tans_roll=data(7,:);
tans_pitch=data(8,:);
tans_alt=data(9,:);
fclose(fid);


 i=find(pstat~=-999.99 & pstat<1100);
 pstat_int=interp1(UT(i),pstat(i),UT,'linear');
 disp(sprintf('%i Pressure readings have been linearly interpolated',size(pstat,2)-size(i,2)))
 
 i=find(tans_lat~=-999.99);
 tans_lat_int=interp1(UT(i),tans_lat(i),UT,'linear');
 disp(sprintf('%i Latitude readings have been linearly interpolated',size(pstat,2)-size(i,2)))

 i=find(tans_lon~=-999.99);
 tans_lon_int=interp1(UT(i),tans_lon(i),UT,'linear');
 disp(sprintf('%i Longitude readings have been linearly interpolated',size(pstat,2)-size(i,2)))

 i=find(tans_alt~=-999.99);
 tans_alt_int=interp1(UT(i),tans_alt(i),UT,'linear');
 disp(sprintf('%i altitude readings have been linearly interpolated',size(pstat,2)-size(i,2)))
 
 %Pressure Altitude according to J. Livingston
 %Pressure > 226.32 & Pressure<1100   
  p0=1013.25 % Standard Atmosphere
  T0=288.15
 
if (day==14 & month==8 & year==2000)
    p0=1027;  %SAFARI Aug 14, 2000
    T0=298;   %SAFARI Aug 14, 2000
end
if strcmp(flight_no,'1812')
    p0=1027;  %SAFARI Aug 14, 2000
    T0=300;   %SAFARI Aug 14, 2000
end
if strcmp(flight_no,'1814')
    p0=1030;  %SAFARI Aug 15, 2000
    T0=298;   %SAFARI Aug 15, 2000
end
 if (day==17 & month==8 & year==2000)
     p0=1020;  %SAFARI Aug 17, 2000
     T0=302;   %SAFARI Aug 17, 2000
 end
 if (day==18 & month==8 & year==2000)
  p0=1020;  %SAFARI Aug 18, 2000
  T0=302;   %SAFARI Aug 18, 2000
 end
 if strcmp(flight_no,'1818')
    p0=1022;  %SAFARI Aug 20, 2000
    T0=300;   %SAFARI Aug 20, 2000
 end
 if (day==20 & month==8 & year==2000)
    p0=1022;  %SAFARI Aug 20, 2000
    T0=300;   %SAFARI Aug 20, 2000
end
 if (day==22 & month==8 & year==2000)
     p0=1018;  %SAFARI Aug 22, 2000
     T0=302;   %SAFARI Aug 22, 2000
 end
 if (day==23 & month==8 & year==2000)
    p0=1020;  %SAFARI Aug 23, 2000
    T0=302;   %SAFARI Aug 23, 2000
 end
 if (day==24 & month==8 & year==2000)
     p0=1025;  %SAFARI Aug 24, 2000
     T0=299;   %SAFARI Aug 24, 2000
 end
if strcmp(flight_no,'1823')
    p0=1017;  %SAFARI Aug 29, 2000
    T0=304;   %SAFARI Aug 29, 2000
end
if strcmp(flight_no,'1824')
    p0=1017;  %SAFARI Aug 29, 2000
    T0=304;   %SAFARI Aug 29, 2000
end
 if (day==31 & month==8 & year==2000)
    p0=1013;  %SAFARI Aug 31, 2000
    T0=303;   %SAFARI Aug 31, 2000
 end
 if (day==1 & month==9 & year==2000)
     p0=1015;  %SAFARI Sep 1, 2000
     T0=305;   %SAFARI Sep 1, 2000
 end
 if (day==2 & month==9 & year==2000)
    p0=1013;  %SAFARI Sep 2, 2000
    T0=306;   %SAFARI Sep 2, 2000
 end
 if (day==3 & month==9 & year==2000)
     p0=1010;  %SAFARI Sep 3, 2000
     T0=306;   %SAFARI Sep 3, 2000
 end
 if (day==5 & month==9 & year==2000)
    p0=1009;  %SAFARI Sep 5, 2000
    T0=308;   %SAFARI Sep 5, 2000
 end
 if (day==6 & month==9 & year==2000)
     p0=1010;  %SAFARI Sep 6, 2000
     T0=308;   %SAFARI Sep 6, 2000
 end
 if (day==7 & month==9 & year==2000)
     p0=1014;  %SAFARI Sep 7, 2000
     T0=301;   %SAFARI Sep 7, 2000
 end
 if (day==11 & month==9 & year==2000)
     p0=1015;  %SAFARI Sep 11, 2000
     T0=307;   %SAFARI Sep 11, 2000
 end
 if (day==13 & month==9 & year==2000)
     p0=1017;  %SAFARI Sep 13, 2000
     T0=302;   %SAFARI Sep 13, 2000
 end
 if (day==14 & month==9 & year==2000)
     p0=1025;  %SAFARI Sep 14, 2000
     T0=287;   %SAFARI Sep 14, 2000
 end
 if (day==16 & month==9 & year==2000)
     p0=1016;  %SAFARI Sep 16, 2000
     T0=302;   %SAFARI Sep 16, 2000
 end
p_alt = T0/6.5*(1-(pstat_int/p0).^(1/5.255876114));
ii= find(pstat_int>100 & pstat_int <= 226.32);
p_alt(ii) = 11 - 6.34162008 * log(pstat_int(ii) / 226.32);
p_alt=p_alt*1000;

figure(21)
subplot(4,1,1)
plot(UT,tans_lat,UT,tans_lat_int,'r')
ylabel('Latitude(\circ)')
set(gca,'ylim',[-30 -10])
title(sprintf('%s %g %4d-%02d-%02d', 'UW Flight', flight_no_pstat,year,month,day))
subplot(4,1,2)
plot(UT,tans_lon,UT,tans_lon_int,'r')
ylabel('Longitude(\circ)')
set(gca,'ylim',[20 35])
subplot(4,1,3)
plot(UT,tans_alt,UT,tans_alt_int,'r',UT,p_alt);
legend('GPS alt','GPS alt int', 'P alt')
ylabel('Altitude(m)')
set(gca,'ylim',[-100 5500])
subplot(4,1,4)
plot(UT,tans_alt_int-p_alt,'r')
ylabel('Difference(m)')
set(gca,'ylim',[-200 200])
grid on

figure(22)
subplot(3,1,1)
plot(UT,tans_azimth);
ylabel('Azim(\circ)')
title(sprintf('%s %g %4d-%02d-%02d', 'UW Flight', flight_no_pstat,year,month,day))
set(gca,'ylim',[0 360])
subplot(3,1,2)
plot(UT,tans_roll);
set(gca,'ylim',[-45 45])
ylabel('Roll(\circ)')
subplot(3,1,3)
plot(UT,tans_pitch);
set(gca,'ylim',[-15 15])
ylabel('Pitch(\circ)')
