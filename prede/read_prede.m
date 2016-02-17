function prede = read_prede(filename,prede);
% prede = read_prede(filename,prede)
%This should read Prede sun/sky files of all types except disk scan.
if ~exist('filename', 'var')
   filename= getfullname('*.*','prede_scan');
elseif ~exist(filename,'file')
   filename= getfullname(filename,'prede_scan');
end
[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];
if ~exist('prede','var')
   prede = [];
end
% Changing structure to remove the concept of unique 'skymode'.  This will
% be stored as a time-varying field and the modes flagged with boolean
% fields


% Prede sky-scan header looks like this:
% POM-01,0000000,0000000,-119.279, 046.341,08/05/31,00:34:47,08/05/30,17:34:47
% 7,0315,0400,0500,0675,0870,0940,1020
% 08/05/31,00:34:47,08/05/30,17:34:47,H,PNNL,pnnl201.obs
% Disection:
% Line 1: ModelNum, ?,?,lat, lon, yy/mm/dd,HH:MM:SS (UTC) yy/mm/dd,HH:MM:SS(LST)
% Line 2: Filters, WL1, WL2, WL3, WL..N (in nm)
% Line 3: yy/mm/dd,HH:MM:SS (UTC), yy/mm/dd,HH:MM:SS(LST), mode H = horiz scan, location?, setup_filename

% POM-01,0000000,0000000,-155.566, 019.550,16-01-14,17:09:12,16-01-14,07:09:12
% 7,0315,0400,0500,0675,0870,0940,1020
% 16-01-14,17:09:12,16-01-14,07:09:13,S,Akiruno,mlo_sun.obs
% 17:09:15,07:09:15,-066.79,001.34,0.0000E+00,4.2725E-12,1.2665E-11,1.3809E-11,4.5776E-12,1.2360E-11,2.0599E-12

fid = fopen(filename);
if fid>0
   if ~isfield(prede,'header')
      hed = 1;
   else
      hed = length(prede.header)+1;
   end
   prede.header(hed).fname = fname;
   done = false; header_rows = 0;
   % Read line 1
   tmp = fgetl(fid);
   C = textscan(tmp,'%s %*d %*d %f %f %s %s %s %s', 'delimiter',',');
   prede.header(hed).model = C{1};
   prede.header(hed).lon = C{2};
   prede.header(hed).lat = C{3};
   UTC = [char(C{4}) ' ' char(C{5})];
   UTC = strrep(UTC,'/','-');
   UTC = datenum(UTC,'yy-mm-dd HH:MM:SS');
   LST = [char(C{4}) ' ' char(C{5})];
   LST = strrep(LST,'/','-');
   LST = datenum(LST,'yy-mm-dd HH:MM:SS');
   prede.header(hed).UTC_start = UTC;
   prede.header(hed).UTC_str = datestr(UTC,'yyyy-mm-dd');
   prede.header(hed).LST_offset = (UTC - LST)*24;
   % Read line 2
   tmp = fgetl(fid);
   C = textscan(tmp,'%d','delimiter',',');
   C = C{1};
   if length(C) == (C(1)+1)
      prede.header(hed).numFilters = double(C(1));
      prede.header(hed).wl = double(C(2:end));
   else
      disp('Badly formatted filter string in second line.')
   end
   % Read line 3
   tmp = fgetl(fid);
   C = textscan(tmp,'%*s %*s %*s %*s %s %s %s','delimiter',',');
   sky_mode = C{1}{:};
   prede.header(hed).sky_mode = sky_mode;
   %    if isfield(prede,sky_mode)
   %       rec = length(prede.time)+1;
   %    else
   %       rec = 1;
   %    end
   prede.header(hed).location = C{2}{:};
   prede.header(hed).setup_fname = C{3}{:};
   ii = 3;
   while ~done&&~feof(fid)
      ii = ii+1;
      tmp = fgetl(fid);
      if length(tmp)>30
         if strcmp(tmp(3),'/')||strcmp(tmp(3),'-') %Then it looks like we've read another skymode header
            % Line 3: yy/mm/dd,HH:MM:SS (UTC), yy/mm/dd,HH:MM:SS(LST), mode H = horiz scan, location?, setup_filename
            if ~isfield(prede,'file')
               hed = 1;
            else
               hed = length(prede.header)+1;
            end
            C = textscan(tmp,'%s %s %s %s %s %s %s','delimiter',',');
            UTC = [char(C{1}) ' ' char(C{2})];
            UTC = strrep(UTC,'/','-');
            UTC = datenum(UTC,'yy-mm-dd HH:MM:SS');
            LST = [char(C{3}) ' ' char(C{4})];
            LST = strrep(LST,'/','-');
            LST = datenum(LST,'yy-mm-dd HH:MM:SS');
            prede.header(hed).UTC_start = UTC;
            prede.header(hed).UTC_str = datestr(UTC,'yyyy-mm-dd');
            prede.header(hed).LST_offset = (UTC - LST)*24;
            sky_mode = C{5}{:};
            prede.header(hed).sky_mode = sky_mode;
            prede.header(hed).location = C{6};
            prede.header(hed).setup_fname = C{7}{:};
         else
            if isfield(prede,'time')
               rec = length(prede.time)+1;
            else
               rec = 1;
            end
            format_str = '%s %*s %f %f %f %f %f %f %f %f %f';
            C = textscan(tmp,format_str, 'delimiter',',');
            UTC = C{1}{:};
            %          {sky_mode, num2str(rec)}
%             if length(prede.header(hed))>10
%                 prede.time(rec) = datenum([prede.header(hed).UTC_str ' ' UTC],'yyyy-mm-dd HH:MM:SS');
%             else
%                 prede.time(rec) = datenum([prede.header(hed).UTC_str ' ' UTC],'yyyy-mm-dd');
%             end
            prede.time(rec) = datenum([prede.header(hed).UTC_str ' ' UTC],'yyyy-mm-dd HH:MM:SS');
            prede.azi(rec) = C{2}+180;%Prede reports relative to south.  We want relative to north.
            prede.ele(rec) = C{3};
            prede.zen(rec) = 90-C{3};
            prede.sky_mode(rec) = sky_mode;
            prede.hed(rec) = hed;
            prede.lon(rec) = prede.header(hed).lon;
            prede.lat(rec) = prede.header(hed).lat;
            for f = 1:prede.header(hed).numFilters
%                disp(ii)
               prede.(['filter_' num2str(f)])(rec) = C{4+f-1};
            end

         end
      end
   end
   fclose(fid);
   if isfield(prede,'time')&&(length(prede.time)>1)&&any(diff(prede.time)<0)
      jump = 1+find(diff(prede.time)<0);
      prede.time(jump:end) = prede.time(jump:end)+1;
   end
end
for h = length(prede.header):-1:1
   h_time(h) = prede.header(h).UTC_start;
end
[htimes,ind] = unique(h_time);
temp = prede.header(ind);
prede.header = temp;
fields = fieldnames(prede);
[ptimes,ind] = unique(prede.time);
for f = length(fields):-1:2
   prede.(fields{f}) = prede.(fields{f})(ind);
end
%Now sort headers and records chronologically
 prede.pname = [pname,filesep];
 prede.LatN = prede.header.lat;% MLO is 19.5365;
 prede.LonE = prede.header.lon; % MLO is -155.5761;
 prede.wl = prede.header.wl;
 [prede.zen_sun,prede.azi_sun, prede.soldst, HA_Sun, Decl_Sun, prede.ele_sun, prede.airmass] = ...
    sunae(prede.LatN, prede.LonE, prede.time);
return