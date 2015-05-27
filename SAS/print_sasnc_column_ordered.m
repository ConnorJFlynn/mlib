function print_sasnc_column_ordered(sas, logi)

if exist('logi','var')
    if isfield(logi,'t_')
        t_ = logi.t_;
    end
    if isfield(logi,'w_')
        w_ = logi.w_;
    end
end
if ~exist('t_','var')
    t_ = true(size(sas.time));
end

if ~exist('w_','var')
    w_ = true(size(sas.vars.wavelength.data));
end

TopRow = ['Wavelength '];
Second = ['   [nm]    '];
t_ii = find(t_);
for tii = t_ii
    TopRow = [TopRow, datestr(sas.time(tii),', yyyy-mm-dd ')];
    Second = [Second, datestr(sas.time(tii),', HH:MM:SS   ')];    
end

A = [sas.vars.wavelength.data(w_), sas.vars.zenith_radiance.data(w_,t_)];
f_str = ['  %4.2f   ',repmat(',   %8g ',1, size(A,2)-1), '\n'] ;
[pname, fname] = fileparts(sas.fname);
pname = [pname, filesep];
fname = strtok(fname, '.');
outfile = [pname, fname, '.',datestr(sas.time(t_ii(1)),'yyyymmdd.HHMMSS'),'_to_',datestr(sas.time(t_ii(end)),'yyyymmdd.HHMMSS'),'.dat'];
fid = fopen(outfile,'w');
fprintf(fid,'%s \n', TopRow);
fprintf(fid,'%s \n', Second);
fprintf(fid,f_str, A');
fclose(fid);
return
