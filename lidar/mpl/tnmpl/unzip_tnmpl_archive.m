function unzip_tnmpl_archive;
archive = ['F:\case_studies\tnmpl\archive_raw\'];
proc = ['F:\case_studies\tnmpl\mpl\processing\'];

zips = dir([archive, '*.zip']);
for z = 1:length(zips)
    disp(zips(z).name)
    if ~zips(z).isdir
        [pname, fname, ext] = fileparts(zips(z).name);
        day = fname(1:(end-3));
        if ~exist([proc,day],'dir')
            mkdir(proc,day);
        end
        unzip([archive,zips(z).name],[proc,day]);
    end
end
    