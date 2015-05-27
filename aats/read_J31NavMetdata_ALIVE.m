function [UT,RH, h2o_dens]=read_J31NavMetdata_ALIVE(day,month,year)

% HEADER (AMES)
% checksum
% date
% time
% latitude (deg)
% longitude (deg)
% pitch (deg)
% roll (deg)
% heading (deg)
% altitude (m)
% static pressure (adjusted) (hPa)
% static temperature (adjusted) (deg C)
% relative humidity (%) (adjusted)
% track (deg)
% speed (km/hr)
% pressure2 (wing) (total p, hPa)
% water vapor density (g/m3)
% temperature (total temperature deg C)
% TAIL (Ames)

pathname='c:\beat\data\ALIVE\NavMet\Processed\';
filename=[num2str(year) sprintf('%02d',month) sprintf('%02d',day) '_Navmet_rewrite.txt']
fid=fopen([pathname filename]);
[datain]=fscanf(fid,'AMES %d %2d/%2d/%2d %2d:%2d:%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f AMES\r\n',[21,inf]);
UT=datain(5,:)+datain(6,:)/60.+datain(7,:)/3600.;

%find data on the same second
ii=find(diff(UT)~=0);
UT=UT(ii);

lat=datain(8,:);
lon=datain(9,:);
pitch=datain(10,:);
roll=datain(11,:);
heading=datain(12,:);
GPSkm=datain(13,:)/1000;
Pstat=datain(14,:);
TempCstat=datain(15,:);
RH=datain(16,ii); %corrected RH
track=datain(17,:);
speed=datain(18,:);
Ptot=datain(19,:); %total
h2o_dens=datain(20,ii); 
TempCtot=datain(21,:);

fclose(fid);