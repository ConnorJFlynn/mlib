function barn = read_nimbarnod(filename);
%This reads Jim Barnard's aod files from Niamey and Banizoumbou.  Not fully tested...
if ~exist('filename', 'var')||~exist(filename,'file')
   [fid,fname, pname] = getfile('*.dat','barnod');
   fclose(fid);
   filename = [pname, fname];
end
[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];
%678990 %number of lines to read
%Hours(LST) Frac_day(LST) YEAR Mu0    AOT_415 AOT_500 AOT_615 AOT_673 AOT_870 AOT_940 Angstrom  PWV    Azimuth Long_cf Michalsky_cf

fid = fopen(filename);
if fid>0
   barn.nlines = fscanf(fid,'%f',1);
   dump = fgetl(fid);
   header = fgetl(fid);
   format_str = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';
   txt = textscan(fid,format_str,barn.nlines);
end
fclose(fid);
barn.time = datenum(2006,1,1)-1+floor(txt{2})+txt{1}./24 -1./24;
% txt{1} = round(txt{1}*1e4)/1e4;
% barn.time = datenum(txt{1},1,1);

barn.airmass = txt{4};
barn.aod_415 = txt{5};
barn.aod_500 = txt{6};
barn.aod_615 = txt{7};
barn.aod_673 = txt{8};
barn.aod_870 = txt{9};
barn.aod_940 = txt{10};
barn.ang = txt{11};
barn.pwv = txt{12};
barn.az = txt{13};
barn.cf_long = txt{14};
barn.cf_mich = txt{15};

fields = fieldnames(barn);
for fl = length(fields):-1:1
   nans = barn.(fields{fl})<-0.9;
   barn.(fields{fl})(nans) = NaN;
end
barn.fname = fname;
barn.header = header;
barn.aero = false(size(barn.time));
barn.eps = NaN(size(barn.time));
nonNaN = ~isNaN(barn.aod_500);
% [barn.aero(nonNaN),barn.eps(nonNaN)] = aod_screen(barn.time(nonNaN), barn.aod_500(nonNaN),0,3.5,[],[],5e-5);





   
