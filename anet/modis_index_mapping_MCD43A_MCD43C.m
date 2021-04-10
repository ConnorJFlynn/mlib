% Open MCD43A1 file for the grid containing south korea.
% Load one of the parameters and make an image plot of it to see if it
% looks like S Korea.  Flip accordingly.

% Open MCD43C1 file.  Identify the world coords equivalent to the lat/lon
% for the Sin Grid dims.  Load one of the paramters

% First call [x,y] = SinProj(lat, lon) to get x,y for given lat,lon coords
% then call [xi, yi] = world2ind(x,y,hdf_in); to get the indices in the hdf
% grid

% As an exercise to verify that this is working read in some of the global
% file.  Plot large image, then subset in Lat and Lon.
% Then plot b1 (1200x1200 sinusoid) and identify features.  Then specify
% the lat and lon of these features and extract the portion.


pname = ['C:\_star\IOP\20160426_20160614_KORUS\MCD43C\'];
hdf_A1 = 'MCD43A1.A2016117.h28v05.006.2016180180348.hdf';
hdf_C1 = 'MCD43C1.A2016117.006.2016196210556.hdf';
hdf_D4 = 'MCD43D04.A2016117.006.2016196210552.hdf';
hdf_QA = strrep(hdf_C1,'C1.','C2.');
c1_info = hdfinfo([pname, hdf_C1]);
c1_band2_iso = hdfread([pname, hdf_C1],'/MCD_CMG_BRDF_0.05Deg/Data Fields/BRDF_Albedo_Parameter1_Band2');

d_info = hdfinfo([pname, hdf_D4])
d_band2_iso = hdfread([pname, hdf_D4],'/MCD_CMG_BRDF_30Arc Second/Data Fields/BRDF_Albedo_Parameter1_Band2');

BLAH = d_info.Attributes(2).Value;
BLAH = c1_info.Attributes(2).Value;
a1_info = hdfinfo([pname, hdf_A1]);

BLAH = a1_info.Attributes(2).Value;
UL_ij = findstr(BLAH,'UpperLeftPointMtrs=(');
[UL_coords] = sscanf(BLAH(UL_ij+length('UpperLeftPointMtrs=('):end),'%f,%f');
LR_ij = findstr(BLAH,'LowerRightMtrs=(');
[LR_coords] = sscanf(BLAH(LR_ij+length('LowerRightMtrs=('):end),'%f,%f');
figure; imagesc([UL_coords(1),LR_coords(1)],[UL_coords(2),LR_coords(2)],d_band2_iso); axis('xy');
title('MCD43D06 iso')


a1_band2 = hdfread([pname, hdf_A1],'/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band2');
mask = ones(size(c1_band2_iso)).*0.001; mask(c1_band2_iso==32767) = NaN;
figure; imagesc([UL_coords(1),LR_coords(1)],[UL_coords(2),LR_coords(2)],double(c1_band2_iso).*mask); axis('xy')
caxis([0,1]); cm = colormap; cm(1,:) = 0; colormap(cm);

[UL_lat, UL_long] = invSinProj(UL_coords(1),UL_coords(2)) 






[LR_lat, LR_long] = invSinProj(LR_coords(1),LR_coords(2));
figure; imagesc(a1_band2(:,:,1)); axis('xy')
figure; imagesc([UL_long, LR_long],[UL_lat, LR_lat],a1_band2(:,:,1)); axis('xy')
% Okay, I think I know the orientation of that Sin Grid, so now load the a
% tiny piece at Taehwa % lat_lon =[ 39.9,127.310 ];
% To do that, I guess we need the line and sample within that Sin Grid
% corresponding to our Lat, Lon
%First compute world coords for this Lat,Lon using SinProj
[x,y] = SinProj(39.9,127.310);
% next convert to line,samp indices with world2ind
[xi, yi] = world2ind(x,y,[pname, hdf_A1])

[x,y] = SinProj(lat_U,lon_L)
[x_b1, y_b1] = world2ind(x,y,[pname,hdf_B1]);
b1_Band2_trim_xy = hdfread([pname,hdf_B1], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band2', 'Index', {[y_b1,x_b1, 1],[1  1  1],[1,1, 3]});
BRDF_Albedo_Band_Quality_xy = hdfread([pname, hdf_QA], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Band_Quality', 'Index', {[y_b1,x_b1],[1  1 ],[1 1]});

band_1 = bitget(BRDF_Albedo_Band_Quality_xy,1)&bitget(BRDF_Albedo_Band_Quality_xy,2)&...
    bitget(BRDF_Albedo_Band_Quality_xy,3)&bitget(BRDF_Albedo_Band_Quality_xy,4);
band_1(band_1~=0) = NaN;



figure(5); imagesc(log10(double(b1_Band2_trim_2)./1000));





iso = ['MCD43GF_iso_Band2_225_2013.hdf'];


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

% [x,y] = SinProj(30, -92);
[x_r,y_r] = SinProj(29.99, -93);

b1_Band2 = hdfread([pname,hdf_B1], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Parameters_Band2', 'Index', {[1  1  1],[1  1  1],[1200  1200     1]});
figure; imagesc(log10(double(b1_Band2)./1000))



BRDF_Albedo_Band_Quality = hdfread([pname, hdf_QA], '/MOD_Grid_BRDF/Data Fields/BRDF_Albedo_Band_Quality', 'Index', {[1  1],[1  1],[1200  1200]});



