function brdf = get_mcd_brdf(lat,lon,t, alt);
%  Get BRDF parameters from the sinusoid projection MCD43A1
% Use call to tilemap webservice to identify tile and pixel within tile
% Identify the correct modis file.  We'll use MCD43A1 which has 0.5 km
% resolution and potentially average a ring around the central pixel.


if ~exist('lat','var')
    lat = 37.312; lon = 127.310;% 37.312,127.310 Taehwa
    t = datenum(2016,04,26);
    alt = .3;
end
%taehwa 37.312N,127.310E
lat = mean(lat); lon = mean(lon); t = mean(t); alt = mean(alt)./1000;
MCD = 'MCD43A1';
lat_str = sprintf('%2.6f',lat); lon_str = sprintf('%3.6f',lon);
web_str = ['https://lpdaacsvc.cr.usgs.gov/services/tilemap?',...
   'product=',MCD,'&latitude=',lat_str,'&longitude=',lon_str,'&output=json'];
blop = webread(web_str); 
tilemap.h = sscanf(blop.tilemap.horizontal,'%d');
tilemap.h_str = sprintf('h%02d', tilemap.h);
tilemap.v = sscanf(blop.tilemap.vertical,'%d');
tilemap.v_str = sprintf('v%02d', tilemap.v);
tilemap.line_YDim = round(sscanf(blop.tilemap.line_YDim,'%f'));
tilemap.sample_XDim = round(sscanf(blop.tilemap.sample_XDim,'%f'));
% MCD43A1.A2016117.h28v05.006.2016180180348
doy = serial2doy(t); 
doy = sprintf('%03d',floor(doy));
yyyy = datestr(t,'yyyy');
mcd_str = ['MCD43A1.A',yyyy,doy,'.',tilemap.h_str, tilemap.v_str,'.006.*.hdf'];
[list,pname] = dir_(mcd_str,'modis_brdf');
mcd_hdf = dirlist_to_filelist(list,pname);
if length(mcd_hdf)~=1 || ~isafile(char(mcd_hdf))
   pause(0.1);mcd_hdf = getfullname(['MCD43A1.A',yyyy,doy,'*.',tilemap.h_str, tilemap.v_str,'.006.*.hdf'],'modis_brdf','Select SSFR mat or cdf file');
else
   mcd_hdf = mcd_hdf{1};
end
% mcd_hdf = getfullname(['MCD43A1.A',yyyy,doy,'.',tilemap.h_str, tilemap.v_str,'.006.*.hdf'],'MCD43A1');
mcd_info = hdfinfo(mcd_hdf);
% Now we pull in the BRDF parameters for all seven bands.

vstem =  '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band';

bandw(1,:) = [620, 670]; 
bandw(2,:) = [841, 876];
bandw(3,:) = [459, 479];
bandw(4,:) = [545 , 565];
bandw(5,:) = [1230, 1250];
bandw(6,:) = [1628, 1652];
bandw(7,:) = [2105, 2155];
brdf = mean(bandw,2);brdf(1) = 659;
brdf = brdf./1000;
% Taihwa: 37.312N,127.310  37.312,127.310
% bloop = wget('https://lpdaacsvc.cr.usgs.gov/services/tilemap?product=MCD43A1&latitude=37.312&longitude=127.310')
% Can scale the line and sample indices according to the pixel resolution
% As we increase "line" we decrease Lat
% As we increase "sample" we increase Long
% 0,2399: lat 39.997917  long 143.587701  0,0:  lat 39.997917  long 130.539466
% 2399,0: lat 30.002083  long 115.474884  2399,2399: lat 30.002083  long 127.017320
C_lat = tilemap.line_YDim;
C_lon = tilemap.sample_XDim;
if strcmp(MCD,'MCD43A1')
   res = 0.5; % make this the same units as s.Alt
   d_bin = 2.*ceil(alt./res);% collect a group of pixels with radius ~= alt
   start_pix = [max([1,C_lat - d_bin]),max([1,C_lon - d_bin]), 1];
   lat_rem = 2400 - (C_lat -d_bin); lon_rem = 2400 - (C_lon-d_bin);
   stop_pix = [min([lat_rem, 1+2.*d_bin]), min([lon_rem, 1+2.*d_bin]), 3];
end


for b = 1:7
    
block = hdfread(mcd_hdf,[vstem,num2str(b)], 'Index', {start_pix,[1 1 1],stop_pix});
mask = 0.001.* ones(size(block));  fill = 32767; mask(block==fill) = NaN; 
block = double(block).*mask;
bip = squeeze(meannonan(meannonan(block)))';
brdf(b,2:4) = bip;
end

[~,ij] = sort(brdf(:,1));
brdf = brdf(ij,:)

return

