function all_oz = gen_site_oz(anc,lon);
% all_oz = gen_site_oz(nc_site);
% all_oz = gen_site_oz(lat,lon);
% For the supplied lat and lon (or the lat and lon in the supplied nc file)
% Reads all available TOMS and OMI data, creating a subset for the supplied
% coords.  Returns an nc_struct containing the complete time series of
% ozone values for this location.
%Site: 61° 50' 36.73" N, 24° 17' 16.25" E
% Following values for TMP (Finland) before ARM site was operational.
%  Coords copied from AMF2 web site.
% anc = 61 + (50+37.73./60)./60;
% lon = 24 + (17 + 16.25./60)./60;
if ~exist('anc','var') || (exist('anc','var')&&~isstruct(anc)&&~exist('lon','var'))
    anc = ancloadcoords(getfullname('*.cdf;*.nc','arm_site','Select a file from the desired site'));
end

if isstruct(anc) && isfield(anc,'vars') && isfield(anc.vars,'lat')&& isfield(anc.vars,'lon')...
        && isfield(anc.vars.lat,'data')&& isfield(anc.vars.lon,'data')
    lon = mean(anc.vars.lon.data);
    lat = mean(anc.vars.lat.data);
end

if ~isstruct(anc)
    lat = anc;
end



%% Read in all of TOMS data, creating lat/lon subset
%% cat the subsets all together
%
% From Ian:
% Lat:     40 27' 18.55021" = 40.45515;
% Lon:  -106 44' 40.03441" = -106.74445
% 3203 m = 10508.5 ft (via Google-Earth altitude...)

% lat = 40.45515;
% lon= -106.74445;

% This line should be modified to reflect the data path
oz_path = 'D:\case_studies\ozone\toms\';
if ~exist(oz_path,'dir')
    oz_path = get_dir;
end

oz_file = dir([oz_path,'gectomsX1.*.cdf']);
all_oz = get_oz(lat,lon,ancload([oz_path,oz_file(1).name]));
for f = length(oz_file):-1:2
    oz = get_oz(lat,lon,ancload([oz_path,oz_file(f).name]));
    all_oz = anccat(all_oz,oz);
    disp(f)
end

% This line should be modified to reflect the data path
oz_path = 'D:\case_studies\ozone\omi\';
if ~exist(oz_path,'dir')
    oz_path = get_dir;
end
oz_file = dir([oz_path,'gecomiX1.*.cdf'])
for f = length(oz_file):-1:1
    oz = get_oz(lat,lon,ancload([oz_path,oz_file(f).name]));
    all_oz = anccat(all_oz,oz);
    disp(f)
end

if isstruct(anc)
    
    dsname = strtok(fliplr(strtok(fliplr(anc.fname),filesep)),'.');
    DSNAME = upper(dsname)
    SS=dsname(1:3);
    F = length(dsname);
    while strcmp(dsname(F),DSNAME(F)) && F>3
        F = F-1;
    end
    FF = dsname(F+1:end);
    fname = [SS,'ozonedu',FF,'.a1.',datestr(all_oz.time(1),'yyyymmdd_'),datestr(all_oz.time(end),'yyyymmdd'),'.nc'];
else
    fname = ['SSSozoneduFF.a1.Lat',sprintf('%03.2f',lat),'_Lon',sprintf('%03.2f',lon),'.',...
        datestr(all_oz.time(1),'yyyymmdd_'),datestr(all_oz.time(end),'yyyymmdd'),'.nc'];
end
% This line should be modified to reflect the data path
out_path = 'D:\case_studies\ozone\'
if ~exist(out_path,'dir')
    out_path = get_dir;
end
% fname = [SS,'ozonedu',FF,'.a1.',datestr(all_oz.time(1),'yyyymmdd_'),datestr(all_oz.time(end),'yyyymmdd'),'.nc'];
all_oz.fname = [out_path, fname];
k = menu('Save this file?','Yes','New name','Don''t save')
if k == 2
    [fn,pn] = putfile([out_path,fname],'ozone','Save ozone files here...');
    out_path = pn;
    fname = fn;
    all_oz.fname = [out_path,fname];
    all_oz.clobber = true;
end
if k==1 || k==2
    ancsave(all_oz);
end

return
% omi path = C:\case_studies\ozone\omi
