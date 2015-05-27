function [DOY_Cimel,IPWV_Cimel,AOD_Cimel,lambda_Cimel, Air_Mass_Cimel]=read_Cimel_Lev20(pathname,filename);
% Reads Cimel data
lambda_Cimel=[0.340 0.380 0.440 0.500 0.670 0.870 1.020];
fid=fopen(deblank([pathname filename]));
for i=1:8
  fgetl(fid);
end
 
data=fscanf(fid,'%2d:%2d:%4d, %2d:%2d:%2d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f',[16 inf]);

fclose(fid)
day=data(1,:);
month=data(2,:);
year=data(3,:);
hour=data(4,:);
minute=data(5,:);
second=data(6,:);
time_offset=data(7,:);
AOD_Cimel=data([14,13,12,11,10,9,8],:); %AOT_1020,AOT_870,AOT_670,AOT_500,AOT_440,AOT_380,AOT_340
IPWV_Cimel=data(15,:);
Air_Mass_Cimel=data(16,:);
UT=hour+minute/60+second/60/60;

DOY_Cimel=julian(day,month,year,UT)-julian(31,12,year-1,0);

