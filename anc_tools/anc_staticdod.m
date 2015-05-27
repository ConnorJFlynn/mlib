function out = anc_staticdod (in, ncfile)

% This is not yet migrated to new structure.
% out = anc_staticdod (in, ncfile)
%Strip time-varying data...
% Create netcdf file with only static info, recdim.length=0;
disp('Might want to re-implement this to use anclink and get data rather than ancload and delete data.')
status = 1;
if ~exist('in','var')
   in = ancload;
end
if ~isstruct(in)&&exist(in,'file')
   in = anc_load(in);
end
if ~exist('ncfile','var')
   ncfile = in.fname;
end
in.time = [];
in = timesync(in);
vars = fieldnames(in.vars);
for v = 1:length(vars)
   if any(strcmp('time',in.vars.(vars{v}).dims))
   disp(['Deleting data for ',vars{v}]);
      in.vars.(vars{v}).data = [];
   end
end

[pname,fname,ext] = fileparts(ncfile);
i = 0;
outfname = fullfile(pname,[fname,'.',num2str(i),ext]);
while exist(outfname,'file')
i = i+1;
outfname = fullfile(pname,[fname,'.',num2str(i),ext]);
end
status = ancsave(in,outfname);
out = in;
out.fname = outfname;
