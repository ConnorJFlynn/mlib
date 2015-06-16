function hsrl=hsrlread(h5file, vars)

% reads HSRL data from an h5 file.
% 
% Example
% h5file=fullfile(starpaths, 'download','20120717_F1_sub.h5');
% h5disp(h5file);
vars={'532_ext' 'Altitude' '532_AOT_hi'};
% hsrl=hsrlread(h5file, vars);
% 
% Yohei, 2012/08/03
if ~exist('h5file','var')
    h5file = getfullname('*.h5','hdf5');
end


% read time and location data
ApplanixIMUvarnamelist={'gps_alt' 'gps_lat' 'gps_lon' 'gps_time' 'UTCtime2'};   
hsrl.t=[];
for i=1:length(ApplanixIMUvarnamelist)
    hsrl.(formalizefieldname(ApplanixIMUvarnamelist{i})) = h5read(h5file, ['/ApplanixIMU/' ApplanixIMUvarnamelist{i}])';
end;
daystr=h5readatt(h5file, '/',  'data_collection_start_date');
hsrl.t=hsrl.gps_time/24+datenum([str2num(daystr(1:4)) str2num(daystr(5:6)) str2num(daystr(7:8))]);

% read data products
for i=1:length(vars)
    hsrl.(formalizefieldname(vars{i})) = h5read(h5file, ['/DataProducts/' vars{i}])';
end;
hsrl.filename=h5file;
hsrl.note=['Created on ' datestr(now,31) ' with hsrlread.m'];