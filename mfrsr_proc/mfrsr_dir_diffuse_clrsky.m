function clearsky =  mfrsr_dir_diffuse_clrsky(infile)
% Reading Jim Barnard's version of Chuck Long's clear sky file augmented
% with screened MFRSR data.  I'll check the direct/diffuse C1/E13 in these
% files and will also use these clear sky times as a filter on ARM
% MFRSR data.
if ~exist('infile,'var')
   infile = getfullname('*_clr_mfrsrdata.asc','asc','Select clear sky file.');
end
[pname, infile, ext] = fileparts(infile);
pname = [pname, filesep]; 
% pname = 'D:\case_studies\clong\clr_sky\from_JCB_with_formatting_errors\';

fid1 = fopen([pname, infile, ext]);
fid2 = fopen([pname, infile,'.cleaned', ext],'w');

header = fgetl(fid1);
fprintf(fid2, '%s \n',header);

while ~feof(fid1)
   this = fgetl(fid1);
   if isempty(strfind(this,'ff'))
%       fwrite(fid2,this,'char')
      fprintf(fid2, '%s \n',this);

   end
end
fclose(fid2);
fclose(fid1);

fid2 = fopen([pname, infile,'.cleaned', ext],'r');
header = fgetl(fid2);

header = textscan(header,'%s');
header = header{:};
A = textscan(fid2,['%f %f %f %f ',repmat('%f ',[1,23]),' %*[^\n] %*[\n]']);
fclose(fid2);
UT_date = floor(A{1});
UT_time = floor(A{2});
dd = rem(UT_date,100); UT_date = floor(UT_date./100);
mm = rem(UT_date,100); yyyy = floor(UT_date./100);
MM = rem(UT_time,100); HH = floor(UT_time./100);
V = [yyyy,mm,dd,HH,MM,zeros(length(MM),1)];
clearsky.time = datenum(V);
datestr(clearsky.time(1))

   for h = 5:length(header)
      clearsky.(header{h}) = A{h};
      
   end
      
   save([pname, 'clrsky_jcb.',datestr(clearsky.time(1),'yyyy'),'.mat'],'clearsky');
display(['Saved clrsky_jcb.',datestr(clearsky.time(1),'yyyy'),'.mat'])

return