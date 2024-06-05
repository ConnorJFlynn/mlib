function cimel = read_cimel_cloudrad_v3(filename)
%cimel = read_cimel_cloudrad(filename);
% https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_zenith_radiance_v3?site=Cart_Site&year=2024&month=4&day=26&year2=2024&month2=4&day2=28&ZEN00=1&AVG=10&if_no_html=1
if ~exist('filename', 'var')
   filename = getfullname('*.*','cimel_cloud');
elseif ~exist(filename,'file')
   filename = getfullname(filename,'cimel_cloud');
end
[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];

fid = fopen(filename,'r');
blah =  webwrite(httpUrl,data);
blah = char(fread(fid,'uchar=>uchar'))';
fclose(fid);
blah = strrep(blah,',<br>',''); blah = strrep(blah,'<br>','');
blah = strrep(blah,'</body></html>','');
fid = fopen(filename,'w');
blah = fwrite(fid,blah);
fclose(fid);
fid = fopen(filename,'r');


if fid>0
   cimel.fname = fname;
   cimel.pname = pname;
   done = false; header_rows = 0;
   tmp = [];
   while ~done
      while isempty(tmp)&&~feof(fid)
         tmp = fgetl(fid);
         header_rows = header_rows +1;
      end
      if isavar('label_line') %((tmp(1)>47)&&(tmp(1)<58)&&isempty(strfind(tmp,'Locations')))|feof(fid)
         done = true;
      else
         header_rows = header_rows +1;
         if strfind(tmp,'Longitude=')&strfind(tmp,'Latitude=')
            loc_line = tmp;
         end
         if (findstr(tmp,'Date(')&findstr(tmp,'Time(')) | (findstr(tmp,'Date (')&findstr(tmp,'Time ('))
            label_line = tmp;
            header_rows = header_rows -1;
         end
         tmp = fgetl(fid);
      end
      
   end
   if ~isavar('loc_line')
      loc_line = [];
   else
      cimel.loc_line = loc_line;

      pat = 'Location=';
      i = strfind(loc_line,pat);
      j = i(1)+length(pat)-1;
      k = j+1;
      [tok,rest] = strtok(loc_line((j+1):end),',');
      cimel.Location = tok;

      pat = 'Longitude=';
      i = strfind(loc_line,pat);
      j = i(1)+length(pat)-1;
      k = j+1;
      cimel.lon = sscanf(loc_line(k:end),'%f');

      pat = 'Latitude=';
      i = strfind(loc_line,pat);
      j = i(1)+length(pat)-1;
      k = j+1;
      cimel.lat = sscanf(loc_line(k:end),'%f');

      pat = 'Elevation[m]=';
      i = strfind(loc_line,pat);
      j = i(1)+length(pat)-1;
      k = j+1;
      cimel.alt = sscanf(loc_line(k:end),'%f');
   end
   cimel.label_line = label_line;

   label{1} = 'Site'; label{2} = 'Date'; label{3} = 'Time';
   %Strip date and time from label_line, also remove trailing comma-delimiter
   [tok,label_line] = strtok(label_line,',');
   label_line = label_line(2:end);
   [tok,label_line] = strtok(label_line,',');
   label_line = label_line(2:end);
   [tok,label_line] = strtok(label_line,',');
   label_line = label_line(2:end);
   format_str = '%s %s %s ';
   lab = 4;
   while ~isempty(label_line)
      [tmp,label_line] = strtok(label_line,',');
      label_line = label_line(2:end);
      tmp = legalizename(tmp);
      label{lab} = tmp;
      if ~isempty(findstr(lower(label{lab}),'date'))||~isempty(findstr(lower(label{lab}),'time'))||~isempty(findstr(label{lab},'Sky_Scan'))||~isempty(findstr(label{lab},'AERONET_Site'))
         format_str = [format_str '%s '];
      else 
         format_str = [format_str '%f '];
      end
      lab = lab +1;
   end

   if header_rows > 0
      fseek(fid,0,-1);
      txt = textscan(fid,format_str,'headerlines',header_rows,'delimiter',',','treatAsEmpty','N/A');
      if length(txt)~=length(label);
         disp('Mismatch between number of labels and number of columns')
         return
      else
         txt(1) = [];label(1) = [];
         this = txt{1};
         txt(1) = [];label(1) = [];
         that = txt{1};
         txt(1) = [];label(1) = [];
         thisthat = [this,that];
         for d = length(this):-1:1
              dates(d,:) = [thisthat{d,1},' ',thisthat{d,2}];
%             dates{d} = [this{d},' ',that{d}];
         end
         try
            cimel.time = datenum(dates,'dd:mm:yyyy HH:MM:SS');
         catch
            cimel.time = datenum(dates,'dd-mm-yyyy HH:MM:SS');
         end
            

         while length(label)>0
            if isnumeric(txt{1})&&~all(isNaN(txt{1}))
               cimel.(label{1}) = txt{1};
            elseif ~isempty(findstr(lower(label{1}),'date'))
               cimel.(label{1}) = datenum(txt{1},'dd/mm/yyyy');
%             elseif isempty(findstr(lower(label{1}),'data_type'))
%                cimel.(label{1}) = txt{1};
%             else
            end
            txt(1) = [];
            label(1) = [];
         end
         % From aeronet_zenith_radiance for PPL
         cimel.zenrad_units = 'mW/(m^2 nm sr)';
         flds = fieldnames(cimel);
         for f = length(flds):-1:1;
            fld = flds{f};
            if (strcmp(fld(1),'K')||strcmp(fld(1),'A'))&&strcmp(fld(end-1:end),'nm')
               cimel.(fld) = 10.*cimel.(fld);
            end
         end
         % Original units µW/cm^2/sr/nm = mW/cm^2/sr/um
         % 1e-3 * 1e4
         % Desire radiance units W/(m^2 um sr)
         % aip.sky_rad = aip.sky_rad * 10;


      end
   end
   fclose(fid);
end
return;

function newname = legalizename(oldname)
% Replaces illegal characters in names of structure elements.
newname = oldname;
if ((newname(1)>47)&(newname(1)<58))
   newname = ['pos',newname];
end
if newname(1) == '-'
   newname = ['neg',newname ];
end
newname = strrep(newname,'%','pct_');
newname = strrep(newname,'(','_');
newname = strrep(newname,')','_');
newname = strrep(newname,'[','_');
newname = strrep(newname,']','_');
newname = strrep(newname,'{','_');
newname = strrep(newname,'}','_');
newname = strrep(newname,' ','_');
newname = strrep(newname,'-','_');
newname = strrep(newname,'/','_');
newname = strrep(newname,'+','_');
newname = strrep(newname,'>=','_gte_');
newname = strrep(newname,'<=','_lte_');
newname = strrep(newname,'>','_gt_');
newname = strrep(newname,'<','_lt_');
newname = strrep(newname,'=','_eq_');
newname = strrep(newname,'.','pt');
if newname(1) == '_'
   newname = ['underbar',newname ];
end

return