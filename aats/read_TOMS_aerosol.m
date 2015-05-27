function []=read_TOMS_aerosol(day,month,year,geog_lat,geog_long);

%Reads TOMS aerosol file provided by Omar Torres
filename='c:\beat\data\SAFARI-2000\TOMS\saf2000_eptoms_new.dat'
fid=fopen(filename);
for i=1:2
   fgetl(fid);
end
data=fscanf(fid,'%f',[12 inf]);
fclose(fid);

jul_day=data(1,:);

jul_day_seek=julian(day,month,year,0)-julian(31,12,1999,0);
ii=find(jul_day==jul_day_seek);

jul_day=data(1,ii);
TOMS_UT=data(2,ii)/3600;
TOMS_lat=data(3,ii);
TOMS_long=data(4,ii);
press_terr=data(5,ii);
A=data(6,ii);
sfc_ref=data(7,ii);
pix_ref=data(8,ii);
AI=data(9,ii);
aer_hgt=data(10,ii);
AOD=data(11,ii);
SSA=data(12,ii);


rng=distance(ones(1,length(TOMS_lat))*geog_lat,ones(1,length(TOMS_long))*geog_long,TOMS_lat,TOMS_long);
rng=deg2km(rng);

figure(1)
subplot(1,2,1)
plot(TOMS_UT,rng,'o')
grid on
xlabel('UT')
ylabel('Distance')
subplot(1,2,2)
plot(TOMS_long,TOMS_lat,'o',geog_long, geog_lat,'o')
grid on
xlabel('Longitude')
ylabel('Latitude')

[min_rng,ii]=min(rng)

jul_day=jul_day(ii)
TOMS_UT=TOMS_UT(ii)
TOMS_lat=TOMS_lat(ii)
TOMS_long=TOMS_long(ii)
press_terr=press_terr(ii)
A=A(ii)
sfc_ref=sfc_ref(ii)
pix_ref=pix_ref(ii)
AI=AI(ii)
aer_hgt=aer_hgt(ii)
AOD=AOD(ii)
SSA=SSA(ii)
