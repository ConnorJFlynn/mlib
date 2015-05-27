function [qry_cell,out] = write_sbdart_input(in_args,in_path);
%w = write_sbdart_input(in_args,in_path);
% Writes out sbdart qry (in_args), runs SBDART, returns qry and output.

if ~exist('in_path','var')|~exist(in_path,'dir')
   in_path = getdir;
end

if ~iscell(in_args)
   fields = fieldnames(in_args);
   for ff = 1:length(fields)
      qry_cell(2*ff -1) = fields(ff);
      qry_cell(2*ff) = {in_args.(fields{ff})};
   end
else
   qry_cell = in_args;
end


fid = fopen([in_path, 'INPUT'],'wt');
y = (['&INPUT']);
fprintf(fid,'%s \n',y);

for ff = 1:2:length(qry_cell)
   fprintf(fid,'%s = ',upper(qry_cell{ff}));
   fprintf(fid, ' %g, ',qry_cell{ff+1});
   fprintf(fid,' \n');
end
y = (['/']);
fprintf(fid,'%s \n',y);


fclose(fid);
ret = pwd;
cd(in_path);
system('sbdart.exe > outs.dat')
% system(['bash -c /cygdrive/c/mlib/sbdart/sbdart_exe.exe > out.dat']);
cd(ret);
fout = [in_path, 'outs.dat'];
if exist(fout,'file')
   fid = fopen(fout);
   out = textscan(fid,'%f %f %f %f %f %f %f %f ', 'headerlines',3);
   fclose(fid);
   delete(fout);
end
%%
