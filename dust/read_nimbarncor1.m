function barn = read_nimbarncor1(filename);
% %This reads Jim Barnard's corrected aod files from Niamey and Banizoumbou.  Not fully tested...

if ~exist('filename', 'var')||~exist(filename,'file')
   [fid,fname, pname] = getfile('niamey_corrected_aod.txt','barncor1');
   fclose(fid);
   filename = [pname, fname];
end
[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];
% (1) date, fractional year (UT, I think, I will check)
% (2) fractional julian day (LST)
% (3) fractional julian day (UT)
% (4) CSZA
% (5-9) AOD, 415 through 870 nm
% (10) Angstrom (500/870)
% (11 – 14) Correction factors, 415 through 870.

fid = fopen(filename);
if fid>0
   format_str = '%f %f %f %f ';
   format_str = [format_str, '%f %f %f %f %f '];
   format_str = [format_str, '%f '];
   format_str = [format_str, '%f %f %f %f %f '];   
   txt = textscan(fid,format_str);
end
fclose(fid);
year = floor(txt{1});
tmp = txt{1}; % This is in year + fraction of year in LST
tmp2 = [tmp ,zeros(size(tmp)),ones(size(tmp)),-1*ones(size(tmp)),zeros(size(tmp)),zeros(size(tmp))];
% This adjusts for doy =1 and UTC = LST - 1; 
barn.time = datenum(tmp2);
clear tmp tmp2
% doy = mod(txt{1},1)*365;
barn.doy_lst = txt{2};
barn.doy_utc = txt{3};
barn.csza = txt{4};
barn.aod_415 = txt{5};
barn.aod_500 = txt{6};
barn.aod_615 = txt{7};
barn.aod_673 = txt{8};
barn.aod_870 = txt{9};
barn.ang = txt{10};
barn.cor_415 = txt{11};
barn.cor_500 = txt{12};
barn.cor_615 = txt{13};
barn.cor_673 = txt{14};
barn.cor_870 = txt{15};

fields = fieldnames(barn);
for fl = length(fields):-1:1
   nans = barn.(fields{fl})<-0.9;
   barn.(fields{fl})(nans) = NaN;
end
barn.fname = fname;

% [barn.aero(nonNaN),barn.eps(nonNaN)] = aod_screen(barn.time(nonNaN), barn.aod_500(nonNaN),0,3.5,[],[],5e-5);





   
