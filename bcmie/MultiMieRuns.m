% MultiMieRuns(inputfile)
% Runs multiple Mie runs from an Excel spreadsheet (for PC platforms only)
%   and writes the answers into another worksheet in the same file.
% Optional arguments: 
%   insheet (default 'Inputs')
%   outsheet (default 'Outputs')
%   nobackscat (default false)
% Input file *must* have labeled columns: run, lambda, cmd, gsd, 
%   ncore, kcore, fcoat, nshell, kshell in worksheet labeled Inputs
% Output file gives: run num, ext, scat, hembs, abs
% Example input file is SampleInputFile.xls
% Because this uses xlsread, it may not work with versions prior to Matlab 7.0

function MultiMieRuns(infile, varargin)

% Author: Tami Bond, University of Illinois, yark@uiuc.edu
% Version 2.3   Dec 2007
% This program is distributed under the Creative Commons by-sa license 3.0
%   (http://creativecommons.org/licenses/by-sa/3.0/).
%
% Required additional files:
%   Everything associated with SizeDist_Optics.m
%   xls2struc, fixtext, varg_val, varg_proof (utilities)

if ~varg_proof(varargin, {'insheet', 'outsheet', 'nobackscat'}, true)
    return
end

% Get arguments
insheet = varg_val(varargin, 'insheet', 'Inputs');
outsheet = varg_val(varargin, 'outsheet', 'Outputs');
nobackscat = varg_val(varargin, 'nobackscat', false);

% Read input data
indata = xls2struc(infile, 'sheetname', insheet);

Nruns = length(indata.run);
nwriteint = 50;             % Interval at which to write data
Nstart = 1;

% check if coating is in file 
if isfield(indata, 'fcoat')
    fcoat = indata.fcoat;
    mcoat = indata.nshell + 1i * indata.kshell;
else
    fcoat = zeros([1 Nruns]);
    mcoat = ones([1 Nruns]);
end
    
% Get columns
outdata = [];

if nobackscat
  outheads = {'run', 'extinction', 'scattering', 'absorption', ...
    'ssa', 'asym'};
  outidx = 1:5;

else
  outheads = {'run', 'extinction', 'scattering', 'absorption', ...
    'backscat', 'ssa', 'asym', 'forceff'};
  outidx = 1:7;
end

xlswrite(infile, outheads, outsheet, 'A1');

lumpdata = [];
lumpi = Nstart;

for i=Nstart:Nruns
    disp([num2str(i) ' of ' num2str(Nruns)]);
    MieAns = SizeDist_Optics(indata.ncore(i) + 1i*indata.kcore(i),...
        indata.cmd(i), indata.gsd(i), indata.lambda(i), 'nephscats', false,...
        'm_coating', mcoat(i), 'coating', fcoat(i), 'vectorout', true, ...
        'nobackscat', nobackscat);
    
    onedata = [indata.run(i) MieAns(outidx)];
    outdata = [outdata; onedata];
    lumpdata = [lumpdata; onedata];
    
    % Write out every nwriteint
    if mod(i, nwriteint)==0 | i==Nruns
       xlswrite(infile, lumpdata, outsheet, ['A' num2str(lumpi+1)]);
       lumpdata = [];
       lumpi = i+1;
    end
    
end

return
