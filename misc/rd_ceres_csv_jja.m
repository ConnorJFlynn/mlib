function ceres = rd_ceres_jja_csv

%N, Unnamed,Unnamed0,STID,TIME,PRES,TAIR,TMIN,TMAX,TDEW,RELH,WDIR,WSPD,WMAX,RAIN,SRAD_x,DATE,YEAR,MONTH,DAY,HOUR,MINUTE,DATES,HOUR_UTC,lon_x,lat_x,DT,DT_UTC,CERES_STID,DT_CERES,lon_y,lat_y,DIST,INDEX,SRAD_y,CFRAC,Year,SRAD_Diff,Station_Number,stid,cdiv,Month,SAT,z_score
%50,50,45665,ACME,2019-06-08T13:25,28.5,85,-999,-999,65,50,144,3,8,0.0,933,2019-06-08 13:25:00,2019,6,8,13,25,2019-06-08 13:25:00,19,-98.02325,34.80833,2019-06-08 13:25:00,2019-06-08 19:25:00,ACME,2019-06-08 19:25:00,-98.00751,34.783024,3.1598108397551137,86419,963.86334,37.0,2019,30.863339999999994,1,ACME,Central,6,Aqua,0.24520212665152616
                 
%f %f %f %s %s %f %f %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %s %s %s %s %f %f %f %f %f %f %f %f %f %s %s %f %s %f
infile = getfullname('E:\case_studies\lamkin\Aqua_jja.csv','ceres')
fid = fopen(infile,'r');
this = fgetl(fid);
AA = textscan(this, '%s','Delimiter',',');AA=AA{:};
A = textscan(fid, ['%f %f %f %s %s %f %f %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %s %s %s %s %f %f %f %f %f %f %f %f %f %s %s %f %s %f' ' %*[^\n]'],'delimiter',',');

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
