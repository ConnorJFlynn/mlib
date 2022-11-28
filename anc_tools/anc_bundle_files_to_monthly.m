function nc = anc_bundle_files_to_monthly(filelist)
% Loops over a collection of netcdf files (of same type) and produces
% monthly files. Does not fill data gaps. 

pause(.1);
if ~isavar('filelist')||isempty(filelist)
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
    [pname, ~, ~] = fileparts(filelist{1}); monthly_dir = strrep([pname, filesep,'monthly'],[filesep filesep], filesep); 
    if ~isadir(monthly_dir)
        mkdir(monthly_dir);
    end
    V = datevec(nc_.time(1)); this_month = V(2);
    day_file = [datestr(nc_.time(1),'yyyymmdd'),'.mat'];
    while ii <= length(filelist)   
       V = datevec(nc_.time(end)); end_month = V(2);
       while (end_month==this_month) &&  ii < length(filelist)
            ii = ii + 1;
            nc_ = anc_cat(nc_, anc_load(filelist{ii}));
            V = datevec(nc_.time(end)); end_month = V(2);
        end
        V = datevec(nc_.time);
        [nc, nc_] = anc_sift(nc_, V(:,2) == this_month );
        % 
        nc.fname = [monthly_dir, filesep, day_file]; nc.clobber = true; 
        save(nc.fname,'-struct', 'nc');disp(['Saved ', day_file])
        if isempty(nc_.time)
           V = datevec(nc.time(end)); 
           V(2) = V(2) + 1;  V(3) = 1;
           this_month = V(2);
           day_file = [datestr(datenum(V),'yyyymmdd'),'.mat'];
        else
           V = datevec(nc_.time(1)); this_month = V(2);
        day_file = [datestr(nc_.time(1),'yyyymmdd'),'.mat'];
        end
    end
      
    disp(' ')
    disp(['Finished processing selected files in ' pname])
    disp(' ')
end
return