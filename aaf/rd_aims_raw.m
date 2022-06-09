function aims = rd_aims_raw(in_file)
% aims = rd_aims_raw(in_file)
% Reads aims raw csv file and returns time-dimensioned struct
% V 0.1, 2022-05-30, Connor Flynn (in preparation for UAS3 STAP processing

% System_Date,System_Time,Met_Hr,Met_Min,Met_sec,Met_Temp,Met_RH,Met_Press,Met_WindVectN,Met_WindVectE,Met_WindSpeed,Met_WindDir,Aircraft_Hr,Aircraft_Min,Aircraft_Sec,Aircraft_Lat,Aircraft_Long,Aircraft_Alt,Aircraft_VelN,Aircraft_VelE,Aircraft_VelDown,Aircraft_Roll,Aircraft_Pitch,Aircraft_Yaw,Aircraft_TrueAirSpeed,Aircraft_VertWind,Aircraft_SideSlip,Aircraft_AOAPressDiff,Aircraft_SideSlipDiff,WindSolutionStatus,PurgeStatus,GPS1Status,GPS2Status
% 20211109,14:37:26.873,0,0,0,18.32,64.8,98378.0,0.0,0.0,0.0,90.0,0,0,0,0.0,0.0,0,0.0,0.0,0.0,0.0,0.0,0.0,5.18,0.0,0.0,0.0,0.0,0,0,0,0

if ~isavar('in_file')||~isafile(in_file)
    in_file = getfullname('*AIMMS*.csv','aaf_aims');
end
fid = fopen(in_file)

header_line = fgetl(fid); 
header = textscan(header_line,'%s','delimiter',',');header = header{:};
fmt = ['%f  %s ', repmat('%f ',[1,31]),'%*[^\n]'];
AA = textscan(fid,fmt,'delimiter',','); AA;
fclose(fid);

year = floor(AA{1}./10000); year; 
month = rem(AA{1}, 10000); day = rem(month,100); month = floor(month./100);
t1 = datenum(year,month,day);
t2 = datenum(AA{2})-datenum('00:00:00.000');
aims.time = t1+t2;
% fseek(fid,0,-1)
for L = 3:length(header)
label = header{L};
aims.(label) = AA{L};
end

end