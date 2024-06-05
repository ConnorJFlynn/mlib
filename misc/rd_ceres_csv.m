function ceres = rd_ceres_csv

% Col1,Col2,Col3,ID,TIME,PRES,TAIR,TMIN,TMAX,TDEW,RELH,WDIR,WSPD,WMAX,RAIN,SRAD,DATE,YEAR,MONTH,DAY,HOUR,MINUTE,DATES,HOUR_UTC,lon_x,lat_x,DT,DT_UTC,CERES_STID,Overpass_t,DT_CERES,lon_y,lat_y,DIST,INDEX,CERES_lon,CERES_lat,CRS_SRAD,SSF_SRAD,CFRAC
% 81,81,43648,ACME,2019-06-01T13:20,28.63,69,-999,-999,64,83,358,26,35,0.06,128,2019-06-01 13:20:00,2019,6,1,13,20,2019-06-01 13:20:00,19,-98.02325,34.80833,2019-06-01 13:20:00,2019-06-01 19:20:00,ACME,2019-06-01 19:21:00,2019-06-01 19:20:00,-97.904144,34.684235,17.5737674954934,82545,-97.904144,34.684235,465.9,538.2035,0.47111517
infile = getfullname('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\1_xfer _tmp\brad\Aqua_JJA_SSF_CRS.csv','ceres');


fid = fopen(infile,'r');
this = fgetl(fid);
AA = textscan(this, '%s','Delimiter',',');AA=AA{:};
A = textscan(fid, ['%d %d %d %s %s %f %f %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %s %s %s %s %s %f %f %f %f %f %f %f %f %f %*[^\n]'],'delimiter',',');

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
