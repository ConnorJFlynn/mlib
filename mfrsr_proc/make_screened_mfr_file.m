function nc = make_screened_mfr_file 
%status = make_screened_mfr_file 
%%
[pname] = uigetdir(['D:\case_studies\new_xmfrx_proc'],'Select directory containing mfr aod files');
pname = [pname, '/'];
file_list = dir([pname, '*.nc']);
if (size(file_list,1) > 0)
for f = 1:size(file_list,1)
   disp(['Processing file ',num2str(f), ' of ', num2str(size(file_list,1)), ' : ',file_list(f).name]);
   mfr = ancload([pname, file_list(f).name]);
   lose = find(~isnan(mfr.vars.aod_cloud_screened500nm.data));
   [nc1,nc2] = ancsift(mfr, mfr.dims.time, lose);
   if length(nc1.time)>0
      nc1 = anccheck(nc1);
      nc1.clobber = true;
      nc1.quiet = true;
      status = ancsave(nc1);
      if ~exist('nc', 'var')
         nc = nc1;
      else
         nc = anccat(nc, nc1);
      end
   end
end
fname = strtok(file_list(1).name, '.');
fname = [fname, '.cloud-screened.',datestr(nc.time(1),'YYYYmmDD_'),datestr(nc.time(end),'YYYYmmDD'),'.nc'];
nc.fname = [pname, '..\',fname];
nc.clobber = true;
disp(['Saving file as: ',nc.fname]);
status = ancsave(nc);
else
disp('No files found?')
   status = -1;
end

%%



