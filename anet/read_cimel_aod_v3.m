function cimel = read_cimel_aod_v3(filename);
%This should read AOD version 3 files from the Aeronet AOD site, but not the
%inversions.  To read the inversions, try read_cimel_aip
if ~exist('filename', 'var')
   filename= getfullname('*.lev*','anet_aod');
end
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];

% AERONET Version 3; 
% ARM_Highlands_MA
% Version 3: AOD Level 1.5
% The following data are cloud cleared and quality controls have been applied but these data may not have final calibration applied.  These data may change.
% Contact: PI=Rick_Wagener_and_Laurie_Gregory; PI Email=wagener@bnl.gov_and_gregory@bnl.gov
% All Points,UNITS can be found at,,, http://aeronet.gsfc.nasa.gov/new_web/units.html
% Date(dd-mm-yyyy),Time(hh:mm:ss),Day_of_Year,Day_of_Year(Fraction),AOD_1640nm,AOD_1020nm,AOD_870nm,AOD_675nm,AOD_667nm,AOD_555nm,AOD_551nm,AOD_532nm,AOD_531nm,AOD_500nm,AOD_490nm,AOD_443nm,AOD_440nm,AOD_412nm,AOD_380nm,AOD_340nm,Precipitable_Water(cm),Triplet_Variability_1640,Triplet_Variability_1020,Triplet_Variability_870,Triplet_Variability_675,Triplet_Variability_667,Triplet_Variability_555,Triplet_Variability_551,Triplet_Variability_532,Triplet_Variability_531,Triplet_Variability_500,Triplet_Variability_490,Triplet_Variability_443,Triplet_Variability_440,Triplet_Variability_412,Triplet_Variability_380,Triplet_Variability_340,Triplet_Variability_Precipitable Water(cm),440-870_Angstrom_Exponent,380-500_Angstrom_Exponent,440-675_Angstrom_Exponent,500-870_Angstrom_Exponent,340-440_Angstrom_Exponent,440-675_Angstrom_Exponent[Polar],Data_Quality_Level,AERONET_Instrument_Number,Site_Latitude(Degrees),Site_Longitude(Degrees),Site_Elevation(m),Solar_Zenith_Angle(Degrees),Optical_Air_Mass,Sensor_Temperature(Degrees_C),Ozone(Dobson),NO2(Dobson),Last_Date_Processed,Number_of_Wavelengths,Exact_Wavelengths_of_AOD
% 15:07:2012,13:31:40,197,197.563657,0.034630,0.062542,0.084788,0.135716,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,0.248363,-999.000000,-999.000000,0.306553,-999.000000,0.384448,0.434197,2.322172,0.002402,0.002370,0.002895,0.002983,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,0.002127,-999.000000,-999.000000,0.001715,-999.000000,0.001923,0.003038,0.011069,1.912505,1.605432,1.932701,1.944621,1.362569,-999.,lev15,402,42.030478,-70.049317,47.853600,45.453674,1.423875,28.000000,0.329231,0.208681,28:06:2016,8,1.639400,1.020700,0.867600,0.672700,0.498900,0.439400,0.380100,0.339700

% Another format wtih date using colons instead of dashes.
% Date(dd:mm:yyyy),Time(hh:mm:ss),Day_of_Year,Day_of_Year(Fraction),AOD_1640nm,AOD_1020nm,AOD_870nm,AOD_865nm,AOD_779nm,AOD_675nm,AOD_667nm,AOD_620nm,AOD_560nm,AOD_555nm,AOD_551nm,AOD_532nm,AOD_531nm,AOD_510nm,AOD_500nm,AOD_490nm,AOD_443nm,AOD_440nm,AOD_412nm,AOD_400nm,AOD_380nm,AOD_340nm,Precipitable_Water(cm),AOD_681nm,AOD_709nm,AOD_Empty,AOD_Empty,AOD_Empty,AOD_Empty,AOD_Empty,Triplet_Variability_1640,Triplet_Variability_1020,Triplet_Variability_870,Triplet_Variability_865,Triplet_Variability_779,Triplet_Variability_675,Triplet_Variability_667,Triplet_Variability_620,Triplet_Variability_560,Triplet_Variability_555,Triplet_Variability_551,Triplet_Variability_532,Triplet_Variability_531,Triplet_Variability_510,Triplet_Variability_500,Triplet_Variability_490,Triplet_Variability_443,Triplet_Variability_440,Triplet_Variability_412,Triplet_Variability_400,Triplet_Variability_380,Triplet_Variability_340,Triplet_Variability_Precipitable_Water(cm),Triplet_Variability_681,Triplet_Variability_709,Triplet_Variability_AOD_Empty,Triplet_Variability_AOD_Empty,Triplet_Variability_AOD_Empty,Triplet_Variability_AOD_Empty,Triplet_Variability_AOD_Empty,440-870_Angstrom_Exponent,380-500_Angstrom_Exponent,440-675_Angstrom_Exponent,500-870_Angstrom_Exponent,340-440_Angstrom_Exponent,440-675_Angstrom_Exponent[Polar],Data_Quality_Level,AERONET_Instrument_Number,AERONET_Site_Name,Site_Latitude(Degrees),Site_Longitude(Degrees),Site_Elevation(m),Solar_Zenith_Angle(Degrees),Optical_Air_Mass,Sensor_Temperature(Degrees_C),Ozone(Dobson),NO2(Dobson),Last_Date_Processed,Number_of_Wavelengths,Exact_Wavelengths_of_AOD(um)_1640nm,Exact_Wavelengths_of_AOD(um)_1020nm,Exact_Wavelengths_of_AOD(um)_870nm,Exact_Wavelengths_of_AOD(um)_865nm,Exact_Wavelengths_of_AOD(um)_779nm,Exact_Wavelengths_of_AOD(um)_675nm,Exact_Wavelengths_of_AOD(um)_667nm,Exact_Wavelengths_of_AOD(um)_620nm,Exact_Wavelengths_of_AOD(um)_560nm,Exact_Wavelengths_of_AOD(um)_555nm,Exact_Wavelengths_of_AOD(um)_551nm,Exact_Wavelengths_of_AOD(um)_532nm,Exact_Wavelengths_of_AOD(um)_531nm,Exact_Wavelengths_of_AOD(um)_510nm,Exact_Wavelengths_of_AOD(um)_500nm,Exact_Wavelengths_of_AOD(um)_490nm,Exact_Wavelengths_of_AOD(um)_443nm,Exact_Wavelengths_of_AOD(um)_440nm,Exact_Wavelengths_of_AOD(um)_412nm,Exact_Wavelengths_of_AOD(um)_400nm,Exact_Wavelengths_of_AOD(um)_380nm,Exact_Wavelengths_of_AOD(um)_340nm,Exact_Wavelengths_of_PW(um)_935nm,Exact_Wavelengths_of_AOD(um)_681nm,Exact_Wavelengths_of_AOD(um)_709nm,Exact_Wavelengths_of_AOD(um)_Empty,Exact_Wavelengths_of_AOD(um)_Empty,Exact_Wavelengths_of_AOD(um)_Empty,Exact_Wavelengths_of_AOD(um)_Empty,Exact_Wavelengths_of_AOD(um)_Empty
% 02:01:2008,15:50:28,2,2.660046,0.027715,0.030546,0.030595,-999.000000,-999.000000,0.031348,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,0.036988,-999.000000,-999.000000,0.038891,-999.000000,-999.000000,0.039517,0.039591,0.426345,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,0.004762,0.003593,0.003766,-999.000000,-999.000000,0.004068,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,0.004889,-999.000000,-999.000000,0.004220,-999.000000,-999.000000,0.004231,0.004667,0.027218,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,-999.000000,0.375972,0.237546,0.516072,0.347983,0.070908,-999.000000,lev15,374,TABLE_MOUNTAIN_CA,34.380000,-117.680000,2200.000000,81.377596,6.404450,8.500000,0.285357,0.268806,12:04:2018,9,1.642900,1.020900,0.870800,-999.,-999.,0.673700,-999.,-999.,-999.,-999.,-999.,-999.,-999.,-999.,0.500300,-999.,-999.,0.440500,-999.,-999.,0.380200,0.340000,0.940200,-999.,-999.,-999.,-999.,-999.,-999.,-999.


% One notable difference in V3 files is that lat/lon have become column values.   
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
         if ~isempty(findstr(tmp,'Email='))
            contact_line = tmp;
         end
         if ~isempty(strfind(tmp,'Date(dd-mm-yy'))&&~isempty(strfind(tmp,'Time(hh:mm:ss)'))...
               ||(~isempty(strfind(tmp,'Date(dd:mm:yy'))&&~isempty(strfind(tmp,'Time(hh:mm:ss)')))
            label_line = tmp;
         end
      end
   end
%    cimel.loc_line = loc_line;
   if exist('label_line','var')
   cimel.label_line = label_line;
   end

%    pat = 'Location=';
%    i = strfind(loc_line,pat);
%    j = i(1)+length(pat)-1;
%    k = j+1;
%    [tok,rest] = strtok(loc_line((j+1):end),',');
%    cimel.Location = tok;
% 
%    pat = 'long=';
%    i = strfind(loc_line,pat);
%    j = i(1)+length(pat)-1;
%    k = j+1;
%    cimel.lon = sscanf(loc_line(k:end),'%f');
% 
%    pat = 'lat=';
%    i = strfind(loc_line,pat);
%    j = i(1)+length(pat)-1;
%    k = j+1;
%    cimel.lat = sscanf(loc_line(k:end),'%f');
% 
%    pat = 'elev=';
%    i = strfind(loc_line,pat);
%    j = i(1)+length(pat)-1;
%    k = j+1;
%    cimel.alt = sscanf(loc_line(k:end),'%f');

   pat = 'PI=';
   i = strfind(contact_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   [tok,rest] = strtok(contact_line((j+1):end),';');
   cimel.PI = tok;

   pat = 'Email=';
   i = strfind(contact_line,pat);
   j = i(1)+length(pat)-1;
   k = j+1;
   [tok,rest] = strtok(contact_line((j+1):end),';');
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
      ang = findstr(lower(tmp),'angstrom_exponent[polar]');
      if ang>0
         tmp = ['AE_Pol_' tmp(1:(ang-1))];
      end      
      ang = findstr(lower(tmp),'angstrom');
      if ang>0
         tmp = ['AE_' tmp(1:(ang-1))];
      end
      label{lab} = legalizename(tmp); legalizename(tmp);
      if ~isempty(strfind(label{lab},'Date'))...
            ||~isempty(strfind(label{lab},'Data_Quality'))...
            ||~isempty(strfind(label{lab},'Site_Name'))
         format_str = [format_str '%s '];
      elseif ~isempty(strfind(label{lab},'Exact_Wavelengths')) || ~isempty(strfind(label{lab},'Empty'))
          format_str = [format_str '%*s ']; 
          label(lab) = []; lab = lab -1;
      else
         format_str = [format_str '%f '];
      end
      lab = lab +1;
   end
   data_line = fgetl(fid); data_cols = length(strfind(data_line,','))+1;
   format_str = [format_str, repmat('%f ',[1,data_cols - length(label)])];

   if header_rows > 0
      fseek(fid,0,-1);
      txt = textscan(fid,format_str,'headerlines',header_rows,'delimiter',',','treatAsEmpty','N/A');
%       if length(txt)~=length(label);
%          disp('Mismatch between number of labels and number of columns')
%          return
%       else
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
               cimel.(label{1}) = datenum(txt{1},'dd:mm:yyyy');
            else
%                if ~all(isempty(txt{1}))||~all(isNaN(txt{1}))
                  cimel.(label{1}) = txt{1};
%                end
            end
            txt(1) = [];
            label(1) = [];
         end
%       end
   end
   if isfield(cimel,'Number_of_Wavelengths')&&(cimel.Number_of_Wavelengths(1)==length(txt))
       for X = 1:cimel.Number_of_Wavelengths(1)
           cimel.(['Exact_wavelength_',num2str(X)]) = txt{1}; txt(1) = [];
       end
   end
   % Remove empty fields
   fields = fieldnames(cimel);
   for fld = 1:length(fields)
      field = fields{fld};
      if isnumeric(cimel.(field))&&all(cimel.(field)<=-998)
         cimel = rmfield(cimel,field);
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
if newname(end) == '_'
   newname(end) = [];
end

return