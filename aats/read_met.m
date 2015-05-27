% Reads meteo data  tf*.met.txt files and optionally compares them with 
% pressure stored in AATS-14 files.

%[day,month,year,UT,data,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,...
%   Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,path,filename]=Ames14_raw('d:\beat\data\');

[met_filename,met_pathname]=uigetfile('d:\beat\data\ACE-2\Meteo\tf*.met.txt','Choose Meteo File', 0, 0);
fid=fopen([met_pathname met_filename]);
for i=1:8
  fgetl(fid);
end

met_data=fscanf(fid,'%g',[4,inf]);
fclose(fid);

%remove double lines so X will be monotonic for interpolation
L=find(diff(met_data(1,:))~=0);
met_data=met_data(:,L);

Met_UT   = mod(met_data(1,:),86400)/60/60;
Met_press= met_data(2,:);
Met_temp = met_data(3,:);

clear met_data

figure(1)
subplot(2,1,1)
plot(UT,Pressure,Met_UT,Met_press)
ylabel('Pressure [hPa]')
grid on
axis([-inf inf -inf inf])
subplot(2,1,2)
plot(Met_UT,Met_temp)
ylabel('Temperature [°C]')
grid on
axis([-inf inf -inf inf])

i=find(UT<=max(Met_UT) & UT>=min(Met_UT));
Met_press= interp1(Met_UT,Met_press,UT(i));
Met_temp= interp1(Met_UT,Met_temp,UT(i));

figure(2)
plot(UT(i),Pressure(i)-Met_press,'.')
ylabel('Press. Diff. [hPa]')
grid on

