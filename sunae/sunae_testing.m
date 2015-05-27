% Oliktok
nox = datenum(2010,10,24) + [0:.01:21]; % Defining a time series spanning the March 21, equinox.
ae.zen = []; ae.az = []; ae.soldst = []; ae.ha = []; ae.dec = []; ae.el = []; ae.am = [];
ae_temp = ae;
%
lat = 70.51028;
lon = -149.86;

[ae.zen, ae.az, ae.soldst, ae.ha, ae.dec, ae.el, ae.am]=sunae(lat,lon,nox); 

figure; 
s(1) = subplot(2,1,1); plot(serial2doy(nox), 90-ae.zen, '.-')
title('Solar elevation angle and airmass for Oliktok, Oct 24-Nov 14 2010');
ylabel('degrees');
legend('Solar elevation angle');
s(2) = subplot(2,1,2); plot(serial2doy(nox), ae.am, 'r.-')
title(['Oliktok Lat:',sprintf('%3.3f ',lat), ' Long:',sprintf('%3.3f',lon)]);
ylabel('airmass');
xlabel('day of year (Oct 27 = 300, Nov 11 = 315)');
legend('airmass');
linkaxes(s,'x');
%%
  figure; pl = plot(serial2doy(nox),[ae_15.zen;ae_30.zen;ae_45.zen;ae_60.zen;ae_75.zen],'.-'); lg = legend('15','30','45','60','75');

%
V = datevec(nox); % Convert the matlab serial date "time" to an array with columns of year, month, day, hour, minute, and second
yyyy = V(:,1);
mon = V(:,2);
day = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);

doy = serial2doy(nox)';% Also represent time as "day of year"
HHhh = (doy - floor(doy)) *24; % Also represent time in fractional hours
%

% Arrange the data to be written to file as column vectors: 
txt_out = [lat.*ones([length(nox),1]), lon.*ones([length(nox),1]), yyyy, mon,day, HH, MM,round(SS), ...
    ae.zen',...
    ae.az',...
    ae.soldst',...
    ae.ha',...
    ae.dec',...
    ae.el',...
    ae.am'];
 %
 
%
%
% Define the header row for the resulting text file
header_row = ['Lat[deg]',9, 'Lon[deg]',9, 'yyyy',9, 'mon',9, 'day',9, 'HH',9, 'MM',9, 'SS',9, ];
header_row = [header_row, 'SolarZenithAngle[deg]',9, 'SolarAzimuthAngle[deg]',9,];
header_row = [header_row, 'SolarDistance[au]',9, 'HourAngle[deg]',9, 'Declination[deg]',9,];
header_row = [header_row, 'SolarElevationAngle',9, 'AirMass'];

% Define the corresponding format string to convert the data in txt_out
% into columns corresponding to the header row
format_str = ['%d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t '];
format_str = [format_str, '%2.7f \t %2.7f \t '];
format_str = [format_str, '%2.7f \t %2.7f \t %2.7f \t  '];
format_str = [format_str, '%2.7f \t %2.7f \n'];
%

% Open the text file for writing 
pname = ['C:\case_studies\ARRA\SAS\sw_testing\sunae_port\'];
fname = ['Lat',num2str(lat),'deg_Lon',num2str(lon),'deg.',datestr(floor(nox(1)),'yyyymmdd.'),datestr(ceil(nox(end)),'yyyymmdd.'),'txt'];
fid = fopen([pname, '/', fname],'wt');
% Print the header row to the file
fprintf(fid,'%s \n',header_row );
% Print the column-ordered data to the file
fprintf(fid,format_str,txt_out');
% Close the file
fclose(fid)
