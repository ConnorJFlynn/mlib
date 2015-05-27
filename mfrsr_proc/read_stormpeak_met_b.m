function nrel = read_stormpeak_met_b(filename);
% Read Storm Peak met data from web page of such
% Used on met4 with addition of gust.
if ~exist('filename', 'var')
   filename= getfullname_('*.met','sp_met');
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
end

fid = fopen(filename);
if fid>0
   nrel.fname = filename;
   nrel.pname = pname;
   nrel.lon = -106.74445; % east longitude, negatives are west
   nrel.lat =  40.45515;
   
nrel.tz = floor(nrel.lon / 15);
   
% header:
% :       LST,Deg C,  %  , m/s , Deg , mm  ,mbar ,     ,Deg K,     , Ave 
% : Date/Time, Av Air,  Rel  ,  Wind , Wind  , Precip, Barom ,  Unk  ,  Pot. ,  Unk  ,Aerosol
% :YYMMDDhhmm,  Temp ,Humidty,  Speed, Direc ,       , Press ,  #1   , Temp. ,  #2   , #K/cm3
% 9801010000,-6.477,88.2,8.53,210.3,0,688.5,0,305.2,0,-9999

      header_lines = 3;
      format_str = ['%2n %2n %2n  %2n %2n ']; % YY MM DD hh mm (LST) 5
      format_str = [format_str '%n %n %n %n %*n %n ']; % Temp, RH, wspd, wdir, wgust,precip 5 
      format_str = [format_str '%n %*[^\n]']; % pres, skip rest
      txt = textscan(fid,format_str,'headerlines',header_lines,'delimiter',',');
      fclose(fid);

      %Dang!  Need to parse line-by-line since format changes. 
      % Check if LST is found
      for t = length(txt):-1:1
         txt{t}(end) = [];
      end
      year = txt{1} + 1900 + 100*(txt{1}<10);
      V = [year,txt{2},txt{3},txt{4},txt{5},zeros(size(txt{2}))];
      nrel.lst = datenum(V);
      nrel.time = nrel.lst - nrel.tz/24;
      nrel.temp = txt{6};
      nrel.RH = txt{7};
      nrel.wspd = txt{8};
      nrel.wdir = txt{9};
%       nrel.wgust = txt{10};
      nrel.precip = txt{10};
      nrel.pres = txt{11};
      
      NaNs = nrel.pres>703 | nrel.pres<0;
      nrel.pres(NaNs) = NaN;
end
return
