%
% This example code illustrates how to access and visualize NSIDC
% MCD19A2 L3 HDF-EOS2 Sinusoidal Grid file in MATLAB.
%
% If you have any questions, suggestions, comments on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r MCD19A2_A2010010_h25v06_006_2018047103710_hdf
%
% Tested under: MATLAB R2018b
% Last updated: 2019-05-20
import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Open the HDF-EOS2 Grid file.
FILE_NAME=getfullname('MCD*.hdf','MCDhdf','Select MCD file');%D:\nsf_prop\MCD19A2.A2020254.h07v05.061.2023139080512.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='grid1km';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME='Optical_Depth_055'; DATAFIELD_NAME = 'Injection_Height';
[data, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
% data=data';

% Detach from the Grid Object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);


lon(lon<0) = lon(lon<0) + 360;

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'unit');
units = sd.readAttr(sds_id, units_index);

% Read long_name from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read _FillValue attribute.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read scale_factor attribute.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);

% Read add_offset attribute.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);


% Replace fill value with NaN.
data(data<0) = NaN;

% Apply MODIS scale/offset rule.
% data = scale*(data-offset);

% Convert 3D data to 2D.
data=squeeze(data(:,:,1));

% Preparation of combining multiple swaths for Hyplit-derived age
good_ij =sub2ind(size(data), find(~isnan(data)));
lats = lat(good_ij);
lons = lon(good_ij)
figure; scatter(lons, lats, 12,data(good_ij),'filled');

f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','on');

% Set map boundary limits.
latlim=[floor(min(min(lat)))-20, ceil(max(max(lat)))+20];
lonlim=[floor(min(min(lon)))-20, ceil(max(max(lon)))+20];

% Plot the data using axesm and surfacem.
axesm('sinusoid', 'Frame', 'on', 'Grid', 'on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation', 5,'PLabelLocation', 5, 'MLabelParallel','south');
coast = load('coastlines.mat');
surfacem(lat,lon,data);
colormap('Jet');
h = colorbar();
plotm(coast.coastlat,coast.coastlon,'k');

tightmap;

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');

% Save image.
set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

