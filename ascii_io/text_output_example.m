%%
smos = ancload;
[pname,fname] = fileparts(smos.fname);

%%
V = datevec(smos.time); % Convert the matlab serial date "time" to an array with columns of year, month, day, hour, minute, and second
yyyy = V(:,1);
mm = V(:,2);
dd = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);
doy = serial2doy(smos.time)';% Also represent time as "day of year"
HHhh = (doy - floor(doy)) *24; % Also represent time in fractional hours

% Arrange the data to be written to file as column vectors: 
txt_out = [yyyy, mm, dd, HH, MM, SS, doy, HHhh, ...
    smos.vars.bar_pres.data',...
    smos.vars.temp.data',...
    smos.vars.rh.data',...
    smos.vars.vap_pres.data',...
    smos.vars.wspd.data',...
    smos.vars.wdir.data',...
    smos.vars.precip.data'];
%
% Define the header row for the resulting text file
header_row = ['yyyy, mm, dd, HH, MM, SS, doy, HHhh, '];
header_row = [header_row, 'atm_pres, TempC, '];
header_row = [header_row, 'RH, vapor_pres, WindSpeed, '];
header_row = [header_row, 'WindDir, Precip'];

% Define the corresponding format string to convert the data in txt_out
% into columns corresponding to the header row
format_str = ['%d, %d, %d, %d, %d, %0.f, %3.6f, %2.4f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f \n'];

% or for tab-separated:
% Define the header row for the resulting text file
% header_row = ['Lat[deg]',9, 'Lon[deg]',9, 'yyyy',9, 'mon',9, 'day',9, 'HH',9, 'MM',9, 'SS',9, ];
% header_row = [header_row, 'SolarZenithAngle[deg]',9, 'SolarAzimuthAngle[deg]',9,];
% header_row = [header_row, 'SolarDistance[au]',9, 'HourAngle[deg]',9, 'Declination[deg]',9,];
% header_row = [header_row, 'SolarElevationAngle',9, 'AirMass'];
% 
% % Define the corresponding format string to convert the data in txt_out
% % into columns corresponding to the header row
% format_str = ['%d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t '];
% format_str = [format_str, '%2.3f \t %2.3f \t '];
% format_str = [format_str, '%2.3f \t %2.3f \t %2.3f \t  '];
% format_str = [format_str, '%2.3f \t %2.3f \n'];

% Open the text file for writing 
fid = fopen([pname, '/', fname, '.txt'],'wt');
% Print the header row to the file
fprintf(fid,'%s \n',header_row );
% Print the column-ordered data to the file
fprintf(fid,format_str,txt_out');
% Close the file
fclose(fid);
%%

