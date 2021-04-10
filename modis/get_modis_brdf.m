function brdf = get_modis_brdf(lat,lon,doy);
%  Check the BRDF parameters retrieved from the sinusoid projection MCD43A1
% against the corresponding valuees from MCD43GF

% According to MODLAND Tile Calculator:
% for 4STAR ground lat,lon position on Aug 16 of 29.6091,-95.1683
% [sn k fwd tp] lat 29.609100  long -95.168300  =>  vert tile 6  horiz tile 9  line 46.41  samp 870.59
% [sn h fwd tp] lat 29.609100  long -95.168300  =>  vert tile 6  horiz tile 9  line 93.32  samp 1741.69
% [sn q fwd tp] lat 29.609100  long -95.168300  =>  vert tile 6  horiz tile 9  line 187.13  samp 3483.87

% Looking for modis BRDF parameters for 4STAR ground-based sky scans
% Identify the correct modis file.  We'll use MCD43A1 which has 0.5 km
% resolution and potentially average a ring around the central pixel.


if ~exist('lat','var')
    lat = 29.6091; lon = -95.1683;
end
%taehwa 37.312N,127.310E
lat = 37.312; lon= 127.310;
g_lon = floor(interp1([-180,180],[1,43200],lon,'linear'));
g_lat = floor(interp1([90,-90],[1,21600],lat,'linear'));

pname = 'D:\data\4STAR\Anet_4STAR_compares\Jens_aeronet_SEAC4RS_compares\';
pname = getnamedpath('modis','Select a MODIS MCD43 file.');
fstem = 'MCD43GF_geo_BandN_225_2013.hdf';
vstem =  '/MCD43GF_30arc_second/Data Fields/';
bstem = {['Albedo_Map_0.659'];['Albedo_Map_0.858'];['Albedo_Map_0.47'];['Albedo_Map_0.555'];['Albedo_Map_1.24'];['Albedo_Map_1.64'];['Albedo_Map_2.13']};
b = 1;
bandw(1,:) = [620, 670]; 
bandw(2,:) = [841, 876];
bandw(3,:) = [459, 479];
bandw(4,:) = [545 , 565];
bandw(5,:) = [1230, 1250];
bandw(6,:) = [1628, 1652];
bandw(7,:) = [2105, 2155];
brdf = mean(bandw,2);brdf(1) = 659;
for b = 1:7
    
    fgeo = strrep(fstem,'_BandN_',['_Band',num2str(b),'_']);
    block = hdfread([pname, fgeo],[vstem,bstem{b}], 'Index', {[g_lat-1,g_lon-1],[1  1],[3  3]});
    fill = 32767; block(block==fill) = NaN; block = double(block);
    brdf(b,4) = meannonan(meannonan(block));
    
    fvol = strrep(fgeo,'_geo_',['_vol_']);
    block = hdfread([pname, fvol],[vstem,bstem{b}], 'Index', {[g_lat-1,g_lon-1],[1  1],[3  3]});
    fill = 32767; block(block==fill) = NaN;block = double(block);
    brdf(b,3) = meannonan(meannonan(block));

    fiso = strrep(fgeo,'_geo_',['_iso_']);
    block = hdfread([pname, fiso],[vstem,bstem{b}], 'Index', {[g_lat-1,g_lon-1],[1  1],[3  3]});
    fill = 32767; block(block==fill) = NaN;block = double(block);
    brdf(b,2) = meannonan(meannonan(block));

end
brdf = double(brdf)./1000;

return

