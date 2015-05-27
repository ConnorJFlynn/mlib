function status = savedatever;
% Prompts for directory location of m-files
% For each m-file, creates duplicate with mod-date appended to filename

% 2007-04-17, CJF: Created to facilitate 4Star m-file archive
% 2007-04-18, CJF: Added option to create date-stamp of single file
% 2007-06-01, CJF: Modified to append ".ver" and renamed to savedatever
k = menu('Create date-stamped copy of:','single file','all files in directory');
if k==1
    [status, fname, pname] = getfile('*.m');
    if status>1
        mfile = dir([pname,fname]);
        arcfile = [mfile.name ,'.',datestr(datenum(mfile.date),'yyyy_mm_dd'),'.ver'];
        if (exist([pname,filesep,mfile.name]))&(~exist([pname,filesep,arcfile],'file'))
            fid_in = fopen([pname,filesep,mfile.name],'r');
            fid_out = fopen([pname,filesep,arcfile],'w');
            disp(['Archiving ',arcfile]);
            status = fwrite(fid_out,fread(fid_in));
            fclose(fid_in);
            fclose(fid_out);
        end
    else
        disp(['Could not locate ',pname, fname]);
    end
else
    pname = uigetdir;
    mfiles = dir([pname, filesep,'*.m']);
    for m = length(mfiles):-1:1
        arcfile = [mfiles(m).name ,'.',datestr(datenum(mfiles(m).date),'yyyy_mm_dd'),'.ver'];
%         if (exist([pname,filesep,mfiles(m).name]))&(exist([pname,filesep,arcfile],'file'))
        if (exist([pname,filesep,mfiles(m).name]))&(~exist([pname,filesep,arcfile],'file'))            
            fid_in = fopen([pname,filesep,mfiles(m).name],'r');
            fid_out = fopen([pname,filesep,arcfile],'w');
            disp(['Archiving ',arcfile]);
            status = fwrite(fid_out,fread(fid_in));
            fclose(fid_in);
            fclose(fid_out);
        end
    end
end
