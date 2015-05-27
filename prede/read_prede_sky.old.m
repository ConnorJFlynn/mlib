function prede = read_prede_sky(filename);
%This should read Prede sky-scan files
if ~exist('filename', 'var')
   filename= getfullname('*.dat','prede_scan');
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
end

% Prede sky-scan header looks like this:
% POM-01,0000000,0000000,-119.279, 046.341,08/05/31,00:34:47,08/05/30,17:34:47
% 7,0315,0400,0500,0675,0870,0940,1020
% 08/05/31,00:34:47,08/05/30,17:34:47,H,PNNL,pnnl201.obs
% Disection:
% Line 1: ModelNum, ?,?,lat, lon, yy/mm/dd,HH:MM:SS (UTC) yy/mm/dd,HH:MM:SS(LST)
% Line 2: Filters, WL1, WL2, WL3, WL..N (in nm)
% Line 3: yy/mm/dd,HH:MM:SS (UTC), yy/mm/dd,HH:MM:SS(LST), mode H = horiz scan, location?, setup_filename

fid = fopen(filename);
if fid>0
   prede.fname = fname;
   done = false; header_rows = 0;
   % Read line 1
   tmp = fgetl(fid);
   C = textscan(tmp,'%s %*d %*d %f %f %s %s %s %s', 'delimiter',',');
   prede.model = C{1};
   prede.lon = C{2};
   prede.lat = C{3};
   UTC = datenum([char(C{4}) ' ' char(C{5})],'yy/mm/dd HH:MM:SS');
   LST = datenum([char(C{6}) ' ' char(C{7})],'yy/mm/dd HH:MM:SS');
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
   if isfield(prede,sky_mode)
      scan = length(prede.(sky_mode).time)+1;
   else
      scan = 1;
   end
   rec = 1;
   prede.location = C{2}{:};
   prede.setup_fname = C{3}{:};
   while ~done&&~feof(fid)
      tmp = fgetl(fid);
      if findstr(tmp,prede.setup_fname)
         C = textscan(tmp,'%*s %*s %*s %*s %s %s %s','delimiter',',');
         sky_mode = C{1}{:};
         if isfield(prede,sky_mode)
            scan = length(prede.(sky_mode))+1;
         else
            scan = 1;
         end
         rec = 1;
         prede.location = C{2};
         prede.setup_fname = C{3}{:};
      else
         format_str = '%s %*s %f %f %f %f %f %f %f %f %f';
         C = textscan(tmp,format_str, 'delimiter',',');
         UTC = C{1}{:};
         prede.(sky_mode)(scan).azi(rec) = C{2}+180;
         prede.(sky_mode)(scan).elev(rec) = C{3};
         for f = 1:prede.numFilters
            prede.(sky_mode)(scan).(['filter_' num2str(f)])(rec) = C{4+f-1};
         end
         prede.(sky_mode)(scan).time(rec) = datenum([prede.UTC_str ' ' UTC],'yyyy-mm-dd HH:MM:SS');
         rec = rec + 1;
      end
   end
   fclose(fid);
end

