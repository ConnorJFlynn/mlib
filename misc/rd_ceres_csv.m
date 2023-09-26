function ceres = rd_ceres_csv

% N,Unnamed,STID,TIME,PRES,TAIR,TMIN,TMAX,TDEW,RELH,WDIR,WSPD,WMAX,RAIN,SRAD_x,DATE,YEAR,MONTH,DAY,HOUR,MINUTE,DATES,HOUR_UTC,lon_x,lat_x,
% DT,DT_UTC,CERES_STID,DT_CERES,lon_y,lat_y,DIST,INDEX,SRAD_y,CFRAC,Year
% 0,1326,ACME,2019-01-05T14:30,28.64,63,-999,-999,40,42,163,7,9,0.4,482,2019-01-05 14:30:00,2019,1,5,14,30,2019-01-05 14:30:00,20,-98.02325,34.80833
%DT,DT_UTC,CERES_STID,DT_CERES,lon_y,lat_y,DIST,INDEX,SRAD_y,CFRAC,Year
% ,2019-01-05 14:30:00,2019-01-05 20:30:00,ACME,2019-01-05 20:30:00,-98.15427,34.820324,12.034709476408429,2486,480.0627,38.0,2019
infile = getfullname('C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\Aqua_Joined_CORR.csv','ceres');


fid = fopen(infile,'r');
this = fgetl(fid);
AA = textscan(this, '%s','Delimiter',',');AA=AA{:};
A = textscan(fid, ['%d %d %d %s %s %f %f %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %s %s %s %s %f %f %f %f %f %f %f %s %s %s %s %f %f %f %f %f %f %f %*[^\n]'],'delimiter',',');

fclose(fid)

for lab = 1:length(AA)
   ceres.(AA{lab}) = A{lab};
end

end

% infile = getfullname('C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\Amazing.csv','ceres');

% 
% fid = fopen(infile,'r');
% this = fgetl(fid);
% AA = textscan(this, '%s','Delimiter',',');AA=AA{:};
% A = textscan(fid, ['%d %d %d %s %s %f %f %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %s %s %s %s %f %f %f %f %f %f %f' ' %*[^\n]'],'delimiter',',');
