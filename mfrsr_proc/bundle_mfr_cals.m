function [nc_out, head_ids, logger_ids] = bundle_mfr_cals(filelist)

pause(.1);
if ~exist('filelist','var')||isempty(filelist)
disp('Please select one or more files having the same DOD.');
[filelist] = getfullname('*.cdf;*.nc');
end
if ~iscell(filelist)&&exist(filelist,'file')
   [pname, fname, ext] = fileparts(filelist);
    nc = anc_load(filelist);
    head_id = nc.ncdef.vars.time;
    head_id.long_name = 'Head ID';
    head_id.units = 'unitless';
    nc.ncdef.vars.head_id = head_id;
    nc.vdata.head_id = sscanf(nc.gatts.head_id) .* ones(size(nc.vdata.time));
    logger_id = nc.ncdef.vars.time;
    logger_id.long_name = 'Logger ID';
    logger_id.units = 'unitless';
    nc.ncdef.vars.logger_id = logger_id;
    nc.vdata.logger_id = sscanf(nc.gatts.logger_id) .* ones(size(nc.vdata.time));
else
    nc = anc_load(filelist{1});
    head_id = nc.ncdef.vars.time;
    head_id.long_name = 'Head ID';
    head_id.units = 'unitless';
    nc.ncdef.vars.head_id = head_id;
    nc.vdata.head_id = sscanf(nc.gatts.head_id,'%f') .* ones(size(nc.vdata.time));
    logger_id = nc.ncdef.vars.time;
    logger_id.long_name = 'Logger ID';
    logger_id.units = 'unitless';
    nc.ncdef.vars.logger_id = logger_id;
    nc.vdata.logger_id = sscanf(nc.gatts.logger_id,'%f') .* ones(size(nc.vdata.time));
    year = datevec(nc.time(1)); year = year(1);
    [pname, fname, ext] = fileparts(filelist{1});
    disp(['Processing ', fname, ext,' : ', num2str(1), ' of ', num2str(length(filelist))]);
    for i = 2:length(filelist);
        [pname, fname, ext] = fileparts(filelist{i});
        if mod(i,50)==1
           disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
        end
        %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
        nc_ = anc_load(filelist{i}); 
        nc_.ncdef.vars.head_id = head_id;
        nc_.vdata.head_id = sscanf(nc_.gatts.head_id,'%f') .* ones(size(nc_.vdata.time));
        nc_.ncdef.vars.logger_id = logger_id;
        nc_.vdata.logger_id = sscanf(nc_.gatts.logger_id,'%f') .* ones(size(nc_.vdata.time));
        year_ = datevec(nc_.time(1)); year_ = year_(1);
        if year~=year_
           disp(['Done processing ', num2str(year)]);        
           if ~exist('nc_out','var')
              nc_out = nc;
           else
              nc_out = anc_cat(nc_out, nc);
           end
           year = year_;
           nc = nc_;
        else
           nc = anc_cat(nc,nc_);
        end
        
    end;
    nc_out = anc_cat(nc_out, nc);
    disp(' ')
    disp(['Finished processing selected files in ' pname])
    disp(' ')
end

head_ids = unique(nc.vdata.head_id);
logger_ids = unique(nc.vdata.logger_id);

return