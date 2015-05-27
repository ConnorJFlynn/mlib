%Reads Santiagos new format

%[day,month,year,UT,data,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,...
%   Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,path,filename]=Ames14_raw('d:\beat\data\');

%opens data file
[filename_UW,path_UW]=uigetfile('d:\beat\data\ACE-2\UW\*.*','Choose UW File', 0, 0);
fid_UW=fopen([path_UW filename_UW]);
 UW_data=fscanf(fid_UW,'%g',[23,inf]);
fclose(fid_UW)
UW_press1=UW_data(15,:);
UW_press2=UW_data(21,:);
UW_UT=UW_data(5,:)+UW_data(6,:)/60+UW_data(7,:)/3600;

%figure(4)
%subplot(2,1,1)
%plot(UT,Pressure,UW_UT,UW_press1);
%xlabel('UT')
%ylabel('Pressure [hPa]')
%grid on


i=find(UT<=max(UW_UT) & UT>=min(UW_UT));
UW_press1=interp1(UW_UT,UW_press1,UT(i));

%figure(4)
%subplot(2,1,2)
%plot(UT(i),UW_press1-Pressure(i),'.');
%xlabel('UT')
%ylabel('UW-Pelican')


%figure(5)
%[p,S] = polyfit (Pressure(i),UW_press1,1)
%[y_fit,delta] = polyval(p,Pressure(i),S);
%plot(Pressure(i),UW_press1,'.',Pressure(i),y_fit);
%grid on
%xlabel('CIRPAS Pressure [hPa]')
%ylabel('UW Pressure [hPa]')





