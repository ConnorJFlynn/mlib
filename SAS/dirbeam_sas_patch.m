function dirbeam = dirbeam_sas_patch(infile)
% This populates a "dirbeam" struct from an SAS "infile"
dirbeam.time = []; dirbeam.wl = []; dirbeam.dirn = []; dirbeam.oam = []; dirbeam.AU = [];

keeps = (infile.oam>.9 & infile.oam<=7);
infile.AU(~keeps) = [];
infile.difh(:,~keeps) = [];
infile.dirh(:,~keeps) = [];
infile.oam(~keeps) = [];
infile.sza(~keeps) = [];
infile.time(~keeps) = [];
if isfield(infile,'Site_Longitude_Degrees')
   tz = double(infile.Site_Longitude_Degrees(1)/15)./24;
elseif isfield(infile,'vdata')&&isfield(infile.vdata, 'lon')
   tz = double(infile.vdata.lon/15)./24;
elseif isfield(infile,'lon')
   tz = double(infile.lon/15)./24;
end
tz = floor(24.*tz)./24;

AU = infile.AU;
oam = infile.oam;
WL = [340,355,368,387,408,415,440,500,532,615,650,673,762,870,910,940:948,975];
% WL = unique([WL,infile.wl(1:5:end)']);
wl_i = unique(interp1(infile.wl, [1:length(infile.wl)],WL,'nearest'));
WL_nm = infile.wl(wl_i);
for ww = 1:length(WL)
   dirh = infile.dirh(wl_i(ww),:);
   dirn = dirh./cosd(infile.sza);
   dirbeam.time = [dirbeam.time, infile.time(dirn>0)];
   dirbeam.wl = [dirbeam.wl, zeros(size(dirn(dirn>0)))+WL_nm(ww)];
   dirbeam.dirn = [dirbeam.dirn, dirn(dirn>0)];
   dirbeam.oam = [dirbeam.oam, oam(dirn>0)]; dirbeam.AU = [dirbeam.AU, AU(dirn>0)];
end
dirbeam.time_LST = dirbeam.time + tz;
dirbeam.wls = unique(dirbeam.wl);
dirbeam.tag = 'sashevis'
end