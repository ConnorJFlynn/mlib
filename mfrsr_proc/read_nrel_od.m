function nrel = read_nrel_od(filename);
% This should read any of the MFRSR OD files from NREL but was written
% to read those from StormPeak for Ian McCubbin

if ~exist('filename', 'var')
   filename= getfullname('*.txt','nrel_od');
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
end
if ~exist('pname','var')
   [pname, fname, ext] = fileparts(filename);
end
fid = fopen(filename);
if fid>0
   nrel.fname = filename;
   nrel.pname = pname;

   
      tmp = fgetl(fid);
      fseek(fid,0,-1);
      pmt = fliplr(tmp);
      header_lines = sscanf(fliplr(strtok(pmt)),'%f');
      format_str = ['%s ']; % Site
      format_str = [format_str '%f %f %f %f %f %f %f ']; % UTC: yyyy mm dd HH MM SS doy 
      format_str = [format_str '%f %f %f %f %f %f %f ']; % LST: yyyy mm dd HH MM SS doy
      format_str = [format_str '%f %f ']; % SZA Airmass 
      format_str = [format_str '%f %f %f %f %f %f %f ']; % OD for filters 1-7
      txt = textscan(fid,format_str,'headerlines',header_lines,'delimiter',',','treatAsEmpty','N/A');
      fclose(fid);
      %The last record is bad #EOD, so delete it
      for t = length(txt):-1:1
         txt{t}(end) = [];
      end
      V = [txt{2},txt{3},txt{4},txt{5},txt{6},txt{7}];
      nrel.time = datenum(V);
      nrel.doy = txt{8};
      V = [txt{9},txt{10},txt{11},txt{12},txt{13},txt{14}];
      nrel.time_lst = datenum(V);
      nrel.doy_lst = txt{15};
      nrel.sza = txt{16};
      nrel.airmass = txt{17};
      
      for t = 18:24
         bad = txt{t}<0;
         txt{t}(bad) = NaN;
      end

      nrel.ODunf = txt{18};
      nrel.OD_415nm = txt{19};
      nrel.OD_500nm = txt{20};
      nrel.OD_610nm = txt{21};
      nrel.OD_665nm = txt{22};
      nrel.OD_860nm = txt{23};
      nrel.OD_940nm = txt{24};
      
      
            
   end

% Number of Lines in header: 16
% Site Code: site, (unitless), Location ID (State Abbrev plus numeric id)
% UTC Date-Time: UYYY,UM,UD,Uh,Um,Us, UYYY is year, UM is month, UD is day, Uh is hour, Um is minute, Us is seconds, 24-hour clock, UTC
% UTC Day of Year: UDy, (Days, UTC)
% Local Date-Time: LYYY,LM,LD,Lh,Lm,Ls, LYYY is year, LM is month, LD is day, Lh is hour, Lm is minute, Ls is seconds, 24-hour clock, Local Standard Time
% Local Day of year: LDy, (Days, Local Standard Time) 
% Zenith angle: Zen, (degrees)
% Air mass: Airmass, (unitless)
% Optical Depth Unfiltered: ODunf, (unitless), total
% Optical Depth 415 nm: OD415, (unitless), total
% Optical Depth 500 nm: OD500, (unitless), total
% Optical Depth 610 nm: OD610, (unitless), total
% Optical Depth 665 nm: OD665, (unitless), total
% Optical Depth 860 nm: OD860, (unitless), total
% Optical Depth 940 nm: OD940, (unitless), total
% Site,UYYY,UM,UD,Uh,Um,Us,   UDy   ,LYYY,LM,LD,Lh,Lm,Ls,   LDy   ,   Zen  ,  Airmass ,   ODunf ,   OD415 ,   OD500 ,   OD610 ,   OD665 ,   OD860 ,   OD940 
% CO11,2003,01,01,16,21,00,  1.68125,2003,01,01,09,21,00,  1.38958,   74.77,    3.7589,   -9.000,    1.527,    1.324,    1.337,   -9.000,    1.354,   -9.000


