function [info var]=readHDF(filename,parameter,start,edges)
% Function readHDF
% Uses the low-level hdf (hdfsd) routines to read data from a hdf data file.
% Inputs:
% filename (string)  - The name of the file to read. The entire path should be supplied
%                      unless the file is in the current working directory.
% parameter(string ) - This is the name of the SDS that you want to read in.
%
% Optional inputs:
%
% start  (vector)    - This contains the staring index to begin reading for each
%                      dimension (e.g. [0 0] for the beginning of the file).
% edges (vector)     - The number of elements to read in for each dimension.
%
% Example:
% To read in the first 100 profiles of attenuated backscatter data from a L1b file
% do the following,
% >fname = '/Users/kuehn/Data/L1AtBkz01.11n070125-110650.hdf';
% >[info data] = readHDF(fname,'Total_Attenuated_Backscatter_532',[0 0],[100 583]);

info.stat = 0;
var = '';

if nargin ~= 2 & nargin ~=4,
    error('Either 2 or 4 inputs are required');
end

if  (~exist(filename,'file'))
    error('The file %s does not exist!',filename);
    return;
end

try
    sd_id = hdfsd('start',filename,'DFACC_RDONLY');
    [ndatasets, nglobal_atts, stat] = hdfsd('fileinfo',sd_id);
    if (stat ~=0),
        info.stat = stat;
        var = '';
        fprintf('Error: An error was encountered while trying to open the file for reading:\n%s\n',filename);
        hdfml('closeall');
        return;
    elseif ndatasets == 0,
	info.stat = -2;
        var = '';
        fprintf('Error: No data sets were found in the file:\n%s\n',filename);
        hdfml('closeall');
        return;
    end
catch
    hdfml('closeall');
    error('The file %s could not be opened.',filename);
end


try
    % Find the sds in the file
    iSDS = -1;
    iSDS = hdfsd('nametoindex',sd_id,parameter);
    if iSDS == -1,
	info.stat = -3;
        var = '';
        fprintf('The dataset(%s) in file could not be found:\n%s\n',parameter,filename);
	stat = hdfsd('end',sd_id);
	return;
    end
    sds_id = hdfsd('select',sd_id,iSDS);
    [ds_name, ds_ndims, ds_dims, ds_type, ds_atts, stat] = hdfsd('getinfo',sds_id);
    if (stat ~=0)
	info.stat = stat;
	var = '';
	fprintf('Error: An error was encountered while trying to getinfo from`the sds (%d)\n in the file %s.\n',sds_id,filename);
	hdfml('closeall');
	return;
    end

%    for i=1:ndatasets,
%        sds_id = hdfsd('select',sd_id,i);
%        [ds_name, ds_ndims, ds_dims, ds_type, ds_atts, stat] = hdfsd('getinfo',sds_id);
%        if (stat ~=0)
%            info.stat = stat;
%            var = '';
%            fprintf('Error: An error was encountered while trying to getinfo from`the sds (%d)\n in the file %s.\n',sds_id,filename);
%            hdfml('closeall');
%            return;
%        end
%        if strcmp(ds_name, parameter),
%            iSDS = i;
%            break;
%        end;
%        stat = hdfsd('endaccess',sds_id);
%    end
%    if iSDS == -1,
%	info.stat = -3;
%        var = '';
%        fprintf('The dataset(%s) in file could not be found:\n%s\n',parameter,filename);
%        hdfml('closeall');
%	return;
%    end
catch
    hdfml('closeall');
    error('An error was encountered while trying to read and select a dataset\nfrom file %s',filename);
end

% Determine the size of the SDS
nElements = max(ds_dims);

if nargin ==2,
    ds_start = zeros(1,ds_ndims); % Creates the vector [0 0]
    ds_stride = [];
    ds_edges = ds_dims;
elseif nargin == 4,
    if length(start) ~= ds_ndims,
        start
        ds_ndims
        error('The number of start indices are incorrect');
    end

    if length(edges) ~= ds_ndims,
        edges
        ds_ndims
        error('The number of end indices are incorrect');
    end

    for i=1:ds_ndims,
        if start(i) > ds_dims(i)
            fprintf('start(%d)=%d > %d\n',i,start(i),ds_dims(i))
            error('The start index exceeds the number of elements in the dimension. ');
        end
	% This is a special case that will read to the end of the file
	if (edges(i) == -9)
	    edges(i)  = ds_dims(i) - start(i);
	end
        if (start(i)+edges(i)) > ds_dims(i)
            fprintf('(start(%d) + edges(%d) )=%d > %d\n',i,i,start(i)+edges(i),ds_dims(i))
            error('The number of elements to read exceeds the number of elements in the dimension.');
        end
    end

    ds_start = start;
    ds_stride = [];
    ds_edges = edges;
else
    error('Wrong number of arguments');  % Should never happen
end

% Save the sds information
info.ds_name = ds_name;
info.ds_ndims = ds_ndims;
info.ds_dims = ds_dims;
info.ds_type = ds_type;
info.ds_attr = ds_atts;
info.ds_start = ds_start;
info.ds_edges = ds_edges;

% Read the data
[var, stat] = hdfsd('readdata',sds_id,ds_start,ds_stride,ds_edges);
if (stat ~=0)
    info.stat = stat;
    var = '';
    fprintf('Error: An error was encountered while trying to read from`the sds (%d)\n in the file %s.\n',sds_id,filename);
    hdfml('closeall');
    return;
end

% Reverse the data rows->columns, this now how hdfread would present it.
% This is only for backward compatibility witht the previous version of readHDF
if info.ds_ndims == 2,
    var = var';
end

% Close access to the file
stat = hdfsd('endaccess',sds_id);
stat = hdfsd('end',sd_id);
