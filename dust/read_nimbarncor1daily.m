function barn = read_nimbarncor1daily(filename);
% %This reads Jim Barnard's corrected aod files from Niamey and Banizoumbou.  Not fully tested...

if ~exist('filename', 'var')||~exist(filename,'file')
   [fid,fname, pname] = getfile('daily-average-aot.txt','barncor1');
   fclose(fid);
   filename = [pname, fname];
end
[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];

% (1) date, fractional year (UT, I  think, I will check) <= this is LST
% (2)  Julian day
% (3 –7 ) corrected AODs, 1-5 (415 to 870 nm)
% (8) Angstrom  (500/870)

fid = fopen(filename);
if fid>0
   format_str = '%f %f ';
   format_str = [format_str, '%f %f %f %f %f '];
   format_str = [format_str, '%f '];
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
barn.aod_415 = txt{3};
barn.aod_500 = txt{4};
barn.aod_615 = txt{5};
barn.aod_673 = txt{6};
barn.aod_870 = txt{7};
barn.ang = txt{8};

fields = fieldnames(barn);
for fl = length(fields):-1:1
   nans = barn.(fields{fl})<-0.9;
   barn.(fields{fl})(nans) = NaN;
end
barn.fname = fname;
figure; subplot(2,1,1); plot(barn.time - barn.time(1) + serial2doy(barn.time(1)), barn.aod_500,'.-b');
subplot(2,1,2); plot(barn.time - barn.time(1) + serial2doy(barn.time(1)), barn.ang,'.-r')
% [barn.aero(nonNaN),barn.eps(nonNaN)] = aod_screen(barn.time(nonNaN), barn.aod_500(nonNaN),0,3.5,[],[],5e-5);





   
