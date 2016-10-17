function cimel = read_cimel_aod(filename);
%This should read any of the files from the Aeronet AOD site, but not the
%inversions.  To read the inversions, try read_cimel_aip
if ~exist('filename', 'var')
   filename= getfullname('*.lev20*','anet_aod');
end
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
% end
% Level 2.0. Quality Assured Data.<p>The following data are pre and post field calibrated, automatically cloud cleared and manually inspected.
% Version 2 Direct Sun Algorithm
% Location=Cart_Site,long=-97.486,lat=36.607,elev=318,Nmeas=3,PI=Rick_Wagener,Email=wagener@bnl.gov
% AOD Level 2.0,Daily Averages,UNITS can be found at,,, http://aeronet.gsfc.nasa.gov/data_menu.html
% Date(dd-mm-yy),Time(hh:mm:ss),Julian_Day,AOT_1640,AOT_1020,AOT_870,AOT_675,AOT_667,AOT_555,AOT_551,AOT_532,AOT_531,AOT_500,AOT_490,AOT_443,AOT_440,AOT_412,AOT_380,AOT_340,Water(cm),%TripletVar_1640,%TripletVar_1020,%TripletVar_870,%TripletVar_675,%TripletVar_667,%TripletVar_555,%TripletVar_551,%TripletVar_532,%TripletVar_531,%TripletVar_500,%TripletVar_490,%TripletVar_443,%TripletVar_440,%TripletVar_412,%TripletVar_380,%TripletVar_340,%WaterError,440-870Angstrom,380-500Angstrom,440-675Angstrom,500-870Angstrom,340-440Angstrom,440-675Angstrom(Polar),N[AOT_1640],N[AOT_1020],N[AOT_870],N[AOT_675],N[AOT_667],N[AOT_555],N[AOT_551],N[AOT_532],N[AOT_531],N[AOT_500],N[AOT_490],N[AOT_443],N[AOT_440],N[AOT_412],N[AOT_380],N[AOT_340],N[Water(cm)],N[440-870Angstrom],N[380-500Angstrom],N[440-675Angstrom],N[500-870Angstrom],N[340-440Angstrom],N[440-675Angstrom(Polar)]
% 09:04:1994,00:00:00,99.000000,N/A,0.183468,0.219118,0.296234,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,0.461879,N/A,0.511920,0.547170,2.515951,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,1.085359,0.691464,1.049668,1.152921,0.646608,N/A,N/A,3,3,3,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,3,N/A,3,3,3,3,3,3,3,3,N/A

fid = fopen(filename);
if fid>0
   cimel.fname = filename;
   cimel.pname = pname;
   done = false; header_rows = 0;
   while ~done
      tmp = fgetl(fid);
      if ((tmp(1)>47)&(tmp(1)<58))|feof(fid)
         done = true;
      else
         header_rows = header_rows +1;
         if (~isempty(findstr(tmp,'long='))&~isempty(findstr(tmp,'lat='))&~isempty(findstr(tmp,'Email')))...
               ||(~isempty(findstr(tmp,'Longitude='))&~isempty(findstr(tmp,'Latitude='))&~isempty(findstr(tmp,'Email')))
            tmp = strrep(tmp,'Locations=','Location=');
            loc_line = tmp;
         end
         if findstr(tmp,'Date(dd-mm-yy)')&findstr(tmp,'Time(hh:mm:ss)')
            label_line = tmp;
         end
      end
   end
   cimel.loc_line = loc_line;
   if exist('label_line','var')
   cimel.label_line = label_line;
   end

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
      label{lab} = legalizename(tmp);
      if findstr(label{lab},'Date')
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
         for d = 1:length(this)
            dates{d} = [this{d},' ',that{d}];
         end
         cimel.time = datenum(dates,'dd:mm:yyyy HH:MM:SS');

         while length(label)>0
            if findstr(lower(label{1}),'date')
               cimel.(label{1}) = datenum(txt{1},'dd/mm/yyyy');
            else
               if ~all(isNaN(txt{1}))
                  cimel.(label{1}) = txt{1};
               end
            end
            txt(1) = [];
            label(1) = [];
         end
      end
   end
end
return;

function newname = legalizename(oldname)
% Replaces illegal characters in names of structure elements.
newname = oldname;
if ((newname(1)>47)&(newname(1)<58))
   newname = ['n_',newname];
end
newname = strrep(newname,'%','');
newname = strrep(newname,'(','_');
newname = strrep(newname,')','_');
newname = strrep(newname,' ','_');
newname = strrep(newname,'-','_');
newname = strrep(newname,'+','_');
newname = strrep(newname,'[','_');
newname = strrep(newname,']','_');
newname = strrep(newname,'/','_');
if newname(1) == '_'
   newname(1) = ['underbar__'];
end

return