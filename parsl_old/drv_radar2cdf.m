% Generate NetCDF file from raw radar data

directory = 'E:/twpice/raw_archive/radar/20060212/'

desired_date = '20060212';

[times,power,mean_velocity,mean_width,all_data_time] = ingest_netcdf_moments_avgzt(directory,desired_date);