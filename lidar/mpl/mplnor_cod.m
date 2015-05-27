function [time, cod, below_lo, below_hi, above_lo, above_hi] = mplnor_cod(max_deviation, mpl_id, sonde_id)
% [time, cod] = mplnor_cod(max_deviation, mpl_id, sonde_id)
% This function accepts open netcdf files of MPLnor and sonde data
% It returns a time-series of MPL cloud optical depths
% 0 = cloud-free
% -1 = either opaque cloud or blocked-beam

if nargin==0
   max_deviation = .05;
   mpl_id = get_ncid('mplnor');
   sonde_id = get_ncid('sonde');
elseif nargin==1
   mpl_id = get_ncid('mplnor');
   sonde_id = get_ncid('sonde');   
end;

time = nc_time(mpl_id);
height = nc_getvar(mpl_id, 'height');
if size(height,1)==1;
    height = height';
end

backscatter = nc_getvar(mpl_id, 'backscatter');
cloud_base_height = nc_getvar(mpl_id, 'cloud_base_height');
cloud_top_height = nc_getvar(mpl_id, 'cloud_top_height');
cloud_mask_2 = nc_getvar(mpl_id, 'cloud_mask_2');
random_error = nc_getvar(mpl_id, 'random_error');
[atten,tau, max_altitude] = sonde_std_atm_ray_atten(sonde_id, height);
if size(atten,1)==1;
    atten = atten';
end
% figure; imagesc(serial2Hh(time), height, backscatter); colormap('jet'); axis('xy'); 
% title([' MPL backscatter: 'datestr(time(1),29) ]);
% xlabel('Time (Jd0)');
% ylabel('height (km)');
% axis([0 24 0 12 0 1 0 1]); zoom
for t = length(time):-1:1
%   [cod_1(t), below_lo1(t), below_hi1(t), above_lo1(t), above_hi1(t)] = calc_cod(height, backscatter(:,t), cloud_mask_2(:,t), atten, max_deviation, random_error(:,t));
   [cod(t), below_lo(t), below_hi(t), above_lo(t), above_hi(t), flag(t)] = calc_codv2(height, backscatter(:,t), cloud_mask_2(:,t), atten, max_deviation, random_error(:,t));
%   pause
end;   
% figure; plot(serial2Hh(time), cod, 'r.', serial2Hh(time), cod_1, 'g.'); 
%  figure; plot(serial2Hh(time), cod, 'r.');
%  title([' Cloud optical depth for ', datestr(time(1),29), '. max dev=', num2str(max_deviation) ]);
%  xlabel('Time (H.h)');
%  ylabel('Cloud Optical Depth');

% figure; plot(serial2Hh(time), [below_lo1; below_hi1 ;above_lo1; above_hi1], '.');
% xlabel('Time (H.h)');
% ylabel('height(km)');
% legend('below_lo', 'below_hi', 'above_lo', 'above_hi');
% title(['Rayleigh comparison regions ', datestr(time(1),29), '. max dev=', num2str(max_deviation) ]);

% figure; plot(serial2Hh(time), [above_hi; below_hi; above_lo; below_lo], '.');
% xlabel('Time (H.h)');
% ylabel('height(km)');
% legend('above_hi', 'above_lo', 'below_hi', 'below_lo');
% title(['Rayleigh comparison regions ', datestr(time(1),29), '. max dev=', num2str(max_deviation) ]);
% 
% figure; plot(serial2Hh(time), [log2(flag+1)], '.');
% xlabel('Time (H.h)');
% ylabel('flag bits');
% legend('flags');
% 
% pause
% close all

%      print('-dpng',[pname, datestr(time(1),29), '.cloud_od.mdev_',num2str(max_dev(j)),'.png']);
%Check to see if the optical depth is already defined in the file. 
% If so, replace it with the new one.
% If not, define it and populate it.
[varid, rcode] = ncmex('VARID', mpl_id, 'total_cloud_ODs');
if varid <= 0 
   [temp, datatype, ndims, dim_ids, natts, varid] = ncmex('VARINQ', mpl_id, 'energy_monitor');
   [att_datatype, len, status] = ncmex('ATTINQ', mpl_id, 'energy_monitor', 'long_name');
   status = ncmex('REDEF', mpl_id);
   status = ncmex('VARDEF', mpl_id, 'total_cloud_OD', datatype, ndims, dim_ids);
   att_val = 'total cloud optical depth';
   status = ncmex('ATTPUT', mpl_id, 'total_cloud_OD', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'unitless';
   status = ncmex('ATTPUT', mpl_id, 'total_cloud_OD', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'Cloud optical depth of 0 assigned in absense of cloud.';
   status = ncmex('ATTPUT', mpl_id, 'total_cloud_OD', 'meaning_of_0', att_datatype, length(att_val), att_val) ;
   att_val = 'Cloud optical depth of -1 assigned when no clear region is identified below the cloud or when signal above cloud does not match Rayleigh shape.';
   status = ncmex('ATTPUT', mpl_id, 'total_cloud_OD', 'meaning_of_-1', att_datatype, length(att_val), att_val) ;
   att_val = max_deviation;
   status = ncmex('ATTPUT', mpl_id, 'total_cloud_OD', 'Max_allowed_deviation_from_Rayleigh_above_cloud', datatype, length(att_val), att_val) ;
   
   status = ncmex('VARDEF', mpl_id, 'below_cloud_lo_bin', datatype, ndims, dim_ids);
   att_val = 'lowest bin used below cloud base';
   status = ncmex('ATTPUT', mpl_id, 'below_cloud_lo_bin', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'km';
   status = ncmex('ATTPUT', mpl_id, 'below_cloud_lo_bin', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'Height of 0 km assigned in absense of cloud.';
   status = ncmex('ATTPUT', mpl_id, 'below_cloud_lo_bin', 'No_cloud_found', att_datatype, length(att_val), att_val) ;
   
   status = ncmex('VARDEF', mpl_id, 'below_cloud_hi_bin', datatype, ndims, dim_ids);
   att_val = 'highest bin used below cloud base';
   status = ncmex('ATTPUT', mpl_id, 'below_cloud_hi_bin', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'km';
   status = ncmex('ATTPUT', mpl_id, 'below_cloud_hi_bin', 'units', att_datatype, length(att_val), att_val) ;
   att_val = ['Maximim height is assigned in absense of cloud.'];
   status = ncmex('ATTPUT', mpl_id, 'below_cloud_hi_bin', 'No_cloud_found', att_datatype, length(att_val), att_val) ;
   
   
   status = ncmex('VARDEF', mpl_id, 'above_cloud_lo_bin', datatype, ndims, dim_ids);
   att_val = 'lowest bin used above cloud base';
   status = ncmex('ATTPUT', mpl_id, 'above_cloud_lo_bin', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'km';
   status = ncmex('ATTPUT', mpl_id, 'above_cloud_lo_bin', 'units', att_datatype, length(att_val), att_val) ;
   att_val = ['Maximim height is assigned in absense of cloud.'];
   status = ncmex('ATTPUT', mpl_id, 'above_cloud_lo_bin', 'No_cloud_found', att_datatype, length(att_val), att_val) ;
   
   status = ncmex('VARDEF', mpl_id, 'above_cloud_hi_bin', datatype, ndims, dim_ids);      
   att_val = 'highest bin used above cloud base';
   status = ncmex('ATTPUT', mpl_id, 'above_cloud_hi_bin', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'km';
   status = ncmex('ATTPUT', mpl_id, 'above_cloud_hi_bin', 'units', att_datatype, length(att_val), att_val) ;
   att_val = ['Maximim height is assigned in absense of cloud.'];
   status = ncmex('ATTPUT', mpl_id, 'above_cloud_hi_bin', 'No_cloud_found', att_datatype, length(att_val), att_val) ;
   
   status = ncmex('VARDEF', mpl_id, 'qc_total_cloud_OD', 4, ndims, dim_ids);      
   att_val = 'quality flag for cloud optical depth';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'long_name', att_datatype, length(att_val), att_val) ;
   att_val = 'unitless';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'units', att_datatype, length(att_val), att_val) ;
   att_val = 'flag is a bit-mapped field: 0 = true; 1 = false';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_map', att_datatype, length(att_val), att_val) ;
   att_val = 'cloud detected (same as num_cloud_bins > 0)';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_0', att_datatype, length(att_val), att_val) ;
   att_val = 'cloud base > 200 meters from ground';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_1', att_datatype, length(att_val), att_val) ;
   att_val = 'found clear air region below cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_2', att_datatype, length(att_val), att_val) ; 
   att_val = 'found molecular return above cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_3', att_datatype, length(att_val), att_val) ;
   att_val = 'more than zero bins retained below cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_4', att_datatype, length(att_val), att_val) ;
   att_val = 'more than zero bins retained above cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_5', att_datatype, length(att_val), att_val) ;
   att_val = 'positive average backscatter below cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_6', att_datatype, length(att_val), att_val) ;
   att_val = 'positive attenuated profile below cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_7', att_datatype, length(att_val), att_val) ;
   att_val = 'positive average backscatter above cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_8', att_datatype, length(att_val), att_val) ;
   att_val = 'positive attenuated profile above cloud';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_9', att_datatype, length(att_val), att_val) ;
   att_val = 'positive optical depth retrieved from regions passing all tests';
   status = ncmex('ATTPUT', mpl_id, 'qc_total_cloud_OD', 'bit_10', att_datatype, length(att_val), att_val) ;
   status = ncmex('ENDEF', mpl_id);
end;
att_val = max_deviation;
status = ncmex('ATTPUT', mpl_id, 'total_cloud_OD', 'Max_allowed_deviation_from_Rayleigh_above_cloud', datatype, length(att_val), att_val) ;
[status] = nc_putvar(mpl_id, 'total_cloud_OD', cod);
[status] = nc_putvar(mpl_id, 'below_cloud_lo_bin', below_lo);
[status] = nc_putvar(mpl_id, 'below_cloud_hi_bin', below_hi);
[status] = nc_putvar(mpl_id, 'qc_total_cloud_OD', flag);
[status] = nc_putvar(mpl_id, 'above_cloud_hi_bin', above_hi);
[status] = nc_putvar(mpl_id, 'above_cloud_lo_bin', above_lo);

if nargin==0
   ncmex('close', mpl_id);
   ncmex('close', sonde_id);
end
