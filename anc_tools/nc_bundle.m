function [nc, nc_] = nc_bundle()
% [nc, nc_] = nc_bundle(nc_dir, part)
%  
in_files = getfile('sgpsws*.cdf','sws');
N = length(in_files);
files.time = [];
for n = N:-1:1
    files.fullnames(n) = in_files.name(N-n+1);
    nc_ = ancloadcoords(files.fullnames(n));
    nc_filenum = n.*ones(size(nc_.time));
    tmp = [files.time, nc_.time];
    [files.time,ii] = unique(tmp);
    tmp = [files.nc_filenum, nc_filenum];
    file.nc_filenum = tmp(ii);
end

% Okay, so now we should have a structure of monotonic times and the
% related data files


nc1 = ancloadcoords;
nc2 = ancloadcoords;

% For all selected files, load anccoords, concat the time variable over the
% entire collection. Then 




