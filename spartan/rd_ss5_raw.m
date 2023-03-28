function out = rd_ss5_raw(infile);
% out = rd_ss5_raw(infile); 
% Reads a supplied or selected Air Photon SS05 raw hk file
% Written by Connor Flynn, OU, 2023-03-03, 
% TBD: make recursive to bundle multiple selected files.

if ~isavar('infile')||~isafile(infile)
   infile = getfullname('FC*.csv','ss5','Select SS5 Filter Cartridge FC raw csv file.');
end

fid = fopen(infile,'r');
SN_line = fgetl(fid);
FIRMWARE_line = fgetl(fid); out.firmware = sscanf(FIRMWARE_line, 'FIRMWARE: %s')
START_line = fgetl(fid);
SETTINGS_line = fgetl(fid); out.setting_string = sscanf(SETTINGS_line, 'SETTINGS: %s %s');
CARTRIDGE_line = fgetl(fid); out.cartridge = sscanf(CARTRIDGE_line, 'CARTRIDGE: %d');
FILTER_line = fgetl(fid); out.filter = sscanf(FILTER_line, 'FILTER: %d %d')';

header = fgetl(fid); header;
head_str = textscan(header,'%s','Delimiter',',');head_str = head_str{1};
fmt_str = ['SS%f %s ',repmat('%f ',[1,22]), '%s'];
A = textscan(fid,fmt_str,'Delimiter',',');
fclose(fid);
out.SN = A{1};
out.time = datenum(A{2},'yyyy-mm-ddTHH:MM:SS');

for col=9:25
   out.(head_str{col}) = A{col};
end

figure; sb(1) = subplot(3,1,1); plot(out.time, out.TEMP_C, 'x'); ylabel('Deg C'); legend('Temp C'); dynamicDateTicks
sb(2) = subplot(3,1,2); plot(out.time, out.FLOW_A_LPM, 'o',out.time, out.FLOW_B_LPM,'+'); dynamicDateTicks; ylabel('LPM'); legend('Flow A','Flow B')
sb(3) = subplot(3,1,3); plot(out.time, out.VACUUM_A_KPA, 'o',out.time, out.VACUUM_B_KPA,'+'); dynamicDateTicks; ylabel('kPa'); legend('Vac A','Vac B')
linkaxes(sb,'x');
end
