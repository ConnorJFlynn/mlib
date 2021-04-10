function make_daily_mplnc_nz

files = getfullname('*.nc','minimpl_lauder','Select UC miniMPL nc files to bundle into dailies.');

if ischar(files) && ~isempty(files) && isafile(files)
    files = {files};
end
[pname,fname_nc] = fileparts(files{1}); pname = strrep([pname, filesep],[filesep filesep],filesep);
if ~isempty(pname)&&isadir(pname)&&~isadir([pname,'daily'])
    mkdir([pname 'daily']);
end

nc = anc_load(files{1}); 
date = floor(nc.time(1));
[nc, nc_] = anc_sift(nc,nc.time<(date+1));

while ~isempty(nc_)&&nc_.ncdef.recdim.length>0
    [pname, fname, ext] = fileparts(nc.fname);
    pname = strrep([pname, filesep],[filesep filesep],filesep);
    ext = '.mat';
    save([pname, 'daily',filesep,fname, ext],'-struct','nc');
    date = floor(nc_.time(1));
    [nc, nc_] = anc_sift(nc_, nc_.time<date+1);
end
    
for f = 2:length(files)
     disp(files{f})
    try
        nc = anc_cat(nc, anc_load(files{f}));
    catch
        disp(['Problem with ',files{f}])
    end
    date = floor(nc.time(1));
    [nc, nc_] = anc_sift(nc,nc.time<(date+1));
    while ~isempty(nc_)&&nc_.ncdef.recdim.length>0
        [pname, fname, ext] = fileparts(nc.fname); 
        fname = datestr(nc.time(1),'yyyymmdd'); % make daily name
        pname = strrep([pname, filesep],[filesep filesep],filesep);
        ext = '.mat';
        save([pname, 'daily',filesep,fname, ext],'-struct','nc');
        date = floor(nc_.time(1));
        [nc, nc_] = anc_sift(nc_, nc_.time<date+1);
    end
end



return