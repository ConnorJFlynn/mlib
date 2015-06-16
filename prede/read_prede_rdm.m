function prede = read_prede_rdm(filename);
%This should read Prede random-scan files
if ~exist('filename', 'var')
   filename= getfullname('*.rdm','prede_scan');
end
% Changing structure to remove the concept of unique 'scans'.
% Essentially, we'll still separate the data according to H or V, but
% within a given scan direction each point stands on it's own. This will
% probably force some level of selection as a function of time.

% Prede rdm-scan header looks like this:
% POM-01,0000000,0000000,-119.279, 046.341,08/05/31,00:34:47,08/05/30,17:34:47
% 7,0315,0400,0500,0675,0870,0940,1020
% 08/05/31,00:34:47,08/05/30,17:34:47,H,PNNL,pnnl201.obs
% Disection:
% Line 1: ModelNum, ?,?,lat, lon, yy/mm/dd,HH:MM:SS (UTC) yy/mm/dd,HH:MM:SS(LST)
% Line 2: Filters, WL1, WL2, WL3, WL..N (in nm)
% Line 3: yy/mm/dd,HH:MM:SS (UTC), yy/mm/dd,HH:MM:SS(LST), mode R = random scan, location?, setup_filename

[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];
fid = fopen(filename);
prede.fname = fname;
if fid>0
   done = false; header_rows = 0;
   % Read line 1
   tmp = fgetl(fid);
   C = textscan(tmp,'%s %*d %*d %f %f %s %s %s %s', 'delimiter',',');
   prede.model = C{1};
   prede.lon = C{2};
   prede.lat = C{3};
%    UTC = datenum([char(C{4}) ' ' char(C{5})],'yy/mm/dd HH:MM:SS');
%    LST = datenum([char(C{6}) ' ' char(C{7})],'yy/mm/dd HH:MM:SS');
   UTC = datenum([char(C{4}) ' ' char(C{5})],'yy-mm-dd HH:MM:SS');
   UTC = STRREP(UTC,'/','-');
   LST = datenum([char(C{6}) ' ' char(C{7})],'yy-mm-dd HH:MM:SS');
   LTC = STRREP(LTC,'/','-');
   prede.UTC_start = UTC;
   prede.UTC_str = datestr(UTC,'yyyy-mm-dd');
   prede.LST_offset = (UTC - LST)*24;
   % Read line 2
   tmp = fgetl(fid);
   C = textscan(tmp,'%d','delimiter',',');
   C = C{1};
   if length(C) == (C(1)+1)
      prede.numFilters = double(C(1));
      prede.wl = double(C(2:end));
   else
      disp('Badly formatted filter string in second line.')
   end
   % Read line 3
   tmp = fgetl(fid);
   C = textscan(tmp,'%*s %*s %*s %*s %s %s %s','delimiter',',');
   sky_mode = C{1}{:};
   %    if isfield(prede,sky_mode)
   %       rec = length(prede.(sky_mode).time)+1;
   %    else
   %       rec = 1;
   %    end
   prede.location = C{2}{:};
   prede.setup_fname = C{3}{:};
   while ~done&&~feof(fid)
      tmp = fgetl(fid);
      if ~isempty(tmp)
         if isfield(prede,sky_mode)
            rec = length(prede.(sky_mode).time)+1;
         else
            rec = 1;
         end
         format_str = '%s %*s %f %f %f %f %f %f %f %f %f';
         C = textscan(tmp,format_str, 'delimiter',',');
         UTC = C{1}{:};
         prede.(sky_mode).azi(rec) = C{2}+180;
         prede.(sky_mode).ele(rec) = C{3};
         prede.(sky_mode).zen(rec) = 90-C{3};
         for f = 1:prede.numFilters
            prede.(sky_mode).(['filter_' num2str(f)])(rec) = C{4+f-1};
         end
         %          {sky_mode, num2str(rec)}
         prede.(sky_mode).time(rec) = datenum([prede.UTC_str ' ' UTC],'yyyy-mm-dd HH:MM:SS');
      end
   end
   fclose(fid);
   if any(diff(prede.R.time)<0)
      jump = 1+find(diff(prede.R.time)<0);
      prede.R.time(jump:end) = prede.R.time(jump:end)+1;
   end
end
% pause(.1);

