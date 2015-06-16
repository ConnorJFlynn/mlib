function cimel = read_cimel_aip(filename);
%This should read any of the Aeronet files.  Not fully tested...
if ~exist('filename', 'var')
   filename = getfullname('*.*','cimel');
elseif ~exist(filename,'file')
   filename = getfullname(filename,'cimel');
end
[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];

fid = fopen(filename);

if fid>0
   cimel.fname = fname;
   cimel.pname = pname;
   done = false; header_rows = 0;
   while ~done
      tmp = fgetl(fid);
      if ((tmp(1)>47)&&(tmp(1)<58)&&isempty(findstr(tmp,'Locations=')))|feof(fid)
         done = true;
      else
         header_rows = header_rows +1;
         if findstr(tmp,'long=')&findstr(tmp,'lat=')&findstr(tmp,'Email')
            tmp = strrep(tmp,'Locations=','Location=');
            loc_line = tmp;
         end
         if findstr(tmp,'Date(')&findstr(tmp,'Time(')
            label_line = tmp;
         end
      end
   end
   cimel.loc_line = loc_line;
   cimel.label_line = label_line;

   pat = 'Location=';
   i = strfind(loc_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   [tok,rest] = strtok(loc_line((j+1):end),',');
   cimel.Location = tok;

   pat = 'long=';
   i = strfind(loc_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   cimel.lon = sscanf(loc_line(k:end),'%f');

   pat = 'lat=';
   i = strfind(loc_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   cimel.lat = sscanf(loc_line(k:end),'%f');

   pat = 'elev=';
   i = strfind(loc_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   cimel.alt = sscanf(loc_line(k:end),'%f');

   pat = 'PI=';
   i = strfind(loc_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   [tok,rest] = strtok(loc_line((j+1):end),',');
   cimel.PI = tok;

   pat = 'Email=';
   i = strfind(loc_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   [tok,rest] = strtok(loc_line((j+1):end),',');
   cimel.email = tok;

   label{1} = 'Date'; label{2} = 'Time';
   %Strip date and time from label_line, also remove trailing comma-delimiter
   [tok,label_line] = strtok(label_line,',');
   label_line = label_line(2:end);
   [tok,label_line] = strtok(label_line,',');
   label_line = label_line(2:end);
   format_str = '%s %s ';
   lab = 3;
   while ~isempty(label_line)
      [tmp,label_line] = strtok(label_line,',');
      label_line = label_line(2:end);
      ang = findstr(lower(tmp),'angstrom');
      if ang>0
         tmp = ['Angstrom_' tmp(1:(ang-1))];
      end
      tmp = legalizename(tmp);
      label{lab} = tmp;
      if ~isempty(findstr(lower(label{lab}),'date'))||~isempty(findstr(label{lab},'DATA_TYPE'))
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
         this = txt{1};
         txt(1) = [];label(1) = [];
         that = txt{1};
         txt(1) = [];label(1) = [];
         for d = length(this):-1:1
            dates{d} = [this{d},' ',that{d}];
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