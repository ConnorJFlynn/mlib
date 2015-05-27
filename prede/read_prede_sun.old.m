function prede = read_prede_sun(filename);
%This should read Prede sun tracking files
if ~exist('filename', 'var')
   filename= getfullname('*.SUN','prede_sun');
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
end

% Prede SUN header looks like this:
% POM-01,0000000,0000000,-119.279, 046.341,08/05/15,12:30:38,08/05/15,05:30:38
% 7,0315,0400,0500,0675,0870,0940,1020
% 08/05/15,12:30:38,08/05/15,05:30:38,S,PNNL,pnnl201.obs
% Disection:
% Line 1: ModelNum, ?,?,lat, lon, yy/mm/dd,HH:MM:SS (UTC) yy/mm/dd,HH:MM:SS(LST)
% Line 2: Filters, WL1, WL2, WL3, WL..N (in nm)
% Line 3: yy/mm/dd,HH:MM:SS (UTC), yy/mm/dd,HH:MM:SS(LST), mode S = sun, location?, setup_filename

fid = fopen(filename);
if fid>0
   prede.fname = fname;
   done = false; header_rows = 0;
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
      tmp = fgetl(fid);
      C = textscan(tmp,'%d','delimiter',',');
      C = C{1};
      if length(C) == (C(1)+1) 
         prede.numFilters = double(C(1));
         prede.wl = double(C(2:end));
      else
         disp('Badly formatted filter string in second line.')
      end
      tmp = fgetl(fid);
      C = textscan(tmp,'%*s %*s %*s %*s %s %s %s','delimiter',',');
      prede.mode = C{1};
      prede.location = C{2};
      prede.setup_fname = C{3};
      
      format_str = '%s %*s %f %f %f %f %f %f %f %f %f';
      C = textscan(fid,format_str,'delimiter',',');
      UTC = C{1};
      for t = length(UTC):-1:1
         prede.time(t) = datenum([prede.UTC_str ' ' char(UTC{t})],'yyyy-mm-dd HH:MM:SS');
      end
      prede.azi = C{2}+180;
      prede.elev = C{3};
      for f = 1:prede.numFilters
         prede.(['filter_' num2str(f)]) = C{4+f-1};
      end
end

