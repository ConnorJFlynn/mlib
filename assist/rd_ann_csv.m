function ann = rd_ann_csv(infile);
% ann = rd_ann_csv(infile);;
% Reads an ASSIST "csv" annotation file 
% Accepts optional infile
if ~exist('infile','var')||~exist(infile,'file')
   infile = getfullname('*.csv','assist_ann','Select ASSIST annotation file.');
end
% Edgar Annpro BETA v1.4.13; Thu Apr 17 23:43:16 GMT 2014 (Edgar D1.06 X1.3; Annotator Comm v1.1.3.19; Annotator FPGA v2.2.2.3)

% Read first two lines.  
[pname, fname, ext] = fileparts(infile);
ann.pname = [pname,filesep];
ann.fname = [fname, ext];
%%
fid = fopen(infile,'r');
header = fgetl(fid);
row_labels = fgetl(fid);
spc.row_labels = textscan(row_labels,'%s','delimiter',',');
spc.row_labels = spc.row_labels{:};
% Scan Number,Direction,Scene,Scene Angle (°),Size,ZPD,Year,Day,Time of Day,Detector A,
% Filter A,Gain A,P-P A,Min A Loc,Max A Loc,DC Level A,Detector B,Filter B,Gain B,P-P B,Min B Loc,Max B Loc,Detector C,
% Filter C,Gain C,P-P C,Min C Loc,Max C Loc,Cooler Software revision,Cooler Set Point,Cooler Diode Voltage,Cooler Ready Window,
%Cooler Voltage AC,Cooler Voltage DC,Cooler AC Output Freq.,Cooler Ambient Temp,Cooler Current DC,Cooler Pwr Up Cycles,
% Cooler Remote Status,Cooler Output Voltage,Hatch Open,Hatch Closed,Hatch Mode,Hatch Rain Out,Hatch Rain Aux,Hatch Sun,
% Hot BB Set Point,Hot BB Mean,Hot BB Thermistor 1,Hot BB Thermistor 2,Hot BB Thermistor 3,Cold BB Set Point,Cold BB Mean,
% Cold BB Thermistor 1,Cold BB Thermistor 2,Cold BB Thermistor 3,GPS UTC of Position,GPS Latitude,GPS Longitude,GPS Altitude,
% GPS Fix Quality,GPS NB Satellites,GPS Precision

% 74094,Forward,Up,0.0,32768,16378,2014,107,23:43:20.236756,MCT MB,0,8,7316,16384,16377,-1.9822998,InSb,0,16,4794,16381,16377,
% MCT/DC,0,1,18,16381,16374,9501 836 03503,1052.0,1051.99,4,7.38,24.86,50.0,30.6,0.97,312,true,9.5,True,False,Automatic,Clear,
% Light,0.00,60.0,60.0,60.234,60.202,59.946,35.0,12.27,12.276,12.274,12.268,12:01:31,N61.843983,E24.28745,154.5M,DGPS Fix,07,1.6m
f_str = '%f %s %s %f %f %f %f %f %s %s %f %f %f %f %f %f %s %f %f %f %f %f';
f_str = [f_str, ' %s %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %s %f %s %s %s %s'];
f_str = [f_str, ' %s %f %f %f %f %f %f %f %f %f %f %f %s %s %s %fM %s %f %f %*[^\n]'];

% 2422,Forward,Up,0.0,32768,16382,2015,154,18:12:21.178055,MCT MB,0,8,1415,
% 16388,16381,4142.8037,InSb,0,16,1367,16377,16381,9501 836 03503,1052.0,
% 1052.01,4,7.71,24.79,50.0,36.6,1.05,354,true,9.5,60.0,59.998,60.174,60.174,
% 59.954,25.0,28.402,28.406,28.406,28.402,18:12:21,N36.60515,W97.48572,N/A,Invalid,00,m
f_str = '%f %s %s %f %f %f %f %f %s %s %f %f %f ' ; %13
f_str = [f_str, '%f %f %f %s %f %f %f %f %f %s %f ']; % +11 = 24
f_str = [f_str, '%f %f %f %f %f %f %f %f %s %f %f %f ']; % +14 = 38;
f_str = [f_str, '%f %f %f %f %f %f %f %f %s %s %s %s %s %f %s %*[^\n]']; %13

in_str = char(fread(fid,'char')); 
fclose(fid);
C = textscan(in_str, f_str, 'delimiter',',');

for n = length(spc.row_labels):-1:1
    blah = C{n};
    lab = legalize(spc.row_labels{n});
    ann.(lab) = blah;
    if any(isnumeric(blah))
        
        
    end
end
dnum = datenum(ann.Year,1,1);
dstr = datestr(dnum+ann.Day,'yyyy-mm-dd');
for L = length(ann.TimeofDay):-1:1
    tod(L) = {[dstr(L,:),' ', ann.TimeofDay{L}]};
    switch ann.Scene{L}
        case {'Up'}
        Scene(L) = 0;
    end
    if ~isempty(ann.GPSLatitude)
    Lat_S(L) = strcmp(ann.GPSLatitude{L}(1),'S');
    Lat(L) = sscanf(ann.GPSLatitude{L}(2:end),'%f');
    Lon_W(L) = strcmp(ann.GPSLongitude{L}(1),'W');
    Lon(L) = sscanf(ann.GPSLongitude{L}(2:end),'%f');
    else
    Lat_S(L) = NaN;
    Lat(L) = NaN;
    Lon_W(L) = NaN;
    Lon(L) = NaN;
    end
end
Lat = (1-2.*double(Lat_S)).*Lat; ann.GPSLatitude = Lat';
Lon = (1-2.*double(Lon_W)).*Lon; ann.GPSLongitude = Lon';

Direction = {strcmp(ann.Direction, 'Reverse')}; ann.Direction = Direction{:};
%     'HatchSun'
%     'HatchRainAux'
%     'HatchRainOut'
%     'HatchMode'
%     'HatchClosed'
%     'HatchOpen'
%     'CoolerOutputVoltage'
%     'CoolerRemoteStatus'
%     'CoolerPwrUpCycles'
%     'CoolerCurrentDC'
%     'CoolerAmbientTemp'
%     'CoolerACOutputFreq'
%     'CoolerVoltageDC'
%     'CoolerVoltageAC'
%     'CoolerReadyWindow'
%     'CoolerDiodeVoltage'
%     'CoolerSetPoint'
%     'CoolerSoftwarerevision'
%     'MaxCLoc'
%     'MinCLoc'
%     'PPC'
%     'GainC'
%     'FilterC'
%     'DetectorC'
%     'MaxBLoc'
%     'MinBLoc'
%     'PPB'
%     'GainB'
%     'FilterB'
%     'DetectorB'
%     'DCLevelA'
%     'MaxALoc'
%     'MinALoc'
%     'PPA'
%     'GainA'
%     'FilterA'
%     'DetectorA'
%     'TimeofDay'
%     'Day'
%     'Year'
%     'ZPD'
%     'Size'
%     'SceneAngle'
%     'Scene'

ann.time = datenum(tod,'yyyy-mm-dd HH:MM:SS.FFF');
  
return

function lab = legalize(lab)
lab = strrep(lab,' ','');
lab = strrep(lab,'-','');
lab = strrep(lab,'.','');
lab = strrep(lab,'(°)','');
return