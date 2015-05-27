function [O3_col,Aero_Index]=read_TOMS_ovp(filename,day,month,year);

%Reads TOMS overpass O3 data file

fid=fopen(filename);
for i=1:4
   fgetl(fid);
end
data=fscanf(fid,'%f',[14 inf]);
fclose(fid);

MJD=data(1,:);
Year=data(2,:);
Day=data(3,:);
sec_UT=data(4,:);
SCN=data(5,:);
LAT=data(6,:);
LON=data(7,:);
DIS=data(8,:);
PT=data(9,:);
SZA=data(10,:);
OZONE=data(11,:);
REF=data(12,:);
A_I=data(13,:);
SOI=data(14,:);

MJD_seek=julian(day,month,year,12)-2400000.5;

N=length(MJD);
Y= 1:N;
YI=interp1(MJD,Y,MJD_seek,'nearest');
O3_col=OZONE(YI);
AeroIndex=A_I(YI);

d=datestr(datenum(Year(YI),0,0)+Day(YI));
sprintf('%s %g %s %s %g %s %s %g %s %s %g %s','found O3=',O3_col,'DU','Aerosol Index=',AeroIndex,' on',d,sec_UT(YI)/3600,'UT','at a distance of ',DIS(YI),'km')


%figure (1)
%plot(MJD,OZONE,'.')
%figure(2)
%plot(MJD,A_I,'.');
