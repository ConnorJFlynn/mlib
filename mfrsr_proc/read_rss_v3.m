function rss = read_rss_v3(filename);
%%

if ~exist('filename', 'var')
    [fname, pname] = uigetfile('C:\case_studies\Alive\data\kiedron-rss\Oct2006\orig\*.*');
    filename = [pname, fname];
end

fid = fopen(filename);
%%
%244.52152 5.22 980.6 288.1 0.071 0.506 0.247 0.105 0.087 0.070 -2.67223 -1.59836 0.34215 0.00621 -2.63114 -1.20468 1.16395 0.00048 

txt = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ','headerlines',16);
rss.time = txt{1} + datenum('2005-01-01','yyyy-mm-dd') -1;
rss.elevation = txt{2};
rss.pres = txt{3};
rss.aod_500 = txt{7};
rss.aod_870 = txt{9};
return;