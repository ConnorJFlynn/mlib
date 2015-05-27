function [DOY_Cimel,IPWV_Cimel,AOD_Cimel,lambda_Cimel]=read_Cimel;
% Reads Cimel data
lambda_Cimel=[0.340 0.380 0.440 0.500 0.673 0.870 1.019];
pathname='c:\Beat\Data\Oklahoma\WVIOP2\Cimel\version_980108\';
filename='cimel.prn' 
fid=fopen(deblank([pathname filename]));
for i=1:8
  fgetl(fid);
end
 
data=fscanf(fid,'%2d-%2d-%2d %2d:%2d:%2d %f %f %f %f %f %f %f %f %f',[15 inf]);
day=data(1,:);
month=data(2,:);
year=data(3,:)+1900;
hour=data(4,:);
minute=data(5,:);
second=data(6,:);
SZA_Cimel=data(7,:);
AOD_Cimel=data([14,13,11,12,10,9,8],:); %lambda_Cimel=[1.019 0.870 0.673 0.440 0.500 0.380 0.340];
IPWV_Cimel=data(15,:);
UT=hour+minute/60+second/60/60;

DOY_Cimel=julian(day,month,year,UT)-julian(31,12,1996,0);

i=find(diff(DOY_Cimel)~=0); %remove duplicate times
DOY_Cimel=DOY_Cimel(i);
IPWV_Cimel=IPWV_Cimel(i);
AOD_Cimel=AOD_Cimel(:,i);

