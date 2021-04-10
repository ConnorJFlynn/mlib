% First call [x,y] = SinProj(lat, lon) to get x,y for given lat,lon coords
% then call [xi, yi] = world2ind(x,y,hdf_in); to get the indices in the hdf
% grid

% As an exercise to verify that this is working read in some of the global
% file.  Plot large image, then subset in Lat and Lon.
% Then plot b1 (1200x1200 sinusoid) and identify features.  Then specify
% the lat and lon of these features and extract the portion.


pname = ['D:\data\4STAR\Anet_4STAR_compares\Jens_aeronet_SEAC4RS_compares\'];
hdf_A1 = 'MCD43A1.A2013225.h09v06.005.2013243013845.hdf'
hdf_B1 = 'MCD43B1.A2013225.h09v06.005.2013243013846.hdf'
hdf_QA = strrep(hdf_B1,'B1.','B2.');
iso = ['MCD43GF_iso_Band2_225_2013.hdf'];

lat_U = 29.609100;
lon_L = -95.168300;
lat_U = 37.312;
lon_L = 127.31;
% According to MODLAND Tile Calculator:
% for 4STAR ground lat,lon position on Aug 16 of 29.6091,-95.1683
% [sn k fwd tp] lat 29.609100  long -95.168300  =>  vert tile 6  horiz tile 9  line 46.41  samp 870.59
% [sn h fwd tp] lat 29.609100  long -95.168300  =>  vert tile 6  horiz tile 9  line 93.32  samp 1741.69
% [is_k k fwd gm] lat 29.609100  long -95.168300  =>  x -9200183.39  y 3292385.41
% [sn q fwd tp] lat 29.609100  long -95.168300  =>  vert tile 6  horiz tile 9  line 187.13  samp 3483.87

x_ind = floor(interp1([-90,90],[21600 1],lat_U,'linear'));
y_ind = floor(interp1([-180,180],[1,43200],lon_L,'linear'));
x_end = floor(interp1([-90,90],[21600 1],lat_U-2,'linear'));
y_end = floor(interp1([-180,180],[1,43200],lon_L+2,'linear'));

Latitude = hdfread([pname, iso], '/Latitude', 'Index', {1,1,21600});
Longitude = hdfread([pname, iso], '/Longitude', 'Index', {1,1,43200});

Lat_xy = hdfread([pname, iso], '/Latitude', 'Index', {[x_ind],[1],[x_end-x_ind]});
Long_xy = hdfread([pname, iso], '/Longitude', 'Index', {[y_ind],[1],[y_end-y_ind]});
Albedo_Map_0_858_sub_xy = hdfread([pname, iso], '/MCD43GF_30arc_second/Data Fields/Albedo_Map_0.858', 'Index', {[x_ind  y_ind],[1  1],[x_end-x_ind  y_end-y_ind]});
figure; imagesc(log10(double(Albedo_Map_0_858_sub_xy)./1000));
figure; imagesc(Long_xy,Lat_xy,log10(double(Albedo_Map_0_858_sub_xy)./1000));axis('xy')

[x,y] = SinProj(lat_U,lon_L)
% [x,y] = SinProj(30, -92);
[x_r,y_r] = SinProj(29.99, -93);
pname = ['D:\data\4STAR\Anet_4STAR_compares\Jens_aeronet_SEAC4RS_compares\'];

hdf_B1 = 'MCD43B1.A2013225.h09v06.005.2013243013846.hdf';
[x_b1, y_b1] = world2ind(x,y,[pname,hdf_B1]);
[x_r_i, y_r_i] = world2ind(x_r,y_r,[pname,hdf_B1]);

b1_Band2 = hdfread([pname,hdf_B1], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band2', 'Index', {[1  1  1],[1  1  1],[1200  1200     1]});
figure; imagesc(log10(double(b1_Band2)./1000))


b1_Band2_trim_2 = hdfread([pname,hdf_B1], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band2', 'Index', {[y_b1,x_b1, 1],[1  1  1],[abs(y_r_i-y_b1),abs(x_r_i-x_b1), 3]});
figure(5); imagesc(log10(double(b1_Band2_trim_2)./1000));

BRDF_Albedo_Band_Quality = hdfread([pname, hdf_QA], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Band_Quality', 'Index', {[1  1],[1  1],[1200  1200]});

BRDF_Albedo_Band_Quality_trim = hdfread([pname, hdf_QA], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Band_Quality', 'Index', {[y_b1,x_b1],[1  1 ],[abs(y_r_i-y_b1),abs(x_r_i-x_b1)]});
band_1 = bitget(BRDF_Albedo_Band_Quality_trim,1)&bitget(BRDF_Albedo_Band_Quality_trim,2)&...
    bitget(BRDF_Albedo_Band_Quality_trim,3)&bitget(BRDF_Albedo_Band_Quality_trim,4);
band_1(band_1~=0) = NaN;

b1_Band2_trim_N = hdfread([pname,hdf_B1], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band2', 'Index', {[y_b1,x_b1, 1],[1  1  1],[1,1, 3]});


