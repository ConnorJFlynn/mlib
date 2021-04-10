function rd_minimpl_raw
% Crack minimpl counts
% Jan 18, 2020
% Not quite done yet.  Reading in an entire raw profile, but not the rest
% of the file.  Plus this doesn't use existing nomenclature for fields. 

fname = ['C:\case_studies\miniMPL_data\202008291000.mpl'];
fid = fopen(fname, 'r');
fseek(fid,0,-1); clear unit
unit  = fread(fid, 1, 'uint16');
sw_version = fread(fid,1,'uint16');
V = fread(fid,6,'uint16');
shots_sum = fread(fid, 1, 'uint32');
prf = fread(fid,1,'int32');
em = fread(fid, 1, 'uint32');
temp0= fread(fid,1,'uint32');temp1= fread(fid,1,'uint32');temp2= fread(fid,1,'uint32');
temp3= fread(fid,1,'uint32');temp4= fread(fid,1,'uint32');
bg_1 = fread(fid, 1, 'float32');
bg_std_1 = fread(fid, 1, 'float32');
N_ch = fread(fid,1,'uint16');
nbins = fread(fid,1,'uint32');
bin_time = fread(fid,1, 'float32');
range_offset = fread(fid,1,'float32');
ndatabins = fread(fid,1,'uint16');
scan_flag = fread(fid,1,'uint16');
N_bg_bins = fread(fid,1,'uint16');

Az_angle = fread(fid,1,'float32');
El_angle = fread(fid,1,'float32');
Compass_deg = fread(fid,1,'float32');
lidar_site = char(fread(fid,6,'uchar'));
wavelength =fread(fid,1,'uint16');
Lat = fread(fid,1,'float32');
Lon = fread(fid,1,'float32');
Alt = fread(fid,1,'float32');
AD_bad_flag = fread(fid,1,'uchar');
DatafileVers = fread(fid,1,'uchar');
bg_2 = fread(fid,1,'float32');
bg_std_2 = fread(fid,1,'float32');
MCS_mode = fread(fid,1,'uchar');
first_bin  = fread(fid,1,'uint16');;
system_type = fread(fid,1,'uchar')
sync_pulse_Hz = fread(fid,1,'uint16');
first_bg_bin  = fread(fid,1,'uint16');
header_size = fread(fid,1,'uint16');



weather_station = fread(fid,1,'uchar');
WS_iat = fread(fid,1,'float32');
WS_oat = fread(fid,1,'float32');
WS_irh = fread(fid,1,'float32');
WS_orh = fread(fid,1,'float32');
WS_Tdew = fread(fid,1,'float32');
WS_wspd = fread(fid,1,'float32');
WS_wdir = fread(fid,1,'short');
WS_pres = fread(fid,1,'float32');
WS_rrate = fread(fid, 1,'float32');
ch_1 = fread(fid,nbins, 'float32');
ch_2 = fread(fid,nbins,'float32');

mark = ftell(fid); 
fseek(fid,mark,-1)

unitN  = fread(fid, 1, 'uint16');
if unit == unitN
    %looks good! so read them all in
end

fclose(fid)