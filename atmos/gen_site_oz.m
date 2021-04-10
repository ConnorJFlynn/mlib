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
    anc = anc_loadcoords(getfullname('*.cdf;*.nc','arm_site','Select a file from the desired site'));    
end

if isstruct(anc) && isfield(anc,'vdata') && isfield(anc.vdata,'lat')&& isfield(anc.vdata,'lon')   
    lon = mean(anc.vdata.lon);
    lat = mean(anc.vdata.lat);
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
oz_path = getnamedpath('oz_toms','Select location of TOMS Ozone files.');

oz_file = dir([oz_path,'gectomsX1.*.cdf']);
all_toms = get_oz(lat,lon,anc_load([oz_path,oz_file(1).name]));
for f = length(oz_file):-1:2
    oz = get_oz(lat,lon,anc_load([oz_path,oz_file(f).name]));
    all_toms = anc_cat(all_toms,oz);
    disp(f)
end

% This line should be modified to reflect the data path
oz_path = getnamedpath('oz_omi','Select location of OMI Ozone files.');
oz_file = dir([oz_path,'gecomiX1.*.cdf']);
all_omi = get_oz(lat,lon,anc_load([oz_path,oz_file(1).name]));
for f = length(oz_file):-1:1
    oz = get_oz(lat,lon,anc_load([oz_path,oz_file(f).name]));
    all_omi = anc_cat(all_omi,oz);
    disp(f)
end

bad = all_toms.vdata.ozone < 10;
all_toms.vdata.ozone(bad) = NaN;
bad = all_omi.vdata.ozone < 10;
all_omi.vdata.ozone(bad) = NaN;
all_oz = anc_cat(all_toms, all_omi);
bad = all_oz.vdata.ozone < 10;
all_oz.vdata.ozone(bad) = NaN;

if isstruct(anc)
    
    dsname = strtok(fliplr(strtok(fliplr(anc.fname),filesep)),'.');
    DSNAME = upper(dsname);
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

all_doy = serial2doy(all_oz.time);
all_du = all_oz.vdata.ozone;
good = ~isNaN(all_du);
for d = 365:-1:1
   degs = acosd(cos(2.*pi.*(all_doy-d)/365));
   week = (degs<4)&(good);
  [P,S] = polyfit(degs(week), all_du(week),2);
  daily.doy(d) = d;
  daily.Ozone(d) = polyval(P,0,S);
  daily.stddev(d) = std(all_du(week));
end


fig_12 = figure_(12); plot(all_toms.time, all_toms.vdata.ozone,'o',all_omi.time, all_omi.vdata.ozone,'r*'); dynamicDateTicks; 
xlabel('time'); ylabel('DU'); legend('TOMS','OMI'); 
title({fname;[sprintf('Lat = %3.3f, Lon = %3.3f',all_oz.vdata.lat, all_oz.vdata.lon)]}, 'interp','none');

fig_13 = figure_(13); plot(serial2doy(all_toms.time), all_toms.vdata.ozone,'o',serial2doy(all_omi.time), all_omi.vdata.ozone,'r*');
hold('on');
errorbar(daily.doy(1:10:end), daily.Ozone(1:10:end), daily.stddev(1:10:end), '-gx');
xlabel('time [day of year]'); ylabel('DU'); legend('TOMS','OMI', 'doy avg'); 
title({fname;[sprintf('Lat = %3.3f, Lon = %3.3f',all_oz.vdata.lat, all_oz.vdata.lon)]}, 'interp','none');
hold('off');
xlim([0,365])


out_path = getnamedpath('oz_site','Select a directory to store the site ozone record.');

% fname = [SS,'ozonedu',FF,'.a1.',datestr(all_oz.time(1),'yyyymmdd_'),datestr(all_oz.time(end),'yyyymmdd'),'.nc'];
all_oz.fname = [out_path, fname];
% k = menu('Save this file?','Yes','New name','Don''t save');
k = 1;
if k == 2
    [fn,pn] = uiputfile([out_path,fname],'Save ozone files here...');
    out_path = pn;
    fname = fn;
    all_oz.fname = [out_path,fname];    
end
all_oz = anc_check(all_oz);
all_oz.clobber = true;
if k==1 || k==2    
    [~, fn,] = fileparts(fname); 
    saveas(fig_12, [out_path, fn, '.timeseries.fig']);
    saveas(fig_13, [out_path, fn, '.doy.fig']);
    anc_save(all_oz,'clobber');
    all_oz.daily = daily;
    save([out_path,fn,'.mat'],'-struct','all_oz')

end

return
% omi path = C:\case_studies\ozone\omi
