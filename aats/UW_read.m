%Reads Santiagos old format

[day,month,year,UT,data,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,...
   Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,path,filename]=Ames14_raw('d:\beat\data\');

%opens data file
[filename,path]=uigetfile('d:\beat\data\ACE-2\others\','Choose UW File', 0, 0);
fid=fopen([path filename]);
UW_data=fscanf(fid,'%g',[18,inf]);
fclose(fid)
UW_press1=UW_data(10,:);
UW_press2=UW_data(16,:);
UW_UT=mod(UW_data(2,:),86400)/60/60;

figure(4)
subplot(2,1,1)
plot(UT,Pressure,UW_UT,UW_press1);
xlabel('UT')
ylabel('Pressure [hPa]')
grid on


i=find(UT<=max(UW_UT) & UT>=min(UW_UT));
UW_press1=interp1(UW_UT,UW_press1,UT(i));

figure(4)
subplot(2,1,2)
plot(UT(i),UW_press1-Pressure(i),'.');
xlabel('UT')
ylabel('UW-Pelican')


%figure(5)
%[p,S] = polyfit (Pressure(i),UW_press1,1)
%[y_fit,delta] = polyval(p,Pressure(i),S);
%plot(Pressure(i),UW_press1,'.',Pressure(i),y_fit);
%grid on
%xlabel('CIRPAS Pressure [hPa]')
%ylabel('UW Pressure [hPa]')




