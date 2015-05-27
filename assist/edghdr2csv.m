function edghdr2csv(edg,out_file);
% edghdr2csv(edg,out_file);
% Output main and subfile headers from edgar mat file to CSV file
if ~exist('edg','var')
   in_file = getfullname_('*.mat','edgar_mat','Select Edgar mat file');
   edg = loadinto(in_file);
   [pname, fname,ext] = fileparts(in_file);
   edg.pname = [pname,filesep];
   edg.fname = [fname, ext];
   out_file = [in_file,'.csv'];
end
if ~exist('out_file','var')
   in_file = getfullname_('*.mat','edgar_mat','Select Edgar mat file');
   out_file = [in_file,'.csv'];
end
fid = fopen([out_file],'w+');
c = onCleanup(@()fclose(fid));
%%
edgdate = edgar_date_struct(edg.mainHeaderBlock.date);
edg.mainHeaderBlock.memo = strrep(edg.mainHeaderBlock.memo,[char(13), char(10)],', ');
parts = fieldnames(edg.mainHeaderBlock);
head_str = 'mainHeaderBlock.';
for fld = 1:length(parts)
   part = char(parts(fld));
   if strcmp(part,'date')
      x = fprintf(fid,'%s \n',['"',head_str,part,' (yyyy-mm-dd HH:MM:SS)=',datestr(edgdate,'yyyy-mm-dd HH:MM:SS'),'"']);
   elseif ischar(edg.mainHeaderBlock.(part))
      x = fprintf(fid,'%s \n',['"',head_str,part,'=',edg.mainHeaderBlock.(part),'"']);
   else
      x = fprintf(fid,'%s',['"',head_str,part,'=']);
      x = fprintf(fid,'%g',[edg.mainHeaderBlock.(part)]);
      x = fprintf(fid,'%s \n',['"']);
   end
end
%%
subfileheader = edg.subfiles{1}.subfileHeader
fields = fieldnames(subfileheader);
for f = 1:length(fields)
   for N= size(edg.subfiles,2):-1:2
      subfileheader.(char(fields(f)))(N) = edg.subfiles{N}.subfileHeader.(char(fields(f)));
   end
      x = fprintf(fid,'%s',['"subfileheader.',char(fields(f)),'=[']);
      x = fprintf(fid,'%g,',subfileheader.(char(fields(f))));
      x = fprintf(fid,'%s \n',[']"']);
 
end
   for N= size(edg.subfiles,2):-1:1
      subfiledata(N,:) = edg.subfiles{N}.subfileData;
   end
%%
% X =[edg.mainHeaderBlock.firstX:edg.mainHeaderBlock.lastX];
% for x= 1:length(X)
%    fprintf(fid,'%i, %7.12g, %7.12g \n',[X(x); subfiledata(:,x)]);
% end   
fclose(fid);
%%
return

function datenm = edgar_date_struct(in_date);
V = double([in_date.year, in_date.month, in_date.day, in_date.hours, in_date.minutes, in_date.seconds]);
datenm = datenum(V);