function [DOY_Cimel,IPWV_Cimel,SZA_Cimel]=read_Cimel_H2O;

% Reads Cimel data
pathname='d:\Beat\Data\Oklahoma\Cimel\version_20000505\';
%filename='CART_SITE_97_WV_LOWTRAN' 
filename='CART_SITE_97_WV_LBLRTM' 
fid=fopen(deblank([pathname filename]));
for i=1:7
  fgetl(fid);
end

%Date, Time, Julian Day(float),Julian Day(integer),Solar Zenit Angle, Water Vapor (cm)
data=fscanf(fid,'%2d-%2d-%4d,%2d:%2d:%2d,%f,%i,%f,%f',[10 inf]);
fclose(fid)

day=data(1,:);
month=data(2,:);
year=data(3,:);
hour=data(4,:);
minute=data(5,:);
second=data(6,:);
DOY_Cimel=data(7,:)+1;
JD_int=data(8,:);
SZA_Cimel=data(9,:);
IPWV_Cimel=data(10,:);

%i=find(diff(DOY_Cimel)~=0);
%DOY_Cimel=DOY_Cimel(i);
%IPWV_Cimel=IPWV_Cimel(i);

