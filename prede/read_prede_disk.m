function prede = read_prede_disk(filename);
%This should read Prede disk scan files
if ~exist('filename', 'var')
   filename= getfullname_('*.V*','prede_disk');
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
end

% Prede V__ header looks like this:
% POM-01,0000000,0000000,-119.279, 046.341,08/05/31,00:30:39,08/05/30,17:30:39
% 7,0315,0400,0500,0675,0870,0940,1020
% 08/05/31,00:30:39,08/05/30,17:30:39,D,500,PNNL,pnnl201.obs
% Disection:
% Line 1: ModelNum, ?,?,lat, lon, yy/mm/dd,HH:MM:SS (UTC) yy/mm/dd,HH:MM:SS(LST)
% Line 2: Filters, WL1, WL2, WL3, WL..N (in nm)
% Line 3: yy/mm/dd,HH:MM:SS (UTC), yy/mm/dd,HH:MM:SS(LST), mode (D=diskscan), 500 = monitor filter, location?, setup_filename

fid = fopen(filename);
if fid>0
   prede.fname = fname;
   done = false; header_rows = 0;
      tmp = fgetl(fid);
      C = textscan(tmp,'%s %*d %*d %f %f %s %s %s %s', 'delimiter',',');
      prede.model = C{1};
      prede.lon = C{2};
      prede.lat = C{3};
      try
      UTC = datenum([char(C{4}) ' ' char(C{5})],'yy-mm-dd HH:MM:SS');
      catch
         UTC = datenum([char(C{4}) ' ' char(C{5})],'yy/mm/dd HH:MM:SS');
      end
      try
         LST = datenum([char(C{6}) ' ' char(C{7})],'yy-mm-dd HH:MM:SS');
      catch
         LST = datenum([char(C{6}) ' ' char(C{7})],'yy/mm/dd HH:MM:SS');
      end
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
      
      format_str = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
      C = textscan(fid,format_str,'delimiter',',');
      ii = 1;
      while (length(C{ii})>length(C{end}))&ii<length(C)
        C{ii}(end) = []; 
        ii = ii+1;
      end
      prede.deg = C{1};
      for i = length(prede.deg):-1:1
         prede.disk(:,i) = C{i+1};
      end

end
%%
prede.min_disk = min(min(prede.disk));
prede.disk_normed = prede.disk - prede.min_disk;
prede.max_disk = max(max(prede.disk));
prede.disk_normed = prede.disk./prede.max_disk;

%%
figure; surf(prede.deg, prede.deg, prede.disk_normed);
%%
