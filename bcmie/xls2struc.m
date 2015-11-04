% xls2struc(filename, 'sheetname', 'wantcols') reads an Excel file and 
%   turns it into a Matlab structure with fields named after the 
%   headings directly above the data. Other headings are ignored.
% Required arguments:
%   filename     name of Excel file (no extension needed)
% Optional arguments:
%   sheetname    worksheet name; default first
%   wantcols     array of columns desired; default all
%   emptycols    want empty columns? default true
% ~tcb

function datstruc=xls2struc(fname, varargin);
% Author: Tami Bond, University of Illinois, yark@uiuc.edu
%    November 2005; updated Jan 2008
% This program is distributed under the Creative Commons by-sa license 3.0
%   (http://creativecommons.org/licenses/by-sa/3.0/).
% Known problems: overwrites columns if two headers are the same 

global datamat txmat allmat
% Empty return value
datstruc = struct();

% check arguments
if ~varg_proof(varargin, {'sheetname', 'wantcols', 'emptycols'}, true)
    return
end

% Read Excel file
sheetname = varg_val(varargin, 'sheetname', '');
if length(sheetname)==0
    [datamat, txmat, allmat] =xlsread(fname);
else
    [datamat, txmat, allmat] =xlsread(fname, sheetname);
end
ncols = size(allmat, 2);

% Determine vertical offset for numeric values. This identifies the
% header lines. If there are no numeric values then there's no offset.
headerlines = size(allmat, 1) - size(datamat, 1);

% Check that headers are all text, and find first numeric column
notchar = [];
numercols = [];
for i=1:ncols
    if ~ischar(allmat{headerlines, i})
       notchar(length(notchar)+1) = i;
    end
    if isnumeric(allmat{headerlines+1,i})
       numercols(length(numercols)+1) = i;
    end
end

if ~isempty(notchar)
    if notchar>1
       disp(['Warning: header problem. Last column will be ' allmat{headerlines, notchar(1)-1}]);
       ncols = notchar(1)-1;
    else
       disp('No headers, exiting')
    end
end

% Pad numeric information if first columns are text. 
if ~isempty(numercols)
    datamat = [NaN(size(datamat, 1), numercols(1)-1) datamat];
end

% Cut down text matrix
if size(txmat, 1)>headerlines
   txmat = txmat((headerlines+1):(size(txmat, 1)), :);
else
   txmat = {};
end

% Get column numbers wanted
wantcols = varg_val(varargin, 'wantcols', 1:ncols);
emptycols = varg_val(varargin, 'emptycols', true);
isnumempty = sum(~isnan(datamat), 1)==0;
ischarempty = sum(strcmp(txmat, ''))==0;

% Put fields into structure
for i=1:length(wantcols)
    n = wantcols(i);

    % Fix name
    varname = fixtext(allmat(headerlines, n));
 
    % Numeric column
    if ~isempty(find(n==numercols)) & (emptycols | ~isnumempty(n))
       datstruc = setfield(datstruc, varname, datamat(:,n));
       
    % Text column
    elseif (emptycols | ~ischarempty(n))
        datstruc = setfield(datstruc, varname, txmat(:, n));

    end
end

return
