function [Altitude, gps_lat, gps_lon, gps_time, A532_ext, A532_bsc, A532_bsc_cloud_screened, A1064_ext, A1064_bsc_cloud_screened]...
    = read_HSRL_hdf(HSRL_filename)




Altitude = hdfread(HSRL_filename,'/Altitude', 'Index', {[1],[1],[304]});

gps_lat = hdfread(HSRL_filename,'/gps_lat', 'Index', {[1],[1],[1709]});

gps_lon = hdfread(HSRL_filename,'/gps_lon', 'Index', {[1],[1],[1709]});

gps_time = hdfread(HSRL_filename,'/gps_time', 'Index', {[1],[1],[1709]});

A532_ext = hdfread(HSRL_filename,'/532_ext', 'Index', {[1  1],[1  1],[1709   304]});

A532_bsc = hdfread(HSRL_filename,'/532_bsc', 'Index', {[1  1],[1  1],[1709   304]});

A532_bsc_cloud_screened = hdfread(HSRL_filename,'/532_bsc_cloud_screened', 'Index', {[1  1],[1  1],[1709   304]});

A1064_bsc_cloud_screened = hdfread(HSRL_filename, '/1064_bsc_cloud_screened', 'Index', {[1  1],[1  1],[1709   304]});

A1064_ext = hdfread(HSRL_filename, '/1064_ext', 'Index', {[1  1],[1  1],[1709   304]});





