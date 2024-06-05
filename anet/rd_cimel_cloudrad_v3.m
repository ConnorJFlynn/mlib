function cimel = rd_cimel_cloudrad_v3(end_date,start_date,  site)
%cimel = rd_cimel_cloudrad_v3(end_date, start_date, site)
% Use webservice call to get cloudrad data.
% ALL arguments are optional.  
%   Default end_date = ceil(now);     % (today);
%   Default start_date = end_date -1; % (yesterday);
%   Default site = "ARM_SGP"; "OU_NWC"

% https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_zenith_radiance_v3?site=Cart_Site&year=2024&month=4&day=26&year2=2024&month2=4&day2=28&ZEN00=1&AVG=10&if_no_html=1

if ~isavar('end_date')||isempty(end_date)
   end_date = ceil(now);
end
if ~isavar('start_date')||isempty(start_date)
   start_date = end_date-1;
end
if end_date==start_date
   start_date = end_date - 1;
end
if ~isavar('site')
   site = 'ARM_SGP';
end
V = datevec(start_date); year = num2str(V(1));month=num2str(V(2));day=num2str(V(3));
V = datevec(end_date); year2 = num2str(V(1));month2=num2str(V(2));day2=num2str(V(3));
blop = 'ZEN00=1&AVG=10&if_no_html=1';
httpUrl = "https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_zenith_radiance_v3?";
data = "site=ARM_SGP&year=2024&month=4&day=27&year2=2024&month2=4&day2=30&ZEN00=1&AVG=10&if_no_html=1";
data2 = sprintf("site=%s&year=%s&month=%s&day=%s&year2=%s&month2=%s&day2=%s&%s",site, year, month, day, year2,month2,day2,blop);
blah =  webwrite(httpUrl,data2);
blah = strrep(blah,',<br>',''); blah = strrep(blah,'<br>','');
blah = strrep(blah,'</body></html>','');


   tmp = [];header_rows = 0;done = isempty(blah);
   while ~done
      while isempty(tmp)&&~isempty(blah)
         [tmp, blah] = getl(blah);
         header_rows = header_rows +1;
      end
      if isavar('label_line')||isempty(blah) 
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
         [tmp,blah] = getl(blah);
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
   if isavar('label_line')
   cimel.label_line = label_line;
   else
      cimel = [];
   end
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
      [tmp2,label_line] = strtok(label_line,',');
      label_line = label_line(2:end);
      tmp2 = legalizename(tmp2);
      label{lab} = tmp2;
      if ~isempty(findstr(lower(label{lab}),'date'))||~isempty(findstr(lower(label{lab}),'time'))||~isempty(findstr(label{lab},'Sky_Scan'))||~isempty(findstr(label{lab},'AERONET_Site'))
         format_str = [format_str '%s '];
      else 
         format_str = [format_str '%f '];
      end
      lab = lab +1;
   end

   if header_rows > 0
      txt = textscan([tmp,blah],format_str,'delimiter',',','treatAsEmpty','N/A');
      if length(txt)~=length(label)
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
            

         while ~isempty(label)
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
         for f = length(flds):-1:1
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

return;

function newname = legalizename(oldname)
% Replaces illegal characters in names of structure elements.
newname = oldname;
if ((newname(1)>47)&&(newname(1)<58))
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