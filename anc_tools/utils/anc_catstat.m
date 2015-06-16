function nc = anc_catstat(filelist)
% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then
% loops over the user specified actions for each file.
if ~exist('filelist','var')||isempty(filelist)
disp('Please select one or more files to concatenate the static elements.');
[filelist] = getfullname('*.cdf;*.nc');
end

if ~iscell(filelist)&&exist(filelist,'file')
     nc = anc_stat2rec(filelist);
else
    i = 1;
    [pname, fname, ext] = fileparts(filelist{i});pname = [pname,filesep];
        disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
     nc = anc_stat2rec(filelist{i});
    for i = 2:length(filelist);
        [pname, fname, ext] = fileparts(filelist{i});
        disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
        %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
        [nc,nc_] = ancxcat(nc,anc_stat2rec(filelist{i}));
        if ~isempty(nc_)           
            stem = strtok(fname, '.');
            disp(['Saving ',stem,'.globals.',datestr(nc_.time(1),'yyyymmdd'),'_',datestr(nc_.time(end),'yyyymmdd'),'.mat'])
            save([pname, stem,'.globals.',datestr(nc_.time(1),'yyyymmdd'),'_to_',datestr(nc_.time(end),'yyyymmdd'),'.mat'],'-struct','nc_');
            % Need to save this portion
        end
        disp(['   Done processing ', fname,ext]);
        
    end;
    disp(' ')
    disp(['Finished processing selected files in ' pname])
    disp(' ')
end
stem = strtok(fname, '.');
disp(['Saving ',stem,'.globals.',datestr(nc.time(1),'yyyymmdd'),'_',datestr(nc.time(end),'yyyymmdd'),'.mat'])
save([pname, stem,'.globals.',datestr(nc.time(1),'yyyymmdd'),'_to_',datestr(nc.time(end),'yyyymmdd'),'.mat'],'-struct','nc');

return