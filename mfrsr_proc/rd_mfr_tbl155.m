function mfr = rd_mfr_tbl155(infile)

if ~isavar('infile')||~isafile(infile)
   infile = getfullname('*_Table155.dat','mfr_tbl155','Select MFRSR CR1000X table155 file');
end

fid = fopen(infile,'r');
tmp = fgetl(fid);
header = fgetl(fid);
units = fgetl(fid);
tmp = fgetl(fid);

fmt = ['%s %d',repmat(' %f',[1,41])];
% here = ftell(fid);
A = textscan(fid,fmt,'delimiter',',','TreatAsEmpty',['"NAN"']);
fclose(fid);
labels = textscan(header,'%s','delimiter',','); labels = labels{:};
TS = A{1};A(1) = []; labels(1) = []
mfr.time = datenum(TS,'"yyyy-mm-dd HH:MM:SS"');

for L = 1:length(labels)
   lab = labels{L}; 
   lab = strrep(lab,'"',''); lab = strrep(lab,'(','');lab = strrep(lab,')','');
   mfr.(lab) = A{L};
end
datestr(mfr.time(end))l

for N = 7:-1:1
   ch = num2str(N);
   mfr.TH_raw(:,N) = mfr.(['Dnadir',ch]);
   mfr.Deast(:,N) = mfr.(['Deast',ch]);
   mfr.Dwest(:,N) = mfr.(['Dwest',ch]);
   mfr.Dsun(:,N) = mfr.(['Dsun',ch]);
end
mfr.dhor_raw = (mfr.Deast+mfr.Dwest)./2 - mfr.Dsun;
mfr.difh_raw = mfr.TH_raw - mfr.dhor_raw;


return