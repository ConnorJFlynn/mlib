function nc = anc_bundle_files_to_daily(filelist)
% Loops over a collection of netcdf files (of same type) and produces
% daily files. Does not fill data gaps. 
if ~isavar('N')
    N = 24;
end
pause(.1);
if isempty(who('filelist'))||isempty(filelist)
[filelist] = getfullname('*.cdf;*.nc', 'nc_data','Please select one or more files of the same datastream');
end
if ~iscell(filelist)&&~isempty(dir(filelist))
    nc = anc_load(filelist);
else
    try 
       xticks([]);yticks([]);
    catch
    end
    pause(0.01);
    ii = 1;
    nc_ = anc_load(filelist{ii}); 
    [pname, ~, ~] = fileparts(filelist{1}); daily_dir = strrep([pname, filesep,'daily'],[filesep filesep], filesep); 
    if ~isadir(daily_dir)
        mkdir(daily_dir);
    end
    this_start = floor(nc_.time(1)); day_file = [datestr(nc_.time(1),'yyyymmdd'),'.mat'];
    while ii <= length(filelist)       
        while (nc_.time(end)<=this_start + 1) &&  ii < length(filelist)
            ii = ii + 1;
            nc_ = anc_cat(nc_, anc_load(filelist{ii}));
        end
        [nc, nc_] = anc_sift(nc_, nc_.time <= this_start +1);
        % 
        nc.fname = [daily_dir, filesep, day_file]; nc.clobber = true; 
        save(nc.fname,'-struct', 'nc');disp(['Saved ', day_file])
        this_start = floor(nc_.time(1)); day_file = [datestr(nc_.time(1),'yyyymmdd'),'.mat'];
    end
      
    disp(' ')
    disp(['Finished processing selected files in ' pname])
    disp(' ')
end
return